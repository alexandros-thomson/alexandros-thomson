-- 🔮 Crown Treasury Synthetic Alert Testing Data (adjusted for RLS / FK safety)
-- NOTE: canonical_user_id set to NULL to avoid FK violations; run in staging.
-- Run this file AFTER supabase/migrations/20250927_add_revenue_columns.sql

-- 🏛️ Create Baseline Revenue History (30 days, every 2 hours)
WITH revenue_baseline AS (
  SELECT 
    gs AS occurred_at,
    CASE
      WHEN EXTRACT(dow FROM gs) IN (0, 6) THEN (random() * 50 + 25)::numeric(10,2)
      ELSE (random() * 30 + 15)::numeric(10,2)
    END AS amount,
    CASE (random() * 4)::int
      WHEN 0 THEN 'patreon'
      WHEN 1 THEN 'youtube'
      WHEN 2 THEN 'consulting'
      ELSE 'direct'
    END AS platform,
    CASE (random() * 3)::int
      WHEN 0 THEN 'subscription_payment'
      WHEN 1 THEN 'one_time_payment'
      ELSE 'consulting_payment'
    END AS event_type,
    'success'::text AS status,
    'USD'::text AS currency,
    json_build_object('synthetic', true, 'test_phase', 'baseline')::jsonb AS metadata
  FROM generate_series(
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '1 hour',
    INTERVAL '2 hours'
  ) AS gs
)
INSERT INTO public.revenue_events (
  occurred_at, amount, platform, event_type, status, currency, canonical_user_id, metadata
)
SELECT 
  occurred_at, amount, platform, event_type, status, currency, NULL::uuid, metadata
FROM revenue_baseline;


-- 📈 Insert Recent Success Pattern (establishes recent baseline)
INSERT INTO public.revenue_events (
  occurred_at, amount, platform, event_type, status, currency, canonical_user_id, metadata
)
SELECT
  NOW() - (interval '1 hour' * generate_series(1, 24)) AS occurred_at,
  (25 + random() * 15)::numeric(10,2) AS amount,
  'patreon' AS platform,
  'subscription_payment' AS event_type,
  'success' AS status,
  'USD' AS currency,
  NULL::uuid AS canonical_user_id,
  '{"synthetic": true, "test_phase": "recent_success"}'::jsonb AS metadata
FROM generate_series(1, 24);


-- 🔥 Create Alert-Triggering Scenarios
-- Scenario 1: Payment Failure Spike (10 rapid failed events)
INSERT INTO public.revenue_events (
  occurred_at, amount, platform, event_type, status, currency, canonical_user_id, metadata
)
SELECT
  NOW() - (interval '10 seconds' * generate_series(1, 10)) AS occurred_at,
  (20 + random() * 10)::numeric(10,2) AS amount,
  'stripe' AS platform,
  'subscription_payment' AS event_type,
  'failed' AS status,
  'USD' AS currency,
  NULL::uuid AS canonical_user_id,
  json_build_object(
    'synthetic', true, 
    'test_scenario', 'payment_failure_spike',
    'error_code', 'card_declined'
  )::jsonb AS metadata
FROM generate_series(1, 10);


-- Scenario 2: Revenue Drop (low-value events within the last hour)
INSERT INTO public.revenue_events (
  occurred_at, amount, platform, event_type, status, currency, canonical_user_id, metadata
)
SELECT
  NOW() - (interval '5 minutes' * generate_series(1, 12)) AS occurred_at,
  (1 + random() * 2)::numeric(10,2) AS amount,
  'patreon' AS platform,
  'subscription_payment' AS event_type,
  'success' AS status,
  'USD' AS currency,
  NULL::uuid AS canonical_user_id,
  json_build_object('synthetic', true, 'test_scenario', 'revenue_drop_simulation')::jsonb AS metadata
FROM generate_series(1, 12);


-- 🔍 Verification Queries (run after insert to confirm data)
-- 1) Recent revenue distribution (last 2 hours)
SELECT 
  status,
  COUNT(*) as event_count,
  SUM(amount) as total_amount,
  AVG(amount) as avg_amount,
  MIN(occurred_at) as earliest,
  MAX(occurred_at) as latest
FROM public.revenue_events 
WHERE occurred_at >= NOW() - INTERVAL '2 hours'
GROUP BY status
ORDER BY status;

-- 2) Failure rate in the last 10 minutes
SELECT 
  (
    COUNT(*) FILTER (WHERE status = 'failed')::float 
    / 
    NULLIF(COUNT(*)::float,0)
  ) * 100 as failure_rate_percent,
  COUNT(*) FILTER (WHERE status = 'failed') as failed_count,
  COUNT(*) as total_count
FROM public.revenue_events 
WHERE occurred_at >= NOW() - INTERVAL '10 minutes';

-- 3) Current vs same time yesterday rate comparison (events count)
WITH current_rate AS (
  SELECT COUNT(*) as current_events
  FROM public.revenue_events 
  WHERE occurred_at >= NOW() - INTERVAL '1 hour' 
    AND status = 'success'
),historical_rate AS (
  SELECT COUNT(*) as historical_events
  FROM public.revenue_events 
  WHERE occurred_at >= NOW() - INTERVAL '25 hours'
    AND occurred_at < NOW() - INTERVAL '24 hours'
    AND status = 'success'
)
SELECT 
  c.current_events,
  h.historical_events,
  CASE 
    WHEN h.historical_events > 0 THEN
      (c.current_events::float / h.historical_events::float)
    ELSE NULL
  END as rate_ratio,
  CASE 
    WHEN h.historical_events > 0 AND 
         (c.current_events::float / h.historical_events::float) < 0.5 
    THEN 'SHOULD TRIGGER REVENUE DROP ALERT'
    ELSE 'Rate normal'
  END as alert_prediction
FROM current_rate c, historical_rate h;


-- 🧹 Cleanup Command (run to remove synthetic test data)
-- DELETE FROM public.revenue_events WHERE metadata->> 'synthetic' = 'true';
-- REFRESH MATERIALIZED VIEW private.member_current_state;

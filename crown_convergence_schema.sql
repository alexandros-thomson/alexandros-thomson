-- Crown Treasury Convergence Schema - Corrected for RLS
CREATE SCHEMA IF NOT EXISTS private;

CREATE TABLE public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username text,
    created_at timestamptz DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.webhook_audit_log (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    source text NOT NULL,
    event_type text NOT NULL,
    payload jsonb NOT NULL,
    canonical_user_id uuid REFERENCES public.profiles(id),
    received_at timestamptz DEFAULT now()
);
ALTER TABLE public.webhook_audit_log ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.revenue_events (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    canonical_user_id uuid REFERENCES public.profiles(id),
    platform text NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency text DEFAULT 'USD',
    occurred_at timestamptz DEFAULT now()
);
ALTER TABLE public.revenue_events ENABLE ROW LEVEL SECURITY;

-- Indexes for performance
CREATE INDEX idx_webhook_audit_time ON public.webhook_audit_log (received_at DESC);
CREATE INDEX idx_revenue_events_time ON public.revenue_events (occurred_at DESC);

-- Materialized view in private schema (bypasses RLS)
CREATE MATERIALIZED VIEW private.member_current_state AS
SELECT
    wal.canonical_user_id,
    max((payload->>'tier')::text) FILTER (WHERE source='patreon') AS patreon_tier,
    max((payload->>'role')::text) FILTER (WHERE source='discord') AS discord_role,
    count(*) FILTER (WHERE source='discord' AND received_at > now() - interval '7 days') AS discord_activity_7d,
    (count(DISTINCT source) * 10.0) AS cross_platform_activity_score
FROM public.webhook_audit_log wal
WHERE received_at > now() - interval '30 days'
GROUP BY wal.canonical_user_id;

-- RLS Policies
CREATE POLICY "profiles: self select" ON public.profiles FOR SELECT TO authenticated USING ((SELECT auth.uid()) = id);
CREATE POLICY "webhook_audit: service insert" ON public.webhook_audit_log FOR INSERT TO authenticated WITH CHECK ((auth.jwt() ->> 'role') = 'service');
CREATE POLICY "revenue_events: owner select" ON public.revenue_events FOR SELECT TO authenticated USING ((SELECT auth.uid()) = canonical_user_id);

-- RPC for clean inserts
CREATE OR REPLACE FUNCTION public.ingest_convergence_event(
    p_source text,
    p_event_type text,
    p_payload jsonb
) RETURNS json
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    audit_id bigint;
BEGIN
    INSERT INTO public.webhook_audit_log (source, event_type, payload)
    VALUES (p_source, p_event_type, p_payload)
    RETURNING id INTO audit_id;
    
    REFRESH MATERIALIZED VIEW private.member_current_state;
    
    RETURN json_build_object('status', 'success', 'audit_id', audit_id);
END;
$$;

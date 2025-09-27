-- Migration: add status, event_type, and metadata to revenue_events (idempotent)
ALTER TABLE public.revenue_events
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'success',
  ADD COLUMN IF NOT EXISTS event_type text,
  ADD COLUMN IF NOT EXISTS metadata jsonb;

-- Optional: ensure occurred_at index exists for performance on time-range queries
CREATE INDEX IF NOT EXISTS idx_revenue_events_occurred_at
  ON public.revenue_events (occurred_at DESC);

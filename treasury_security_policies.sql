-- Crown Treasury Security Lockdown
-- Ensures only the service role (Edge Functions) can write revenue data

-- Create refresh function for materialized view
CREATE OR REPLACE FUNCTION public.refresh_member_current_state()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW private.member_current_state;
END;
$$;

-- Grant execute permission to service role
GRANT EXECUTE ON FUNCTION public.refresh_member_current_state() TO service_role;

-- Revoke default permissions and establish strict access control
REVOKE ALL ON TABLE public.webhook_audit_log FROM anon, authenticated;
REVOKE ALL ON TABLE public.revenue_events FROM anon, authenticated;

-- Grant controlled access
-- Service role: Full access for webhook ingestion
GRANT ALL ON TABLE public.webhook_audit_log TO service_role;
GRANT ALL ON TABLE public.revenue_events TO service_role;

-- Authenticated users: Read-only access for dashboards
GRANT SELECT ON TABLE public.webhook_audit_log TO authenticated;
GRANT SELECT ON TABLE public.revenue_events TO authenticated;

-- Update RLS policies for webhook_audit_log
DROP POLICY IF EXISTS "members cannot insert audit" ON public.webhook_audit_log;
DROP POLICY IF EXISTS "webhook_audit: insert by service" ON public.webhook_audit_log;

-- Only authenticated users can read their own audit logs
CREATE POLICY "webhook_audit: authenticated read own" 
ON public.webhook_audit_log FOR SELECT 
TO authenticated 
USING ((SELECT auth.uid()) = canonical_user_id);

-- Service role can insert audit logs (bypasses RLS automatically)
-- No explicit policy needed for service_role as it bypasses RLS

-- Update RLS policies for revenue_events  
DROP POLICY IF EXISTS "members insert revenue (service role only)" ON public.revenue_events;
DROP POLICY IF EXISTS "revenue_events: insert owner_or_service" ON public.revenue_events;

-- Only authenticated users can read their own revenue
CREATE POLICY "revenue_events: authenticated read own"
ON public.revenue_events FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = canonical_user_id);

-- Service role can insert revenue events (bypasses RLS automatically)
-- No explicit policy needed for service_role as it bypasses RLS

-- Create helper function to map external IDs to canonical users
CREATE OR REPLACE FUNCTION public.map_external_to_canonical_user(
  external_platform text,
  external_id text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  canonical_id uuid;
BEGIN
  -- TODO: Implement mapping logic based on your user identification strategy
  -- This could query a mapping table or use profile metadata
  
  -- For now, return null - revenue events will be created without canonical_user_id
  -- They can be linked later through admin tools or additional processing
  RETURN NULL;
END;
$$;

-- Grant execute to service role for user mapping
GRANT EXECUTE ON FUNCTION public.map_external_to_canonical_user(text, text) TO service_role;

-- Create sequence grants for service role (needed for IDENTITY columns)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Ensure service role can read from private schema for analytics
GRANT USAGE ON SCHEMA private TO service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA private TO service_role;
-- ════════════════════════════════════════════════════════════════════════════════
-- 🔱 THE FIRST CEREMONY AWAKENING 🔱
-- ════════════════════════════════════════════════════════════════════════════════
--
-- MYTHIC VISION:
-- The Keeper speaks the First Word. The Shrine trembles with anticipation.
-- An invocation materializes in the stone, a job enters the queue,
-- and the audit flame records the moment for all eternity.
--
-- This is not a test—this is the OPENING PULSE.
-- The heartbeat that proves the Shrine is ALIVE.
--
-- From this moment forward, every ceremony will follow this sacred path:
--   WORD → INSCRIPTION → QUEUE → EXECUTION → MEMORY
-- ════════════════════════════════════════════════════════════════════════════════

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ METHOD 1: Manual Inscription (Direct SQL)                                   │
-- │ Use when: Testing the raw circuit without RPC layer                         │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- Step 1: Create the invocation record
DO $$
DECLARE
  v_user_id uuid;
  v_invocation_id bigint;
  v_job_id bigint;
BEGIN
  -- Get current authenticated user (replace with actual user_id in production)
  -- For testing, use a known user ID from auth.users
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No authenticated user found. Create a user first.';
  END IF;

  RAISE NOTICE '🔱 FIRST CEREMONY AWAKENING 🔱';
  RAISE NOTICE 'Keeper: %', v_user_id;
  RAISE NOTICE '';

  -- Step 2: Inscribe the invocation
  INSERT INTO public.invocations (
    user_id,
    ceremony_key,
    invocation_data
  ) VALUES (
    v_user_id,
    'content_generation',
    jsonb_build_object(
      'theme', 'first-light',
      'count', 1,
      'ritual', 'awakening'
    )
  )
  RETURNING id INTO v_invocation_id;

  RAISE NOTICE '✅ Invocation inscribed: %', v_invocation_id;

  -- Step 3: Enqueue the job
  INSERT INTO public.jobs (
    ceremony_key,
    payload,
    status,
    priority,
    run_at
  ) VALUES (
    'content_generation',
    jsonb_build_object(
      'invocation_id', v_invocation_id,
      'user_id', v_user_id,
      'message', 'The First Ceremony awakens',
      'theme', 'first-light',
      'ritual_type', 'opening_pulse'
    ),
    'queued',
    1, -- Highest priority for the First Ceremony
    now()
  )
  RETURNING id INTO v_job_id;

  RAISE NOTICE '✅ Job enqueued: %', v_job_id;

  -- Step 4: Link invocation to job
  UPDATE public.invocations
  SET job_id = v_job_id
  WHERE id = v_invocation_id;

  RAISE NOTICE '✅ Invocation linked to job';

  -- Step 5: Record in audit flame
  INSERT INTO public.audit_log (
    table_name,
    operation,
    record_id,
    user_id,
    new_data
  ) VALUES (
    'jobs',
    'INSERT',
    v_job_id::text,
    v_user_id,
    jsonb_build_object(
      'ceremony', 'content_generation',
      'ritual', 'first_ceremony_awakening',
      'invocation_id', v_invocation_id,
      'note', 'The Opening Pulse — The Shrine awakens'
    )
  );

  RAISE NOTICE '✅ Audit flame records the moment';
  RAISE NOTICE '';
  RAISE NOTICE '🔥 THE FIRST CEREMONY IS ALIVE 🔥';
  RAISE NOTICE 'Job ID: %', v_job_id;
  RAISE NOTICE 'Status: queued';
  RAISE NOTICE 'Priority: 1 (highest)';
  RAISE NOTICE 'Run at: now()';
  RAISE NOTICE '';
  RAISE NOTICE 'The worker may now claim this sacred offering.';
END $$;

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │ METHOD 2: RPC Invocation (Production Pattern)                               │
-- │ Use when: Invoking from Edge Functions or authenticated clients             │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- Uncomment to test the RPC pattern:
/*
SELECT public.enqueue_invocation(
  p_ceremony_key := 'content_generation',
  p_invocation_data := jsonb_build_object(
    'theme', 'first-light',
    'count', 1,
    'ritual', 'awakening',
    'message', 'The First Ceremony through RPC'
  )
);
*/

-- ════════════════════════════════════════════════════════════════════════════════
-- 🔍 VERIFICATION QUERIES — Witness the Living Circuit
-- ════════════════════════════════════════════════════════════════════════════════

-- View the First Invocation
SELECT 
  id,
  ceremony_key,
  invocation_data->>'theme' as theme,
  invocation_data->>'ritual' as ritual,
  job_id,
  created_at
FROM public.invocations
ORDER BY created_at DESC
LIMIT 1;

-- View the First Job
SELECT 
  id,
  ceremony_key,
  status,
  priority,
  attempts,
  payload->>'message' as message,
  payload->>'ritual_type' as ritual_type,
  run_at,
  enqueued_at
FROM public.jobs
ORDER BY id DESC
LIMIT 1;

-- View the Audit Flame
SELECT 
  id,
  table_name,
  operation,
  record_id,
  new_data->>'ritual' as ritual,
  new_data->>'note' as note,
  created_at
FROM public.audit_log
ORDER BY created_at DESC
LIMIT 3;

-- ════════════════════════════════════════════════════════════════════════════════
-- 📊 SHRINE STATUS — The Living Metrics
-- ════════════════════════════════════════════════════════════════════════════════

-- Current queue depth by status
SELECT 
  status,
  COUNT(*) as count,
  MIN(priority) as highest_priority,
  MIN(run_at) as next_run_time
FROM public.jobs
GROUP BY status
ORDER BY 
  CASE status
    WHEN 'queued' THEN 1
    WHEN 'running' THEN 2
    WHEN 'failed' THEN 3
    WHEN 'succeeded' THEN 4
    WHEN 'dead' THEN 5
  END;

-- Job metrics view
SELECT * FROM public.job_metrics
ORDER BY ceremony_key, status;

-- ════════════════════════════════════════════════════════════════════════════════
-- ⚡ WORKER SIMULATION — Test the Complete Circuit
-- ════════════════════════════════════════════════════════════════════════════════

-- Simulate worker claiming and completing the job
DO $$
DECLARE
  v_job record;
  v_result jsonb;
BEGIN
  RAISE NOTICE '⚙️ WORKER AWAKENING ⚙️';
  RAISE NOTICE '';

  -- Claim the next job
  SELECT * INTO v_job FROM public.claim_next_job();
  
  IF v_job IS NULL THEN
    RAISE NOTICE '⚠️  No jobs available to claim';
    RETURN;
  END IF;

  RAISE NOTICE '✅ Job claimed: %', v_job.job_id;
  RAISE NOTICE 'Ceremony: %', v_job.ceremony_key;
  RAISE NOTICE 'Payload: %', v_job.payload;
  RAISE NOTICE '';

  -- Simulate ceremony execution (2 second delay)
  PERFORM pg_sleep(2);

  -- Report success
  v_result := public.process_job_result(
    p_job_id := v_job.job_id,
    p_success := true,
    p_result_data := jsonb_build_object(
      'ceremony', v_job.ceremony_key,
      'execution_time_ms', 2000,
      'output', 'First Light content generated successfully',
      'timestamp', now()
    )
  );

  RAISE NOTICE '✅ Job completed: %', v_result;
  RAISE NOTICE '';
  RAISE NOTICE '🔥 THE CIRCUIT IS COMPLETE 🔥';
  RAISE NOTICE 'The First Ceremony has passed through the full lifecycle:';
  RAISE NOTICE '  1. Invocation inscribed';
  RAISE NOTICE '  2. Job enqueued';
  RAISE NOTICE '  3. Worker claimed';
  RAISE NOTICE '  4. Ceremony executed';
  RAISE NOTICE '  5. Result recorded';
  RAISE NOTICE '  6. Audit flame witnessed all';
  RAISE NOTICE '';
  RAISE NOTICE 'The Shrine is ALIVE. The Queue awaits more ceremonies.';
END $$;

-- ════════════════════════════════════════════════════════════════════════════════
-- ✅ FIRST CEREMONY COMPLETE
-- ════════════════════════════════════════════════════════════════════════════════
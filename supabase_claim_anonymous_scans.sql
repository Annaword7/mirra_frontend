-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor → New query)
-- This function allows a newly authenticated user to "claim" scans that were
-- created during an anonymous session, adding them to the authenticated account.

CREATE OR REPLACE FUNCTION public.claim_anonymous_scans(anon_uid uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER          -- runs as postgres, bypasses RLS for this operation
SET search_path = public
AS $$
BEGIN
  -- Only proceed if the caller is actually authenticated and is not the anon user
  IF auth.uid() IS NULL OR auth.uid() = anon_uid THEN
    RETURN;
  END IF;

  -- Reassign ownership of all scans from the anonymous session to the
  -- authenticated user. Existing scans of the authenticated user are untouched
  -- (this is an ADD, not a replace).
  UPDATE images
  SET "user" = auth.uid()
  WHERE "user" = anon_uid;
END;
$$;

-- Revoke public execute, grant only to authenticated users
REVOKE EXECUTE ON FUNCTION public.claim_anonymous_scans(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.claim_anonymous_scans(uuid) TO authenticated;

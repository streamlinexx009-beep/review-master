-- ReviewMaster practice question RPC volatility correction
-- Date: 2026-06-22
-- Purpose:
--   get_practice_questions_safe uses random() for question order, so mark it
--   volatile instead of stable.

begin;

alter function public.get_practice_questions_safe(uuid, integer) volatile;

commit;

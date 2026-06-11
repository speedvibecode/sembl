# Executor Prompt - wo-fastapitempl-1781181564-in-the-dashboard-resetting-a-password-is

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix the password reset form validation to correctly compare the two password fields and allow submission when they match. Original request: in the dashboard, resetting a password is broken - i open the reset password page, type the same password in both fields and it always errors with 'The passwords do not match' even though they are literally identical. so nobody can ever complete a password reset. signup/login still work fine. please fix the reset password flow.. User-visible outcome: Users can successfully reset their password by entering the same password in both fields without receiving a false 'passwords do not match' error. Non-goals: Modify signup or login flows; Change password hashing or backend validation; Alter UI styling or layout of the reset page; Add new features to the reset flow. You MAY only edit these paths: frontend/biome.json; backend/app/initial_data.py; backend/app/backend_pre_start.py; frontend/src/routes/_layout/index.tsx; frontend/src/routes/reset-password.tsx; frontend/src/hooks/useAuth.ts; frontend/src/routes/login.tsx; backend/app/api/routes/login.py. You must NOT touch: backend/app; frontend/package.json; frontend/biome.json; frontend/src/routes/_layout/auth. Inspect these files before changing code: frontend/src/routes/reset-password.tsx; frontend/src/hooks/useAuth.ts; frontend/src/routes/login.tsx; backend/app/api/routes/login.py; frontend/src/client/core/types.ts; frontend/src/client/core/OpenAPI.ts; frontend/modify-openapi-operationids.js; frontend/src/routes/recover-password.tsx; backend/app/tests/api/routes/test_login.py; frontend/src/components/UserSettings/ChangePassword.tsx; backend/app/crud.py; backend/app/main.py. Inspect these tests before changing code: backend/app/tests_pre_start.py; backend/app/tests/api/routes/test_login.py; backend/app/tests/conftest.py; backend/app/tests/utils/item.py; backend/app/tests/utils/user.py; backend/app/tests/utils/utils.py; backend/app/tests/crud/test_user.py; backend/app/tests/api/routes/test_items.py. Acceptance criteria: Password reset form accepts matching passwords in both fields without error; Password reset form still rejects non-matching passwords with 'passwords do not match' error; Form submits successfully to backend when passwords match and meet other requirements; No console errors during password reset flow; Existing signup/login flows remain unaffected. Stop and ask the human if: Cannot locate the password reset form component after inspecting likely files; Password comparison logic is in backend (would require backend changes); Form validation involves complex state management not visible in frontend code; Any modification would require changes to backend auth endpoints. Patch expectations: Minimal changes to password comparison logic in frontend form validation; No changes to backend files; No changes to config files (package.json, biome.json); Added or updated tests for password matching validation; No changes to unrelated auth flows. Report your work using this format: {'summary': 'Brief description of the fix', 'files_changed': ['list of modified files'], 'changes_made': ['description of each change'], 'tests_added': ['list of new/updated tests'], 'test_results': 'output of validation commands', 'manual_verification': 'steps taken to verify the fix', 'risks_identified': ['any potential risks not mitigated']}

---

## Scope enforcement

**You MAY only edit these paths:**
- `frontend/biome.json`
- `backend/app/initial_data.py`
- `backend/app/backend_pre_start.py`
- `frontend/src/routes/_layout/index.tsx`
- `frontend/src/routes/reset-password.tsx`
- `frontend/src/hooks/useAuth.ts`
- `frontend/src/routes/login.tsx`
- `backend/app/api/routes/login.py`

**You must NOT touch:**
- `backend/app`
- `frontend/package.json`
- `frontend/biome.json`
- `frontend/src/routes/_layout/auth`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- Cannot locate the password reset form component after inspecting likely files
- Password comparison logic is in backend (would require backend changes)
- Form validation involves complex state management not visible in frontend code
- Any modification would require changes to backend auth endpoints

## Patch expectations

- Minimal changes to password comparison logic in frontend form validation
- No changes to backend files
- No changes to config files (package.json, biome.json)
- Added or updated tests for password matching validation
- No changes to unrelated auth flows
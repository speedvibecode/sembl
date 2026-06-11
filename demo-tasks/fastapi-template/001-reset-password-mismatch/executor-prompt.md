# Executor Prompt - wo-fastapitempl-1781196074-in-the-dashboard-resetting-a-password-is

_Paste this directly into Claude Code, Aider, Cursor, or any other AI coding agent._
_Do not modify the scope, forbidden areas, or stop conditions._

---

Your task is to Fix the frontend password reset form validation logic to correctly compare the two password fields and allow submission when they match. Original request: in the dashboard, resetting a password is broken - i open the reset password page, type the same password in both fields and it always errors with 'The passwords do not match' even though they are literally identical. so nobody can ever complete a password reset. signup/login still work fine. please fix the reset password flow.. User-visible outcome: Users can successfully reset their password by entering the same password in both fields without receiving a false 'passwords do not match' error. Non-goals: Modify signup or login flows; Change backend password reset API logic; Update password hashing or security policies; Alter UI styling or layout of the reset page. You MAY only edit these paths: frontend/src/components/Admin/AddUser.tsx; frontend/src/components/Admin/EditUser.tsx; frontend/src/routes/reset-password.tsx; frontend/src/utils.ts; frontend/src/routes/login.tsx; backend/app/api/routes/login.py; frontend/src/client/core/OpenAPI.ts; backend/app/initial_data.py; backend/app/tests_pre_start.py. You must NOT touch: frontend/src/api/; frontend/src/lib/auth.ts; frontend/biome.json; frontend/package.json. Inspect these files before changing code: frontend/src/routes/reset-password.tsx; frontend/src/hooks/useAuth.ts; frontend/src/routes/login.tsx; backend/app/api/routes/login.py; frontend/src/client/core/types.ts; frontend/src/client/core/OpenAPI.ts; frontend/modify-openapi-operationids.js; frontend/src/routes/recover-password.tsx; backend/app/tests/api/routes/test_login.py; frontend/src/components/UserSettings/ChangePassword.tsx; backend/app/crud.py; backend/app/main.py. Inspect these tests before changing code: backend/app/tests_pre_start.py; backend/app/tests/api/routes/test_login.py; backend/app/tests/conftest.py; backend/app/tests/utils/item.py; backend/app/tests/utils/user.py; backend/app/tests/utils/utils.py; backend/app/tests/crud/test_user.py; backend/app/tests/api/routes/test_items.py. Acceptance criteria: Password reset form accepts submission when both password fields contain identical values; Password reset form still rejects submission when password fields differ; All other validation rules (length, complexity) remain enforced; No console errors or unhandled exceptions during form interaction; Existing tests for password reset (if any) continue to pass. Stop and ask the human if: Cannot locate the password reset form component after inspecting likely_affected_areas; Password validation logic is shared with signup/login flows (risk of regression); Backend API changes are required to fix the issue; The bug is in a third-party library (e.g., React Hook Form) rather than custom code; If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.. Patch expectations: Minimal diff touching only the password comparison logic in the reset password form; No changes to backend or API client code; Preservation of all other validation rules; New or updated tests for the password reset form. Validate with: curl -s http://localhost:8000/docs | grep -i 'reset.*password' | head -5. Report your work using this format: JSON with keys: { files_modified: [], root_cause: '', acceptance_criteria_met: boolean, tests_added: [], manual_verification_notes: '' }

---

## Scope enforcement

**You MAY only edit these paths:**
- `frontend/src/components/Admin/AddUser.tsx`
- `frontend/src/components/Admin/EditUser.tsx`
- `frontend/src/routes/reset-password.tsx`
- `frontend/src/utils.ts`
- `frontend/src/routes/login.tsx`
- `backend/app/api/routes/login.py`
- `frontend/src/client/core/OpenAPI.ts`
- `backend/app/initial_data.py`
- `backend/app/tests_pre_start.py`

**You must NOT touch:**
- `frontend/src/api/`
- `frontend/src/lib/auth.ts`
- `frontend/biome.json`
- `frontend/package.json`

## Stop conditions

Stop immediately and ask the human if any of these occur:

- Cannot locate the password reset form component after inspecting likely_affected_areas
- Password validation logic is shared with signup/login flows (risk of regression)
- Backend API changes are required to fix the issue
- The bug is in a third-party library (e.g., React Hook Form) rather than custom code
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

## Patch expectations

- Minimal diff touching only the password comparison logic in the reset password form
- No changes to backend or API client code
- Preservation of all other validation rules
- New or updated tests for the password reset form
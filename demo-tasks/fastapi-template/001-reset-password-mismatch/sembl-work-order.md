# Work Order - wo-fastapitempl-1781196074-in-the-dashboard-resetting-a-password-is

**Repo:** `fastapi-template` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T16:41:14.905002+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> in the dashboard, resetting a password is broken - i open the reset password page, type the same password in both fields and it always errors with 'The passwords do not match' even though they are literally identical. so nobody can ever complete a password reset. signup/login still work fine. please fix the reset password flow.

**Clarified goal:** Fix the frontend password reset form validation logic to correctly compare the two password fields and allow submission when they match

**User-visible outcome:** Users can successfully reset their password by entering the same password in both fields without receiving a false 'passwords do not match' error

## 2. Boundary Lock

**Non-goals:**

- Modify signup or login flows
- Change backend password reset API logic
- Update password hashing or security policies
- Alter UI styling or layout of the reset page

**Must not change:**

- Existing signup/login functionality
- Backend API contracts for password reset
- Password validation rules (length, complexity, etc.)
- Error messages for other validation cases

**Forbidden areas (agent must not touch):**

- frontend/src/api/
- frontend/src/lib/auth.ts
- frontend/biome.json
- frontend/package.json

## 3. Scope Lock

**Likely affected areas:**

- .github/workflows
- .copier
- frontend
- backend/app
- frontend/src
- backend/app/api
- backend/app/core
- backend/app/tests
- frontend/src/hooks
- backend/app/alembic

**Editable paths (agent MAY modify):**

- frontend/src/components/Admin/AddUser.tsx
- frontend/src/components/Admin/EditUser.tsx
- frontend/src/routes/reset-password.tsx
- frontend/src/utils.ts
- frontend/src/routes/login.tsx
- backend/app/api/routes/login.py
- frontend/src/client/core/OpenAPI.ts
- backend/app/initial_data.py
- backend/app/tests_pre_start.py

**Read-only context (inspect, do not modify):**

- backend/app/core/security.py
- README.md
- frontend/src/client/core/types.ts

## 4. Context Lock

**Files to inspect before starting:**

- frontend/src/routes/reset-password.tsx
- frontend/src/hooks/useAuth.ts
- frontend/src/routes/login.tsx
- backend/app/api/routes/login.py
- frontend/src/client/core/types.ts
- frontend/src/client/core/OpenAPI.ts
- frontend/modify-openapi-operationids.js
- frontend/src/routes/recover-password.tsx
- backend/app/tests/api/routes/test_login.py
- frontend/src/components/UserSettings/ChangePassword.tsx
- backend/app/crud.py
- backend/app/main.py

**Tests to inspect:**

- backend/app/tests_pre_start.py
- backend/app/tests/api/routes/test_login.py
- backend/app/tests/conftest.py
- backend/app/tests/utils/item.py
- backend/app/tests/utils/user.py
- backend/app/tests/utils/utils.py
- backend/app/tests/crud/test_user.py
- backend/app/tests/api/routes/test_items.py

**Architecture notes:**

- Frontend uses React + TypeScript + Chakra UI
- Password reset is likely a frontend-only validation issue
- Backend API for password reset should remain untouched
- Form validation may use React Hook Form or custom hooks

## 5. Success Lock

**Acceptance criteria:**

1. Password reset form accepts submission when both password fields contain identical values
2. Password reset form still rejects submission when password fields differ
3. All other validation rules (length, complexity) remain enforced
4. No console errors or unhandled exceptions during form interaction
5. Existing tests for password reset (if any) continue to pass

**Regressions to preserve:**

- Signup flow continues to work
- Login flow continues to work
- Password reset API endpoint remains unchanged
- Other form validations (e.g., required fields) still work

## 6. Proof Lock

**Validation commands:**

- `curl -s http://localhost:8000/docs | grep -i 'reset.*password' | head -5`

**Tests to add or update:**

- frontend/src/components/__tests__/ResetPasswordForm.test.tsx
- frontend/src/hooks/__tests__/useResetPassword.test.ts

**Manual checks:**

1. Open password reset page in browser, enter matching passwords, verify submission succeeds
2. Enter non-matching passwords, verify error message appears
3. Test edge cases: empty fields, whitespace-only passwords, very long passwords

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Frontend-only bug but affects critical user flow (password reset)
- Potential for hidden coupling with other auth forms (signup/login)
- Graph data is thin-no direct nodes for reset password logic, increasing risk of undetected dependencies

**Stop conditions (agent must halt and ask human):**

- Cannot locate the password reset form component after inspecting likely_affected_areas
- Password validation logic is shared with signup/login flows (risk of regression)
- Backend API changes are required to fix the issue
- The bug is in a third-party library (e.g., React Hook Form) rather than custom code
- If the correct fix requires editing a file outside editable_paths, stop and report which file and why instead of proceeding or expanding scope.

**Approval triggers (blocks merge):**

- Changes touch shared authentication state management
- Modifications required in backend password reset endpoint
- Test failures in existing password-related tests after the fix

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal diff touching only the password comparison logic in the reset password form
- No changes to backend or API client code
- Preservation of all other validation rules
- New or updated tests for the password reset form

**Reporting format:** JSON with keys: { files_modified: [], root_cause: '', acceptance_criteria_met: boolean, tests_added: [], manual_verification_notes: '' }

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**

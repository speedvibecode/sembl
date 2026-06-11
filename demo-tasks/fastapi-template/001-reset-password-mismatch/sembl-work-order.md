# Work Order - wo-fastapitempl-1781181564-in-the-dashboard-resetting-a-password-is

**Repo:** `fastapi-template` | **Branch:** `pinned-base` | **Risk:** `MEDIUM`
**Created:** 2026-06-11T12:39:24.525578+00:00
**Task type:** `bugfix`

---

## 1. Intent Lock

**Original request:**
> in the dashboard, resetting a password is broken - i open the reset password page, type the same password in both fields and it always errors with 'The passwords do not match' even though they are literally identical. so nobody can ever complete a password reset. signup/login still work fine. please fix the reset password flow.

**Clarified goal:** Fix the password reset form validation to correctly compare the two password fields and allow submission when they match

**User-visible outcome:** Users can successfully reset their password by entering the same password in both fields without receiving a false 'passwords do not match' error

## 2. Boundary Lock

**Non-goals:**

- Modify signup or login flows
- Change password hashing or backend validation
- Alter UI styling or layout of the reset page
- Add new features to the reset flow

**Must not change:**

- Existing signup/login functionality
- Password hashing or security logic
- Backend API contracts for auth
- Chakra UI component behavior outside this form

**Forbidden areas (agent must not touch):**

- backend/app
- frontend/package.json
- frontend/biome.json
- frontend/src/routes/_layout/auth

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

- frontend/biome.json
- backend/app/initial_data.py
- backend/app/backend_pre_start.py
- frontend/src/routes/_layout/index.tsx
- frontend/src/routes/reset-password.tsx
- frontend/src/hooks/useAuth.ts
- frontend/src/routes/login.tsx
- backend/app/api/routes/login.py

**Read-only context (inspect, do not modify):**

- frontend/package.json
- frontend/biome.json
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
- Password reset is likely a client-side form with validation before API submission
- Backend auth endpoints are in backend/app/api/api_v1/endpoints/auth.py
- Shared validation logic may exist in frontend/src/utils

## 5. Success Lock

**Acceptance criteria:**

1. Password reset form accepts matching passwords in both fields without error
2. Password reset form still rejects non-matching passwords with 'passwords do not match' error
3. Form submits successfully to backend when passwords match and meet other requirements
4. No console errors during password reset flow
5. Existing signup/login flows remain unaffected

**Regressions to preserve:**

- Signup flow continues to work
- Login flow continues to work
- Password hashing remains unchanged
- Backend auth endpoints remain unchanged

## 6. Proof Lock

**Validation commands:** _none identified_

**Tests to add or update:**

- frontend/src/tests/PasswordResetForm.test.tsx (add test for matching passwords)
- frontend/src/tests/validation.test.ts (add test for password comparison logic)

**Manual checks:**

1. Manually test password reset flow in browser with matching passwords
2. Verify non-matching passwords still show error
3. Check browser console for errors during reset flow

## 7. Safety Lock

**Risk level:** `MEDIUM`

**Risk reasons:**

- Affects user-facing auth flow (critical path)
- Potential for breaking other forms if shared validation is modified
- Unknown location of password comparison logic (could be in multiple places)
- No graph visibility into password reset implementation details

**Stop conditions (agent must halt and ask human):**

- Cannot locate the password reset form component after inspecting likely files
- Password comparison logic is in backend (would require backend changes)
- Form validation involves complex state management not visible in frontend code
- Any modification would require changes to backend auth endpoints

**Approval triggers (blocks merge):**

- Changes touch shared validation utilities used by other forms
- Modifications affect auth-related state management
- Any backend API changes are needed

## 8. Executor Packet

_See `executor-prompt.md` for the agent-ready prompt._

**Patch expectations:**

- Minimal changes to password comparison logic in frontend form validation
- No changes to backend files
- No changes to config files (package.json, biome.json)
- Added or updated tests for password matching validation
- No changes to unrelated auth flows

**Reporting format:** {'summary': 'Brief description of the fix', 'files_changed': ['list of modified files'], 'changes_made': ['description of each change'], 'tests_added': ['list of new/updated tests'], 'test_results': 'output of validation commands', 'manual_verification': 'steps taken to verify the fix', 'risks_identified': ['any potential risks not mitigated']}

---

## Reconciliation _(fill after execution)_

- **Status:** pending
- **Files changed:**
- **Validation results:**
- **Human decision:**
- **Notes:**

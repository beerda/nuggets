# Branch Protection Quick Setup Checklist

## Quick Steps

1. **Go to**: Repository Settings → Branches → Add branch protection rule
2. **Branch pattern**: `main`
3. **Check these boxes**:

### Must Have ✅
- [ ] Require a pull request before merging
  - [ ] Require 1 approval
  - [ ] Dismiss stale reviews on push
- [ ] Require status checks to pass before merging
  - [ ] Require branches to be up to date
  - [ ] Select: `macos-latest (release)`
  - [ ] Select: `windows-latest (release)`
  - [ ] Select: `ubuntu-latest (devel)`
  - [ ] Select: `ubuntu-latest (release)`
  - [ ] Select: `test-coverage`
- [ ] Require conversation resolution before merging
- [ ] Do not allow force pushes
- [ ] Do not allow deletions

### Nice to Have (Optional) ⭐
- [ ] Require linear history
- [ ] Do not allow bypassing the above settings

4. **Click**: "Create" or "Save changes"

## Verify Setup

After setup, test by attempting to:
- Push directly to main (should fail)
- Merge a PR without approval (should fail)
- Merge a PR with failing checks (should fail)

See [BRANCH_PROTECTION.md](./BRANCH_PROTECTION.md) for detailed explanations.

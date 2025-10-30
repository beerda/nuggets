# Branch Protection Setup Guide

This document provides instructions for setting up branch protection rules for the `main` branch of the nuggets repository.

## Why Branch Protection?

Branch protection rules help maintain code quality and stability by:
- Preventing accidental force pushes that could rewrite history
- Preventing accidental deletion of important branches
- Ensuring all changes go through pull requests with proper review
- Requiring status checks to pass before merging
- Maintaining a clean and reliable git history

## Recommended Branch Protection Settings

### Step-by-Step Setup Instructions

1. **Navigate to Branch Protection Settings**
   - Go to your repository on GitHub: https://github.com/beerda/nuggets
   - Click on "Settings" (requires admin access)
   - In the left sidebar, click "Branches"
   - Under "Branch protection rules", click "Add rule" or "Add branch protection rule"

2. **Configure Branch Name Pattern**
   - In the "Branch name pattern" field, enter: `main`
   - This will apply the rules specifically to the main branch

3. **Enable Required Settings**

   #### Essential Protection Rules (Highly Recommended):
   
   - **☑ Require a pull request before merging**
     - This ensures all changes go through code review
     - Sub-options:
       - **☑ Require approvals**: Set to at least **1** approval
       - **☑ Dismiss stale pull request approvals when new commits are pushed**: Ensures re-review after changes
       - **☐ Require review from Code Owners**: Enable if you have a CODEOWNERS file (optional)
   
   - **☑ Require status checks to pass before merging**
     - This ensures CI/CD tests pass before merging
     - After enabling, search for and select these status checks:
       - **R-CMD-check** (multiple variants based on OS/R version):
         - `macos-latest (release)`
         - `windows-latest (release)`
         - `ubuntu-latest (devel)`
         - `ubuntu-latest (release)`
       - **test-coverage**
     - **☑ Require branches to be up to date before merging**: Ensures merge commits are tested with latest main
   
   - **☑ Require conversation resolution before merging**
     - Ensures all review comments are addressed
   
   - **☑ Do not allow bypassing the above settings**
     - Applies rules even to administrators
     - Alternative: Leave unchecked if you need emergency bypass capability

   #### Additional Protection Rules (Recommended):
   
   - **☑ Require linear history**
     - Prevents merge commits, enforcing rebase or squash merges
     - Keeps history clean and easier to navigate
     - Choose this if you prefer a linear git history
   
   - **☑ Require deployments to succeed before merging**
     - Enable if you have deployment workflows (not applicable for R packages typically)
   
   - **☑ Lock branch**
     - Makes the branch read-only (use only if you want to archive/freeze the branch)
     - **Not recommended for active development branch**
   
   - **☑ Do not allow force pushes**
     - **HIGHLY RECOMMENDED**: Prevents rewriting history on main branch
     - Protects against accidental data loss
   
   - **☑ Allow force pushes** (with restrictions)
     - Only if you need administrators to occasionally force push
     - Better to keep this disabled for safety
   
   - **☑ Do not allow deletions**
     - **HIGHLY RECOMMENDED**: Prevents accidental deletion of main branch
     - Critical for preserving repository history

4. **Save the Rules**
   - Scroll to the bottom and click "Create" or "Save changes"

## Recommended Configuration Summary

For the nuggets R package repository, we recommend this configuration:

```
Branch name pattern: main

✅ Require a pull request before merging
  ✅ Require approvals: 1
  ✅ Dismiss stale pull request approvals when new commits are pushed
  
✅ Require status checks to pass before merging
  ✅ Require branches to be up to date before merging
  Status checks:
    - macos-latest (release)
    - windows-latest (release) 
    - ubuntu-latest (devel)
    - ubuntu-latest (release)
    - test-coverage
    
✅ Require conversation resolution before merging

✅ Require linear history (optional but recommended)

✅ Do not allow force pushes

✅ Do not allow deletions

⚠️  Do not allow bypassing the above settings (optional - your choice)
```

## Status Checks Explained

The nuggets repository has the following CI/CD workflows that should be used as required status checks:

1. **R-CMD-check**: Runs `R CMD check` on multiple platforms
   - Tests on macOS, Windows, and Ubuntu
   - Tests with both release and development versions of R
   - Ensures the package builds correctly across platforms

2. **test-coverage**: Measures code coverage
   - Runs on Ubuntu with latest R
   - Reports coverage to Codecov
   - Helps maintain code quality standards

## Alternative: Rulesets (GitHub's Newer Feature)

GitHub now also offers "Repository rules" (Rulesets) as a more flexible alternative to branch protection rules. If available for your account:

1. Go to Settings → Rules → Rulesets
2. Create a new ruleset for the `main` branch
3. Configure similar protections with additional flexibility

Rulesets offer better targeting and bypass mechanisms but may not be available for all account types.

## Testing the Protection Rules

After setting up branch protection:

1. Try to push directly to main - it should be rejected
2. Create a new branch and PR - it should work
3. Try to merge PR without approvals - it should be blocked
4. Try to merge PR with failing status checks - it should be blocked

## Questions?

If you need different protection settings based on your workflow, please let us know:

- Do you work alone or with a team?
- Do you want to allow direct pushes in some cases?
- Do you want to require multiple reviewers?
- Are there specific status checks you want to exclude?
- Do you prefer merge commits, squash merging, or rebase merging?

## Additional Resources

- [GitHub Documentation: About Protected Branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Documentation: Managing a Branch Protection Rule](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)

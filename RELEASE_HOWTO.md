- Merge devel into main:
    git checkout main
    git pull origin main
    git merge devel
    git push origin main
- Create release issue: usethis::use_release_issue()
- Update version & date in DESCRIPTION
- Update NEWS.md
- Disable debug in src/common.h
- Update Github actions:
    usethis::use_github_action("check-standard")
    usethis::use_github_action("test-coverage")
- Test:
    devtools::spell_check()
    rhub::rhub_check()
    devtools::check_win_release()
    devtools::check_win_oldrelease()
    devtools::check_win_devel()
    devtools::check_mac_release()
- Release:
    devtools::submit_cran()
- After release:
    - commit CRAN-SUBMISSION and make GIT tag & release
- Prepare for next development iteration:
    - Search for deprecate_stop() and consider if you’re ready to 
      the remove the function completely.
    - Search for deprecate_warn() and replace with deprecate_stop().
      Remove the remaining body of the function and any tests.
    - Search for deprecate_soft() and replace with deprecate_warn().
- Update devel:
    git checkout devel
    git pull origin devel
    git merge main
    git push origin devel
- To install the release candidate of Rcpp (to fix LTO errors):
    install.packages("Rcpp", repos = "https://RcppCore.github.io/drat")
    

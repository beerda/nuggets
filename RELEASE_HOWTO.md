- Update version & date in DESCRIPTION
- Update NEWS.md
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
    devtools::release()

- To install the release candidate of Rcpp (to fix LTO errors):
    install.packages("Rcpp", repos = "https://RcppCore.github.io/drat")
    

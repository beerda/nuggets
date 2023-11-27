- Update version & date in DESCRIPTION
- Update NEWS.md
- Test:
    devtools::spell_check()
    rhub::check_for_cran(env_vars=c(`_R_CHECK_FORCE_SUGGESTS_`="false"))
    devtools::check_win_devel()
- Release:
    devtools::release()

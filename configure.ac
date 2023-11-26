# Require the latest version of autoconf
AC_PREREQ([2.71])

# Provide information about package and version numbering
AC_INIT([nuggets],m4_esyscmd_s([awk -- '/^Version:/ {print $2}' DESCRIPTION]))

# Supply copyright information
AC_COPYRIGHT(Copyright (C) 2023 Michal Burda)

AC_LANG(C++)
AC_PROG_CXX

# Verify the correct src directory exists from where the file is being run.
AC_CONFIG_SRCDIR([src])

# Set package flags
PKG_CXXFLAGS="-march=native -O3 -mtune=native"
PKG_LIBS="${PKG_LIBS}"

# Dynamically generate list of sources from subdirectories via shell
ROOTDIR_SOURCES="$(cd src/ && ls *.cpp | tr '\n' ' ')"
SUBDIR_SOURCES="$(cd src/ && ls */*.cpp | tr '\n' ' ')"

# Substitute the variables into the Makevars file
AC_SUBST(ROOTDIR_SOURCES)
AC_SUBST(SUBDIR_SOURCES)
AC_SUBST(PKG_CXXFLAGS)
AC_SUBST(PKG_LIBS)

AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT

echo "
--------------------------------------------------
Configuration for ${PACKAGE_NAME} ${PACKAGE_VERSION}

    cxxflags: ${CXXFLAGS} ${PKG_CXXFLAGS}
    libs:     ${PKG_LIBS}

--------------------------------------------------
"

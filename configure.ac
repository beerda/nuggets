# Require the latest version of autoconf
AC_PREREQ([2.71])

# Provide information about package and version numbering
AC_INIT([nuggets],m4_esyscmd_s([awk -- '/^Version:/ {print $2}' DESCRIPTION]))

# Supply copyright information
AC_COPYRIGHT(Copyright (C) 2023 Michal Burda)

# Find the compiler and compiler flags used by R.
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi

RBIN="${R_HOME}/bin/R"
CXX="`"${RBIN}" CMD config CXX20` `"${RBIN}" CMD config CXX20STD`"
CXXFLAGS="`"${RBIN}" CMD config CXX20FLAGS`"

PKG_CXXFLAGS="${CXXFLAGS}"
PKG_LIBS="${PKG_LIBS}"

AC_LANG(C++)
AC_PROG_CXX

# Verify the correct src directory exists from where the file is being run.
AC_CONFIG_SRCDIR([src])

# Dynamically generate list of sources from subdirectories via shell
ROOTDIR_SOURCES="$(cd src/ && ls *.cpp | tr '\n' ' ')"
SUBDIR_SOURCES="$(cd src/ && ls */*.cpp | tr '\n' ' ')"

# Substitute the variables into the Makevars file
AC_SUBST(ROOTDIR_SOURCES)
AC_SUBST(SUBDIR_SOURCES)
AC_SUBST(PKG_LIBS)
AC_SUBST(PKG_CXXFLAGS)

AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT

echo "
--------------------------------------------------
Configuration for ${PACKAGE_NAME} ${PACKAGE_VERSION}

    cxxflags: ${CXXFLAGS} ${PKG_CXXFLAGS}
    libs:     ${PKG_LIBS}

--------------------------------------------------
"

#! /bin/bash

PRGNAME="cppcheck"

### cppcheck (A tool for static C/C++ code analysis)
# Инструмент статического анализа кода C/C++. В отличие от компиляторов C/C++ и
# многих других инструментов анализа, cppcheck обнаруживает только те типы
# ошибок, которые компиляторы обычно не замечают.

# Required:    no
# Recommended: no
# Optional:    libxslt  (для создания man-страниц)
#              asciidoc (для создания man-страниц)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

FLAGS="-O2 -fPIC -Wall -Wextra -pedantic -Wno-long-long -DNDEBUG"
make install                         \
    CFLAGS="${FLAGS}"                \
    CXXFLAGS="${FLAGS}"              \
    HAVE_RULES=yes                   \
    MATCHCOMPILER=yes                \
    FILESDIR="/usr/share/${PRGNAME}" \
    CFGDIR="/usr/share/${PRGNAME}/cfg" DESTDIR="${TMP_DIR}" || exit 1

if command -v xsltproc &>/dev/null; then
    if [ -r /etc/asciidoc/docbook-xsl/manpage.xsl ]; then
        xsltproc                                  \
            --nonet                               \
            --output man/                         \
            --param make.year.ranges        "1"   \
            --param man.charmap.use.subset  "0"   \
            --param make.single.year.ranges "1"   \
            /etc/asciidoc/docbook-xsl/manpage.xsl \
            "man/${PRGNAME}.1.xml"

        MANDIR="/usr/share/man/man1"
        mkdir -p "${TMP_DIR}${MANDIR}"
        cp "man/${PRGNAME}.1" "${TMP_DIR}${MANDIR}"
    fi
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A tool for static C/C++ code analysis)
#
# Cppcheck is a static analysis tool for C/C++ code. Unlike C/C++ compilers and
# many other analysis tools, it doesn't detect syntax errors. Cppcheck only
# detects the types of bugs that the compilers normally fail to detect. The
# goal is no false positives.
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

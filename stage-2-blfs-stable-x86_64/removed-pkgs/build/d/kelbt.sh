#! /bin/bash

PRGNAME="kelbt"

### kelbt (Backtracking LR Parsing)
# Анализатор программного кода

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure     \
  --prefix=/usr \
  --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Backtracking LR Parsing)
#
# Kelbt generates backtracking LALR(1) parsers. Where traditional LALR(1)
# parser generators require static resolution of shift/reduce conflicts, Kelbt
# generates parsers that handle conflicts by backtracking at runtime. Kelbt is
# able to generate a parser for any context-free grammar that is free of hidden
# left recursion.
#
# Home page: http://freecode.com/projects/${PRGNAME}
# Download:  http://ponce.cc/slackware/sources/repo/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

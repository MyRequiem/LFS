#! /bin/bash

PRGNAME="meson"

### Meson (A high performance build system)
# Система сборки, ориентированная на скорость и на максимальное удобство для
# пользователя

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-cache-dir       \
    --no-build-isolation \
    --no-deps            \
    "${PWD}" || exit 1

# для запуска набора тестов требуются некоторые пакеты, выходящие за рамки LFS

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    "${PRGNAME}" || exit 1

install -vDm644 data/shell-completions/bash/meson \
    "${TMP_DIR}/usr/share/bash-completion/completions/meson"
install -vDm644 data/shell-completions/zsh/_meson \
    "${TMP_DIR}/usr/share/zsh/site-functions/_meson"

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

install -vDm644 "data/shell-completions/bash/${PRGNAME}" \
    "${TMP_DIR}/usr/share/bash-completion/completions/${PRGNAME}"
install -vDm644 "data/shell-completions/zsh/_${PRGNAME}" \
    "${TMP_DIR}/usr/share/zsh/site-functions/_${PRGNAME}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A high performance build system)
#
# Meson is a cross-platform build system designed to be both as fast and as
# user friendly as possible. It supports many languages and compilers,
# including GCC and Clang. Its build definitions are written in a simple
# non-turing complete domain specific language.
#
# Home page: https://mesonbuild.com
# Download:  https://github.com/mesonbuild/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

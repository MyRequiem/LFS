#! /bin/bash

PRGNAME="nmap"

### Nmap (network scanner)
# Утилита для исследования и аудита безопасности сети. Поддерживает
# сканирование ping, сканирование портов и снятие отпечатков TCP/IP

# Required:    python3-build
# Recommended: liblinear
#              libpcap
#              libssh2
#              lua
#              pcre2
#              python3-pygobject3
# Optional:    libdnet                       (http://code.google.com/p/libdnet/)
#              python3-setuptools-gettext    (https://pypi.org/project/setuptools-gettext/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# заставим систему сборки использовать модуль Python Setuptools (пакет
# python3-setuptools) из LFS вместо загрузки копии из интернета и установки
# Python wheels, уже созданные при запуске make
sed -ri Makefile.in \
    -e 's#-m build#& --no-isolation#'  \
    -e '/pip install/s#(ZENMAP|NDIFF)DIR\)/#&dist/*.whl#' || exit 1

# удалим бесполезную зависимость от setuptools-gettext
sed 's/, "setuptools-gettext"//' -i zenmap/pyproject.toml || exit 1

./configure \
    --prefix=/usr || exit 1

make || exit 1

# тесты должны проводится в графическом окружении
# sed -e '/import imp/d'                \
#     -e 's/^ndiff = .*$/import ndiff/' \
#     -i ndiff/ndifftest.py || exit 1
#
# make check

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (network scanner)
#
# Nmap is a utility for network exploration and security auditing. It supports
# ping scanning, port scanning and TCP/IP fingerprinting.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/dist/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

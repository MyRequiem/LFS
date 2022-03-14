#! /bin/bash

PRGNAME="python3-idna"
ARCH_NAME="idna"

### python3-idna (Internationalized Domain Names for Python)
# Поддержка Internationalised Domain Names (IDNA) в приложениях. Библиотека
# также обеспечивает поддержку Unicode Technical Standard 46 и обработку
# совместимости с Unicode IDNA

# Required:    python3
#              python2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Internationalized Domain Names for Python)
#
# Support for the Internationalised Domain Names in Applications (IDNA)
# protocol as specified in RFC 5891. This is the latest version of the protocol
# and is sometimes referred to as IDNA 2008. This library also provides support
# for Unicode Technical Standard 46, Unicode IDNA Compatibility Processing.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/62/08/e3fc7c8161090f742f504f40b1bccbfc544d4a4e09eb774bf40aafce5436/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

#! /bin/bash

PRGNAME="etc-shells"
LFS_VERSION="12.4"

### /etc/shells (login shell list)
# Файл /etc/shells содержит список оболочек для входа в систему. Приложения
# используют этот файл, чтобы определить, является ли оболочка действительной.

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

SHELLS="/etc/shells"
cat << EOF > "${TMP_DIR}${SHELLS}"
# Begin ${SHELLS}

/bin/sh
/bin/bash

# End ${SHELLS}
EOF

if [ -f "${SHELLS}" ]; then
    mv "${SHELLS}" "${SHELLS}.old"
fi

/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${SHELLS}"

rm -f "/var/log/packages/${PRGNAME}"-*

cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (login shell list)
#
# /etc/shells
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${LFS_VERSION}"

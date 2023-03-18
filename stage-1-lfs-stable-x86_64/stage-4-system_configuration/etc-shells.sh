#! /bin/bash

PRGNAME="etc-shells"
LFS_VERSION="11.3"

### /etc/shells (login shell list)
# Файл /etc/shells содержит список оболочек для входа в систему. Приложения
# используют этот файл, чтобы определить, является ли оболочка действительной.

# в файле /etc/profile мы изменили $PATH и этот файл уже установлен в систему
# LFS, поэтому тест скрипта check_environment.sh в этой директории не будет
# пройден. Проверим окружение явно:
if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# мы в chroot окружении?
ID1="$(awk '$5=="/" {print $1}' < /proc/1/mountinfo)"
ID2="$(awk '$5=="/" {print $1}' < /proc/$$/mountinfo)"
if [[ "${ID1}" == "${ID2}" ]]; then
    echo "You must enter chroot environment."
    echo "Run 003_entering_chroot.sh script in this directory."
    exit 1
fi

ROOT="/"

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

SHELLS="/etc/shells"
# оболочки записываются как полный путь к исполняемому файлу в отдельной строке
cat << EOF > "${TMP_DIR}${SHELLS}"
# Begin ${SHELLS}

/bin/sh
/bin/bash

# End ${SHELLS}
EOF

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (login shell list)
#
# /etc/shells
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${LFS_VERSION}"

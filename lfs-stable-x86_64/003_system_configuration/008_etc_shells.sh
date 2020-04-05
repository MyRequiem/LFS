#! /bin/bash

PRGNAME="etc_shells"
VERSION="9.0"

### etc_shells
# Файл /etc/shells содержит список оболочек для входа в систему. Приложения
# используют этот файл, чтобы определить, является ли оболочка действительной.
# Каждая оболочка записывается как полный путь к исполняемому файлу в отдельной
# строке.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter07/etcshells.html

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
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

SHELLS="/etc/shells"
if [ -f "${SHELLS}" ]; then
    mv "${SHELLS}" "${SHELLS}.old"
fi

cat << EOF > "${SHELLS}"
# Begin ${SHELLS}

/bin/sh
/bin/bash

# End ${SHELLS}
EOF

cp "${SHELLS}" "${TMP_DIR}/etc/"
config_file_processing "${SHELLS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (login shell list)
#
# /etc/shells
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

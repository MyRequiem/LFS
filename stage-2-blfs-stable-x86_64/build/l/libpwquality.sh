#! /bin/bash

PRGNAME="libpwquality"

### libpwquality (password quality checking library)
# Общие функции для проверки качества паролей и их оценки на основе очевидной
# случайности

# Required:    cracklib
# Recommended: linux-pam
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/pam.d"

./configure                            \
    --prefix=/usr                      \
    --disable-static                   \
    --with-securedir=/usr/lib/security \
    --disable-python-bindings || exit 1

make || exit 1

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}/python"

# пакет не имеет набора тестов

make install DESTDIR="${TMP_DIR}"

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    --no-user           \
    pwquality

###
# Конфигурация PAM
###
# libpwquality является заменой устаревшего модуля PAM pam_cracklib.so
# настроим систему на использование модуля pam_pwquality

SYSTEM_PASSWORD="/etc/pam.d/system-password"
cp "${SYSTEM_PASSWORD}" "${TMP_DIR}${SYSTEM_PASSWORD}"
cat << EOF >> "${TMP_DIR}${SYSTEM_PASSWORD}"
# check new passwords for strength (man pam_pwquality)
password  required    pam_pwquality.so   authtok_type=UNIX retry=1 difok=1 \\
                                         minlen=8 dcredit=0 ucredit=0      \\
                                         lcredit=0 ocredit=0 minclass=1    \\
                                         maxrepeat=0 maxsequence=0         \\
                                         maxclassrepeat=0 gecoscheck=0     \\
                                         dictcheck=1 usercheck=1           \\
                                         enforcing=1 badwords=""           \\
                                         dictpath=/usr/lib/cracklib/pw_dict

EOF

if [ -f "${SYSTEM_PASSWORD}" ]; then
    mv "${SYSTEM_PASSWORD}" "${SYSTEM_PASSWORD}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SYSTEM_PASSWORD}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (password quality checking library)
#
# The libpwquality package provides common functions for password quality
# checking and also scoring them based on their apparent randomness. The
# library also provides a function for generating random passwords with good
# pronounceability
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

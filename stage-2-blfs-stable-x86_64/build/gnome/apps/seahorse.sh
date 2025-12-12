#! /bin/bash

PRGNAME="seahorse"

### Seahorse (encryption made easy)
# Графическое приложение в Linux, особенно популярное в среде рабочего стола
# GNOME, которое служит удобным интерфейсом для управления ключами шифрования
# GPG и SSH, а также паролями, позволяя создавать, импортировать, кэшировать и
# публиковать ключи. Он упрощает криптографические операции для пользователей,
# интегрируясь с файловыми менеджерами (Nautilus) и почтовыми клиентами
# (Evolution) для шифрования файлов и писем, и основан на библиотеке GnuPG

# Required:    gcr3
#              gnupg
#              gpgme
#              itstool
#              libhandy
#              libpwquality
#              libsecret
#              vala
#              --- runtime ---
#              gnome-keyring
# Recommended: libsoup3
#              openssh
# Optional:    avahi

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим ошибку сборки, возникающую при использовании gpgme-2.x.x
sed -i "/GPGME_EVENT_NEXT_TRUSTITEM/d" pgp/seahorse-gpgme.c || exit 1

# исправим некоторые устаревшие записи в шаблонах схем
sed -i -r 's:"(/apps):"/org/gnome\1:' data/*.xml || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (encryption made easy)
#
# Seahorse is a graphical interface for managing and using encryption keys.
# Currently it supports PGP keys (using GPG/GPGME) and SSH keys
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

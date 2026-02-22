#! /bin/bash

PRGNAME="gnome-online-accounts"

### GNOME Online Accounts (framework used to access GNOME online accounts)
# Система в среде рабочего стола GNOME, позволяющая пользователям подключать
# свои онлайн-учетные записи (например, Google, Nextcloud, Microsoft) и
# автоматически интегрировать их с приложениями GNOME

# Required:    gcr4
#              json-glib
#              libadwaita
#              rest
#              vala
# Recommended: glib
# Optional:    python3-gi-docgen
#              keyutils
#              mit-kerberos-v5
#              valgrind

###
# WARNING
###
# Приведенный ниже ключ Google API и токены OAuth предназначены для LFS. Если
# вы используете эти инструкции для другого дистрибутива или собираетесь
# распространять двоичные копии программного обеспечения, используя эти
# инструкции, пожалуйста, получите собственные ключи, следуя инструкциям на
# странице https://www.chromium.org/developers/how-tos/api-keys
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

SECRET="5ntt6GbbkjnTVXx-MSxbmx5e"
ID="595013732528-llk8trb03f0ldpqq6nprjp1s79596646.apps.googleusercontent.com"

meson setup                             \
    --prefix=/usr                       \
    --buildtype=release                 \
    -D documentation=false              \
    -D kerberos=true                    \
    -D google_client_secret="${SECRET}" \
    -D google_client_id="${ID}"         \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (framework used to access GNOME online accounts)
#
# The GNOME Online Accounts package contains a framework used to access the
# user's online accounts
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

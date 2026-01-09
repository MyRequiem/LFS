#! /bin/bash

PRGNAME="gnome-shell-extensions"

### GNOME Shell Extensions (GNOME Shell Extensions)
# Небольшие фрагменты кода (написанные в основном на JavaScript), создаваемые
# сторонними разработчиками, которые добавляют, изменяют или расширяют
# функциональность и внешний вид графической оболочки GNOME. Подобно
# дополнениям для Firefox или расширениям для Chrome, они позволяют
# пользователям кастомизировать свой рабочий стол, добавляя новые панели,
# виджеты, меняя поведение окон и многое другое, не трогая основной код GNOME
# Shell

# Required:    libgtop
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup       \
    --prefix=/usr \
    .. || exit 1

# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Shell Extensions)
#
# The GNOME Shell Extensions package contains a collection of extensions
# providing additional and optional functionality to the GNOME Shell
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

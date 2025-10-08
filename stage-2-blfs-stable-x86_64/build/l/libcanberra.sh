#! /bin/bash

PRGNAME="libcanberra"

### libcanberra (XDG Sound Theme and Name Spec implementation)
# Библиотека для генерации и воспроизведения звуков событий на рабочих столах в
# соответствии со спецификацией XDG. Содержит несколько бэкэндов для различных
# аудиосистем. Модуль libcanberra-gtk-module принимает события GUI от GTK+
# (например, нажатие кнопки или сворачивание окна) и воспроизводит некоторый
# сконфигурированный звук.

# Required:    libvorbis
# Recommended: alsa-lib                 (для сборки утилиты 'canberra-boot' и libcanberra-alsa.so)
#              gstreamer
#              gtk+3
# Optional:    pulseaudio
#              gtk+2                    (https://download.gnome.org/sources/gtk+/2.24/)
#              tdb                      (https://tdb.samba.org/)
#              sound-theme-freedesktop

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему, вызывающую сбой некоторых приложений в окружении рабочего
# стола на основе wayland
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-wayland-1.patch" || exit 1

# отключаем поддержку устаревшего OSS
#    --disable-oss
./configure       \
    --prefix=/usr \
    --disable-oss || exit 1

make || exit 1
# пакет не имеет набора тестов
make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XDG Sound Theme and Name Spec implementation)
#
# libcanberra is an implementation of the XDG Sound Theme and Name
# Specifications, for generating event sounds on free desktops. It comes with
# several backends for several audio systems and is designed to be portable.
#
# Home page: https://0pointer.de/lennart/projects/${PRGNAME}/
# Download:  https://0pointer.de/lennart/projects/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

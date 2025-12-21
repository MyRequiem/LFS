#! /bin/bash

PRGNAME="localsearch"

### Localsearch (filesystem indexer and metadata extractor)
# Индексатор файловой системы и экстрактор метаданных

# Required:    gexiv2
#              gst-plugins-base
#              tinysparql
# Recommended: exempi
#              giflib
#              ffmpeg
#              icu
#              libexif
#              libgxps
#              libseccomp
#              poppler
#              upower
# Optional:    python3-asciidoc         (для генерации man-страниц)
#              cmake
#              dconf
#              libgsf
#              networkmanager
#              taglib
#              totem-pl-parser
#              libcue                   (https://github.com/lipnitsk/libcue)
#              libitpcdata              (https://libiptcdata.sourceforge.net/)
#              libosinfo                (https://libosinfo.org/)
#              gupnp                    (https://gitlab.gnome.org/GNOME/gupnp)

###
# Конфигурация ядра
###
# NOTE:
#  - Обязательно, иначе ошибка конфигурации:
#    ../meson.build:160:4: ERROR: Problem encountered:
#    Landlock was auto-enabled in build options, but is disabled in the kernel
#    Либо собирать с параметром:
#    # Disable landlock sandboxing support in Tracker metadata extractor
#    -D landlock=disabled (не рекомендуется)
#
#    CONFIG_SECURITY=y
#    CONFIG_SECURITY_LANDLOCK=y
#    CONFIG_LSM="landlock,lockdown,smack,yama,loadpin,safesetid,integrity"
#
#  - Перед обновлением установленный пакет следует удалить из системы
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сделаем экстрактор HTML совместимым с libxml2-2.14 и более поздними версиями
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-libxml2_2_14-1.patch" || exit 1

mkdir build
cd build || exit 1

meson setup                        \
    --prefix=/usr                  \
    --buildtype=release            \
    -D systemd_user_services=false \
    -D man=false                   \
    .. || exit 1

ninja || exit 1

# тесты
# dbus-run-session env LC_ALL=C.UTF-8 TRACKER_TESTS_AWAIT_TIMEOUT=20 \
#     ninja test
# тесты создают директорию tracker-tests с кучей файлов тестирования в домашнем
# калоге, удалим их
#    rm -rf ~/tracker-tests

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (filesystem indexer and metadata extractor)
#
# The Localsearch package contains a filesystem indexer as well as a metadata
# extractor
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

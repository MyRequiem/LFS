#! /bin/bash

PRGNAME="xdg-user-dirs"

### Xdg-user-dirs.sh (manage XDG user directories)
# Инструмент, помогающий управлять известными пользовательскими каталогами,
# такими как папка рабочего стола, папка музыки, документов и т.д. Также
# обрабатывает локализацию (т.е. перевод) имен файлов

# Required:    no
# Recommended: no
# Optional:    --- для создания man-страниц ---
#              docbook-xml
#              docbook-xsl
#              libxslt

###
# Конфигурация
###

### Названия и пути к основным пользовательским каталогам
# /etc/xdg/user-dirs.defaults
#    # значения переменных являются относительными путями от домашнего
#    # каталога пользователя, которые переводятся в локаль пользователя
#    DESKTOP=Desktop
#    DOWNLOAD=Downloads
#    TEMPLATES=Templates
#    PUBLICSHARE=Public
#    DOCUMENTS=Documents
#    MUSIC=Music
#    PICTURES=Pictures
#    VIDEOS=Videos
#
#    # альтернативные варианты
#    MUSIC=Documents/Music
#    PICTURES=Documents/Pictures
#    VIDEOS=Documents/Videos
#
# Можно переопределить эти значения в конфиге каждого пользователя
# ~/.config/user-dirs.dirs
#    XDG_DESKTOP_DIR="$HOME/desktop"
#    XDG_DOWNLOAD_DIR="$HOME/tmp"
#    XDG_TEMPLATES_DIR="$HOME/tmp"
#    XDG_PUBLICSHARE_DIR="$HOME/tmp"
#    XDG_DOCUMENTS_DIR="$HOME/docs"
#    XDG_MUSIC_DIR="$HOME/media/audio"
#    XDG_PICTURES_DIR="$HOME/docs/images"
#    XDG_VIDEOS_DIR="$HOME/media/video"

### контроль поведения утилиты xdg-user-dirs-update при входе пользователя
# /etc/xdg/user-dirs.conf
#
#    # также можно настроить конфигурацию для каждого пользователя в
#    #    ~/.config/user-dirs.conf
#    # или установить переменные окружения
#    # XDG_CONFIG_HOME и/или XDG_CONFIG_DIRS
#
#    enabled=True
#    filename_encoding=UTF-8

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                \
    --prefix=/usr          \
    --sysconfdir=/etc      \
    --enable-documentation \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (manage XDG user directories)
#
# Xdg-user-dirs is a tool to help manage "well known" user directories like the
# desktop folder and the music folder. It also handles localization (i.e.
# translation) of the filenames
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://user-dirs.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

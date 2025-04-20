#! /bin/bash

PRGNAME="fontconfig"

### Fontconfig (Font library and tools)
# Библиотека и инструменты, разработанные для конфигурации общесистемных
# шрифтов

# Required:    freetype
# Recommended: no
# Optional:    json-c
#              libxml2
#              --- для тестов ---
#              bubblewrap
#              curl
#              unzip
#              --- для сборки документации ---
#              docbook-utils
#              texlive или install-tl-unx
#              perl-sgmlspm

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/fonts/conf.avail"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --disable-docs       \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# man-страницы
install -v -dm755                 "${TMP_DIR}/usr/share/man"/man{1,3,5}
install -v -m644 fc-*/*.1         "${TMP_DIR}/usr/share/man/man1"
install -v -m644 doc/*.3          "${TMP_DIR}/usr/share/man/man3"
install -v -m644 doc/fonts-conf.5 "${TMP_DIR}/usr/share/man/man5"

# Конфигурация Fontconfig
# -----------------------
#
# конфиги:
#    /etc/fonts/fonts.conf
#    /etc/fonts/conf.d/*
#    /etc/fonts/conf.avail/*
#    /usr/share/fontconfig/conf.avail/*
#
# основной файл конфигурации:
#    /etc/fonts/fonts.conf
# он также читает
#    /etc/fonts/local.conf
# и все ссылки на конфиги в
#    /etc/fonts/conf.d/
#
# Чтобы сконфигурировать новый каталог со шрифтами, создаем/правим
# /etc/fonts/local.conf
#
# По умолчанию шрифты располагаются в
#    /usr/share/fonts/
#    ~/.local/share/fonts/
#    ~/.fonts/ (устарело, но все еще используется)
#
# Fontconfig также содержит множество примеров конфигурационных файлов в
# /usr/share/fontconfig/conf.avail/ Для включения файлов в этой директории
# нужно установить ссылку на файл в /etc/fonts/conf.d/
#
# Описание файлов конфигурации: /etc/fonts/conf.d/README

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Font library and tools)
#
# Fontconfig is a library and tools designed to provide system-wide font
# configuration, customization, and application access.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/release/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

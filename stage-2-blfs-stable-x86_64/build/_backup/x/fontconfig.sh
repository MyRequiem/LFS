#! /bin/bash

PRGNAME="fontconfig"

### Fontconfig (Font library and tools)
# Библиотека и инструменты, разработанные для конфигурации общесистемных
# шрифтов

# http://www.linuxfromscratch.org/blfs/view/stable/general/fontconfig.html

# Home page: https://www.freedesktop.org/wiki/Software/fontconfig/
# Download:  https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.1.tar.bz2

# Required: freetype
# Optional: docbook-utils
#           libxml2
#           texlive или install-tl-unx
#           perl-sgmlspm

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# убедимся, что система регенерирует src/fcobjshash.h
rm -f src/fcobjshash.h

# для сборки документации нужны пакеты texlive или install-tl-unx,
# docbook-utils и perl-sgmlspm
INSTALL_DOCS="--disable-docs"
DOCBOOK_UTILS=""
TEXLIVE=""
PERL_SGMLSPM=""

command -v docbook2html &>/dev/null && DOCBOOK_UTILS="true"
command -v texdoc       &>/dev/null && TEXLIVE="true"
command -v sgmlspl      &>/dev/null && PERL_SGMLSPM="true"
[[ -n "${DOCBOOK_UTILS}" && -n "${TEXLIVE}" && -n "${PERL_SGMLSPM}" ]] && \
    INSTALL_DOCS="--enable-docs"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    "${INSTALL_DOCS}"    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check

# Конфигурация Fontconfig
# -----------------------
#
# конфиги:
#    /etc/fonts/*
#    /etc/fonts/conf.d/*
#    /usr/share/fontconfig/conf.avail/*
#
# основной файл конфигурации:
#    /etc/fonts/fonts.conf
# он также читает
#    /etc/fonts/local.conf
# и все файлы в
#    /etc/fonts/conf.d/
#
# Чтобы сконфигурировать новый каталог со шрифтами, создаем/правим
# /etc/fonts/local.conf
#
# По умолчанию шрифты располагаются в
#    /usr/share/fonts
#    ~/.local/share/fonts
#    ~/.fonts (устарело, но все еще используется)
#
# Fontconfig также содержит множество примеров конфигурационных файлов в
# /usr/share/fontconfig/conf.avail/ Для включения файлов в этой директории
# нужно установить ссылку на файл в /etc/fonts/conf.d/
#
# Описание файлов конфигурации: /etc/fonts/conf.d/README

FONTS_CONF="/etc/fonts/fonts.conf"
if [ -f "${FONTS_CONF}" ]; then
    mv "${FONTS_CONF}" "${FONTS_CONF}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${FONTS_CONF}"

# если мы не устанавливали документацию, то установим ее вручную
if [[ "x${INSTALL_DOCS}" == "x--disable-docs" ]]; then
    DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
    MAN="/usr/share/man"

    install -v -dm755 "${DOCS}/fontconfig-devel"
    install -v -dm755 "${TMP_DIR}${DOCS}/fontconfig-devel"

    install -v -dm755 "${MAN}"/man{1,3,5}
    install -v -dm755 "${TMP_DIR}${MAN}"/man{1,3,5}

    install -v -m644 fc-*/*.1 "${MAN}/man1"
    install -v -m644 fc-*/*.1 "${TMP_DIR}${MAN}/man1"

    install -v -m644 doc/*.3   "${MAN}/man3"
    install -v -m644 doc/*.3   "${TMP_DIR}${MAN}/man3"

    install -v -m644 doc/fonts-conf.5 "${MAN}/man5"
    install -v -m644 doc/fonts-conf.5 "${TMP_DIR}${MAN}/man5"

    install -v -m644 doc/fontconfig-devel/* "${DOCS}/fontconfig-devel"
    install -v -m644 doc/fontconfig-devel/* "${TMP_DIR}${DOCS}/fontconfig-devel"

    install -v -m644 doc/*.{pdf,sgml,txt,html} "${DOCS}"
    install -v -m644 doc/*.{pdf,sgml,txt,html} "${TMP_DIR}${DOCS}"
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Font library and tools)
#
# Fontconfig is a library and tools designed to provide system-wide font
# configuration, customization, and application access.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/release/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

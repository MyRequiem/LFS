#! /bin/bash

PRGNAME="xorg-libraries"
PKG_VERSION="7"

### Xorg Libraries (Xorg libraries)
# Библиотеки Xorg, которые используются во всех X Window приложения

# Required:    fontconfig
#              libxcb
# Recommended: elogind
# Optional:    xmlto
#              fop
#              links or lynx or w3m (для сборки документации пакета libXfont) http://w3m.sourceforge.net/

###
# NOTES:
###
# *** /usr/bin ***
# cxpm               - проверка формата XPM файлов (синтаксический анализ X PixMap)
# sxpm               - просмотр XPM файлов и/или конвертация XPM1 и XPM2 в XPM3
#
# *** /usr/lib ***
# libdmx.so          - DMX (Distributed Multihead X) extension library
# libfontenc.so      - X11 font encoding library
# libFS.so           - library interface to the X Font Server
# libICE.so          - X Inter Client Exchange Library
# libpciaccess.so    - generic PCI Access library for X
# libSM.so           - X Session Management Library
# libX11.so          - Xlib Library
# libXaw6.so         - X Athena Widgets Library, version 6
# libXaw7.so         - X Athena Widgets Library, version 7
# libXaw.so          - link to libXaw7.so
# libXcomposite.so   - X Composite Library
# libXcursor.so      - X Cursor management library
# libXdamage.so      - X Damage Library
# libXext.so         - Misc X Extension Library
# libXfixes.so       - provides augmented versions of core protocol requests
# libXfont2.so       - X font library
# libXft.so          - X FreeType interface library
# libXinerama.so     - Xinerama Library
# libXi.so           - X Input Extension Library
# libxkbfile.so      - xkbfile Library
# libXmu.so          - X interface library for miscellaneous utilities no part of the Xlib standard
# libXmuu.so         - Mini Xmu Library
# libXpm.so          - X Pixmap Library
# libXrandr.so       - X Resize, Rotate and Reflection extension library
# libXrender.so      - X Render Library
# libXRes.so         - X-Resource extension client library
# libxshmfence.so    - exposes an event API on top of Linux futexes
# libXss.so          - X11 Screen Saver extension client library
# libXt.so           - X Toolkit Library
# libXtst.so         - Xtst Library
# libXvMC.so         - X-Video Motion Compensation Library
# libXvMCW.so        - XvMC Wrapper including the Nonstandard VLD extension
# libXv.so           - X Window System video extension library
# libXxf86dga.so     - client library for the XFree86-DGA extension
# libXxf86vm.so      - client library for the XFree86-VidMode X extension
#
# *** Устанавливаемые директории ***
# /usr/include/X11/Xtrans
# /usr/include/X11/fonts
# /usr/share/X11/locale
# /usr/share/doc/libFS
# /usr/share/doc/libICE
# /usr/share/doc/libSM
# /usr/share/doc/libX11
# /usr/share/doc/libXaw
# /usr/share/doc/libXext
# /usr/share/doc/libXi
# /usr/share/doc/libXmu
# /usr/share/doc/libXrender
# /usr/share/doc/libXt
# /usr/share/doc/libXtst
# /usr/share/doc/libXvMC
# /usr/share/doc/xtrans

ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"

source "${ROOT}/check_environment.sh" || exit 1
source "${ROOT}/xorg_config.sh"       || exit 1

show_error() {
    echo -e "\n***"
    echo "* Error: $1"
    echo "***"
}

get_pkg_version() {
    # $1 - имя пакета, версию которого нужно найти
    local TARBOL_VERSION
    TARBOL_VERSION="$(find "${SOURCES}" -type f \
        -name "${1}-[0-9]*.tar.?z*" 2>/dev/null | sort | \
        head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

    echo "${TARBOL_VERSION}"
}

TMP="/tmp/build-${PRGNAME}-${PKG_VERSION}"
rm -rf "${TMP}"

# директория для сборки всего пакета
TMP_PACKAGE="${TMP}/package-${PRGNAME}-${PKG_VERSION}"
mkdir -pv "${TMP_PACKAGE}"

# директория для распаковки исходников
TMP_SRC="${TMP}/src"
mkdir -pv "${TMP_SRC}"

# директория для установки пакетов по отдельности
TMP_PKGS="${TMP}/pkgs"
mkdir -p "${TMP_PKGS}"

# список всех пакетов
PACKAGES="\
xtrans \
libX11 \
libXext \
libFS \
libICE \
libSM \
libXScrnSaver \
libXt \
libXmu \
libXpm \
libXaw \
libXfixes \
libXcomposite \
libXrender \
libXcursor \
libXdamage \
libfontenc \
libXfont2 \
libXft \
libXi \
libXinerama \
libXrandr \
libXres \
libXtst \
libXv \
libXvMC \
libXxf86dga \
libXxf86vm \
libdmx \
libpciaccess \
libxkbfile \
libxshmfence \
"

for PKGNAME in ${PACKAGES}; do
    echo -e "\n***************** Building ${PKGNAME} package *****************"
    sleep 1

    # определяем версию пакета
    VERSION="$(get_pkg_version "${PKGNAME}")"

    # версия не найдена
    if [ -z "${VERSION}" ]; then
        show_error "Version for '${PKGNAME}' package not found in ${SOURCES}"
        exit 1
    fi

    # распаковываем архив
    cd "${TMP_SRC}" || exit 1
    echo "Unpacking ${PKGNAME}-${VERSION} source archive..."
    tar xvf "${SOURCES}/${PKGNAME}-${VERSION}".tar.?z* &>/dev/null || {
        show_error "Can not unpack ${PKGNAME}-${VERSION} archive"
        exit 1
    }

    cd "${PKGNAME}-${VERSION}" || exit 1

    DOCDIR="--docdir=${XORG_PREFIX}/share/doc/${PKGNAME}-${VERSION}"

    # конфигурация
    case "${PKGNAME}" in
        libICE)
            # исправляем нарушение в работе pulseaudio во время выполнения
            #    ICE_LIBS=-lpthread
            #
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                ICE_LIBS=-lpthread || {
                    show_error "'configure' for ${PKGNAME} package"
                    exit 1
                }
            ;;

        libXfont2)
            XMLTO=""
            command -v xmlto &>/dev/null && XMLTO="true"

            TEXT_BROWSER=""
            command -v w3m   &>/dev/null && TEXT_BROWSER="true"
            command -v links &>/dev/null && TEXT_BROWSER="true"
            command -v lynx  &>/dev/null && TEXT_BROWSER="true"

            DEVEL_DOCS="--disable-devel-docs"
            [[ -n "${XMLTO}" && -n "${TEXT_BROWSER}" ]] && \
                DEVEL_DOCS="--enable-devel-docs"

            # для создания pdf-документации
            FOP="--without-fop"
            command -v fop &>/dev/null && FOP="--with-fop"

            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                "${FOP}"       \
                "${DEVEL_DOCS}" || {
                    show_error "'configure' for ${PKGNAME} package"
                    exit 1
                }
            ;;

        libXt)
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                --with-appdefaultdir="/etc/X11/app-defaults" || {
                    show_error "'configure' for ${PKGNAME} package"
                    exit 1
                }
            ;;

        *)
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}" || {
                    show_error "'configure' for ${PKGNAME} package"
                    exit 1
                }
            ;;
    esac

    # сборка
    make || {
        show_error "'make' for ${PKGNAME} package"
        exit 1
    }

    # тесты
    # make check 2>&1 | tee make_check.log
    # grep -A9 summary make_check.log

    # директория для установки собранного пакета
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    make install DESTDIR="${PKG_INSTALL_DIR}" || {
        show_error "'make install' for ${PKGNAME} package"
        exit 1
    }

    # stripping
    BINARY="$(find "${PKG_INSTALL_DIR}" -type f -print0 | \
        xargs -0 file 2>/dev/null | grep -e "executable" -e "shared object" | \
        grep ELF | cut -f 1 -d :)"

    for BIN in ${BINARY}; do
        strip --strip-unneeded "${BIN}"
    done

    # обновляем базу данных info (/usr/share/info/dir)
    INFO="/usr/share/info"
    if [ -d "${PKG_INSTALL_DIR}${INFO}" ]; then
        cd "${PKG_INSTALL_DIR}${INFO}" || exit 1
        # оставляем только *info* файлы
        find . -type f ! -name "*info*" -delete
        for FILE in *; do
            install-info --dir-file="${INFO}/dir" "${FILE}" 2>/dev/null
        done
    fi

    # имя пакета в нижний регистр
    PKGNAME="$(echo "${PKGNAME}" | tr '[:upper:]' '[:lower:]')"

    # пишем в ${PKG_INSTALL_DIR}/var/log/packages/${PKGNAME}-${VERSION}
    (
        cd "${PKG_INSTALL_DIR}" || exit 1

        LOG="var/log/packages/${PKGNAME}-${VERSION}"
        cat << EOF > "${LOG}"
# Package: ${PKGNAME}
#
###
# This package is part of '${PRGNAME}' package
###
#
EOF
        find . | cut -d . -f 2- | sort >> "${LOG}"
        # удалим пустые строки в файле
        sed -i '/^$/d' "${LOG}"
        # комментируем все пути
        sed -i 's/^\//# \//g' "${LOG}"
    )

    # копируем собранный пакет в директорию основного пакета и в корень системы
    /bin/cp -vpR "${PKG_INSTALL_DIR}"/* "${TMP_PACKAGE}"/
    /bin/cp -vpR "${PKG_INSTALL_DIR}"/* /

    # для сборки следующих пакетов, которые могут быть зависимы от текущего,
    # нужно найти установленные библиотеки текущего пакета и кэшировать их в
    # /etc/ld.so.cache
    /sbin/ldconfig
done

cat << EOF > "/var/log/packages/${PRGNAME}-${PKG_VERSION}"
# Package: ${PRGNAME} (Xorg libraries)
#
# The Xorg libraries provide library routines that are used within all X Window
# applications.
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/lib/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_PACKAGE}" "${PRGNAME}-${PKG_VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

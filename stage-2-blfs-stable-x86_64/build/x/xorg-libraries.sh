#! /bin/bash

PRGNAME="xorg-libraries"

### Xorg Libraries (Xorg libraries)
# Библиотеки Xorg, которые используются во всех X Window приложения

# Required:    fontconfig
#              libxcb
# Recommended: elogind
# Optional:    xmlto
#              fop
#              links or lynx or w3m (для сборки документации) http://w3m.sourceforge.net/

TMP="/tmp"
ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"

source "${ROOT}/check_environment.sh" || exit 1
source "${ROOT}/xorg_config.sh"       || exit 1

LIBX11_VERSION="$(find "${SOURCES}" -type f \
    -name "libX11-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

if [ -z "${LIBX11_VERSION}" ]; then
    echo "Error: Version for libX11 package not found in ${SOURCES}"
    exit 1
fi

SRC_DIR="${TMP}/xorg-src"
rm -rf "${SRC_DIR}"
mkdir -pv "${SRC_DIR}"

TMP_DIR="${TMP}/package-${PRGNAME}-${LIBX11_VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

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

for PKG in ${PACKAGES}; do
    VERSION="$(find "${SOURCES}" -type f \
        -name "${PKG}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
        cut -d . -f 3- | cut -d - -f 1 | rev)"

    if [ -z "${VERSION}" ]; then
        echo "Error: Version for ${PKG} package not found in ${SOURCES}"
        exit 1
    fi

    cd "${SRC_DIR}" || exit 1
    tar xvf "${SOURCES}/${PKG}-"[0-9]*.tar.?z* || exit 1
    cd "${PKG}-"[0-9]* || exit 1

    DOCDIR="--docdir=${XORG_PREFIX}/share/doc/${PKG}-${VERSION}"

    case "${PKG}" in
        libICE)
            # исправляем нарушение в работе pulseaudio во время выполнения
            #    ICE_LIBS=-lpthread
            #
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                ICE_LIBS=-lpthread || {
                    echo "Error 'configure' for ${PKG} package"
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
            # command -v fop &>/dev/null && FOP="--with-fop"

            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                "${FOP}"       \
                "${DEVEL_DOCS}" || {
                    echo "Error 'configure' for ${PKG} package"
                    exit 1
                }
            ;;

        libXt)
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                --with-appdefaultdir="/etc/X11/app-defaults" || {
                    echo "Error 'configure' for ${PKG} package"
                    exit 1
                }
            ;;

        *)
            # shellcheck disable=SC2086
            ./configure \
                ${XORG_CONFIG} \
                "${DOCDIR}" || {
                    echo "Error 'configure' for ${PKG} package"
                    exit 1
                }
            ;;
    esac

    make || {
        echo "Error 'make' for ${PKG} package"
        exit 1
    }

    # make check 2>&1 | tee make_check.log
    # grep -A9 summary make_check.log

    TMP_PKG="${TMP}/xorg-packages/package-${PKG}-${VERSION}"
    rm -rf "${TMP_PKG}"
    mkdir -pv "${TMP_PKG}"

    make install DESTDIR="${TMP_PKG}" || {
        echo "Error 'make install' for ${PKG} package"
        exit 1
    }

    # stripping
    BINARY="$(find "${TMP_PKG}" -type f -print0 | xargs -0 file 2>/dev/null | \
        grep -e "executable" -e "shared object" | grep ELF | cut -f 1 -d :)"

    for BIN in ${BINARY}; do
        strip --strip-unneeded "${BIN}"
    done

    # обновляем базу данных info (/usr/share/info/dir)
    INFO="/usr/share/info"
    if [ -d "${TMP_PKG}${INFO}" ]; then
        cd "${TMP_PKG}${INFO}" || exit 1
        # оставляем только *info* файлы
        find . -type f ! -name "*info*" -delete
        for FILE in *; do
            install-info --dir-file="${INFO}/dir" "${FILE}" 2>/dev/null
        done
    fi

    /bin/cp -vpR "${TMP_PKG}"/* "${TMP_DIR}"
    /bin/cp -vpR "${TMP_PKG}"/* /

    /sbin/ldconfig

    if [[ "x${PKG}" == "xlibFS" ]]; then
        break
    fi
done

cat << EOF > "/var/log/packages/${PRGNAME}-${LIBX11_VERSION}"
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
    "${TMP_DIR}" "${PRGNAME}-${LIBX11_VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

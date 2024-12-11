#! /bin/bash

PRGNAME="xorg-libraries"
PKG_VERSION="11"

### Xorg Libraries (Xorg libraries)
# Библиотеки Xorg, которые используются во всех X Window приложения

# Required:    fontconfig
#              libxcb
# Recommended: no
# Optional:    --- для сборки документации ---
#              python3-asciidoc
#              xmlto
#              fop
#              links или lynx или w3m (http://w3m.sourceforge.net/)
#              --- для некоторых тестов ---
#              ncompress              (https://github.com/vapier/ncompress)

ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"

source "${ROOT}/check_environment.sh" || exit 1
source "${ROOT}/xorg_config.sh"       || exit 1

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
libpciaccess \
libxkbfile \
libxshmfence \
libXpresent \
"

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

    chown -R root:root .
    find -L . \
        \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
        -o -perm 511 \) -exec chmod 755 {} \; -o \
        \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
        -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

    DOCDIR="--docdir=${XORG_PREFIX}/share/doc/${PKGNAME}-${VERSION}"

    # конфигурация
    case "${PKGNAME}" in
        libXfont2)
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                --disable-devel-docs || {
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

        libXpm)
            # разрешим сборку пакета без установленного опционального пакета
            # ncompress
            #    --disable-open-zfile
            # shellcheck disable=SC2086
            ./configure        \
                ${XORG_CONFIG} \
                "${DOCDIR}"    \
                --disable-open-zfile || {
                    show_error "'configure' for ${PKGNAME} package"
                    exit 1
                }
            ;;
        libpciaccess)
            mkdir build
            cd build || exit 1

            # shellcheck disable=SC2086
            meson setup                 \
                --prefix=${XORG_PREFIX} \
                --buildtype=release     \
                .. || {
                    show_error "'meson configure' for ${PKGNAME} package"
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
    if [ "${PKGNAME}" == "libpciaccess" ]; then
        ninja || {
            show_error "'make (ninja)' for ${PKGNAME} package"
            exit 1
        }
    else
        make || {
            show_error "'make' for ${PKGNAME} package"
            exit 1
        }
    fi

    # директория для установки собранного пакета
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    if [ "${PKGNAME}" == "libpciaccess" ]; then
        DESTDIR="${PKG_INSTALL_DIR}" ninja install || {
            show_error "'ninja install' for ${PKGNAME} package"
            exit 1
        }

        cd .. || exit 1

    else
        make install DESTDIR="${PKG_INSTALL_DIR}" || {
            show_error "'make install' for ${PKGNAME} package"
            exit 1
        }
    fi

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
#
# INFO:
#    https://www.x.org/wiki/ModuleDescriptions/
#    https://lists.x.org/archives/xorg-modular/2005-November/000801.html
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
# applications
#
# INFO:
#    https://www.x.org/wiki/ModuleDescriptions/
#    https://lists.x.org/archives/xorg-modular/2005-November/000801.html
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

#! /bin/bash

PRGNAME="xorg-fonts"
PKG_VERSION="7"

### xorg-fonts (Xorg Fonts)
# Масштабируемые шрифты и вспомогательные утилиты для приложений Xorg

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

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
FONTS="/usr/share/fonts"
mkdir -pv "${TMP_PACKAGE}${FONTS}/X11/"{OTF,TTF}

# нужно создать ссылки на директории с OTF и TTF шрифтами в /usr/share/fonts
# чтобы Fontconfig мог найти шрифты TrueType, поскольку они находятся не по
# стандартному пути /usr/share/fonts
#    X11-OTF -> ./X11/OTF
#    X11-TTF -> ./X11/TTF
ln -svfn ./X11/OTF "${TMP_PACKAGE}${FONTS}/X11-OTF"
ln -svfn ./X11/TTF "${TMP_PACKAGE}${FONTS}/X11-TTF"

# сразу создадим эти ссылки в корневой системе
(
    mkdir -p "${FONTS}"
    cd "${FONTS}" || exit 1
    rm -f X11-OTF X11-TTF
    ln -svfn ./X11/OTF X11-OTF
    ln -svfn ./X11/TTF X11-TTF
)

# директория для распаковки исходников
TMP_SRC="${TMP}/src"
mkdir -pv "${TMP_SRC}"

# директория для установки пакетов по отдельности
TMP_PKGS="${TMP}/pkgs"
mkdir -p "${TMP_PKGS}"

# список всех пакетов
PACKAGES="\
font-util
encodings
font-alias
font-adobe-utopia-type1
font-bh-ttf
font-bh-type1
font-ibm-type1
font-misc-ethiopic
font-xfree86-type1
font-adobe-100dpi
font-adobe-75dpi
font-jis-misc
font-daewoo-misc
font-isas-misc
font-misc-misc
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

    chown -R root:root .
    find -L . \
        \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
        -o -perm 511 \) -exec chmod 755 {} \; -o \
        \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
        -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

    # shellcheck disable=SC2086
    ./configure \
        ${XORG_CONFIG} || {
            show_error "'configure' for ${PKGNAME} package"
            exit 1
        }

    # сборка
    make || {
        show_error "'make' for ${PKGNAME} package"
        exit 1
    }

    # директория для установки собранного пакета
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    make install DESTDIR="${PKG_INSTALL_DIR}" || {
        show_error "'make install' for ${PKGNAME} package"
        exit 1
    }

    # удаляем файлы fonts.dir и fonts.scale
    find "${PKG_INSTALL_DIR}${FONTS}" \
        -type f \( -name fonts.dir -o -name fonts.scale \) -delete

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
done

# обновим индексы установленных шрифтов (создадим fonts.dir и fonts.scale в
# каждой директории со шрифтами)
for FONTDIR in "${FONTS}/X11"/*; do
    (
        cd "${FONTDIR}" || exit 1
        # создаем индекс файлов масштабируемых шрифтов
        mkfontscale .
        # создаем индекс файлов шрифтов в каталоге
        mkfontdir .
    )
done

# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cat << EOF > "/var/log/packages/${PRGNAME}-${PKG_VERSION}"
# Package: ${PRGNAME} (Xorg Fonts)
#
# The Xorg font packages provide some scalable fonts and supporting packages
# for Xorg applications.
#
# Home page: https://www.x.org
# Download:  https://www.x.org/archive/individual/font/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_PACKAGE}" "${PRGNAME}-${PKG_VERSION}"

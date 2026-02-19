#! /bin/bash

PRGNAME="plasma-applications"
PKG_VERSION="25.08.0"

### KDE Plasma Applications (Applications for KDE Plasma)
# Коллекция приложений для KDE Plasma

# Required:    kde-frameworks
#              plasma-activities
#              libarchive
#              phonon
#              libxml2
#              xapian
# Recommended: qtwebengine
#              alsa-lib
#              libkexiv2
#              libtiff
#              poppler
#              7zip
#              cpio
#              unrar
#              zip
# Optional:    kio-extras
#              libcanberra
#              pulseaudio
#              qca
#              baloo-widgets        (https://download.kde.org/stable/release-service)
#              packagekit-qt        (https://www.freedesktop.org/software/PackageKit/releases/)
#              discount             (https://www.pell.portland.or.us/~orc/Code/discount/)
#              djvulibre            (https://djvu.sourceforge.net/)
#              libspectre           (https://libspectre.freedesktop.org/)
#              libepub              (https://sourceforge.net/projects/ebook-tools)
#              libzip               (https://libzip.org/)

ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"

source "${ROOT}/check_environment.sh" || exit 1

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

# В итоге дерево сборки выглядит так
# /tmp
#     |
#     build-plasma-x.x.x/           ${TMP}
#         |
#         package-plasma-x.x.x/     ${TMP_PACKAGE}
#         pkgs/                     ${TMP_PKGS}
#         src/                      ${TMP_SRC}

# список всех пакетов
PACKAGES="\
ark
dolphin
dolphin-plugins
kmix
khelpcenter
konsole
okular
libkdcraw
kColorPicker
kImageAnnotator
gwenview
kate
kcalc
kcolorchooser
kcron
kdialog
keditbookmarks
kolourpaint
konqueror
kruler
ksystemlog
kweathercore
kweather
yakuake
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

    if [[ "${PKGNAME}" == "konsole" ]]; then
        patch --verbose -Np1 -i \
            "${SOURCES}/${PKGNAME}-adjust_scrollbar-1.patch" || {
                show_error "applying patch for ${PKGNAME} package"
                exit 1
            }
    fi

    # конфигурация
    mkdir build
    cd build || exit 1

    cmake                                                         \
        -D CMAKE_INSTALL_PREFIX=/usr                              \
        -D CMAKE_BUILD_TYPE=Release                               \
        -D CMAKE_INSTALL_LIBEXECDIR=libexec                       \
        -D FORCE_NOT_REQUIRED_DEPENDENCIES='Discount;EPub;LibZip' \
        -D BUILD_QT5=OFF                                          \
        -D BUILD_WITH_QT6=ON                                      \
        -D BUILD_SHARED_LIBS=ON                                   \
        -D BUILD_TESTING=OFF                                      \
        -D BUILD_KCM_TABLET=OFF                                   \
        -W no-dev .. || {
            show_error "'cmake' for ${PKGNAME} package"
            exit 1
        }

    # сборка
    make || {
        show_error "'make' for ${PKGNAME} package"
        exit 1
    }

    # установка
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    make install DESTDIR="${PKG_INSTALL_DIR}" || {
        show_error "'make install' for ${PKGNAME} package"
        exit 1
    }

    # удалим бесполезные systemd модули и документацию
    rm -rf "${PKG_INSTALL_DIR}/usr/lib/systemd"
    rm -rf "${PKG_INSTALL_DIR}/usr/share/doc"

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
# Package: ${PRGNAME} (Applications for KDE Plasma)
#
# Collection of applications for KDE Plasma
#
# Home page: https://download.kde.org/stable/release-service/
# Download:  https://download.kde.org/stable/release-service/${PKG_VERSION}/src/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_PACKAGE}" "${PRGNAME}-${PKG_VERSION}"

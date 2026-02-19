#! /bin/bash

PRGNAME="kde-frameworks"
PKG_VERSION="6.17.0"

### KDE Frameworks (KDE Frameworks)
# Набор библиотек, основанных на Qt6 и QML

# Required:    extra-cmake-modules
#              breeze-icons
#              docbook-xml
#              docbook-xsl
#              libcanberra
#              libgcrypt
#              libical
#              libxslt
#              lmdb
#              qca
#              libqrencode
#              plasma-wayland-protocols
#              python3-pyyaml
#              shared-mime-info
#              perl-uri
#              wget
# Recommended: aspell
#              avahi
#              modemmanager
#              networkmanager
#              polkit-qt
#              vulkan-loader
#              zxing-cpp
# Optional:    bluez
#              datamatrix                   (https://libdmtx.sourceforge.net/)
#              noto-fonts-ttf               (runtime для FrameworkIntegration)
#              --- документация ---
#              doxygen
#              python3-doxypypy
#              python3-doxyqml
#              python3-requests
#              --- дополнительные форматы изображений для KImageFormats ---
#              libavif
#              libjxl
#              libraw
#              libheif                      (https://github.com/strukturag/libheif)
#              openexr                      (https://github.com/AcademySoftwareFoundation/openexr)
#              --- для KDE Solid ---
#              udisks
#              upower
#              media-player-info            (https://www.freedesktop.org/software/media-player-info/)
#              --- для KWallet ---
#              gpgmepp
#              --- для kcoreaddons ---
#              python3-shiboken6            (https://pypi.org/project/shiboken6/)
#              python3-pyside6              (https://pypi.org/project/PySide6/)
#              --- дополнительные словари для Sonnet ---
#              hspell                       (http://hspell.ivrix.org.il/)
#              hunspell                     (https://hunspell.sourceforge.net/)

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
#     build-kde-frameworks-x.x.x/         ${TMP}
#         |
#         package-kde-frameworks-x.x.x/   ${TMP_PACKAGE}
#         pkgs/                           ${TMP_PKGS}
#         src/                            ${TMP_SRC}

# список всех пакетов
PACKAGES="\
attica
kapidox
karchive
kcodecs
kconfig
kcoreaddons
kdbusaddons
kdnssd
kguiaddons
ki18n
kidletime
kimageformats
kitemmodels
kitemviews
kplotting
kwidgetsaddons
kwindowsystem
networkmanager-qt
solid
sonnet
threadweaver
kauth
kcompletion
kcrash
kdoctools
kpty
kunitconversion
kcolorscheme
kconfigwidgets
kservice
kglobalaccel
kpackage
kdesu
kiconthemes
knotifications
kjobwidgets
ktextwidgets
kxmlgui
kbookmarks
kwallet
kded
kio
kdeclarative
kcmutils
kirigami
syndication
knewstuff
frameworkintegration
kparts
syntax-highlighting
ktexteditor
modemmanager-qt
kcontacts
kpeople
bluez-qt
kfilemetadata
baloo
krunner
prison
qqc2-desktop-style
kholidays
purpose
kcalendarcore
kquickcharts
knotifyconfig
kdav
kstatusnotifieritem
ksvg
ktexttemplate
kuserfeedback
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

    # конфигурация
    # kapidox это python-скрипт
    if [[ "${PKGNAME}" != "kapidox" ]]; then
        mkdir build
        cd build || exit 1

        cmake                                   \
            -D CMAKE_INSTALL_PREFIX=/usr        \
            -D CMAKE_BUILD_TYPE=Release         \
            -D CMAKE_INSTALL_LIBEXECDIR=libexec \
            -D CMAKE_PREFIX_PATH="${QT6DIR}"    \
            -D CMAKE_SKIP_INSTALL_RPATH=ON      \
            -D BUILD_TESTING=OFF                \
            -D BUILD_PYTHON_BINDINGS=OFF        \
            -W no-dev .. || {
                show_error "'cmake' for ${PKGNAME} package"
                exit 1
            }
    fi

    # сборка
    if [[ "${PKGNAME}" == "kapidox" ]]; then
        pip3 wheel               \
            -w dist              \
            --no-build-isolation \
            --no-deps            \
            --no-cache-dir       \
            "${PWD}" || {
                show_error "'pip3 wheel' for ${PKGNAME} package"
                exit 1
            }
    else
        make || {
            show_error "'make' for ${PKGNAME} package"
            exit 1
        }
    fi

    # установка
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    if [[ "${PKGNAME}" == "kapidox" ]]; then
        pip3 install                    \
            --root="${PKG_INSTALL_DIR}" \
            --no-index                  \
            --find-links dist           \
            --no-user                   \
            "${PKGNAME}" || {
                show_error "'pip3 install' for ${PKGNAME} package"
                exit 1
            }
    else
        make install DESTDIR="${PKG_INSTALL_DIR}" || {
            show_error "'make install' for ${PKGNAME} package"
            exit 1
        }
    fi

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
# Package: ${PRGNAME} (KDE Frameworks)
#
# KDE Frameworks is a collection of libraries based on top of Qt6 and QML
# derived from the previous KDE libraries. They can be used independent of the
# KDE Display Environment (Plasma 6)
#
# Home page: https://kde.org/
# Download:  https://download.kde.org/stable/frameworks/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_PACKAGE}" "${PRGNAME}-${PKG_VERSION}"

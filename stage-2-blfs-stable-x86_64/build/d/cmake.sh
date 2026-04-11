#! /bin/bash

PRGNAME="cmake"

### CMake (cross-platform, open-source make system)
# Умный помощник для сборки сложных программ (система сборки). Он сам
# проверяет, какие библиотеки установлены в системе, подготавливает проект к
# правильной компиляции, создает Makefile.

# Required:    no
# Recommended: curl
#              libarchive
#              libuv
#              nghttp2
# Optional:    gcc                  (для gfortran)
#              --- для тестов ---
#              git
#              mercurial
#              openjdk
#              qt6                  (для сборки Qt-based GUI)
#              python3-sphinx       (для сборки документации) https://pypi.org/project/Sphinx/
#              subversion
#              cppdap               (https://github.com/google/cppdap/)
#              jsoncpp              (https://github.com/open-source-parsers/jsoncpp/)
#              rhash                (https://rhash.sourceforge.io/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# запрещаем приложениям, использующим cmake при сборке устанавливать файлы в
# /usr/lib64/
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake || exit 1

# заставляет систему сборки связываться с установленной в системе версией для
# всех необходимых библиотек (zlib, bzip2, curl, expat, libarchive и т.д.),
# кроме тех, которые явно указаны с помощью опции --no-system-*
#    --system-libs
# использовать внутренние версии библиотек JSON-C++, cppdap и rhash вместо
# системных
#    --no-system-jsoncpp
#    --no-system-cppdap
#    --no-system-librhash
./bootstrap              \
    --prefix=/usr        \
    --system-libs        \
    --mandir=/share/man  \
    --no-system-jsoncpp  \
    --no-system-cppdap   \
    --no-system-librhash \
    --no-qt-gui          \
    --docdir="/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты
# NUMJOBS="$(nproc)"
# LC_ALL=en_US.UTF-8 && \
#     bin/ctest -j"${NUMJOBS}" -O "${PRGNAME}-${VERSION}-test.log"

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (cross-platform, open-source make system)
#
# The CMake package contains a modern toolset used for generating Makefiles. It
# is a successor of the auto-generated configure script and aims to be
# platform- and compiler-independent. CMake generates native makefiles and
# workspaces that can be used in the compiler environment of your choice.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/files/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

#! /bin/bash

PRGNAME="dtc"

### dtc (Device Tree Compiler for Flat Device Trees)
# Компилятор дерева устройств, который переводит понятные человеку описания
# электроники в двоичный код для ядра операционной системы. Необходим для
# правильной настройки аппаратной части компьютера.

# Required:    no
# Recommended: no
# Optional:    libyaml
#              --- для сборки Python3 модуля ---
#              python3-meson
#              swig

### NOTE:
# Пакет dtc >>> УДАЛИТЬ <<< из системы перед обновлением/переустановкой.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# Предотвращаем создание Python3 модуля с помощью устаревшего метода setup.py
# (далее мы создадим модуль с помощью pip3 wheel).
#    -D python=disabled
meson setup ..                \
    --prefix=/usr             \
    --buildtype=release       \
    -D default_library=shared \
    -D python=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Сразу устанавливаем в систему для дальнейшей сборки Python3 модуля.
source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# Если установлен python3-meson и swig соберем Python3 модуль.
if command -v swig &>/dev/null; then
    # Исправим код для совместимости с SWIG 4.5.x
    sed -e 's/PyString_FromString/PyUnicode_FromString/' \
        -e 's/PyString_AsString/PyBytes_AsString/'       \
        -e 's/PyInt_AsLong/PyLong_AsLong/'               \
        -i ../pylibfdt/libfdt.i || exit 1

    pip3 wheel               \
        -w dist              \
        --no-build-isolation \
        --no-deps            \
        --no-cache-dir       \
        ..

    pip3 install            \
        --root="${TMP_DIR}" \
        --no-index          \
        --find-links dist   \
        --no-user           \
        libfdt

    rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

    # Если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
    # перемещаем ее в ${TMP_DIR}/usr/
    PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
    TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
    [ -d "${TMP_SITE_PACKAGES}/bin" ] && \
        mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

    # Удаляем все скомпилированные байт-коды.
    rm -rf "${TMP_DIR}/usr/bin/__pycache__"
    rm -rf "${TMP_SITE_PACKAGES}/__pycache__"

    source "${ROOT}/stripping.sh"      || exit 1
    source "${ROOT}/update-info-db.sh" || exit 1
    source "${ROOT}/clean-locales.sh"  || exit 1
    /bin/cp -vpR "${TMP_DIR}"/* /
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Device Tree Compiler for Flat Device Trees)
#
# Device Tree Compiler, dtc, takes as input a device-tree in a given format and
# outputs a device-tree in another format for booting kernels on embedded
# systems, transforms a textual description of a device tree (DTS) into a
# binary object (DTB).
#
# Home page: https://git.kernel.org/cgit/utils/${PRGNAME}/${PRGNAME}.git
# Download:  https://github.com/dgibson/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

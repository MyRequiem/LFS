#! /bin/bash

PRGNAME="libusb"

### libusb (USB library)
# Библиотека, используемая некоторыми приложениями для доступа к USB
# устройствам.

# Required:    no
# Recommended: no
# Optional:    doxygen (для создания документации)

### Конфигурация ядра
#    CONFIG_USB_SUPPORT=y
#    CONFIG_USB=m|y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1

# если doxygen установлен, то собираем документацию
DOXYGEN=""
# command -v doxygen &>/dev/null && DOXYGEN="true"

if [ -n "${DOXYGEN}" ]; then
    # предотвращаем появление некоторых предупреждений при создании документации
    sed -i "s/^TCL_SUBST/#&/; s/wide//" doc/doxygen.cfg || exit 1
    make -C doc docs
fi

# пакет не имеет набора тестов

make install DESTDIR="${TMP_DIR}"

if [ -n "${DOXYGEN}" ]; then
    API_DOCS="/usr/share/doc/${PRGNAME}-${VERSION}/apidocs"
    install -v -d -m755 "${TMP_DIR}${API_DOCS}"
    install -v -m644 doc/html/* "${TMP_DIR}${API_DOCS}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (USB library)
#
# The libusb package contains a library used by some applications for USB
# device access.
#
# Home page: http://libusb.info
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

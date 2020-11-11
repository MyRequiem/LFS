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

# убираем предупреждение при сборке документации
sed -i "s/^PROJECT_LOGO/#&/" doc/doxygen.cfg.in || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

# пакет не поддерживаем сборки в несколько потоков, поэтому явно указываем -j1
make -j1 || exit 1

# если doxygen установлен, то собираем документацию
DOXYGEN=""
command -v doxygen &>/dev/null && DOXYGEN="true"
[ -n "${DOXYGEN}" ] && make -C doc docs

# пакет не имеет набора тестов

make install DESTDIR="${TMP_DIR}"

if [ -n "${DOXYGEN}" ]; then
    DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -d -m755 "${TMP_DIR}${DOCS}/apidocs"
    install -v -m644 doc/html/* "${TMP_DIR}${DOCS}/apidocs"
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

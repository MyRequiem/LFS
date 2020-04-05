#! /bin/bash

PRGNAME="libqmi"

### libqmi (Qualcomm MSM Interface (QMI) library and utils)
# Основанная на glib библиотека для общения с модемами и устройствами WWAN,
# которые передают данные по протоколу Qualcomm MSM Interface (QMI)

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libqmi.html

# Home page: https://www.freedesktop.org/wiki/Software/libqmi/
# Download:  https://www.freedesktop.org/software/libqmi/libqmi-1.22.4.tar.xz

# Required:    glib
# Recommended: libmbim
# Optional:    gtk-doc
#              help2man

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

# исправим ошибку сборки путем удаления директивы -Werror из переменной CFLAGS,
# которая говорит компилятору о том, что все предупреждения будут считаться
# ошибкой
# error: Deprecated pre-processor symbol, replace with  [-Werror]
#                                QmiDevicePrivate);
#                     ^          ~~~~~~~~~~~~~~
sed -i "s, -Werror,," src/libqmi-glib/Makefile         || exit 1
sed -i "s, -Werror,," src/qmi-firmware-update/Makefile || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Qualcomm MSM Interface (QMI) library and utils)
#
# libqmi is a glib-based library for talking to WWAN modems and devices which
# speak the Qualcomm MSM Interface (QMI) protocol
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

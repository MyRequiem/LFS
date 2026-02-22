#! /bin/bash

PRGNAME="libgtop"

### libgtop (a top-like library)
# Библиотека для получения информации о работающей системе, такой как загрузка
# процессора, использование памяти и сведения о запущенных процессах. Она
# используется в приложениях для мониторинга, таких как апплеты системного
# монитора в GNOME, но может применяться и как самостоятельная библиотека,
# поскольку ее основной интерфейс независим от среды рабочего стола. Информация
# берется непосредственно из файловой системы /proc

# Required:    glib
#              xorg-libraries
# Recommended: no
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a top-like library)
#
# libgtop is a shared library that provides system-monitoring data, such as CPU
# and memory usage, and information about running processes. It is used by
# applications, particularly within the GNOME desktop environment, to abstract
# the system-specific details of gathering this information, making it easier
# for developers to create monitoring tools like the system monitor applet. The
# information is taken directly from the /proc filesystem
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

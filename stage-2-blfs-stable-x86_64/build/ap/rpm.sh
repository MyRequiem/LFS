#! /bin/bash

PRGNAME="rpm"

### rpm (RPM package format tool)
# Инструмент от Red Hat Software, используемый для установки и удаления пакетов
# в формате .rpm

# Required:    nss
#              nspr
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

# удалим пакет, если установлен
if command -v rpm &>/dev/null; then
    echo "RPM detected."
    echo ""
    echo "The rpm package needs to be removed before building to ensure that"
    echo "the binaries do not link to earlier library versions."
    echo ""
    echo "Removing the rpm package and then continuing with the build."
    echo ""

    /sbin/removepkg "$(find /var/log/packages/ -type f -name "${PRGNAME}-*")"
    sleep 3
fi

source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
VAR_LIB_RPM_TMP="/var/lib/rpm/tmp"
mkdir -pv "${TMP_DIR}"{/bin,"${VAR_LIB_RPM_TMP}"}

autoreconf -vif || exit 1

# сообщаем скрипту 'configure' где найти NSS и NSPR
#    -I/usr/include/nss
#    -I/usr/include/nspr
#
#    --enable-sqlite требует '-ldl' в LDFLAGS
CFLAGS="-O2 -fPIC $(pkg-config --cflags nspr nss)" \
LDFLAGS="-ldl"        \
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --enable-python   \
    --without-selinux \
    --localstatedir=/var || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cd python || exit 1
    # python2 исключен как устаревший
    python3 setup.py install --root="${TMP_DIR}" || exit 1
cd - || exit 1

# раньше rpm был в /bin, поэтому создадим ссылку
#    /bin/rpm -> ../usr/bin/rpm
(
    cd "${TMP_DIR}/bin" || exit 1
    ln -s "../usr/bin/${PRGNAME}" "${PRGNAME}"
)

# удалим /var/tmp
(
    cd "${TMP_DIR}/var" || exit 1
    rm -rf tmp
)

# инициализируем фиктивную базу данных пакетов
zcat "${SOURCES}/Packages.gz" > "${TMP_DIR}${VAR_LIB_RPM_TMP}/Packages"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RPM package format tool)
#
# RPM is a tool from Red Hat Software used to install and remove packages in
# the .rpm format.
#
# Home page: http://ftp.${PRGNAME}.org
# Download:  http://ftp.${PRGNAME}.org/releases/${PRGNAME}-${MAJ_VERSION}.x/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

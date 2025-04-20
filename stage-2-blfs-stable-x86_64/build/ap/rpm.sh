#! /bin/bash

PRGNAME="rpm"

### rpm (RPM package format tool)
# Инструмент от программного обеспечения Red Hat, используемого для установки и
# удаления пакетов в формате .rpm

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -vif || exit 1
./configure               \
    --prefix=/usr         \
    --localstatedir=/var  \
    --sysconfdir=/etc     \
    --enable-python       \
    --with-external-db    \
    --enable-broken-chown \
    --disable-bdb         \
    --without-hackingdocs \
    --without-selinux     \
    --without-lua         \
    --without-dmalloc     \
    --enable-sqlite3 || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cd python || exit 1
python3 setup.py install --root="${TMP_DIR}" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RPM package format tool)
#
# RPM is a tool from Red Hat Software used to install and remove packages in
# the .rpm format. When installing RPM packages on Slackware, you may need to
# use the --nodeps and --force options. Before installing any binary package,
# it's wise to examine it to see what it's going to do, and if it will
# overwrite any files. You can use rpm2tgz to convert .rpm packages to .tgz
# packages so you can look them over.
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

#! /bin/bash

PRGNAME="sassc"

### SassC (Sass CSS preprocessor)
# Sass - язык препроцессора CSS, позволяющий добавлять новые возможности CSS.
# SassC - командная оболочка для библиотеки libsass

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сначала соберем библиотеку libsass
tar -xf ${SOURCES}/libsass-*.tar.gz || exit 1
cd libsass-* || exit 1

autoreconf -fi &&
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
# установим в ${TMP_DIR} и сразу в систему
make install DESTDIR="${TMP_DIR}"
make install

cd .. || exit 1

autoreconf -fi &&
./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Sass CSS preprocessor)
#
# SassC is a wrapper around libsass used to generate a useful command- line
# Sass implementation. Sass is a CSS pre-processor language to add on exciting
# new features to CSS
#
# Home page: https://github.com/sass/libsass
# Download:  https://github.com/sass/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

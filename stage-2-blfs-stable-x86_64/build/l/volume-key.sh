#! /bin/bash

PRGNAME="volume-key"
ARCH_NAME="volume_key"

### volume_key (manipulating storage volume encryption keys)
# Библиотека для управления ключами шифрования томов хранилища и их хранения
# отдельно от зашифрованных томов. Основная цель - восстановление доступа к
# зашифрованному жесткому диску, если пользователь забыл пароль, ключ был
# утерян и т.д. Резервное копирование ключа шифрования также может быть полезно
# для извлечения данных после аппаратного или программного сбоя, который может
# повредить заголовок зашифрованного тома.

# Require:     cryptsetup
#              glib
#              gpgme
#              nss
# Recommended: swig
# Optional:    python2 (для сборки Python 2 bindings, но для этого требуется swig)
#              python3 (для сборки Python 3 bindings, но для этого требуется swig)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PYTHON2="--without-python"
PYTHON3="--without-python3"

if command -v swig &>/dev/null; then
    command -v python2 &>/dev/null && PYTHON2="--with-python"
    command -v python3 &>/dev/null && PYTHON3="--with-python3"
fi

autoreconf -fiv   &&
./configure       \
    --prefix=/usr \
    "${PYTHON2}"  \
    "${PYTHON3}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (manipulating storage volume encryption keys)
#
# The volume_key package provides a library for manipulating storage volume
# encryption keys and storing them separately from volumes to handle forgotten
# passphrases.
#
# Home page: https://github.com/felixonmars/${ARCH_NAME}/
# Download:  https://github.com/felixonmars/${ARCH_NAME}/archive/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

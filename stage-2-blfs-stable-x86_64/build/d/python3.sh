#! /bin/bash

PRGNAME="python3"
ARCH_NAME="Python"

### Python3 (object-oriented interpreted programming language)
# Язык программирования Python3

# Required:    no
# Recommended: sqlite      (для создания дополнительных модулей и сборки firefox или thunderbird)
# Optional:    bluez
#              gdb         (для некоторых тестов)
#              valgrind
#              libmpdec    (http://www.bytereef.org/mpdecimal/)
#              --- для создания дополнительных модулей ---
#              libnsl
#              tk
#              berkeley-db (https://www.oracle.com/database/technologies/related/berkeleydb.html)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

INSTALLED="$(find /var/log/packages/ -type f -name "python3-3.*")"
if [ -n "${INSTALLED}" ]; then
    INSTALLED_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${INSTALLED_VERSION} already installed. Before building Python3 "
    echo "package, you need to remove it."
    removepkg --no-color "${INSTALLED}"
fi

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALGRIND="--without-valgrind"
SQLITE="--disable-loadable-sqlite-extensions"
LIBMPDEC="--without-system-libmpdec"

command -v valgrind &>/dev/null && VALGRIND="--with-valgrind"
command -v sqlite3  &>/dev/null && SQLITE="--enable-loadable-sqlite-extensions"
[ -x /usr/lib/libmpdec.so ]     && LIBMPDEC="--with-system-libmpdec"

# избегаем назойливых сообщений во время конфигурации
#    CXX="/usr/bin/g++"
CXX="/usr/bin/g++"      \
./configure             \
    --prefix=/usr       \
    --enable-shared     \
    --with-system-expat \
    --with-system-ffi   \
    "${VALGRIND}"       \
    "${LIBMPDEC}"       \
    "${SQLITE}"         \
    --enable-optimization || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
# pip3 и pip${MAJ_VERSION} одинаковые скрипты, создадим ссылку
#    pip3 -> pip${MAJ_VERSION}
ln -sfv "pip${MAJ_VERSION}" "${TMP_DIR}/usr/bin/pip3"

# исправим shebang в скрипте pip${MAJ_VERSION}
#    #!/usr/bin/python -> #!/usr/bin/python3
sed 's/\/usr\/bin\/python$/\/usr\/bin\/python3/' \
    -i "${TMP_DIR}/usr/bin/pip${MAJ_VERSION}" || exit 1

# устанавливаем документацию
DOCS="${TMP_DIR}/usr/share/doc/python-${VERSION}/html"
install -v -dm755 "${DOCS}"
tar                       \
    --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C "${DOCS}"          \
    -xvf "${SOURCES}/python-${VERSION}-docs-html.tar.bz2" || exit 1

# чтобы python3 мог найти установленную документацию, создадим не зависимую от
# версии Python3 ссылку в /usr/share/doc/
#    python-3 -> python3-${VERSION}
ln -svfn "python-${VERSION}" "${TMP_DIR}/usr/share/doc/python-3"

# добавим переменную окружения PYTHONDOCS содержащую путь к документации
# Python3
PROFILE_D="/etc/profile.d"
install -v -dm755 "${TMP_DIR}${PROFILE_D}"
PYTHON3_PYTHONDOCS_SH="${PROFILE_D}/python3-pythondocs.sh"
cat << EOF > "${TMP_DIR}${PYTHON3_PYTHONDOCS_SH}"
#! /bin/bash

# Begin ${PYTHON3_PYTHONDOCS_SH}

export PYTHONDOCS=/usr/share/doc/python-3/html

# End ${PYTHON3_PYTHONDOCS_SH}
EOF
chmod 755 "${TMP_DIR}${PYTHON3_PYTHONDOCS_SH}"

# make-ca уже установлен, и корневые системные сертификаты обновлены командой
#    # update-ca-certificates
# добавим переменную окружения _PIP_STANDALONE_CERT содержащую путь к системным
# сертификатам, которые будет использовать 'pip' (по умолчанию он устанавливает
# собственные сертификаты)
PYTHON3_CERTS_SH="${PROFILE_D}/python3-certs.sh"
cat << EOF > "${TMP_DIR}${PYTHON3_CERTS_SH}"
#! /bin/bash

# Begin ${PYTHON3_CERTS_SH}

export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt

# End ${PYTHON3_CERTS_SH}
EOF
chmod 755 "${TMP_DIR}${PYTHON3_CERTS_SH}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (object-oriented interpreted programming language)
#
# Python is an interpreted, interactive, object-oriented programming language
# that combines remarkable power with very clear syntax. Python's basic power
# can be extended with your own modules written in C or C++. Python is also
# adaptable as an extension language for existing applications.
#
# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

#! /bin/bash

PRGNAME="python3"
ARCH_NAME="Python"

### Python3 (object-oriented interpreted programming language)
# Язык программирования Python3

# Required:    no
# Recommended: no
# Optional:    bluez
#              gdb              (для некоторых тестов)
#              valgrind
#              libmpdec         (http://www.bytereef.org/mpdecimal/)
#              --- для создания дополнительных модулей ---
#              libnsl
#              tk
#              berkeley-db      (https://www.oracle.com/database/technologies/related/berkeleydb.html)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                   || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

INSTALLED="$(find /var/log/packages/ -type f -name "${PRGNAME}-3.*")"
if [ -n "${INSTALLED}" ]; then
    PKGNAME_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${PKGNAME_VERSION} already installed."
    echo "Before building ${PRGNAME} package, you need to remove it."
    echo "Wait 10 seconds before deleting or press <Ctrl-C> to exit."
    sleep 10
    yes | removepkg --backup "${INSTALLED}"
fi

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

./configure                \
    --prefix=/usr          \
    --enable-shared        \
    --with-system-expat    \
    --enable-optimizations \
    --without-static-libpython || exit 1

make || exit 1
# make test TESTOPTS="--timeout 120"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "${TMP_DIR}/etc/pip.conf"
[global]
# do not display warnings when running from root
root-user-action = ignore
# do not display warnings about the presence of a newer pip3 version
disable-pip-version-check = true
EOF

# устанавливаем документацию
DOCS="${TMP_DIR}/usr/share/doc/python-${VERSION}/html"
install -v -dm755 "${DOCS}"
tar                       \
    --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C "${DOCS}"          \
    -xvf "${SOURCES}/python-${VERSION}-docs-html.tar.bz2" || exit 1

# чтобы python3 мог найти установленную документацию, создадим независимую от
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

export PYTHONDOCS=/usr/share/doc/python-3/html
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

export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt
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

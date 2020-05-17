#! /bin/bash

PRGNAME="python3"

### python3 (object-oriented interpreted programming language)
# Язык программирования Python 3

# http://www.linuxfromscratch.org/blfs/view/stable/general/python3.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tar.xz
# Docs:      https://www.python.org/ftp/python/doc/3.8.3/python-3.8.3-docs-html.tar.bz2

# Required: no
# Optional: bluez
#           gdb         (для некоторых тестов)
#           valgrind
#           berkeley-db (для создания дополнительных модулей)
#           sqlite      (для создания дополнительных модулей)
#           tk          (для создания дополнительных модулей)
#           libmpdec    (http://www.bytereef.org/mpdecimal/)

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

INSTALLED="$(find /var/log/packages/ -type f -name "python3-3.*")"
if [ -n "${INSTALLED}" ]; then
    INSTALLED_VERSION="$(echo "${INSTALLED}" | rev | cut -d / -f 1 | rev)"
    echo "${INSTALLED_VERSION} already installed. Before building Python3 "
    echo "package, you need to remove it."
    removepkg --no-color "${INSTALLED}"
fi

source "${ROOT}/unpack_source_archive.sh" "Python" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VALGRIND="--without-valgrind"
SQLITE="--disable-loadable-sqlite-extensions"
LIBMPDEC="--without-system-libmpdec"

command -v valgrind &>/dev/null && VALGRIND="--with-valgrind"
command -v sqlite3  &>/dev/null && SQLITE="--enable-loadable-sqlite-extensions"
[ -x /usr/lib/libmpdec.so ] && LIBMPDEC="--with-system-libmpdec"

# избегаем назойливых сообщений во время конфигурации
#    CXX="/usr/bin/g++"
# связываться с уже установленной системной версией Expat
#    --with-system-expat
# связываться с уже установленной системной версией libffi
#    --with-system-ffi
# создавать утилиты pip и setuptools
#    --with-ensurepip=yes
CXX="/usr/bin/g++"      \
./configure             \
    --prefix=/usr       \
    --enable-shared     \
    --with-system-expat \
    --with-system-ffi   \
    "${VALGRIND}"       \
    "${LIBMPDEC}"       \
    "${SQLITE}"         \
    --with-ensurepip=yes || exit 1

make || exit 1

# тесты на данном этапе не запускаем, т.к. они требуют установленных TK и
# X Window System, поэтому сразу устанавливаем
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython${MAJ_VERSION}.so"
chmod -v 755 "${TMP_DIR}/usr/lib/libpython3.so"

# ссылки в /usr/bin
# pip3          -> pip${MAJ_VERSION}
# easy_install3 -> easy_install-${MAJ_VERSION}
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv "pip${MAJ_VERSION}" pip3
    ln -sfv "easy_install-${MAJ_VERSION}" easy_install3
)

# устанавливаем документацию
DOCS="${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}/html"
install -v -dm755 "${DOCS}"
tar                       \
    --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C "${DOCS}"          \
    -xvf "${SOURCES}/python-${VERSION}-docs-html.tar.bz2"

# чтобы python3 мог найти установленную документацию, создадим не зависимую от
# версии Python3 ссылку в /usr/share/doc/
#    python-3 -> python3-${VERSION}
(
    cd "${TMP_DIR}/usr/share/doc/" || exit 1
    ln -svfn "${PRGNAME}-${VERSION}" python-3
)

# добавим переменную окружения PYTHONDOCS в профиль системы
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

# устанавливаем пакет в корень файловой системы
cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (object-oriented interpreted programming language)
#
# Python is an interpreted, interactive, object-oriented programming language
# that combines remarkable power with very clear syntax. Python's basic power
# can be extended with your own modules written in C or C++. Python is also
# adaptable as an extension language for existing applications.
#
# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

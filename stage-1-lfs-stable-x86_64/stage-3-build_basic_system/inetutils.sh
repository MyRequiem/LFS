#! /bin/bash

PRGNAME="inetutils"

### Inetutils (programs for basic networking)
# Пакет содержит базовые сетевые утилиты

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/usr/sbin"

# по умолчанию пакет устанавливает демон сетевого журнала, которые ведет
# логирование. Мы не будем его устанавливать, т.к. пакет Util-Linux содержит
# более продвинутую версию
#    --disable-logger
# НЕ собирать утилиту 'whois', которая считается устаревшей. В BLFS описана
# более лучшая альтернатива данной утилите.
#    --disable-whois
# эти параметры отключают сборку устаревших программ, которые не должны
# использоваться из-за проблем безопасности. Функции, предоставляемые этими
# программами полностью заменяет пакет openssh из BLFS
#    --disable-rcp
#    --disable-rexec
#    --disable-rlogin
#    --disable-rsh
# отключаем установку различных сетевых серверов. Эти серверы считаются
# неподходящими для базовой LFS системы. Некоторые из них небезопасны по своей
# природе и считаются безопасными только в доверенных сетях. Для этих серверов
# существуют более лучшие и безопасные альтернативы
#    --disable-servers
./configure              \
    --prefix=/usr        \
    --bindir=/usr/bin    \
    --localstatedir=/var \
    --disable-logger     \
    --disable-whois      \
    --disable-rcp        \
    --disable-rexec      \
    --disable-rlogin     \
    --disable-rsh        \
    --disable-telnet     \
    --disable-servers || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# переместим утилиту 'ifconfig' из /usr/bin в /usr/sbin
mv -v "${TMP_DIR}/usr"/{,s}bin/ifconfig

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

# добавим suid-бит утилите ping для ее запуска от обычного пользователя
chmod 4755 /usr/bin/ping

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (programs for basic networking)
#
# Inetutils is a collection of common network programs. It includes:
# dnsdomainname, ftp, hostname, ifconfig, ping, ping6, talk, telnet, tftp,
# traceroute
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

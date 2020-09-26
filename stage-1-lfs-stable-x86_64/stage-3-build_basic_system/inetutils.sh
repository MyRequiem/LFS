#! /bin/bash

PRGNAME="inetutils"

### Inetutils (programs for basic networking)
# Пакет содержит базовые сетевые утилиты

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/inetutils.html

# Home page: http://www.gnu.org/software/inetutils/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{bin,sbin}

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
    --localstatedir=/var \
    --disable-logger     \
    --disable-whois      \
    --disable-rcp        \
    --disable-rexec      \
    --disable-rlogin     \
    --disable-rsh        \
    --disable-servers || exit 1

make || make -j1 || exit 1

# тест libls.sh может потерпеть неудачу в текущей среде chroot, но нормально
# проходит после завершения создания LFS и ее чистой загрузки. Тест
# ping-localhost.sh потерпит неудачу, если в ядре хост-системы не включена
# поддержка IPv6 протокола
# make check

make install DESTDIR="${TMP_DIR}"

# переместим некоторые утилиты из /usr/bin в /bin и /sbin
mv -v "${TMP_DIR}/usr/bin"/{hostname,ping,ping6,traceroute} "${TMP_DIR}/bin"
mv -v "${TMP_DIR}/usr/bin/ifconfig"                         "${TMP_DIR}/sbin"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (programs for basic networking)
#
# Inetutils is a collection of common network programs. It includes:
# dnsdomainname, ftp, hostname, ifconfig, ping, ping6, talk, telnet, tftp,
# traceroute
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

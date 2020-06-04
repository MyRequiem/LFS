#! /bin/bash

PRGNAME="perl"

### Perl (Practical Extraction and Report Language)
# Язык программирования Perl

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/perl.html

# Home page: https://www.perl.org/
# Download:  https://www.cpan.org/src/5.0/perl-5.30.3.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

# файл /etc/hosts необходим для правильной ссылки в одном из файлов
# конфигурации Perl, а также для дополнительного набора тестов. Создадим его,
# если не существует
HOSTS="/etc/hosts"
if ! [ -f "${HOSTS}" ]; then
    echo "127.0.0.1 localhost $(hostname)" > "${HOSTS}"
fi

# данная версия Perl создает модули Compress::Raw::Zlib и Compress::Raw::BZip2
# По умолчанию Perl будет использовать внутреннюю копию этих модулей для
# сборки. Попросим сборку Perl использовать библиотеки, которые уже установлены
# в системе
export BUILD_ZLIB=False
export BUILD_BZIP2=0

# -des - это сочетание трех параметров:
#     -d    - использовать значения по умолчанию для всех элементов
#     -e    - обеспечивает выполнение всех заданий
#     -s    - заставляет "замолчать" несущественный вывод
# путь для установки модулей Perl
#    -Dvendorprefix=/usr
# используем 'less' вместо 'more'
#    -Dpager="/usr/bin/less -isR"
# поскольку Groff еще не установлен, Configure считает, что мы не хотим
# устанавливать man-страницы. Отменим его решение и укажем явно пути для
# man-страниц
#    -Dman1dir=/usr/share/man/man1
#    -Dman3dir=/usr/share/man/man3
# создадим общий libperl, необходимый для некоторых модулей perl
#    -Duseshrplib
# сборка Perl с поддержкой потоков
#    -Dusethreads
sh Configure                      \
    -des                          \
    -Dprefix=/usr                 \
    -Dvendorprefix=/usr           \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/usr/bin/less -isR"  \
    -Duseshrplib                  \
    -Dusethreads || exit 1

make || exit 1
make test
make install
make install DESTDIR="${TMP_DIR}"

unset BUILD_ZLIB BUILD_BZIP2

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Practical Extraction and Report Language)
#
# Larry Wall's "Practical Extraction and Report Language". Perl is a language
# optimized for scanning arbitrary text files, extracting information from
# those text files, and printing reports based on that information. It's also a
# good language for many system management tasks. The language is intended to
# be practical (easy to use, efficient, complete) rather than beautiful (tiny,
# elegant, minimal).
#
# Home page: https://www.perl.org/
# Download:  https://www.cpan.org/src/5.0/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

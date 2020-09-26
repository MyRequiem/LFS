#! /bin/bash

PRGNAME="perl"

### Perl (Practical Extraction and Report Language)
# Язык программирования Perl

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/perl.html

# Home page: https://www.perl.org/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

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
# поскольку Groff еще не установлен, Configure считает, что мы не хотим
# устанавливать man-страницы. Отменим его решение и укажем явно пути для
# где Perl ищет установленные модули
#    -Dsitelib,-Dprivlib,-Darchlib, ...
# man-страниц
#    -Dman1dir=/usr/share/man/man1
#    -Dman3dir=/usr/share/man/man3
# используем 'less' вместо 'more'
#    -Dpager="/usr/bin/less -isR"
# создадим общий libperl, необходимый для некоторых модулей perl
#    -Duseshrplib
# сборка Perl с поддержкой потоков
#    -Dusethreads
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1,2)"
sh Configure                                             \
    -des                                                 \
    -Dprefix=/usr                                        \
    -Dvendorprefix=/usr                                  \
    -Dprivlib="/usr/lib/perl5/${MAJ_VER}/core_perl"      \
    -Darchlib="/usr/lib/perl5/${MAJ_VER}/core_perl"      \
    -Dsitelib="/usr/lib/perl5/${MAJ_VER}/site_perl"      \
    -Dsitearch="/usr/lib/perl5/${MAJ_VER}/site_perl"     \
    -Dvendorlib="/usr/lib/perl5/${MAJ_VER}/vendor_perl"  \
    -Dvendorarch="/usr/lib/perl5/${MAJ_VER}/vendor_perl" \
    -Dman1dir=/usr/share/man/man1                        \
    -Dman3dir=/usr/share/man/man3                        \
    -Dpager="/usr/bin/less -isR"                         \
    -Duseshrplib                                         \
    -Dusethreads || exit 1

make || make -j1 || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

unset BUILD_ZLIB BUILD_BZIP2

/bin/cp -vR "${TMP_DIR}"/* /

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

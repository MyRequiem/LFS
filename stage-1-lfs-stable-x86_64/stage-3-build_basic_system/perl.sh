#! /bin/bash

PRGNAME="perl"

### Perl (Practical Extraction and Report Language)
# Язык программирования Perl

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
#    -D man1dir=/usr/share/man/man1
#    -D man3dir=/usr/share/man/man3
# используем 'less' вместо 'more'
#    -D pager="/usr/bin/less -isR"
# создадим общий libperl, необходимый для некоторых модулей perl
#    -D useshrplib
# сборка Perl с поддержкой потоков
#    -Dusethreads
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1,2)"
sh Configure                                             \
    -des                                                 \
    -D prefix=/usr                                        \
    -D vendorprefix=/usr                                  \
    -D privlib="/usr/lib/perl5/${MAJ_VER}/core_perl"      \
    -D archlib="/usr/lib/perl5/${MAJ_VER}/core_perl"      \
    -D sitelib="/usr/lib/perl5/${MAJ_VER}/site_perl"      \
    -D sitearch="/usr/lib/perl5/${MAJ_VER}/site_perl"     \
    -D vendorlib="/usr/lib/perl5/${MAJ_VER}/vendor_perl"  \
    -D vendorarch="/usr/lib/perl5/${MAJ_VER}/vendor_perl" \
    -D man1dir=/usr/share/man/man1                        \
    -D man3dir=/usr/share/man/man3                        \
    -D pager="/usr/bin/less -isR"                         \
    -D useshrplib                                         \
    -D usethreads || exit 1

make || make -j1 || exit 1
# TEST_JOBS=$(nproc) make test_harness
make install DESTDIR="${TMP_DIR}"

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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

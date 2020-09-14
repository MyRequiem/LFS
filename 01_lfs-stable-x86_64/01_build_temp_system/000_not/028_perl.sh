#! /bin/bash

PRGNAME="perl"

### Perl
# Practical Extraction and Report Language

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/perl.html

# Home page: https://www.perl.org/
# Download:  https://www.cpan.org/src/5.0/perl-5.30.1.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# -des - это сочетание трех параметров:
#     -d    - использовать значения по умолчанию для всех элементов
#     -e    - обеспечивает выполнение всех заданий
#     -s    - заставляет "замолчать" несущественный вывод
# эти записи определяют неопределенные переменные, которые заставляют
# при конфигурации искать локально установленные компоненты, которые могут
# существовать в хост-системе
#    -Uloclibpth
#    -Ulocincpth
sh Configure             \
    -des -Dprefix=/tools \
    -Dlibs=-lm           \
    -Uloclibpth          \
    -Ulocincpth || exit 1

make || make -j1 || exit 1

# Perl поставляется с набором тестов, но для временной версии их выполнять не
# будем. На данный момент необходимо установить только несколько утилит и
# библиотек:
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
PERL_LIBS="/tools/lib/perl5/${VERSION}"
mkdir -pv    "${PERL_LIBS}"
cp -Rv lib/* "${PERL_LIBS}"

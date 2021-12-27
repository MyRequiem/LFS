#! /bin/bash

PRGNAME="perl-net-ssleay"
ARCH_NAME="Net-SSLeay"

### Net::SSLeay (Perl extension for using OpenSSL)
# Net::SSLeay Perl модуль

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# в процессе сборки задается вопрос: хотите ли вы запустить внешние тесты,
# которые завершатся ошибкой, если у вас нет подключения к сети (значение по
# умолчанию - 'n'). С помощью инструкции [yes ''] пропускаем эти тесты
yes '' | perl Makefile.PL || exit 1
make                      || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# исправим пути (убираем из путей временную директорию установки пакета)
PERL_MAJ_VER="$(perl -v | /bin/grep version | cut -d \( -f 2 | cut -d v -f 2 | \
    cut -d . -f 1,2)"
PERL_MAIN_VER="$(echo "${PERL_MAJ_VER}" | cut -d . -f 1)"
PERL_LIB_PATH="/usr/lib/perl${PERL_MAIN_VER}/${PERL_MAJ_VER}"
sed -e "s|${TMP_DIR}||" -i \
    "${TMP_DIR}${PERL_LIB_PATH}/site_perl/auto/Net/SSLeay/.packlist"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Perl extension for using OpenSSL)
#
# Net::SSLeay is a PERL extension for using OpenSSL
#
# Home page: https://metacpan.org/dist/Net-SSLeay/view/lib/Net/SSLeay.pod
# Download:  https://cpan.metacpan.org/authors/id/C/CH/CHRISN/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

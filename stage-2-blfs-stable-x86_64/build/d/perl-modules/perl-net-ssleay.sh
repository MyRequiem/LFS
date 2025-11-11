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
# которые завершатся ошибкой, если нет подключения к сети Internet (значение по
# умолчанию - 'n'). С помощью инструкции [yes ''] пропускаем эти тесты
yes '' | perl Makefile.PL || exit 1
make                      || exit 1
# make test || true
make install DESTDIR="${TMP_DIR}"

# удалим perllocal.pod и другие служебные файлы, которые не нужно устанавливать
find "${TMP_DIR}" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

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

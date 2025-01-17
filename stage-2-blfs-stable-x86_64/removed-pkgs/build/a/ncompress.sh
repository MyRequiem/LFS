#! /bin/bash

PRGNAME="ncompress"

### ncompress (the classic *nix compression utility)
# Быстрая и простая утилита для сжатия файлов LZW. Не имеет высокой степени
# сжатия, но является одной из самых быстрых программ для сжатия данных, а так
# же де-факто стандартом в сообществе UNIX

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1
make PREFIX=/usr install DESTDIR="${TMP_DIR}"

(
    cd "${TMP_DIR}/usr/bin/" || exit 1
    # кроме утилиты compress так же устанавливаются утилиты uncompress, zcat,
    # zcmp, zdiff и zmore, но они уже установлены с пакетом gzip, поэтому
    # удалим их
    rm -f ./z* ./uncompress

    # удалим man-страницы для удаленных утилит, кроме uncompress, т.к. этот
    # мануал не устанавливается с пакетом gzip
    cd ../share/man/man1/ || exit 1
    rm -f ./z*
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the classic *nix compression utility)
#
# Compress is a fast, simple LZW file compressor. Compress does not have the
# highest compression rate, but it is one of the fastest programs to compress
# data. Compress is the defacto standard in the UNIX community for compressing
# files.
#
# Home page: https://${PRGNAME}.sourceforge.io/
# Download:  https://fossies.org/linux/privat/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

#! /bin/bash

PRGNAME="ntfs-3g"
ARCH_NAME="${PRGNAME}_ntfsprogs"

# разрешить обычным пользователям монтировать разделы NTFS
ALLOW_USER_MOUNT="false"

### ntfs-3g (NTFS read-write filesystem driver)
# Свободный драйвер файловой системы NTFS. В противоположность драйверу NTFS,
# включённому в само ядро Linux, ntfs-3g поддерживает больше операций с
# файлами, например создание/переименование/перемещение/удаление файлов любого
# размера. Разделы NTFS монтируются, используя Filesystem in Userspace (FUSE) в
# структуру пользовательского пространства FHS.

# Required:    no
# Recommended: no
# Optional:    fuse2 (https://github.com/libfuse/libfuse)

### Конфигурация ядра
#    CONFIG_FUSE_FS=m|y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{bin,lib,sbin,usr/lib}

./configure              \
    --prefix=/usr        \
    --disable-static     \
    --with-fuse=internal \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

(
    # ссылка в /sbin
    #    mount.ntfs -> /bin/ntfs-3g
    cd "${TMP_DIR}/sbin" || exit 1
    ln -sv /bin/${PRGNAME} mount.ntfs

    # ссылка в /usr/share/man/man8
    #    mount.ntfs.8 -> ntfs-3g.8
    cd "${TMP_DIR}/usr/share/man/man8" || exit 1
    ln -sv ntfs-3g.8 mount.ntfs.8
)

if [[ "x${ALLOW_USER_MOUNT}" == "xtrue" ]]; then
    chmod -v 4755 "${TMP_DIR}/bin/ntfs-3g"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (NTFS read-write filesystem driver)
#
# The Ntfs-3g package contains a stable, read-write open source driver for NTFS
# partitions. NTFS partitions are used by most Microsoft operating systems.
# Ntfs-3g allows you to mount NTFS partitions in read-write mode from your
# Linux system. It uses the FUSE kernel module to be able to implement NTFS
# support in user space. The package also contains various utilities useful for
# manipulating NTFS partitions.
#
# Home page: http://www.tuxera.com/community/open-source-${PRGNAME}/
# Download:  https://tuxera.com/opensource/${ARCH_NAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

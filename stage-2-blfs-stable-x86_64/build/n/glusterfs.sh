#! /bin/bash

PRGNAME="glusterfs"

### GlusterFS (scalable network filesystem)
# Распределённая, параллельная, линейно масштабируемая сетевая файловая система
# для задач, требующих обработки больших объемов данных и широкой полосы
# пропускания. GlusterFS работает в пользовательском пространстве при помощи
# технологии FUSE, поэтому не требует поддержки со стороны ядра.

# Required:    liburcu    (http://liburcu.org/)
#              gperftools (https://github.com/gperftools/gperftools/)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./autogen.sh &&                     \
./configure                         \
    --prefix=/usr                   \
    --sysconfdir=/etc               \
    --localstatedir=/var            \
    --disable-linux-io_uring        \
    --with-initdir=/etc/rc.d/init.d \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

(
    # поправим ссылки с абсолютного пути на относительный
    cd "${TMP_DIR}/usr/sbin" || exit 1
    ln -svf ../libexec/glusterfs/gfevents/glustereventsd.py glustereventsd
    ln -svf ../libexec/glusterfs/gfind_missing_files/gfind_missing_files.sh gfind_missing_files
    ln -svf ../libexec/glusterfs/peer_eventsapi.py peer_eventsapi
    ln -svf ../libexec/glusterfs/peer_georep-sshkey.py peer_georep-sshkey
    ln -svf ../libexec/glusterfs/peer_mountbroker.py peer_mountbroker
    ln -svf ../libexec/glusterfs/peer_eventsapi.py gluster-eventsapi
    ln -svf ../libexec/glusterfs/peer_georep-sshkey.py gluster-georep-sshkey
    ln -svf ../libexec/glusterfs/peer_mountbroker.py gluster-mountbroker

    # переместим /sbin в /usr/sbin
    cd "${TMP_DIR}" || exit 1
    if [ -d sbin ]; then
        mv sbin/* usr/sbin/
        rm -rf sbin
    fi
)

# удалим /var/run во временной директории (монтируется в tmpfs)
rm -rf "${TMP_DIR}/var/run"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scalable network filesystem)
#
# GlusterFS is a scalable network filesystem. Using common off-the-shelf
# hardware, you can create large, distributed storage solutions for media
# streaming, data analysis, and other data- and bandwidth-intensive tasks.
# GlusterFS is free and open source software.
#
# Home page: https://www.gluster.org/
# Download:  https://download.gluster.org/pub/gluster/${PRGNAME}/LATEST/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

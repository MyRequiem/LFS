#! /bin/bash

PRGNAME="pcsc-lite"

### PC/SC-lite (Middleware to access a smart card using SCard API)
# Популярный набор спецификаций для доступа к смарткартам. Спецификации
# регламентируют программный интерфейс пользователя (автора приложения с
# использованием смарткарт) с одной стороны и программный интерфейс драйверов
# считывателей смарткарт с другой стороны.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INIT_D="/etc/rc.d/init.d"
mkdir -pv "${TMP_DIR}${INIT_D}"

# добавим группу pcscd, если не существует
! grep -qE "^pcscd:" /etc/group  && \
    groupadd -g 257 pcscd

# добавим пользователя pcscd, если не существует
! grep -qE "^pcscd:" /etc/passwd && \
    useradd -c 'pcsc-lite daemon' \
            -d /var/run/pcscd     \
            -g pcscd              \
            -s /bin/false         \
            -u 257 pcscd

./configure                                     \
    --prefix=/usr                               \
    --sysconfdir=/etc                           \
    --localstatedir=/var                        \
    --disable-debugatr                          \
    --disable-libsystemd                        \
    --enable-confdir=/etc/reader.conf.d         \
    --enable-usbdropdir="/usr/lib/pcsc/drivers" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

RC_PCSCD="${INIT_D}/pcscd"
cat<< EOF > "${TMP_DIR}${RC_PCSCD}"
#!/bin/sh
#
# Start/Stop/Restart the PC/SC-lite smart card daemon
#
# pcscd should be started after pcmcia and shut down
# before it for smooth experience with PCMCIA readers

PIDFILE=/var/run/pcscd/pcscd.pid
PCSCD_OPTS=""

# start
pcscd_start() {
    if [ -x /usr/sbin/pcscd ]; then
        if [ -e "\${PIDFILE}" ]; then
            echo "PC/SC-lite daemon already started!"
        else
            echo "Starting PC/SC-lite smart card daemon..."
            /usr/sbin/pcscd "\${PCSCD_OPTS}"
        fi
    fi
}

# stop
pcscd_stop() {
    echo "Stopping PC/SC-lite smart card daemon..."
    if [ -e "\${PIDFILE}" ]; then
        kill "\$(cat "\${PIDFILE}")"
        rm -f "\${PIDFILE}" &>/dev/null
    fi

    # just in case
    killall pcscd &>/dev/null
}

# restart
pcscd_restart() {
    pcscd_stop
    sleep 3
    pcscd_start
}

# status
pcscd_status() {
    if [ -e "\${PIDFILE}" ]; then
        echo "pcscd is running."
    else
        echo "pcscd is stopped."
    fi
}

case "\$1" in
    'start')
        pcscd_start
        ;;
    'stop')
        pcscd_stop
        ;;
    'restart')
        pcscd_restart
        ;;
    'status')
        pcscd_status
        ;;
    *)
        echo "usage: \$0 start|stop|restart|status"
esac
EOF
chmod 754 "${TMP_DIR}${RC_PCSCD}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Middleware to access a smart card using SCard API)
#
# PC/SC-lite is a middleware to access a smart card using SCard API (PC/SC) Its
# purpose is to provide a Windows(R) SCard interface in a very small form
# factor for communicating to smart cards and readers.
#
# Home page: https://pcsclite.apdu.fr/
# Download:  https://pcsclite.apdu.fr/files/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

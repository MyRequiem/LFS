#! /bin/bash

PRGNAME="samba"

### Samba (CIFS file and print server)
# Набор программного обеспечения с открытым исходным кодом, который позволяет
# компьютерам на базе Linux и Unix взаимодействовать с Windows по сети. Он
# реализует протокол SMB/CIFS (Server Message Block/Common Internet File
# System), обеспечивая общий доступ к файлам и принтерам между разными
# операционными системами. Samba может работать как сервер для совместного
# доступа к ресурсам или как клиент для подключения к другим файловым серверам

# Required:    gnutls
#              libtirpc
#              parse-yapp
#              rpcsvc-proto
# Recommended: dbus
#              fuse3
#              gpgme
#              icu
#              jansson
#              libtasn1
#              libxslt
#              linux-pam
#              lmdb
#              mit-kerberos-v5
#              openldap
# Optional:    avahi
#              bind
#              cups
#              cyrus-sasl
#              gdb
#              git
#              gnupg
#              libaio
#              libarchive
#              libcap                   (собранный с Linux PAM)
#              libgcrypt
#              libnsl
#              libunwind
#              python3-markdown
#              nss
#              popt
#              talloc
#              vala
#              valgrind
#              xfsprogs
#              cmocka
#              cryptography
#              ctdb
#              cwrap
#              dnspython
#              fam
#              gamin
#              glusterfs
#              heimdal
#              iso8601
#              ldb
#              openafs
#              poetry-core
#              pyasn1
#              tevent
#              tdb
#              tracker-2
#              --- для тестов при разработке ---
#              python3-six
#              python3-pytest
#              python3-argparse
#              python3-testtools
#              python3-testscenarios
#              python3-python-subunit

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# для поддержки набора тестов настроим виртуальную среду Python для некоторых
# Python-модулей, выходящих за рамки BLFS

# создаем виртуальное окружение Python в ./pyvenv (в дереве исходников)
python3 -m venv --system-site-packages pyvenv         || exit 1
# устанавливаем в виртуальное окружение модули: cryptography pyasn1 iso8601
./pyvenv/bin/pip3 install cryptography pyasn1 iso8601 || exit 1

PYTHON="${PWD}/pyvenv/bin/python3"         \
PATH="${PWD}/pyvenv/bin:${PATH}"           \
./configure                                \
    --prefix=/usr                          \
    --sysconfdir=/etc                      \
    --localstatedir=/var                   \
    --with-piddir=/run/samba               \
    --with-pammodulesdir=/usr/lib/security \
    --enable-fhs                           \
    --without-ad-dc                        \
    --without-systemd                      \
    --with-system-mitkrb5                  \
    --enable-selftest                      \
    --disable-rpath-install || exit 1

make || exit 1

# тесты
# PATH=$PWD/pyvenv/bin:$PATH make quicktest

# исправим жестко закодированные пути к python3
sed '1s@^.*$@#!/usr/bin/python3@' \
    -i ./bin/default/source4/scripting/bin/*.inst || exit 1

# если обновляем пакет удалим старые файлы поддержки Python из системы
rm -rf /usr/lib/python3.13/site-packages/samba

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

# установим пример конфигурационного файла и исправим в нем директивы
# log file и path
mkdir -p "${TMP_DIR}/etc/samba"
install -v -m644 examples/smb.conf.default "${TMP_DIR}/etc/samba/"

sed -e "s;log file =.*;log file = /var/log/samba/%m.log;"   \
    -e "s;path = /usr/spool/samba;path = /var/spool/samba;" \
    -i "${TMP_DIR}/etc/samba/smb.conf.default" || exit 1

# установим еще несколько файлов в /etc/openldap/
mkdir -pv "${TMP_DIR}/etc/openldap/schema"
install -v -m644 examples/LDAP/README \
    "${TMP_DIR}/etc/openldap/schema/README.samba"
install -v -m644 examples/LDAP/samba*      "${TMP_DIR}/etc/openldap/schema/"
install -v -m755 examples/LDAP/{get*,ol*}  "${TMP_DIR}/etc/openldap/schema/"

###
# Минимальный конфиг
#    /etc/samba/smb.conf
###
# разрешает передавать файлы только с помощью smbclient, монтировать общие
# ресурсы Windows и печатать на принтерах Windows и не хотим делиться своими
# файлами и принтерами с компьютерами Windows
#    - компьютер принадлежит к рабочей группе Windows с именем WORKGROUP
#    - использует набор символов cp850 при общении с MS-DOS и MS Windows 9x
#    - имена файлов хранятся на диске в кодировке ISO-8859-1
cat << EOF > "${TMP_DIR}/etc/samba/smb.conf"
[global]
    workgroup = WORKGROUP
    dos charset = cp850
    unix charset = ISO-8859-1
EOF

# загрузочные скрипты:
# - samba запускает демоны smbd и nmbd, необходимые для предоставления услуг
#    SMB/CIFS
# - winbindd запускает демон winbindd, который используется для предоставления
#    доменных служб Windows клиентам Linux
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-samba    DESTDIR="${TMP_DIR}"
    make install-winbindd DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (CIFS file and print server)
#
# The Samba package provides file and print services to SMB/CIFS clients and
# Windows networking to Linux clients. Samba can also be configured as a
# Windows Domain Controller replacement, a file/print server acting as a member
# of a Windows Active Directory domain and a NetBIOS (RFC1001/1002) nameserver
# (which among other things provides LAN browsing support)
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://download.${PRGNAME}.org/pub/${PRGNAME}/stable/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

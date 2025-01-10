#! /bin/bash

PRGNAME="mit-kerberos-v5"
ARCH_NAME="krb5"

### MIT Kerberos V5 (Kerberos 5 network authentication protocol)
# Свободная реализация сетевого протокола аутентификации Kerberos 5 . Протокол
# предлагает механизм взаимной аутентификации клиента и сервера перед
# установлением связи между ними, причём в протоколе учтён тот факт, что
# начальный обмен информацией между клиентом и сервером происходит в
# незащищенной среде, а передаваемые пакеты могут быть перехвачены и
# модифицированы.

# Required:    no
# Recommended: no
# Optional:    bind-utils
#              cracklib
#              gnupg
#              keyutils
#              openldap
#              valgrind          (для тестов)
#              yasm
#              libedit           (http://thrysoee.dk/editline/)
#              cmocka            (https://cmocka.org/)
#              python3-kdcproxy  (https://pypi.org/project/kdcproxy/)
#              python3-pyrad     (https://pypi.org/project/pyrad/)
#              resolv-wrapper    (https://cwrap.org/resolv_wrapper.html)

### NOTE
# В системе обязательно потребуется какое-то средство синхронизации времени,
# например ntp, т.к. Kerberos не будет аутентифицироваться, если есть разница
# во времени между керберизованным клиентом и KDC сервером

### Конфигурация
#    /etc/krb5.conf
#    /var/lib/krb5kdc/kdc.conf

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

cd src || exit 1

# удалим заведомо неудачный тест
sed -i -e '/eq 0/{N;s/12 //}' plugins/kdb/db2/libdb2/test/run.test || exit 1

./configure                  \
    --prefix=/usr            \
    --sysconfdir=/etc        \
    --localstatedir=/var/lib \
    --runstatedir=/run       \
    --with-system-et         \
    --with-system-ss         \
    --with-system-verto=no   \
    --enable-dns-for-realm   \
    --disable-rpath || exit 1

make || exit 1
# make -j1 -k check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/run"

KRB5_CONF="/etc/krb5.conf"
cat << EOF > "${TMP_DIR}${KRB5_CONF}.example"
# Begin ${KRB5_CONF}

[libdefaults]
    default_realm = <EXAMPLE.ORG>
    encrypt = true

[realms]
    <EXAMPLE.ORG> = {
        kdc = <belgarath.example.org>
        admin_server = <belgarath.example.org>
        dict_file = /usr/share/dict/words
    }

[domain_realm]
    .<example.org> = <EXAMPLE.ORG>

[logging]
    kdc = SYSLOG:INFO:AUTH
    admin_server = SYSLOG:INFO:AUTH
    default = SYSLOG:DEBUG:DAEMON

# End ${KRB5_CONF}
EOF

# установим загрузочный скрипт /etc/rc.d/init.d/krb5 для запуска Kerberos
# сервиса при загрузке системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-krb5 DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Kerberos 5 network authentication protocol)
#
# MIT Kerberos V5 is a free implementation of Kerberos 5. Kerberos is a network
# authentication protocol. It centralizes the authentication database and uses
# kerberized applications to work with servers or services that support
# Kerberos allowing single logins and encrypted communication over internal
# networks or the Internet.
#
# Home page: https://kerberos.org/
# Download:  https://kerberos.org/dist/krb5/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

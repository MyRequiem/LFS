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
#              gnupg
#              keyutils
#              openldap
#              valgrind       (для тестов)
#              yasm
#              libedit        (http://thrysoee.dk/editline/)
#              cmocka         (https://cmocka.org/)
#              python3-pyrad  (https://pypi.org/project/pyrad/)
#              resolv_wrapper (https://cwrap.org/resolv_wrapper.html)

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
mkdir -pv "${TMP_DIR}"/{bin,etc,lib}

INSTALL_DOCS="false"
LDAP="--without-ldap"
command -v ldapadd &>/dev/null && LDAP="--with-ldap"

cd src || exit 1

# увеличим ширину виртуального терминала до 300 символов, используемого для
# некоторых тестов, чтобы предотвратить появление ложного текста в выводе,
# который считается ошибкой
sed -i -e 's@\^u}@^u cols 300}@' tests/dejagnu/config/default.exp     || exit 1
# удалим заведомо неудачный тест
sed -i -e '/eq 0/{N;s/12 //}'    plugins/kdb/db2/libdb2/test/run.test || exit 1
# удалим тест который, как известно, зависает
sed -i '/t_iprop.py/d'           tests/Makefile.in                    || exit 1

./configure                  \
    --prefix=/usr            \
    --sysconfdir=/etc        \
    --localstatedir=/var/lib \
    --runstatedir=/run       \
    --with-system-et         \
    --with-system-ss         \
    "${LDAP}"                \
    --with-system-verto=no   \
    --enable-dns-for-realm || exit 1

make || exit 1

# тесты лучше проводить после установки новой версии пакета в систему, иначе
# может случиться так, что набор тестов будет использовать установленные в
# системе версии библиотек, а не новые, только что собранные
# make -k -j1 check

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/run"

# сделаем библиотеки исполняемыми
for LIB in gssapi_krb5 gssrpc k5crypto kadm5clnt kadm5srv \
        kdb5 kdb_ldap krad krb5 krb5support verto ; do

    find "${TMP_DIR}/usr/lib" -type f -name "lib${LIB}*.so*" \
        -exec chmod -v 755 {} \;
done

# переместим важные библиотеки в /lib, чтобы они были доступны при загрузке
# системы, если файловая система /usr еще не смонтирована
mv "${TMP_DIR}/usr/lib/libkrb5.so".3*        "${TMP_DIR}/lib" || exit 1
mv "${TMP_DIR}/usr/lib/libk5crypto.so".3*    "${TMP_DIR}/lib" || exit 1
mv "${TMP_DIR}/usr/lib/libkrb5support.so".0* "${TMP_DIR}/lib" || exit 1

ln -sfv ../../lib/libkrb5.so.3.3        "${TMP_DIR}/usr/lib/libkrb5.so"
ln -sfv ../../lib/libk5crypto.so.3.1    "${TMP_DIR}/usr/lib/libk5crypto.so"
ln -sfv ../../lib/libkrb5support.so.0.1 "${TMP_DIR}/usr/lib/libkrb5support.so"

# переместим утилиту 'ksu' в /bin, чтобы она была доступна при загрузке
# системы, если файловая система /usr еще не смонтирована
mv -v        "${TMP_DIR}/usr/bin/ksu" "${TMP_DIR}/bin"
chmod -v 755 "${TMP_DIR}/bin/ksu"

# документация
if [[ "x${INSTALL_DOCS}" == "xtrue" ]]; then
    DOC_PATH="${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -dm755 "${DOC_PATH}"
    cp -vfr ../doc/*  "${DOC_PATH}"
fi

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

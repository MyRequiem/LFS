#! /bin/bash

PRGNAME="accountsservice"

### AccountsService (D-Bus interface for user account query)
# Набор D-Bus интерфейсов для запроса и манипулирования информацией учетных
# записей пользователей

# Required:    polkit
# Recommended: glib
#              elogind
#              vala
# Optional:    gtk-doc
#              xmlto
#              --- для тестов ---
#              python3-dbusmock
#              python3-pygobject3

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# переименуем каталог, наличие которого препятствует запуску системы сборки,
# если python3-dbusmock не установлен
mv tests/dbusmock{,-tests}

# исправим тестовый скрипт, чтобы нашелся новый каталог, и адаптируем его для
# Python>=3.12.0
sed -e '/accounts_service\.py/s/dbusmock/dbusmock-tests/' \
    -e 's/assertEquals/assertEqual/'                      \
    -i tests/test-libaccountsservice.py || exit 1

# исправим один тест, который завершается неудачей, если локаль en_IE.UTF-8 не
# установлена
sed -i '/^SIMULATED_SYSTEM_LOCALE/s/en_IE.UTF-8/en_HK.iso88591/' \
    tests/test-daemon.py

mkdir build
cd build || exit 1

meson setup ..             \
      --prefix=/usr        \
      --buildtype=release  \
      -D admin_group=adm   \
      -D elogind=true      \
      -D systemdsystemunitdir=no || exit 1

# исправим сборку с gcc>=14
grep 'print_indent'     ../subprojects/mocklibc-1.0/src/netgroup.c \
    | sed 's/ {/;/' >> ../subprojects/mocklibc-1.0/src/netgroup.h || exit 1
sed -i '1i#include <stdio.h>' \
    ../subprojects/mocklibc-1.0/src/netgroup.h || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# чтобы пользователи, состоящие в группе adm являлись администраторами,
# создадим правило
RULES_D="/etc/polkit-1/rules.d/"
mkdir -p "${TMP_DIR}${RULES_D}"
cat > "${TMP_DIR}${RULES_D}/40-adm.rules" << "EOF"
polkit.addAdminRule(function(action, subject) {
   return ["unix-group:adm"];
});
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (D-Bus interface  for user account query)
#
# The AccountsService package provides a set of D-Bus interfaces for querying
# and manipulating user account information and an implementation of those
# interfaces based on the usermod(8), useradd(8), and userdel(8) commands
#
# Home page: https://www.freedesktop.org/software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

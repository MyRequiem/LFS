#! /bin/bash

PRGNAME="random-number-generator"
VERSION="20191204"

### Инициализация генератора случайных чисел /dev/random и /dev/urandom
# Ядро Linux предоставляет генератор случайных чисел, доступ к которому
# осуществляется через /dev/random и /dev/urandom. Эти устройства используют
# такие программы как OpenSSH и т.п.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/random.html

# Когда система запущена и находится в относительно спокойном состоянии без
# особого взаимодействия с пользователем, пул энтропии (данные, используемые
# для вычисления случайного числа) может быть довольно предсказуемым. Такое
# состояние создает реальную возможность того, что генерируемое случайное число
# всегда может быть одинаковым. Чтобы противодействовать этому эффекту, мы
# должны хранить и предоставлять информацию для пула по всем запускам и
# выключениям системы.

# Скрипт инициализации генератора случайных чисел находится в пакете
# blfs-bootscripts (см. /001_blfs-bootscripts.sh), который мы распоковали и
# положили в /root Устанавливается скрипт /etc/rc.d/init.d/random и ссылки на
# него в директориях /etc/rc.d/rcX.d/

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

TMP_DIR="/tmp/build-${PRGNAME}-${VERSION}/package-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

cd "${ROOT}/blfs-bootscripts" || exit 1
make install-random
make install-random DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (random number generator initialization)
#
# Initialises /dev/urandom from a seed stored in /var/tmp
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

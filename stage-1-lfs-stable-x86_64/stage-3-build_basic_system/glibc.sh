#! /bin/bash

PRGNAME="glibc"
TZDATA_VERSION="2025b"
TIMEZONE="Europe/Astrakhan"

### Glibc (GNU C libraries)
# Пакет Glibc содержит основную библиотеку C. Эта библиотека предоставляет
# основные процедуры для выделения памяти, поиска в каталогах, открытия и
# закрытия файлов, чтения и записи файлов, обработки строк, сопоставления с
# образцом, арифметики и т.д.

###
# IMPORTANT:
###
# При обновлении Glibc до новой minor версии (например, с версии 2.36 до 2.41)
# на рабочей системе LFS, необходимо принять дополнительные меры
# предосторожности, чтобы избежать нарушений работы системы.
#
# ДО СБОРКИ обновленного Glibc:
#    - если обновляем LFS до более новой версии, то нужно обновить ядро
#       (kernel-source, kernel-headers, kernel-generic, kernel-modules) до
#       новой версии и перезагрузить систему
#
# Сборка Glibc:
#    ../configure \
#       .....
#    make ......
#    ......
#
#    make DESTDIR="${TMP_DIR}" install
#    install -vm755 "${TMP_DIR}/usr/lib"/*.so.* /usr/lib
#    make install
#
# После установки нового Glibc >> НЕМЕДЛЕННО << перезагрузить систему
###

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{etc/ld.so.conf.d,usr/lib/locale,var/lib/nss_db}
ZONEINFO=/usr/share/zoneinfo
mkdir -pv "${TMP_DIR}${ZONEINFO}"/{posix,right}

# некоторые из программ Glibc используют не FHS-совместимый каталог /var/db для
# хранения run-time данных. Применим патч, который удаляет ссылки на каталог
# /var/db и заменяет их на
#    /var/cache/nscd    - для nscd
#    /var/lib/nss_db    - для nss_db
patch --verbose -Nvp1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-fhs-1.patch" || exit 1

# исправим проблему сборки Valgrind в BLFS
sed -e '/unistd.h/i #include <string.h>' \
    -e '/libc_rwlock_init/c\
  __libc_rwlock_define_initialized (, reset_lock);\
  memcpy (&lock, &reset_lock, sizeof (lock));' \
    -i stdlib/abort.c || exit 1

# документация glibc рекомендует собирать glibc в отдельном каталоге
mkdir -v build
cd build || exit 1

# утилиты ldconfig и sln будут установлены в /usr/sbin
echo "rootsbindir=/usr/sbin" > configparms

### Конфигурация
# отключает параметр -Werror, передаваемый в GCC. Это необходимо для запуска
# набора тестов.
#    --disable-werror
# не создавать nscd (name service cache daemon), который больше не используется
#    --disable-nscd
# устанавливать библиотеки в /usr/lib вместо /lib64 по умолчанию для x86-64
# архитектуры
#    libc_cv_slibdir=/usr/lib
# повышает безопасность системы, добавляя дополнительный код для проверки
# переполнения буфера, например при атаках с разрушением стека
#    --enable-stack-protector=strong
# указывает Glibc скомпилировать библиотеку с поддержкой ядер Linux >=5.4
# (более ранние версии поддерживаться не будут)
#    --enable-kernel=5.4
../configure                        \
    --prefix=/usr                   \
    --disable-werror                \
    --disable-nscd                  \
    libc_cv_slibdir=/usr/lib        \
    --enable-stack-protector=strong \
    --enable-kernel=5.4 || exit 1

make || make -j1 || exit 1
# make check

# если конфиг динамического загрузчика /etc/ld.so.conf не существует, то на
# этапе установки Glibc будет жаловаться на его отсутствие
LD_SO_CONF="/etc/ld.so.conf"
! [ -r "${LD_SO_CONF}" ] && touch "${LD_SO_CONF}"

# исправим Makefile, чтобы пропустить устаревшую проверку работоспособности
# Glibc, которая не работает в современной конфигурации
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile || exit 1

make DESTDIR="${TMP_DIR}" install
install -vm755 "${TMP_DIR}/usr/lib"/*.so.* /usr/lib
make install

# исправим жестко закодированный путь к динамическому загрузчику в скрипте ldd
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd || exit 1

# ни одна из локалей не требуется на данный момент, но если некоторые из них
# отсутствуют, тестовые наборы пакетов, которые мы будет устанавливать позже,
# пропустят важные тесты, поэтому установим минимальный набор локалей,
# необходимых для оптимального охвата тестов. Отдельные локали могут быть
# установлены с помощью утилиты localedef. Результат ее работы добавляется в
# файл
#    /usr/lib/locale/locale-archive
mkdir -pv /usr/lib/locale
localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

cp /usr/lib/locale/locale-archive "${TMP_DIR}/usr/lib/locale/"

###
# Конфигурация Glibc
###

### Псевдонимы локалей
# в файле /usr/share/locale/locale.alias пропишем псевдонимы для русской локали
# с кодировкой UTF-8
# уберем:
#    russian         ru_RU.ISO-8859-5
# вставим:
#    russian         ru_RU.UTF-8
#    ru_RU           ru_RU.UTF-8
#    ru              ru_RU.UTF-8
sed -i 's/^russian.*$/russian         ru_RU.UTF-8\nru_RU           ru_RU.UTF-8\nru              ru_RU.UTF-8/' \
    "${TMP_DIR}/usr/share/locale/locale.alias"

### создаем файл конфигурации для name service switch /etc/nsswitch.conf
NSSWITCH_CONFIG="/etc/nsswitch.conf"
cat << EOF > "${TMP_DIR}${NSSWITCH_CONFIG}"
# Begin ${NSSWITCH_CONFIG}

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End ${NSSWITCH_CONFIG}
EOF

### Установка и настройка данных часового пояса
ZONEINFO_DIR="${TMP_DIR}${ZONEINFO}"
# компилируем файлы Time Zone Data и помещаем их в /usr/share/zoneinfo
tar -xvf "${SOURCES}/tzdata${TZDATA_VERSION}.tar.gz" || exit 1
for TZ in etcetera southamerica northamerica europe africa antarctica \
        asia australasia backward; do
    zic -L /dev/null   -d "${ZONEINFO_DIR}"       "${TZ}"
    zic -L /dev/null   -d "${ZONEINFO_DIR}/posix" "${TZ}"
    zic -L leapseconds -d "${ZONEINFO_DIR}/right" "${TZ}"
done

cp -v zone.tab zone1970.tab iso3166.tab "${ZONEINFO_DIR}"

# при создании файла posixrules мы используем Нью-Йорк, потому что POSIX
# требует, чтобы правила перехода на летнее время соответствовали правилам США
zic -d "${ZONEINFO_DIR}" -p America/New_York

# один из способов определить местный часовой пояс:
#     $ tzselect
# после ответа на несколько вопросов о местоположении сценарий выведет название
# часового пояса (например, Europe/Astrakhan). В каталоге /usr/share/zoneinfo
# перечислены также некоторые другие возможные часовые пояса, которые не
# определены сценарием, но могут использоваться

# создадим ссылку
#    /etc/localtime -> ../usr/share/zoneinfo/${TIMEZONE}
ln -sfv "../usr/share/zoneinfo/${TIMEZONE}" "${TMP_DIR}/etc/localtime"

###
# Конфигурация динамического загрузчика
###
# По умолчанию динамический загрузчик ld-linux-x86-64.so.2 при запуске программ
# ищет нужные динамические библиотеки в /usr/lib/ Однако если в каталогах
# отличных от /usr/lib есть дополнительные библиотеки, их необходимо добавить в
# файл /etc/ld.so.conf, чтобы динамический загрузчик мог их найти. Например,
# две дополнительные директории могут содержать библиотеки: /usr/local/lib и
# /opt/lib Добавим эти каталоги в пути поиска для динамического загрузчика.
# Также динамический загрузчик будет искать библиотеки, указанные в *.conf
# файлах каталога /etc/ld.so.conf.d/ Как правило, файлы в этом каталоге
# содержат одну строку - путь поиска библиотек. Например, файл
# /etc/ld.so.conf.d/qt6.conf будет содержать строку /opt/qt6/lib

cat << EOF > "${TMP_DIR}${LD_SO_CONF}"
# Begin ${LD_SO_CONF}

# add an include directory
include /etc/ld.so.conf.d/*.conf

/usr/local/lib
/opt/lib

# End ${LD_SO_CONF}
EOF

source "${ROOT}/update-info-db.sh" || exit 1

# устанавливаем конфиги и директории в корень системы
/bin/cp -vR "${TMP_DIR}"/etc       /
/bin/cp -vR "${TMP_DIR}"/usr/share /usr
/bin/cp -vR "${TMP_DIR}"/var       /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU C libraries)
#
# This package contains the main GNU C libraries and header files. This
# libraries provides the basic routines for allocating memory, searching
# directories, opening and closing files, reading and writing files, string
# handling, pattern matching, arithmetic, and so on. You'll need this package
# to compile programs.
#
# Home page: https://www.gnu.org/software/libc/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

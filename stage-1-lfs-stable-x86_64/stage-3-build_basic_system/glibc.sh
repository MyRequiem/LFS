#! /bin/bash

PRGNAME="glibc"
TZDATA_VERSION="2021a"
TIMEZONE="Europe/Astrakhan"

### Glibc (GNU C libraries)
# Пакет Glibc содержит основную библиотеку C. Эта библиотека предоставляет
# основные процедуры для выделения памяти, поиска в каталогах, открытия и
# закрытия файлов, чтения и записи файлов, обработки строк, сопоставления с
# образцом, арифметики и так далее.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{etc/ld.so.conf.d,usr/lib/locale}
mkdir -pv "${TMP_DIR}/var"/{lib/nss_db,cache/nscd}
ZONEINFO=/usr/share/zoneinfo
mkdir -pv "${TMP_DIR}${ZONEINFO}"/{posix,right}

# некоторые из программ Glibc используют не FHS-совместимый каталог /var/db для
# хранения run-time данных. Применим патч, который удаляет ссылки на каталог
# /var/db и заменяет их на
#    /var/cache/nscd    - для nscd
#    /var/lib/nss_db    - для nss_db
patch --verbose -Nvp1 -i "${SOURCES}/${PRGNAME}-${VERSION}-fhs-1.patch" || exit 1

# исправим ошибку, которая вызывает проблемы с приложениями запущенными в среде
# chroot
sed -e '402a\      *result = local->data.services[database_index];' \
    -i nss/nss_database.c

# документация glibc рекомендует собирать glibc в отдельном каталоге
mkdir -v build
cd build || exit 1

### Конфигурация
# отключает параметр -Werror, передаваемый в GCC. Это необходимо для запуска
# набора тестов.
#    --disable-werror
# указывает Glibc скомпилировать библиотеку с поддержкой ядер Linux >=3.2
# (более ранние версии поддерживаться не будут)
#    --enable-kernel=3.2
# повышает безопасность системы, добавляя дополнительный код для проверки
# переполнения буфера, такого как атаки с разбивкой стека
#    --enable-stack-protector=strong
# где искать заголовки API ядра
#    --with-headers=/usr/include
# устанавливать библиотеки в /lib вместо /lib64 по умолчанию для x86-64
# архитектуры
#    libc_cv_slibdir=/lib
../configure                        \
    --prefix=/usr                   \
    --disable-werror                \
    --enable-kernel=3.2             \
    --enable-stack-protector=strong \
    --with-headers=/usr/include     \
    libc_cv_slibdir=/lib || exit 1

make || make -j1 || exit 1

# для тестов меняем ссылку
#    /lib/ld-linux-x86-64.so.2 -> ld-2.3x.so
# на только что собранную библиотеку ld-linux-x86-64.so.2
#    /lib/ld-linux-x86-64.so.2 -> <sources_tree>/build/elf/ld-linux-x86-64.so.2
#
# На этапе установки пакета она обратно перезапишется на правильную
# ln -svfn "${PWD}/elf/ld-linux-x86-64.so.2" /lib
# make check

# если конфиг динамического загрузчика /etc/ld.so.conf не существует, то на
# этапе установки Glibc будет жаловаться на его отсутствие
LD_SO_CONFIG="/etc/ld.so.conf"
! [ -r "${LD_SO_CONFIG}" ] && touch "${LD_SO_CONFIG}"

# исправим сгенерированный Makefile, чтобы пропустить ненужную проверку
# работоспособности Glibc, которая в среде LFS выполняется с ошибкой
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile || exit 1

make install
make install DESTDIR="${TMP_DIR}"

# ни одна из локалей не требуется на данный момент, но если некоторые из них
# отсутствуют, тестовые наборы пакетов, которые мы будет устанавливать позже,
# пропустят важные тесты, поэтому установим минимальный набор локалей,
# необходимых для оптимального охвата тестов. Отдельные локали могут быть
# установлены с помощью утилиты localedef. Результат ее работы добавляется в
# файл
#    /usr/lib/locale/locale-archive
mkdir -pv /usr/lib/locale
localedef -i POSIX      -f UTF-8        C.UTF-8 2> /dev/null || true
localedef -i cs_CZ      -f UTF-8        cs_CZ.UTF-8
localedef -i de_DE      -f ISO-8859-1   de_DE
localedef -i de_DE      -f UTF-8        de_DE.UTF-8
localedef -i de_DE@euro -f ISO-8859-15  de_DE@euro
localedef -i el_GR      -f ISO-8859-7   el_GR
localedef -i en_GB      -f UTF-8        en_GB.UTF-8
localedef -i en_HK      -f ISO-8859-1   en_HK
localedef -i en_PH      -f ISO-8859-1   en_PH
localedef -i en_US      -f ISO-8859-1   en_US
localedef -i en_US      -f UTF-8        en_US.UTF-8
localedef -i es_MX      -f ISO-8859-1   es_MX
localedef -i fa_IR      -f UTF-8        fa_IR
localedef -i fr_FR      -f ISO-8859-1   fr_FR
localedef -i fr_FR      -f UTF-8        fr_FR.UTF-8
localedef -i fr_FR@euro -f ISO-8859-15  fr_FR@euro
localedef -i it_IT      -f ISO-8859-1   it_IT
localedef -i it_IT      -f UTF-8        it_IT.UTF-8
localedef -i ja_JP      -f EUC-JP       ja_JP
localedef -i ja_JP      -f SHIFT_JIS    ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP      -f UTF-8        ja_JP.UTF-8
localedef -i ru_RU      -f KOI8-R       ru_RU.KOI8-R
localedef -i ru_RU      -f UTF-8        ru_RU.UTF-8
localedef -i tr_TR      -f UTF-8        tr_TR.UTF-8
localedef -i zh_CN      -f GB18030      zh_CN.GB18030
localedef -i zh_HK      -f BIG5-HKSCS   zh_HK.BIG5-HKSCS

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

### Установка и настройка данных часового пояса
ZONEINFO_DIR="${TMP_DIR}${ZONEINFO}"
# компилируем файлы временных зон и помещаем их в /usr/share/zoneinfo
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

# создадим сслыку
#    /etc/localtime -> ../usr/share/zoneinfo/${TIMEZONE}
ln -sfv "../usr/share/zoneinfo/${TIMEZONE}" "${TMP_DIR}/etc/localtime"

### Создаем файл конфигурации для Name Service Cache /etc/nscd.conf
NSCD_CONFIG="/etc/nscd.conf"
# бэкапим его, если он существует в системе
if [ -f "${NSCD_CONFIG}" ]; then
    mv -v "${NSCD_CONFIG}" "${NSCD_CONFIG}.old"
fi

cp -v ../nscd/nscd.conf "${TMP_DIR}${NSCD_CONFIG}"

### Создаем файл конфигурации для Name Service Switch /etc/nsswitch.conf
NSSWITCH_CONFIG="/etc/nsswitch.conf"
# бэкапим его, если он существует в системе
if [ -f "${NSSWITCH_CONFIG}" ]; then
    mv "${NSSWITCH_CONFIG}" "${NSSWITCH_CONFIG}.old"
fi

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

### Конфигурация динамического загрузчика
# По умолчанию поиск динамического загрузчика ld-linux-x86-64.so.2, который
# нужен программам при их запуске, происходит в /lib и /usr/lib. Однако если в
# каталогах, отличных от /lib и /usr/lib, есть дополнительные библиотеки, их
# необходимо добавить в файл /etc/ld.so.conf, чтобы динамический загрузчик мог
# их найти. Например, две дополнительные директории могут содержать библиотеки:
# /usr/local/lib и /opt/lib, а так же другие пути к библиотекам могут быть
# указаны в конфигурационных файлах в /etc/ld.so.conf.d/ Добавим эти каталоги в
# пути поиска для динамического загрузчика

# бэкапим /etc/ld.so.conf, если он уже существует
if [ -f "${LD_SO_CONFIG}" ]; then
    mv "${LD_SO_CONFIG}" "${LD_SO_CONFIG}.old"
fi

cat << EOF > "${TMP_DIR}${LD_SO_CONFIG}"
# Begin ${LD_SO_CONFIG}

# Add an include directory
include /etc/ld.so.conf.d/*.conf

/usr/local/lib
/opt/lib

# End ${LD_SO_CONFIG}
EOF

# устанавливаем пакет в корень системы
# NOTE:
#    Устанавливаем все, кроме /lib, т.к. она уже установлена 'make install'.
#    Если мы будем пытаться скопировать ${TMP_DIR}/lib в корень LFS системы, то
#    библиотека /lib/ld-2.3x.so естественно будет занята и копирование
#    прервется с ошибкой:
#       /bin/cp: cannot create regular file '/lib/ld-2.3x.so': Text file busy
/bin/cp -vR "${TMP_DIR}"/etc  /
/bin/cp -vR "${TMP_DIR}"/sbin /
/bin/cp -vR "${TMP_DIR}"/usr  /
/bin/cp -vR "${TMP_DIR}"/var  /

# обрабатываем созданные нами и установленные конфиги
config_file_processing "${NSCD_CONFIG}"
config_file_processing "${NSSWITCH_CONFIG}"
config_file_processing "${LD_SO_CONFIG}"

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU C libraries)
#
# This package contains the main GNU C libraries and header files. This
# libraries provides the basic routines for allocating memory, searching
# directories, opening and closing files, reading and writing files, string
# handling, pattern matching, arithmetic, and so on. You'll need this package
# to compile programs.
#
# Home page: http://www.gnu.org/software/libc/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

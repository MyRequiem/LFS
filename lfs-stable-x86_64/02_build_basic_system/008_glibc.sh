#! /bin/bash

PRGNAME="glibc"

### Glibc
# Пакет Glibc содержит основную библиотеку C. Эта библиотека предоставляет
# основные процедуры для выделения памяти, поиска в каталогах, открытия и
# закрытия файлов, чтения и записи файлов, обработки строк, сопоставления с
# образцом, арифметики и так далее.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/glibc.html

# Home page: http://www.gnu.org/software/libc/
# Download:  http://ftp.gnu.org/gnu/glibc/glibc-2.31.tar.xz
#            https://www.iana.org/time-zones/repository/releases/tzdata2019c.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib64"

# система сборки Glibc является автономной и будет без проблем скомпилирована,
# даже если файл спецификаций компилятора и компоновщик по-прежнему указывают
# на /tools. Спецификации и компоновщик не могут быть изменены до установки
# Glibc, потому что тесты Glibc autoconf дадут неверные результаты и не
# позволят достичь чистой сборки

# некоторые из программ Glibc используют не FHS-совместимый каталог /var/db для
# хранения run-time данных . Применим патч, чтобы такие программы хранили свои
# run-time данные в FHS-совместимых местах (/var/lib/nss_db)
patch --verbose -Nvp1 -i "/sources/${PRGNAME}-${VERSION}-fhs-1.patch" || exit 1

# создадим ссылки в /lib64 для соответствия LSB (Linux Standard Base)
#    ld-linux-x86-64.so.2 -> ../lib/ld-linux-x86-64.so.2
#    ld-lsb-x86-64.so.3   -> ../lib/ld-linux-x86-64.so.2
# необходимую для правильной работы динамического загрузчика
ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
(
    cd "${TMP_DIR}/lib64" || exit 1
    ln -sfv ../lib/ld-linux-x86-64.so.2 ld-linux-x86-64.so.2
    ln -sfv ../lib/ld-linux-x86-64.so.2 ld-lsb-x86-64.so.3
)

# документация glibc рекомендует собирать glibc в отдельном каталоге для сборки
mkdir -v build
cd build || exit 1

### Конфигурация
# рассматривать любые ссылки на файлы в /tools в процессе компиляции, как если
# бы файлы находились в /usr. Это позволяет избежать введения недопустимых
# путей в отладочных символах
#    CC="gcc -ffile-prefix-map=/tools=/usr"
# отключает параметр -Werror, передаваемый в GCC. Это необходимо для запуска
# набора тестов.
#    --disable-werror
# повышает безопасность системы, добавляя дополнительный код для проверки
# переполнения буфера, такого как атаки с разбивкой стека
#    --enable-stack-protector=strong
# где искать заголовки API ядра. По умолчанию заголовки ищутся в /tools/include
#    --with-headers=/usr/include
# эта переменная устанавливает правильную директорию для библиотек (для всех
# систем). Мы не хотим использовать lib64.
#    libc_cv_slibdir=/lib
CC="gcc -ffile-prefix-map=/tools=/usr"  \
../configure                            \
    --prefix=/usr                       \
    --disable-werror                    \
    --enable-kernel=3.2                 \
    --enable-stack-protector=strong     \
    --with-headers=/usr/include         \
    libc_cv_slibdir=/lib || exit 1

# сборка
make || exit 1

# следующая символическая ссылка необходима для запуска тестов сборки
# в среде chroot. Она будет перезаписана на этапе установки пакета
ln -sfnv "${PWD}/elf/ld-linux-x86-64.so.2" /lib

### на данном этапе запуск тестов обязателен
# набор тестов Glibc зависит от хост-системы. Список наиболее распространенных
# проблем с тестами в среде LFS:
#    - misc/tst-ttyname не работает в среде chroot LFS
#    - inet/tst-idna_name_classify дает сбой в среде chroot LFS
#    - posix/tst-getaddrinfo4 и posix/tst-getaddrinfo5 могут не работать на
#       некоторых архитектурах
#    - nss/tst-nss-files-hosts-multi может завершиться неудачей по причинам,
#       которые не были определены
#    - rt/tst-cputimer{1,2,3} зависят от ядра хост-системы. Известно, что ядра
#       4.14.91–4.14.96, 4.19.13–4.19.18 и 4.20.0–4.20.5 вызывают сбой этих
#       тестов.
#    - математические тесты иногда не проходят при работе в системах, где ЦП не
#       является относительно новым процессором Intel или AMD
make check

# на этапе установки Glibc будет жаловаться на отсутствие /etc/ld.so.conf,
# создадим его
touch /etc/ld.so.conf

# исправим сгенерированный Makefile, чтобы пропустить ненужную проверку
# работоспособности Glibc
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

# устанавливаем пакет
make install
make install DESTDIR="${TMP_DIR}"

# бэкапим конфиг /etc/nscd.conf перед его установкой, если он существует
NSCD_CONFIG="/etc/nscd.conf"
if [ -f "${NSCD_CONFIG}" ]; then
    mv -v "${NSCD_CONFIG}" "${NSCD_CONFIG}.old"
fi

# установим конфиг /etc/nscd.conf
cp -v ../nscd/nscd.conf /etc/
mkdir -pv "${TMP_DIR}/etc"
cp -v "${NSCD_CONFIG}" "${TMP_DIR}/etc/"

config_file_processing "${NSCD_CONFIG}"

# установим run-time каталог для nscd
mkdir -pv /var/cache/nscd
mkdir -pv "${TMP_DIR}/var/cache/nscd"

# ни одна из локалей не требуется на данный момент, но если некоторые из них
# отсутствуют, тестовые наборы пакетов, которые мы будет устанавливать позже,
# пропустят важные тесты. Отдельные локали могут быть установлены с помощью
# утилиты localedef. Результат ее работы добавляется в файл
# /usr/lib/locale/locale-archive Следующие инструкции установят минимальный
# набор локалей, необходимых для оптимального охвата тестов
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

mkdir -pv "${TMP_DIR}/usr/lib/locale"
cp /usr/lib/locale/locale-archive "${TMP_DIR}/usr/lib/locale/"

# в файле /usr/share/locale/locale.alias пропишем псевдонимы для русской локали
# с кодировкой UTF-8
# уберем:
#    russian         ru_RU.ISO-8859-5
# вставим:
#    russian         ru_RU.UTF-8
#    ru_RU           ru_RU.UTF-8
#    ru              ru_RU.UTF-8
sed -i 's/^russian.*$/russian         ru_RU.UTF-8\nru_RU           ru_RU.UTF-8\nru              ru_RU.UTF-8/' \
    /usr/share/locale/locale.alias
sed -i 's/^russian.*$/russian         ru_RU.UTF-8\nru_RU           ru_RU.UTF-8\nru              ru_RU.UTF-8/' \
    "${TMP_DIR}/usr/share/locale/locale.alias"

### Конфигурация Glibc
# необходимо создать файл /etc/nsswitch.conf (бэкапим его перед созданием, если
# он уже существует)
NSSWITCH_CONFIG="/etc/nsswitch.conf"
if [ -f "${NSSWITCH_CONFIG}" ]; then
    mv "${NSSWITCH_CONFIG}" "${NSSWITCH_CONFIG}.old"
fi

cat << EOF > "${NSSWITCH_CONFIG}"
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

cp "${NSSWITCH_CONFIG}" "${TMP_DIR}/etc/"

config_file_processing "${NSSWITCH_CONFIG}"

# установка и настройка данных часового пояса
ZONEINFO=/usr/share/zoneinfo
mkdir -pv "${ZONEINFO}"/{posix,right}
ZONEINFO_TMP="${TMP_DIR}/usr/share/zoneinfo"
mkdir -pv "${ZONEINFO_TMP}"/{posix,right}

# компилируем файлы временных зон и помещаем их в /usr/share/zoneinfo
tar -xvf /sources/tzdata2019c.tar.gz || exit 1
for TZ in etcetera southamerica northamerica europe africa antarctica \
        asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d "${ZONEINFO}"           "${TZ}"
    zic -L /dev/null   -d "${ZONEINFO}/posix"     "${TZ}"
    zic -L leapseconds -d "${ZONEINFO}/right"     "${TZ}"

    # то же самое во временную директорию
    zic -L /dev/null   -d "${ZONEINFO_TMP}"       "${TZ}"
    zic -L /dev/null   -d "${ZONEINFO_TMP}/posix" "${TZ}"
    zic -L leapseconds -d "${ZONEINFO_TMP}/right" "${TZ}"
done

cp -v zone.tab zone1970.tab iso3166.tab "${ZONEINFO}"
cp -v zone.tab zone1970.tab iso3166.tab "${ZONEINFO_TMP}"
# создается файл posixrules. Мы используем Нью-Йорк, потому что POSIX требует,
# чтобы правила перехода на летнее время соответствовали правилам США
zic -d "${ZONEINFO}"     -p America/New_York
zic -d "${ZONEINFO_TMP}" -p America/New_York
unset ZONEINFO ZONEINFO_TMP

# один из способов определить местный часовой пояс:
#     $ tzselect
# после ответа на несколько вопросов о местоположении сценарий выведет название
# часового пояса (например, Europe/Astrakhan). В каталоге /usr/share/zoneinfo
# перечислены также некоторые другие возможные часовые пояса, которые не
# определены сценарием, но могут использоваться.

# создадим сслыку /etc/localtime
ln -sfv ../usr/share/zoneinfo/Europe/Astrakhan /etc/localtime
ln -sfv ../usr/share/zoneinfo/Europe/Astrakhan "${TMP_DIR}/etc/localtime"

### Конфигурация динамического загрузчика
# По умолчанию поиск динамического загрузчика ld-linux-x86-64.so.2, который
# нужен программам при их запуске, происходит в /lib и /usr/lib. Однако если в
# каталогах, отличных от /lib и /usr/lib, есть дополнительные библиотеки, их
# необходимо добавить в файл /etc/ld.so.conf, чтобы динамический загрузчик мог
# их найти. Например, две дополнительные директории могут содержать библиотеки:
# /usr/local/lib и /opt/lib, а так же другие пути к библиотекам могут быть
# указаны в конфигурационных файлах в /etc/ld.so.conf.d/ Добавим эти каталоги в
# пути поиска для динамического загрузчика

# бэкапим конфиг /etc/ld.so.conf перед созданием, если он уже существует
LD_SO_CONFIG="/etc/ld.so.conf"
if [ -f "${LD_SO_CONFIG}" ]; then
    mv "${LD_SO_CONFIG}" "${LD_SO_CONFIG}.old"
fi

cat << EOF > "${LD_SO_CONFIG}"
# Begin ${LD_SO_CONFIG}

# Add an include directory
include /etc/ld.so.conf.d/*.conf

/usr/local/lib
/opt/lib

# End ${LD_SO_CONFIG}
EOF

cp "${LD_SO_CONFIG}" "${TMP_DIR}/etc/"

config_file_processing "${LD_SO_CONFIG}"

# создаем директорию /etc/ld.so.conf.d/
mkdir -pv /etc/ld.so.conf.d
mkdir -pv "${TMP_DIR}/etc/ld.so.conf.d"

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

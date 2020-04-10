#! /bin/bash

PRGNAME="system-v-configuration"

### System V configuration
# Конфигурация SysVinit. В Linux используется специальная схема загрузки
# SysVinit, основанная на концепции уровней загрузки. LFS имеет свой
# собственный способ загрузки, но он так же основан на общепринятых стандартах
# SysVinit

# http://www.linuxfromscratch.org/lfs/view/stable/chapter07/usage.html

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc/sysconfig"

###
# Конфигурация init
###
# Во время инициализации ядра Linux первая запущенная программа это init с ID=1
# Она читает файл /etc/inittab и организована в уровни запуска, которые могут
# быть выполнены пользователем:
#    0 -  halt
#    1 -  Single user mode
#    2 -  Multiuser, without networking
#    3 -  Full multiuser mode
#    4 -  User definable
#    5 -  Full multiuser mode with display manager
#    6 -  reboot

# уровень запуска по умолчанию
# запускаются все скрипты в /etc/rc.d/rc?.d/, где '?' - уровень запуска
# id:3:initdefault:

# запускаются все скрипты в /etc/rc.d/rcS.d
# si::sysinit:/etc/rc.d/init.d/rc S
# в самом скрипте /etc/rc.d/init.d/rc используется такая конструкция:
# ...
# [ "${1}" != "" ] && runlevel=${1}
# ...
# if [ "$runlevel" == "S" ]; then
# ...

# Для удобства скрипт /etc/rc.d/init.d/rc читает библиотеку функций
# /lib/lsb/init-functions. В свою очередь эта библиотека читает файл
# конфигурации опциональных параметров запуска /etc/sysconfig/rc.site (имя
# дистрибутива, формат и цвета загрузочных сообщений, очистка /tmp, параметры
# консоли и т.д.). Так же скрипт сохраняет весь вывод загрузочных сообщений в
# /run/var/bootlog. Поскольку каталог /run является виртуальной файловой
# системой tmpfs и не сохраняется между перезагрузками системы, лог так же
# записывается в /var/log/boot.log в конце процесса загрузки.

# В /etc/rc.d/ находятся каталоги вида rc?.d, где '?' это уровень запуска.
# Каждый такой каталог содержит ссылки на скрипты в /etc/rc.d/init.d/
# Формат имен ссылок: <S|K><00-99>script_name
#    К                  - остановить (kill)
#    S                  - запуск службы (start).
#    число от 00 до 99  - определяет порядок запуска скриптов - чем меньше
#                           число, тем раньше скрипт исполняется
# Когда init переключается на другой уровень запуска, соответствующие службы
# запускаются или останавливаются в зависимости от выбранного уровня.

# 'K' и 'S' ссылки с одинаковыми названиями после цифры указывают на один и тот
# же скрипт. Это происходит потому, что сценарии могут быть вызваны с разными
# параметрами: start, stop, restart, reload, status. Когда скрипт запускается
# по ссылке 'К', то в скрипт передается параметр 'stop', по ссылке 'S' -
# параметр 'start'. Исключение составлют каталоги rc0.d (выключение) и rc6.d
# (перезагрузка). В этих каталогах скрипты всегда вызываются с параметром
# 'stop' не зависимо от имени ссылки.

INITTAB="/etc/inittab"
if [ -f "${INITTAB}" ]; then
    mv "${INITTAB}" "${INITTAB}.old"
fi

cat << EOF > "${INITTAB}"
# Begin ${INITTAB}

# default run-level
# run all scripts in /etc/rc.d/rc?.d, where '?' is the run level
id:3:initdefault:

# run all scripts in /etc/rc.d/rcS.d
si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

# three virtual consoles are more than enough :)
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
# 4:2345:respawn:/sbin/agetty tty4 9600
# 5:2345:respawn:/sbin/agetty tty5 9600
# 6:2345:respawn:/sbin/agetty tty6 9600

# End ${INITTAB}
EOF

cp "${INITTAB}" "${TMP_DIR}/etc/"
config_file_processing "${INITTAB}"

###
# Конфигурация системных часов
###
# Скрипт /etc/rc.d/init.d/setclock запускается через udev, когда ядро
# обнаруживает аппаратные средства при загрузке системы. Он считывает время с
# аппаратных часов (с BIOS или CMOS). Если аппаратные часы установлены в UTC,
# этот скрипт преобразует аппаратное время в локальное используя файл
# /etc/localtime, который сообщает программе hwclock часовой пояс пользователя.
# Нет никакого способа определить, установлены ли аппаратные часы в UTC,
# поэтому их необходимо настраивать вручную в BIOS. Вывести время аппаратных
# часов можно командой
#    # hwclock --localtime --show
# а вывести локальное время, с учетом часового пояса, можно командой
#    # hwclock --show

# Если же аппаратные часы не установлены в UTC (в BIOS установлено локальное
# время), то в /etc/sysconfig/clock нужно установить UTC=0 Так же параметры
# CLOCKPARAMS и UTC могут быть установлены в /etc/sysconfig/rc.site

ETC_CLOCK="/etc/sysconfig/clock"
if [ -f "${ETC_CLOCK}" ]; then
    mv "${ETC_CLOCK}" "${ETC_CLOCK}.old"
fi

cat << EOF > "${ETC_CLOCK}"
# Begin ${ETC_CLOCK}

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End ${ETC_CLOCK}
EOF

cp "${ETC_CLOCK}" "${TMP_DIR}/etc/sysconfig/"
config_file_processing "${ETC_CLOCK}"

###
# Конфигурация консоли
###
# Скрипт /etc/rc.d/init.d/console устанавливает раскладку клавиатуры, шрифт и
# уровень логирования сообщений ядра для консоли. Все эти параметры настройки
# он берет из файла конфигурации /etc/sysconfig/console
# Этот конфиг контролирует только текстовую консоль Linux и не имеет ничего
# общего с настройкой графических терминалов в X Window System

# Параметры для /etc/sysconfig/console
# ------------------------------------
# LOGLEVEL           - уровень логирования сообщений ядра отправляемых в dmesg
#                       (от 1 - без сообщений, до 8. По умолчанию 7)
# KEYMAP             - аргументы для программы loadkeys, которая загружает
#                       раскладку клавиатуры (имя таблицы ключей) из
#                       /usr/share/keymaps/. Если эта переменная не
#                       установлена, загрузочный скрипт не запустит программу
#                       loadkeys и будет использоваться раскладка установленная
#                       в ядре по умолчанию. Если несколько таблиц имеют
#                       одинаковое имя, но находятся в разных директориях,
#                       например 'cz' и его варианты в qwerty/ и qwertz/, то
#                       нужно указывать родительский каталог qwerty/cz, чтобы
#                       гарантировать, что загружена правильная таблица ключей
# KEYMAP_CORRECTIONS - эта редко используемая переменная указывает аргументы
#                       для второго вызова loadkeys. Иногда это требуется для
#                       корректировки. Например, чтобы включить знак 'евро' в
#                       раскладке клавиатуры, в которой его нет, установим эту
#                       переменную в "euro2"
# FONT               - указывает аргументы для программы setfont. Как правило,
#                       включает в себя имя шрифта, которые находятся в
#                       /usr/share/consolefonts
# UNICODE            - установка в '1', 'yes' или 'true' включает UTF-8 режим
#                       консоли
# LEGACY_CHARSET     - для многих раскладок клавиатуры нет стандартной Unicode
#                       раскладки в пакете kbd. Загрузочный скрипт преобразует
#                       доступную раскладку в UTF-8 на лету, если эта
#                       переменная установлена в кодировку не UTF-8

CONSOLE="/etc/sysconfig/console"
if [ -f "${CONSOLE}" ]; then
    mv "${CONSOLE}" "${CONSOLE}.old"
fi

cat << EOF > "${CONSOLE}"
# Begin ${CONSOLE}

UNICODE="1"

### layout
# /usr/share/keymaps/i386/qwerty/ruwin_cplk-UTF-8.map.gz
KEYMAP="ruwin_cplk-UTF-8"

### font
# fonts testing in the console
#    $ setfont /path/to/font.ext.gz
#    for example:
#    $ setfont -v /usr/share/consolefonts/ter-v14n.psf.gz
#
# display all characters (glyphs) of the current font
#    $ showconsolefont
#
# install the font from the terminus-font package (specify only the name)
# /usr/share/consolefonts/ter-v14n.psf.gz
FONT="ter-v14n"

# End ${CONSOLE}
EOF

cp "${CONSOLE}" "${TMP_DIR}/etc/sysconfig/"
config_file_processing "${CONSOLE}"

###
# Создание файлов при загрузке
###
# Иногда во время загрузки желательно создавать файлы/каталоги, например
# каталоги /tmp/.ICE-unix и /tmp/.X11-unix Это можно сделать, создав запись в
# скрипте конфигурации /etc/sysconfig/createfiles. Этот файл уже установлен с
# пакетом lfs-bootscripts и его синтаксис описан в нем.

# удалим последнюю строку из конфига: "# End /etc/sysconfig/createfiles"
sed -i '$ d' /etc/sysconfig/createfiles
# и допишем в конец файла
cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix    dir    1777    root    root
/tmp/.X11-unix    dir    1777    root    root

# End /etc/sysconfig/createfiles
EOF

###
# Настройка сценариев загрузки и завершения работы
###
# сценарии загрузки LFS загружают и выключают систему довольно эффективным
# способом, но есть несколько настроек, которые можно сделать в файле
# /etc/sysconfig/rc.site для увеличения скорости

# команда udev_retry при загрузке обычно требуется только если каталог /var
# монтируется как отдельный раздел. Отменим ее запуск
sed -i 's/.*OMIT_UDEV_RETRY_SETTLE.*/OMIT_UDEV_RETRY_SETTLE=yes/' \
    /etc/sysconfig/rc.site

# по умолчанию проверка файловой системы утилитой fsck во время загрузки ничего
# не выводит в консоль. Такое поведение может создавать ощущение паузы во время
# процесса загрузки. Включим вывод утилиты fsck
sed -i 's/.*VERBOSE_FSCK.*/VERBOSE_FSCK=yes/' /etc/sysconfig/rc.site

# при перезагрузке можно полностью пропустить проверку файловой системы, если
# создать файл /fastboot, либо перезагрузить систему с помьщью команды
#    # shutdown -f -r now
# Так же можно принудительно проверить все файловые системы, создав файл
# /forcefsck или запустив
#    # shutdown -F [-r] now
# Установка переменной FASTBOOT=y в файле /etc/sysconfig/rc.site отключит fsck
# во время процесса загрузки, но это не рекомендуется делать на постоянной
# основе.

# как правило, все файлы в каталоге /tmp удаляются во время загрузки, что
# увеличивает общее время загрузки. Отключим очистку директории /tmp
sed -i 's/.*SKIPTMPCLEAN.*/SKIPTMPCLEAN=yes/' /etc/sysconfig/rc.site

# во время выключения системы программа init посылает сигнал TERM каждой
# запущенной программе, затем ждет установленного таймаута (по умолчанию 3
# секунды). Этот таймаут можно отключить
#    # shutdown -t0 -r now
# или установить KILLDELAY=0 в файле /etc/sysconfig/rc.site
sed -i 's/.*KILLDELAY.*/KILLDELAY=0/' /etc/sysconfig/rc.site

cat << EOF > "/var/log/packages/${PRGNAME}"
# Package: ${PRGNAME} (System V configuration)
#
# /etc/inittab
# /etc/sysconfig/clock
# /etc/sysconfig/console
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}"

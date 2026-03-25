#! /bin/bash

PRGNAME="syshealth-utils"

#
# Version: 1.0.0 [25.03.2026]
# Author:  MyRequiem <mrvladislavovich@gmail.com>
#

### syshealth-utils (System Health and Audit Utilities)
# Комплексная проверка состояния LFS-системы.
#
# Состав пакета (Python и Bash скрипты):
#    check-rc-duplicates
#    check-system-deps
#    check-system-health
#    find-new-config
#    remove-la-files.sh
#    removepkg
#
###
# --------------------
# check-rc-duplicates
# --------------------
#    Выявляет дубликаты и «битые» ссылки в директориях инициализации системы
#    /etc/rc.d/rcX.d/, т.е. когда несколько разных ссылок в одной директории
#    ведут на один и тот же исполняемый скрипт (например, если вы случайно
#    создали лишнюю ссылку при настройке уровня загрузки), или ссылка ведет на
#    несуществующий скрипт в /etc/rc.d/init.d/
#
#    Результат выводит в "удобочитаемом" виде:
#       $ check-rc-duplicates
#
#       [ Directory: /etc/rc.d/rc4.d ]
#       Duplicate links for target: sshd
#         -> S30sshd      (Modified: 24-03-2026 05:58:46)
#         -> S32sshd      (Modified: 25-03-2026 01:48:10)
#       ------------------------------
#       Review the red entries and remove outdated links manually.
#       ------------------------------
#
#    Параметры:
#       -h, --help:    Выводит справку по использованию скрипта.
#       -v, --verbose: Расширенный режим. Помимо ошибок, выводит полный список
#                      всех найденных ссылок в каждой директории.
###
# --------------------
# check-system-deps
# --------------------
#    Проверяет целостность системных библиотек и исполняемых файлов (формата
#    ELF). Помогает убедиться, что все программы в LFS-системе имеют
#    необходимые зависимости и не выдают ошибок из-за отсутствующих файлов или
#    конфликтов версий через ldd.
#
#    Выводит статистику качества системы в виде:
#       $ check-system-deps
#       Starting dependency check...
#       opt/
#       /usr/bin/
#       /usr/lib/
#       /usr/libexec/
#       /usr/sbin/
#       ------------------------------
#       Total ELF files checked: 7971
#       Dependency integrity: 100.00%
#       ------------------------------
#       Congratulations! No dependency problems were found.
#
#       $ check-system-deps /usr/bin/python3
#       Starting dependency check...
#       ------------------------------
#       Total ELF files checked: 1
#       Dependency integrity: 100.00%
#       ------------------------------
#       Congratulations! No dependency problems were found.
#
#    Логирует ошибки: если найдены проблемы, отчет выводится в консоль во время
#                       работы скрипта и сохраняется в лог
#                       /tmp/check-system-deps.py.log
#
#    Параметры:
#       -h, --help: Выводит справку по использованию скрипта.
#       [target]:   Путь к конкретному файлу или директории, которые вы хотите
#                   проверить (опционально). Если не указан, скрипт проверит
#                   все стандартные системные пути.
#
###
# --------------------
# check-system-health
# --------------------
#    Проверяет целостность установленных в системе пакетов. Сверяет файлы,
#    фактически находящиеся на диске, со списками файлов, которые были
#    зафиксированы при установке каждого пакета в /var/log/packages/. Это
#    отличный способ найти случайно удаленные библиотеки или бинарные файлы.
#
#    Вывод в виде:
#       $ ./check-system-health
#       ------------------------------
#       Total packages: 746
#       Total files checked: 341025
#       System integrity: 100.00%
#       ------------------------------
#       Congratulations! All package files are in place.
#       ------------------------------
#
#       $ ./check-system-health /var/log/packages/mirage-0.11.2
#       ------------------------------
#       Total packages: 1
#       Total files checked: 77
#       System integrity: 100.00%
#       ------------------------------
#       Congratulations! All package files are in place.
#       ------------------------------
#
#    Если файл отсутствует, скрипт выводит название «пострадавшего» пакета и
#    путь к потерянному файлу. Записывает все найденные несоответствия в лог
#    /tmp/check-system-health-log.txt
#
#    Параметры:
#       -h, --help:     Выводит справку по использованию скрипта.
#       [package_path]: Путь к конкретному пакету (опционально). Например,
#                       /var/log/packages/bash-5.2 Если параметр не указан,
#                       скрипт проверит все пакеты в системе.
###
# --------------------
# find-new-config
# --------------------
#    Сканирует директорию /etc на наличие конфигурационных файлов с
#    расширениями .new и .old. Такие файлы обычно создаются при обновлении
#    пакетов, чтобы избежать автоматической перезаписи существующих
#    пользовательских настроек.
#
#    Помогает администратору решить, следует ли сохранить, объединить
#    или удалить избыточные файлы конфигурации.
#
#    Вывод в виде:
#       $ find-new-config
#       /etc/ssh/sshd_config.new
#       /etc/ssh/ssh_config.new
###
# --------------------
# remove-la-files.sh
# --------------------
#    Находит и перемещает файлы архивов libtool (.la) в директорию
#    /var/log/removed_la_files/. В современных дистрибутивах Linux эти файлы
#    зачастую являются избыточными и могут вызывать проблемы при линковке или
#    обновлении системы.
####
# --------------------
# removepkg
# --------------------
#    Корректно удаляет установленный пакет из системы. Утилита анализирует лог
#    установки пакета в /var/log/packages/, удаляет все связанные с ним файлы
#    и пустые директории, а также обновляет системную базу данных
#    установленного ПО.
#
#    Предотвращает появление «осиротевших» файлов и нарушение целостности
#    файловой системы после удаления программ.
#
#    Параметры:
#       -h, --help: Выводит справку по использованию скрипта.
#       --fake:     Режим тестирования (Dry run): выводит в стандартный поток
#                   список файлов и директорий, которые были бы удалены, но
#                   фактически не удаляет пакет из системы.
#       --backup:   Полная копия структуры пакета воссоздается в директории
#                   /var/log/setup/tmp/preserved/pkgname-version_date_time,
#                   после чего пакет удаляется из системы.
#       --copy:     Полная копия структуры пакета воссоздается в директории
#                   /var/log/setup/tmp/preserved/pkgname-version_date_time, но
#                   сам пакет при этом не удаляется из системы.
#       --no-color: Отключает цветной вывод в консоль.
###

source "/check_environment.sh" || exit 1

SCRIPTS="
check-rc-duplicates \
check-system-deps \
check-system-health \
find-new-config \
remove-la-files.sh \
removepkg \
"

for SCRIPT in ${SCRIPTS} ; do
    ! [ -r "/${SCRIPT}" ] && {
        echo "Error: /${SCRIPT} not found."
        exit 1
    }
done

for SCRIPT in ${SCRIPTS} ; do
    install -v -m 754 -o root -g root "/${SCRIPT}" /usr/sbin/
done

cat << EOF > "/var/log/packages/${PRGNAME}"
# Package: ${PRGNAME} (System Health and Audit Utilities)
#
# A collection of Python and Bash scripts designed to audit and maintain the
# integrity of a Linux system. It includes tools to check for duplicate or
# broken RC links, verify ELF binary dependencies using ldd, and
# cross-reference installed package logs with actual files on the disk.
#
# These utilities help ensure system consistency by identifying missing
# libraries or broken package installations.
#
# Included tools:
#    * check-rc-duplicates - Finds duplicate or broken runlevel links in the
#                               /etc/rc.d/rcX.d/
#    * check-system-deps   - Verifies ELF binary dependencies via ldd.
#    * check-system-health - Validates files against package logs.
#    * find-new-config     - Searches for .new and .old configuration files in
#                               the /etc directory.
#    * remove-la-files.sh  - Strips libtool archives (.la) from the system.
#    * removepkg           - Properly uninstalls packages from the system.
#
/usr/sbin/check-rc-duplicates
/usr/sbin/check-system-deps
/usr/sbin/check-system-health
/usr/sbin/find-new-config
/usr/sbin/remove-la-files.sh
/usr/sbin/removepkg
EOF

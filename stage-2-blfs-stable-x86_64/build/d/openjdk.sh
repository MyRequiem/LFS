#! /bin/bash

PRGNAME="openjdk"
ARCH_NAME="jdk"

### OpenJDK (Open Implementation of Java Development Kit)
# Бесплатная сборка платформы Java с открытым исходным кодом, необходимая для
# разработки и запуска Java-приложений. Включает в себя виртуальную машину
# (JRE) для выполнения программ, базовый набор библиотек, а также инструменты
# разработчика, такие как компилятор (javac) и средства отладки.

# Required:    alsa-lib
#              cpio
#              libcups или cups
#              libarchive
#              which
#              xorg-libraries
#              zip
# Recommended: make-ca
#              giflib
#              harfbuzz
#              lcms2
#              libjpeg-turbo
#              libpng
#              wget
# Optional:    git
#              graphviz
#              mercurial
#              ccache               (https://ccache.dev/)
#              pandoc               (https://pandoc.org/)
#              pigz                 (https://zlib.net/pigz/)

###
# ВАЖНОЕ ОБНОВЛЕНИЕ:
#    Переход на Java LTS (Long-Term Support) в LFS >=13.0
###
# LTS - это версия с долгосрочной поддержкой. В мире Java релизы выходят каждые
# полгода. Обычные версии (Java 24 или 26) - это «экспериментальные площадки».
# Они живут всего 6 месяцев, после чего разработчики бросают их обновлять.
# LTS-версии (такие как Java 21 или 25) - это железобетонные стандарты
# индустрии. Они официально поддерживаются и получают патчи безопасности годами
# (3 - 5 лет).
#
# ==============================================================================
# ПОЧЕМУ НАЧИНАЯ С LFS-13.0 Я УХОЖУ с JAVA 26 НА JAVA 25 LTS:
# -----------------------------------------------------------
# 1. Стабильность: Сидеть на версиях вроде Java 24 или 26 в кастомном
#    дистрибутиве - это вечная «гонка по граблям». Как только выходит новая
#    версия, старая моментально устаревает, и нам приходится пересобирать
#    пакеты. При этом свежие Java часто ломают совместимость со старым софтом,
#    удаляя нужные функции. С LTS версией любые сторонние программы, утилиты
#    сборки и системные пакеты гарантированно запустятся и не упадут с ошибкой.
#    Я выбрал стабильную базу, чтобы дистрибутив работал как швейцарские часы,
#    а не требовал бесконечного напильника каждые 6 месяцев.
# 2. Совместимость: Большинство Linux-утилит и сборщиков (Gradle/Maven)
#    заточены под LTS.
# 3. Фиксация базы: Уходим от гонки за мажорными версиями каждые полгода,
#    чтобы не переписывать скрипты дистрибутива на ровном месте.
# ==============================================================================

####
# Где берем архивы:
####
# Бинарники:
# ---------
# Официальное сборочное правило для OpenJDK звучит строго: для сборки версии N
# в качестве Boot JDK допускается использовать только версию N или N-1. Т.е.
# если исходники версии 25, то версия бинарников должна быть 24 или 25.
#
# https://www.oracle.com/java/technologies/downloads/
# Жмем кнопу: [OpenJDK Early Access Builds], попадаем на
# https://jdk.java.net/
#    Версии из раздела Ready for use - стабильные последние релизы
#    Версии из раздела Early access  - предварительные сборки (в разработке)
#
# Нам нужна LTS версия 25 а не последний релиз, идем в архив:
# https://jdk.java.net/archive/
#
#   25.0.2 (build 25.0.2+10)
#       Windows         64-bit	zip 22167196     (sha256)
#       Mac/AArch64     64-bit  tar.gz 215449592 (sha256)
#       Mac/x64         64-bit  tar.gz 217744020 (sha256)
#       Linux/AArch64   64-bit  tar.gz 220266156 (sha256)
#     * Linux/x64       64-bit  tar.gz 222522097 (sha256)
#     *                 Source  Tag    jdk-25.0.2-ga
#
# Скачиваем бинарники (Linux/x64) и исходники по ссылке Source (ведет на
# GitHub, там ищем по указанному Tag - jdk-25.0.2-ga):
# https://download.java.net/java/GA/jdk25.0.2/b1e0dfa218384cb9959bdcb897162d4e/10/GPL/openjdk-25.0.2_linux-x64_bin.tar.gz
# https://github.com/openjdk/jdk25u/archive/refs/tags/jdk-25.0.2-ga.tar.gz
#
# Суффикс '-ga' в названии архива исходников - это General Availability
# (общедоступный релиз), т.е. перед вами не тестовая, не пробная и не
# бета-версия, а полностью готовый и проверенный рабочий продукт, который
# официально выпущен для всех пользователей и разработчиков. Является аналогом
# «Релиз» - финальная точка в разработке конкретного обновления. Всё
# протестировано, стабильно и готово к установке на «живые» серверы и рабочие
# компьютеры.

### NOTE:
# После установки пакета нужно обновить переменные окружения
#    $ source /etc/profile.d/openjdk.sh
# или
#    выйти и зайти в учетную запись
#
# Проверка Java
#    $ cd /tmp
#    $ cat << EOF > "Test.java"
# public class Test {
#     public static void main(String[] args) {
#         System.out.println("Java is working fine");
#     }
# }
# EOF
#
#    $ javac Test.java
#    $ java Test

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 2 | rev)"

# Номер сборки (см. описание выше: build 25.0.2+10)
BIN_VER_PLUS="10"
PRGVERSION="${VERSION}_b${BIN_VER_PLUS}_lts"
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"

# Для компиляции openjdk и создания JVM (Java Virtual Machine) из исходного
# кода требуется Java Development Kit (JDK), который включает в себя java,
# javac, jar, некоторые другие инструменты и базовый набор JAR-файлов. Если он
# отсутствует в системе (устанавливаем openjdk в первый раз), установим его в
# виде уже готовых бинарных файлов в /opt
if ! command -v java &>/dev/null ; then
    pushd /opt || exit 1
    tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
    chown -R root:root "${ARCH_NAME}-${VERSION}"
    popd || exit 1

    # Настроим окружение:
    PATH=${PATH}:/opt/${ARCH_NAME}-${VERSION}/bin
    export PATH

    # Проверим наличие команды java после распаковки бинарников и настройки
    # окружения:
    if ! command -v java &>/dev/null ; then
        echo "java command not found !!!"
        exit 1
    fi
fi

BUILD_DIR="/tmp/build-${PRGNAME}-${PRGVERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}-ga".tar.?z* || exit 1
cd "${ARCH_NAME}${MAJ_VERSION}u-${ARCH_NAME}-${VERSION}-ga" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${PRGVERSION}"
PROFILE_D="/etc/profile.d"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"{"${PROFILE_D}","${APPLICATIONS}"}
mkdir -pv "${TMP_DIR}/opt/${PRGNAME}-${PRGVERSION}"

# Переменная PATH должна содержать путь к компилятору java - это единственное
# требование к среде окружения. Переменная JAVA_HOME в современных версиях не
# нужна и разработчики рекомендуют отключить ее при сборке.
unset JAVA_HOME
unset CLASSPATH
# Система сборки не допускает использования определения количества потоков
# компиляции посредством переменной окружения MAKEFLAGS (-jX) вместо этого
# используется параметр --with-jobs=<X> (по умолчанию = 1)
unset MAKEFLAGS

JOBS="$(($(nproc) - 2))"
bash configure                             \
    --enable-unlimited-crypto              \
    --disable-warnings-as-errors           \
    --with-stdc++lib=dynamic               \
    --with-giflib=system                   \
    --with-harfbuzz=system                 \
    --with-lcms=system                     \
    --with-libjpeg=system                  \
    --with-libpng=system                   \
    --with-zlib=system                     \
    --with-version-build="${BIN_VER_PLUS}" \
    --with-version-pre=""                  \
    --with-version-opt=""                  \
    --with-jobs="${JOBS}"                  \
    --with-cacerts-file=/etc/pki/tls/java/cacerts || exit 1

make images || exit 1

# Устанавливаем пакет во временную директорию:
cp -Rv build/linux-x86_64-server-release/images/jdk/* \
    "${TMP_DIR}/opt/${PRGNAME}-${PRGVERSION}/"
chown -R root:root "${TMP_DIR}/opt"

# icons
for ICON_SIZE in 16 24 32 48; do
    ICON_DIR="/usr/share/icons/hicolor/${ICON_SIZE}x${ICON_SIZE}/apps"
    mkdir -p "${TMP_DIR}${ICON_DIR}"
    install -vDm644 \
        "src/java.desktop/unix/classes/sun/awt/X11/java-icon${ICON_SIZE}.png" \
        "${TMP_DIR}${ICON_DIR}/java.png"
done

# Удалим *.debuginfo файлы:
find "${TMP_DIR}/opt/${PRGNAME}-${PRGVERSION}" \
    -type f -name "*.debuginfo" -delete

# openjdk-java.desktop
cat << EOF > "${TMP_DIR}${APPLICATIONS}/${PRGNAME}-java.desktop"
[Desktop Entry]
Name=OpenJDK Java ${VERSION} Runtime
Comment=OpenJDK Java ${VERSION} Runtime
Exec=/opt/${PRGNAME}-${PRGVERSION}/bin/java -jar
Terminal=false
Type=Application
Icon=java
MimeType=application/x-java-archive;application/java-archive;application/x-jar;
NoDisplay=true
EOF

# openjdk-jconsole.desktop
cat << EOF > "${TMP_DIR}${APPLICATIONS}/${PRGNAME}-jconsole.desktop"
[Desktop Entry]
Name=OpenJDK Java ${VERSION} Console
Comment=OpenJDK Java ${VERSION} Console
Keywords=java;console;monitoring
Exec=/opt/${PRGNAME}-${PRGVERSION}/bin/jconsole
Terminal=false
Type=Application
Icon=java
Categories=Application;System;
EOF

# сохраняем все сертификаты в одном месте
ln -sfv /etc/pki/tls/java/cacerts "${TMP_DIR}/opt/jdk/lib/security/cacerts"

# /etc/profile.d/openjdk.sh
OPENJDK_SH="${PROFILE_D}/${PRGNAME}.sh"
cat << EOF > "${TMP_DIR}${OPENJDK_SH}"
# Begin ${OPENJDK_SH}

# set JAVA_HOME directory
JAVA_HOME=/opt/${PRGNAME}-${PRGVERSION}

# adjust PATH
PATH=\${PATH}:\${JAVA_HOME}/bin

export JAVA_HOME PATH

# End ${OPENJDK_SH}
EOF
chmod 755 "${TMP_DIR}${OPENJDK_SH}"

# Удаляем установленные бинарники, которые использовались для сборки:
pushd /opt || exit 1
rm -rf "${ARCH_NAME}-${VERSION}"
popd || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${PRGVERSION}"
# Package: ${PRGNAME} (Open Implementation of Java Development Kit)
#
# OpenJDK is an open-source implementation of Oracle's Java Standard Edition
# platform. OpenJDK is useful for developing Java programs, and provides a
# complete runtime environment to run Java programs.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${ARCH_NAME}${MAJ_VERSION}u/archive/refs/tags/${ARCH_NAME}-${VERSION}-ga.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${PRGVERSION}"

#! /bin/bash

PRGNAME="openjdk"
ARCH_NAME="jdk"
BIN_VERSION="26"

### OpenJDK (Open Implementation of Java Development Kit)
# Реализация Oracle Java Standard Edition с открытым исходным кодом. OpenJDK
# используется для разработки Java-программ и предоставляет среду выполнения
# для запуска Java-программ

# Required:    alsa-lib
#              cpio
#              cups
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
#              ccache           (https://ccache.dev/)
#              pandoc           (https://pandoc.org/)
#              pigz             (https://zlib.net/pigz/)

### NOTE:
# После установки пакета нужно обновить переменные окружения
#    # source /etc/profile.d/openjdk.sh
# или
#    выйти и зайти в учетную запись
#
# Проверка Java
#    # cd /tmp
#    # cat << EOF > "Test.java"
# public class Test {
#     public static void main(String[] args) {
#         System.out.println("Java is working fine");
#     }
# }
# EOF
#
#    # javac Test.java
#    # java Test

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
# для компиляции openjdk и создания JVM (Java Virtual Machine) из исходного
# кода требуется Java Development Kit (JDK), который включает в себя java,
# javac, jar, некоторые другие инструменты и базовый набор JAR-файлов. Если он
# отсутствует в системе (устанавливаем openjdk в первый раз), установим его в
# виде уже готовых бинарных файлов в /opt
if ! command -v java &>/dev/null ; then
    (
        cd /opt || exit 1
        tar xvf "${SOURCES}/${PRGNAME}"*.tar.?z* || exit 1
        chown -R root:root "${ARCH_NAME}-${BIN_VERSION}"
        ln -svfn "${ARCH_NAME}-${BIN_VERSION}" "${ARCH_NAME}"
    )

    # настроим окружение
    PATH=${PATH}:/opt/${ARCH_NAME}/bin
    export PATH

    # проверим наличие команды java после распаковки бинарников и настройки
    # окружения
    if ! command -v java &>/dev/null ; then
        echo "java command not found !!!"
        exit 1
    fi
fi

VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

PRGVERSION="$(echo "${VERSION}" | tr + .)"
BUILD_DIR="/tmp/build-${PRGNAME}-${PRGVERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${ARCH_NAME}-$(echo "${VERSION}" | tr + -)" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${PRGVERSION}"
PROFILE_D="/etc/profile.d"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"{"${PROFILE_D}","${APPLICATIONS}"}
mkdir -pv "${TMP_DIR}/opt/${PRGNAME}-${PRGVERSION}"

# переменная PATH должна содержать путь к компилятору java - это единственное
# требование к среде окружения. Переменная JAVA_HOME в современных версиях не
# нужна и разработчики рекомендуют отключить ее при сборке
unset JAVA_HOME
unset CLASSPATH
# система сборки не допускает использования определения количества потоков
# компиляции посредством переменной окружения MAKEFLAGS (-jX)
# вместо этого используется параметр --with-jobs=<X> (по умолчанию = 1)
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

# удалим *.debuginfo файлы
DIR_WITH_COMPILED_FILES="./build/linux-x86_64-server-release/images/jdk"
find "${DIR_WITH_COMPILED_FILES}" -type f -name "*.debuginfo" -delete

# устанавливаем пакет во временную директорию
cp -Rv "${DIR_WITH_COMPILED_FILES}"/* "${TMP_DIR}/opt/${PRGNAME}-${PRGVERSION}/"
chown -R root:root "${TMP_DIR}/opt"

# icons
for ICON_SIZE in 16 24 32 48; do
    ICON_DIR="/usr/share/icons/hicolor/${ICON_SIZE}x${ICON_SIZE}/apps"
    mkdir -p "${TMP_DIR}${ICON_DIR}"
    install -vDm644 \
        "src/java.desktop/unix/classes/sun/awt/X11/java-icon${ICON_SIZE}.png" \
        "${TMP_DIR}${ICON_DIR}/java.png"
done

# ссылка в ${TMP_DIR}/opt/
#    jdk -> openjdk-${VERSION}
ln -svf "${PRGNAME}-${PRGVERSION}" "${TMP_DIR}/opt/${ARCH_NAME}"

# сохраняем все сертификаты в одном месте
(
    cd "${TMP_DIR}/opt/${PRGNAME}-${PRGVERSION}/lib/security" || exit 1
    ln -sfvn /etc/pki/tls/java/cacerts cacerts
)

# openjdk-java.desktop
cat << EOF > "${TMP_DIR}${APPLICATIONS}/${PRGNAME}-java.desktop"
[Desktop Entry]
Name=OpenJDK Java ${PRGVERSION} Runtime
Comment=OpenJDK Java ${PRGVERSION} Runtime
Exec=/opt/jdk/bin/java -jar
Terminal=false
Type=Application
Icon=java
MimeType=application/x-java-archive;application/java-archive;application/x-jar;
NoDisplay=true
EOF

# openjdk-jconsole.desktop
cat << EOF > "${TMP_DIR}${APPLICATIONS}/${PRGNAME}-jconsole.desktop"
[Desktop Entry]
Name=OpenJDK Java ${PRGVERSION} Console
Comment=OpenJDK Java ${PRGVERSION} Console
Keywords=java;console;monitoring
Exec=/opt/jdk/bin/jconsole
Terminal=false
Type=Application
Icon=java
Categories=Application;System;
EOF

# /etc/profile.d/openjdk.sh
OPENJDK_SH="${PROFILE_D}/${PRGNAME}.sh"
cat << EOF > "${TMP_DIR}${OPENJDK_SH}"
# Begin ${OPENJDK_SH}

# set JAVA_HOME directory
JAVA_HOME=/opt/${ARCH_NAME}

# adjust PATH
PATH=\${PATH}:\${JAVA_HOME}/bin

export JAVA_HOME PATH

# End ${OPENJDK_SH}
EOF
chmod 755 "${TMP_DIR}${OPENJDK_SH}"

# удаляем установленные бинарники, которые использовались для сборки
(
    cd /opt || exit 1
    rm -rf "${ARCH_NAME}" "${ARCH_NAME}-${BIN_VERSION}"
)

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
# Download:  https://github.com/${PRGNAME}/${ARCH_NAME}/archive/refs/tags/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${PRGVERSION}"

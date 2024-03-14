#! /bin/bash

PRGNAME="openjdk"
VERSION_BUILD="7"

### OpenJDK (Open Implementation of Java Development Kit)
# Реализация Oracle Java Standard Edition с открытым исходным кодом. OpenJDK
# используется для разработки Java-программ и предоставляет среду выполнения
# для запуска Java-программ

# Required:    alsa-lib
#              cpio
#              cups
#              unzip
#              which
#              xorg-libraries
#              zip
# Recommended: make-ca
#              giflib
#              lcms2
#              libjpeg-turbo
#              libpng
#              wget
# Optional:    git
#              graphviz
#              mercurial
#              pandoc (https://pandoc.org/)

### NOTE:
# После установки пакета нужно обновить переменные окружения
#    # source /etc/profile.d/openjdk.sh
# или
#    # source /etc/profile
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
#
# Обновим man-базу данных
#    # mandb -c /opt/jdk/man
#    проверим:
#    # man java

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
BIN_ARCH_NAME="jdk"
VERSION="$(find "${SOURCES}" -type f \
    -name "${BIN_ARCH_NAME}-*-ga.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    cut -d - -f 2)"

# для компиляции openjdk и создания JVM (Java Virtual Machine) из исходного
# кода требуется Java Development Kit (JDK), который включает в себя java,
# javac, jar, некоторые другие инструменты и базовый набор JAR-файлов. Если он
# отсутствует в системе (устанавливаем openjdk в первый раз), установим его в
# виде уже готовых бинарных файлов в /opt
if ! command -v java &>/dev/null ; then
    (
        echo "Install JDK-bin"
        cd /opt || exit 1
        rm -rf ./${BIN_ARCH_NAME}*
        # распаковываем архив с бинарниками
        #    openjdk-${VERSION}_linux-x64_bin.tar.gz -> jdk-${VERSION}
        tar xvf \
            "${SOURCES}/${PRGNAME}-${VERSION}_linux-x64_bin".tar.?z* || exit 1
        chown -R root:root "${BIN_ARCH_NAME}-${VERSION}"
        # ссылка в /opt
        #    jdk -> jdk-${VERSION}
        ln -svfn "${BIN_ARCH_NAME}-${VERSION}" "${BIN_ARCH_NAME}"
    )

    # настроим окружение
    PATH=${PATH}:/opt/${BIN_ARCH_NAME}/bin
    export PATH

    # проверим наличие команды java после распаковки бинарников и настройки
    # окружения
    if ! command -v java &>/dev/null ; then
        echo "java command not found !!!"
        exit 1
    fi
fi

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

# распаковываем исходники
#    jdk-${VERSION}-ga.tar.gz -> jdk15u-jdk-${VERSION}-ga
tar xvf "${SOURCES}/${BIN_ARCH_NAME}-${VERSION}-ga".tar.?z* || exit 1
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cd "${BIN_ARCH_NAME}${MAJ_VERSION}u-${BIN_ARCH_NAME}-${VERSION}-ga" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
PROFILE_D="/etc/profile.d"
SUDOERS_D="/etc/sudoers.d"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"{"${PROFILE_D}","${SUDOERS_D}","${APPLICATIONS}"}
mkdir -pv "${TMP_DIR}/opt/${PRGNAME}-${VERSION}"

# сохраняем все сертификаты в одном месте
ln -sfvn /etc/pki/tls/java/cacerts /opt/jdk/lib/security/cacerts

# Переменная PATH должна содержать путь к компилятору Java - это единственное
# требование к среде окружения. Переменная JAVA_HOME не нужна, а CLASSPATH не
# используется. Так же система сборки не допускает использование ключа -j в
# MAKEFLAGS
unset MAKEFLAGS
unset JAVA_HOME

# отключаем использование -Werror в сборке
#    --disable-warnings-as-errors
# система сборки ссылается на динамический libstdc++.so, а не на статический
# libstdc++.a
#    --with-stdc++lib=dynamic
# указываем количество потоков сборки вместо MAKEFLAGS и параметра -jX
# (по умолчанию система сборки использует один поток)
#    --with-jobs="$(nproc)"
# используем системные версии библиотек
#    --with-{giflib,lcms,libjpeg,libpng,zlib}=system
# префикс, добавляемый к строке версии
#    --with-version-pre
# необязательное описание сборки, добавляемое в строку версии
#    --with-version-opt
# в настоящее время система сборки не включает номер сборки в строку версии (java -version)
#    --with-version-build
bash configure                              \
    --enable-unlimited-crypto               \
    --disable-warnings-as-errors            \
    --with-stdc++lib=dynamic                \
    --with-jobs="$(nproc)"                  \
    --with-giflib=system                    \
    --with-lcms=system                      \
    --with-libjpeg=system                   \
    --with-libpng=system                    \
    --with-zlib=system                      \
    --with-version-pre=""                   \
    --with-version-opt=""                   \
    --with-version-build="${VERSION_BUILD}" \
    --with-cacerts-file=/etc/pki/tls/java/cacerts || exit 1

make images || exit 1

# удалим *.debuginfo файлы
DIR_WITH_COMPILED_FILES="./build/linux-x86_64-server-release/images/jdk"
find "${DIR_WITH_COMPILED_FILES}" -type f -name "*.debuginfo" -delete

### устанавливаем пакет во временную директорию /opt
cp -Rv "${DIR_WITH_COMPILED_FILES}"/* "${TMP_DIR}/opt/${PRGNAME}-${VERSION}"
chown -R root:root "${TMP_DIR}/opt"

# ссылка в /opt
#    jdk -> openjdk-${VERSION}
(
    cd "${TMP_DIR}/opt" || exit 1
    ln -svf "${PRGNAME}-${VERSION}" "${BIN_ARCH_NAME}"
)

# icons
for ICON_SIZE in 16 24 32 48; do
    ICON_DIR="/usr/share/icons/hicolor/${ICON_SIZE}x${ICON_SIZE}/apps"
    mkdir -p "${TMP_DIR}${ICON_DIR}"
    install -vDm644 \
        "src/java.desktop/unix/classes/sun/awt/X11/java-icon${ICON_SIZE}.png" \
        "${TMP_DIR}${ICON_DIR}/java.png"
done

# сохраняем все сертификаты в одном месте
(
    cd "${TMP_DIR}/opt/${PRGNAME}-${VERSION}/lib/security" || exit 1
    ln -sfvn /etc/pki/tls/java/cacerts cacerts
)

# openjdk-java.desktop
cat << EOF > "${TMP_DIR}${APPLICATIONS}/openjdk-java.desktop"
[Desktop Entry]
Name=OpenJDK Java ${VERSION} Runtime
Comment=OpenJDK Java ${VERSION} Runtime
Exec=/opt/jdk/bin/java -jar
Terminal=false
Type=Application
Icon=java
MimeType=application/x-java-archive;application/java-archive;application/x-jar;
NoDisplay=true
EOF

# openjdk-jconsole.desktop
cat << EOF > "${TMP_DIR}${APPLICATIONS}/openjdk-jconsole.desktop"
[Desktop Entry]
Name=OpenJDK Java ${VERSION} Console
Comment=OpenJDK Java ${VERSION} Console
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
JAVA_HOME=/opt/${BIN_ARCH_NAME}

# adjust PATH
PATH=\${PATH}:\${JAVA_HOME}/bin

# add to MANPATH
MANPATH=\${MANPATH}:\${JAVA_HOME}/man

AUTO_CLASSPATH_DIR=/usr/share/java

CLASSPATH="."

JDIRS="\$(find \${AUTO_CLASSPATH_DIR} -type d 2>/dev/null)"
for JDIR in \${JDIRS}; do
    CLASSPATH=\${CLASSPATH}:\${JDIR}
done

JJARS="\$(find \${AUTO_CLASSPATH_DIR} -name "*.jar" 2>/dev/null)"
for JJAR in \${JJARS}; do
    CLASSPATH=\${CLASSPATH}:\${JJAR}
done

export JAVA_HOME PATH MANPATH CLASSPATH
unset AUTO_CLASSPATH_DIR JDIR JDIRS JJAR JJARS

# End ${OPENJDK_SH}
EOF
chmod 755 "${TMP_DIR}${OPENJDK_SH}"

# настройки sudo: root должен иметь доступ к переменным JAVA_HOME и CLASSPATH
SUDOERS_JAVA="/etc/sudoers.d/java"
cat << EOF > "${TMP_DIR}${SUDOERS_JAVA}"
Defaults env_keep += JAVA_HOME
Defaults env_keep += CLASSPATH
EOF
chmod 644 "${TMP_DIR}${SUDOERS_JAVA}"

# настройка mandb (добавляем в конфиг man_db.conf пути для Java)
MAN_DB_CONF="/etc/man_db.conf"
if [ -r "${MAN_DB_CONF}" ]; then
    if ! grep "/opt/${BIN_ARCH_NAME}" "${MAN_DB_CONF}" &>/dev/null; then
        cat << EOF >> "${MAN_DB_CONF}"

# Begin Java addition
MANDATORY_MANPATH     /opt/${BIN_ARCH_NAME}/man
MANPATH_MAP           /opt/${BIN_ARCH_NAME}/bin  /opt/${BIN_ARCH_NAME}/man
MANDB_MAP             /opt/${BIN_ARCH_NAME}/man  /var/cache/man/${BIN_ARCH_NAME}
# End Java addition
EOF
    fi
fi

mkdir -p "${TMP_DIR}/var/cache/man"

# удаляем установленные бинарники, которые использовались для сборки
rm -rf "/opt/${BIN_ARCH_NAME}"*

# удалим директорию с пакетом, если такая версия уже установлена
rm -rf "/opt/${PRGNAME}-${VERSION}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Open Implementation of Java Development Kit)
#
# OpenJDK is an open-source implementation of Oracle's Java Standard Edition
# platform. OpenJDK is useful for developing Java programs, and provides a
# complete runtime environment to run Java programs.
#
# Home page: http://${PRGNAME}.java.net/
# Download:  https://github.com/${PRGNAME}/${BIN_ARCH_NAME}15u/archive/${BIN_ARCH_NAME}-${VERSION}-ga.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

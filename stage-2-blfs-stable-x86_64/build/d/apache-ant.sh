#! /bin/bash

PRGNAME="apache-ant"

### apache-ant (Java-based build tool)
# Инструмент для автоматизации процесса сборки программных продуктов на основе
# Java. Является кросс-платформенным аналогом утилиты make, где все команды
# записываются в XML-формате.

# Required:    openjdk
#              glib
# Recommended: no
# Optional:    no

### Конфигурация
#    /etc/ant/ant.conf
#    ~/.ant/ant.conf
#    ~/.antrc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}-src".tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{opt,/etc/profile.d}

# устраним проблему несовместимости стандарта документации, используемого в
# сборке openjdk
sed -i 's/--add-modules java.activation/-html4/' build.xml || exit 1

./bootstrap.sh

# загружает недостающии runtime-зависимости в домашнюю директорию, которые
# затем копируются в дерево исходников lib/optional
bootstrap/bin/ant -f fetch.xml -Ddest=optional

# собирает, тестирует, а затем устанавливает пакет в свой временный каталог
./build.sh \
    -Ddist.dir="${PWD}/ant-${VERSION}" dist

# устанавливаем
cp -rv  "ant-${VERSION}" "${TMP_DIR}/opt/"
ln -sfv "ant-${VERSION}" "${TMP_DIR}/opt/ant"
chown -R root:root       "${TMP_DIR}/opt/"

ANT_SH="/etc/profile.d/ant.sh"
cat << EOF > "${TMP_DIR}${ANT_SH}"
# Begin ${ANT_SH}

PATH=\$PATH:/opt/ant/bin
export ANT_HOME=/opt/ant

# End ${ANT_SH}
EOF
chmod 755 "${TMP_DIR}${ANT_SH}"

rm -rf /root/.{ant/tempcache,m2}
rm -f /opt/ant

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Java-based build tool)
#
# The Apache Ant package is a Java-based build tool. In theory, it is like the
# make command, but without make's wrinkles. Ant is different. Instead of a
# model that is extended with shell-based commands, Ant is extended using Java
# classes. Instead of writing shell commands, the configuration files are
# XML-based, calling out a target tree that executes various tasks. Each task
# is run by an object that implements a particular task interface.
#
# Home page: https://ant.apache.org/
# Download:  https://archive.apache.org/dist/ant/source/${PRGNAME}-${VERSION}-src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

#! /bin/bash

PRGNAME="glew"

### GLEW (the OpenGL Extension Wrangler Library)
# Кроссплатформенная C++ библиотека OpenGL Extension Wrangler (GLEW),
# предоставляющая эффективные механизмы для определения поддерживаемых
# расширений OpenGL и их загрузки

# Required:    mesa
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# библиотеку устанавливаем в /usr/lib/
sed -i 's%lib64%lib%g' config/Makefile.linux || exit 1

# не создаем статическую библиотеку
sed -i -e '/glew.lib.static:/d' \
       -e '/0644 .*STATIC/d'    \
       -e 's/glew.lib.static//' Makefile || exit 1

make || exit 1
# пакет не имеет набора тестов

# install.all - устанавливаем библиотеку libGLEW.so и утилиты 'glewinfo' и
# 'visualinfo'
make install.all DESTDIR="${TMP_DIR}"

chmod 755 "${TMP_DIR}/usr/lib/libGLEW.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the OpenGL Extension Wrangler Library)
#
# The OpenGL Extension Wrangler Library (GLEW) is a cross-platform open-source
# C/C++ extension loading library. GLEW provides efficient run-time mechanisms
# for determining which OpenGL extensions are supported on the target platform.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

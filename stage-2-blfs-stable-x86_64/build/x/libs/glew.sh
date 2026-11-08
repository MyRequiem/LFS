#! /bin/bash

PRGNAME="glew"

### GLEW (the OpenGL Extension Wrangler Library)
# Инструмент, который помогает графическим программам определять возможности
# видеокарты и использовать современные расширения OpenGL. Это фундамент для
# игр и 3D - редакторов, позволяющий им работать на полную мощность.

# Required:    mesa
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Библиотеку устанавливаем в /usr/lib/
sed -i 's%lib64%lib%g' config/Makefile.linux || exit 1

# Не устанавлиаваем статическую библиотеку, пакет устанавливаем в /usr
sed -e '/glew.lib.static:/d' \
    -e '/0644 .*STATIC/d'    \
    -e 's/glew.lib.static//' \
    -e 's|/local||' -i Makefile || exit 1

make || exit 1
# Пакет не имеет набора тестов.

# Устанавливаем библиотеку libGLEW.so и утилиты 'glewinfo' и 'visualinfo'
#    install.all
make install.all DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

chmod 755 "${TMP_DIR}/usr/lib/libGLEW.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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

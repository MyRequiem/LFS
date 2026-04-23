#! /bin/bash

PRGNAME="glu"

### GLU (Mesa OpenGL Utility library)
# GLU (OpenGL Utility Library) — стандартная надстройка над OpenGL, которая
# упрощает решение типовых задач: рисование сложных фигур (сфер, цилиндров) и
# настройку камеры. Она берет на себя сложные математические расчеты, чтобы
# программисту не приходилось вручную вычислять матрицы проекции.

# Required:    mesa
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    -D gl_provider=gl         \
    -D default_library=shared || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

rm -f "${TMP_DIR}/usr/lib/libGLU.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Mesa OpenGL Utility library)
#
# glu is the Mesa OpenGL Utility library (libGLU)
#
# Home page: https://cgit.freedesktop.org/mesa/${PRGNAME}/
# Download:  https://archive.mesa3d.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

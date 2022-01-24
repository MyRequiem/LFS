#! /bin/bash

PRGNAME="tk"

### Tk (Tk toolkit for Tcl)
# Расширение Tcl (TCL GUI Toolkit), позволяющее быстро и легко создавать
# X11-приложения, с внешним видом приложений Motif

# Required:    xorg-libraries
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "tk*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d - -f 2 | cut -d k -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}${VERSION}"-src.tar.?z* || exit 1
MIN_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2,3)"
cd "${PRGNAME}${MIN_VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd unix || exit 1
./configure        \
    --prefix=/usr  \
    --enable-64bit \
    --mandir=/usr/share/man || exit 1

make || exit 1

# удаляем ссылки на каталог сборки
sed -e "s@^\(TK_SRC_DIR='\).*@\1/usr/include'@" \
    -e "/TK_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" \
    -i tkConfig.sh

# тесты запускать не рекомендуется, т.к. они могут привести к сбою X-сервера
# или просто зависнуть

make install DESTDIR="${TMP_DIR}"
# устанавливаем заголовки интерфейса библиотеки Tk, которые используются
# другими пакетами, если они связаны с библиотекой Tk
make install-private-headers DESTDIR="${TMP_DIR}"

# ссылка в /usr/bin
#    wish -> wishX.X
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
ln -svf "wish${MAJ_VERSION}" "${TMP_DIR}/usr/bin/wish"

chmod -v 755 "${TMP_DIR}/usr/lib/libtk${MAJ_VERSION}.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Tk toolkit for Tcl)
#
# Tk is an extension to Tcl (TCL GUI Toolkit) that allows you to quickly and
# easily build X11 applications that have the look and feel of Motif apps
#
# Home page: https://www.tcl.${PRGNAME}/
# Download:  https://downloads.sourceforge.net/tcl/${PRGNAME}${VERSION}-src.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

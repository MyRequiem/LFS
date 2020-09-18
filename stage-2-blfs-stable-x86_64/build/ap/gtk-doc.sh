#! /bin/bash

PRGNAME="gtk-doc"

### GTK-Doc (code documenter)
# Пакет GTK-Doc содержит документатор кода. Это полезно для извлечения
# специально отформатированные комментарии из кода для создания документации API. Эта
# пакет не обязателен; если он не установлен, пакеты не будут
# документация. Это не значит, что у вас не будет никакой документации.
# Если GTK-Doc недоступен, процесс установки скопирует все предварительно собранные
# документация к вашей системе.

# http://www.linuxfromscratch.org/blfs/view/stable/general/gtk-doc.html

# Home page  https://developer.gnome.org/gtk-doc-manual/stable/
# Download:  http://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.32/gtk-doc-1.32.tar.xz

# Required:    docbook-xml
#              docbook-xsl
#              itstool
#              libxslt
# Recommended: python3-pygments
# Optional:    fop или dblatex (http://dblatex.sourceforge.net/) для поддержки xml и pdf
#              glib
#              which
#              python-lxml
#              anytree       (https://anytree.readthedocs.io/en/latest/)
#              parameterized (https://pypi.org/project/parameterized/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# если gtk-doc еще не установлен, то тесты будут зависать, поэтому сначала
# установим пакет до запуска тестов
make install
make install DESTDIR="${TMP_DIR}"

# make check

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (code documenter)
#
# The GTK-Doc package contains a code documenter. This is useful for extracting
# specially formatted comments from the code to create API documentation. This
# package is optional; if it is not installed, packages will not build the
# documentation. This does not mean that you will not have any documentation.
# If GTK-Doc is not available, the install process will copy any pre-built
# documentation to your system.
#
# Home page  https://developer.gnome.org/gtk-doc-manual/stable/
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

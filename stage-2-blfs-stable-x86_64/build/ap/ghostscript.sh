#! /bin/bash

PRGNAME="ghostscript"

### ghostscript (Postscript and PDF interpreter)
# Универсальный интерпретатор (процессор) Adobe Systems PostScript и Portable
# Document Format (PDF). Является неотъемлемой частью подсистемы печати,
# принимающей вывод PostScript из приложений и преобразующей его в
# соответствующий формат для принтера или дисплея.

# Required:    no
# Recommended: cups
#              fontconfig
#              freetype
#              lcms2
#              libjpeg-turbo
#              libpng
#              libtiff
#              openjpeg
# Optional:    cairo
#              gtk+3
#              libidn
#              libpaper
#              libwebp
#              Graphical Environments

# NOTE:
#    В запущенной X-сессии можно потестировать работу пакета (должна открыться
#    картинка с тигром):
#    $ gs -q -dBATCH /usr/share/ghostscript/${VERSION}/examples/tiger.eps

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим из исходников копии freetype, lcms2, libjpeg, libpng, zlib и openjpeg,
# т.к. они уже установлены в системе
rm -rf freetype lcms2mt jpeg libpng openjpeg zlib

# исправим сборку с gcc-15
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-gcc15_fixes-1.patch" || exit 1

# опция немного уменьшает размеры файлов gs и libgs.so
#    --disable-compile-inits
./configure                 \
    --prefix=/usr           \
    --disable-compile-inits \
    --with-system-libtiff   \
    --disable-cups || exit 1

make || exit 1
# скомпилируем библиотеку libgs.so
make so || exit 1
# пакет не имеет набора тестов
make install   DESTDIR="${TMP_DIR}"
make soinstall DESTDIR="${TMP_DIR}"

# некоторым пакетам (например, imagemagick) требуются заголовки интерфейса
# ghostscript
install -v -m644 base/*.h "${TMP_DIR}/usr/include/${PRGNAME}"

# некоторые пакеты производят поиск заголовков интерфейса в другом месте,
# поэтому создадим ссылку в /usr/include/
#    ps -> ghostscript
ln -sfvn "${PRGNAME}" "${TMP_DIR}/usr/include/ps"

# удалим документацию
rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MOD_VERSION="${VERSION//./}"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Postscript and PDF interpreter)
#
# Ghostscript a versatile interpreter (processor) of Adobe Systems'
# PostScript(tm) and Portable Document Format (PDF) languages.  Ghostscript is
# an essential part of the printing subsystem, taking PostScript output from
# applications and converting it into an appropriate printer or display format.
# Ghostscript supports many printers directly, and more are supported through
# add-on packages.
#
# Home page: https://www.${PRGNAME}.com/
# Download:  https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${MOD_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

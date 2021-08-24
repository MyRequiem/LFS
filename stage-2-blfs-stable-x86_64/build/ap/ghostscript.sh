#! /bin/bash

PRGNAME="ghostscript"
GHOSTSCRIPT_FONTS_STD_VERSION="8.11"
GNU_GS_FONTS_OTHER_VERSION="6.0"

### ghostscript (Postscript and PDF interpreter)
# Универсальный интерпретатор (процессор) Adobe Systems PostScript и Portable
# Document Format (PDF). Является неотъемлемой частью подсистемы печати,
# принимающей вывод PostScript из приложений и преобразующей его в
# соответствующий формат для принтера или дисплея.

# Required:    no
# Recommended: cups
#              fontconfig
#              freetype
#              libjpeg-turbo
#              libpng
#              libtiff
#              openjpeg
# Optional:    cairo
#              gtk+3
#              libidn
#              libpaper
#              X Window System

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
# т.к. они уже должны быть установлены в системе
rm -rf freetype lcms2mt jpeg libpng openjpeg zlib

# исправим проблему, вызванную изменениями в freetype >= 2.10.3
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-freetype_fix-1.patch" || exit 1

# опция немного уменьшает размеры файлов gs и libgs.so
#    --disable-compile-inits
./configure \
    --prefix=/usr           \
    --disable-compile-inits \
    --enable-dynamic        \
    --with-system-libtiff || exit 1

make || exit 1
# скомпилируем расшаренную библиотеку libgs.so
make so
# пакет не имеет набора тестов
make install   DESTDIR="${TMP_DIR}"
make soinstall DESTDIR="${TMP_DIR}"

# некоторым пакетам (например, imagemagick) требуются заголовки интерфейса
# ghostscript
install -v -m644 base/*.h "${TMP_DIR}/usr/include/ghostscript"

# некоторые пакеты производят поиск заголовков интерфейса в другом месте
# ссылка в /usr/include/
#    ps -> ghostscript
ln -sfvn ghostscript "${TMP_DIR}/usr/include/ps"

# исправим путь к документации
DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
mv -v "${TMP_DIR}/usr/share/doc/ghostscript/${VERSION}" "${TMP_DIR}${DOC_PATH}"
rm -rf "${TMP_DIR}/usr/share/doc/ghostscript"
cp -r examples/ "${TMP_DIR}${DOC_PATH}"

# установим шрифты
FONTS_PATH="/usr/share/fonts/X11/Type1/"
mkdir -p "${TMP_DIR}${FONTS_PATH}"
tar -xvf \
    "${SOURCES}/ghostscript-fonts-std-${GHOSTSCRIPT_FONTS_STD_VERSION}.tar.gz" \
    -C "${TMP_DIR}${FONTS_PATH}" --no-same-owner --strip-components=1 || exit 1
tar -xvf "${SOURCES}/gnu-gs-fonts-other-${GNU_GS_FONTS_OTHER_VERSION}.tar.gz" \
    -C "${TMP_DIR}${FONTS_PATH}" --no-same-owner --strip-components=1 || exit 1

rm -f "${TMP_DIR}${FONTS_PATH}"/{COPYING,ChangeLog,README*,TODO,fonts*}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим индекс шрифтов (fonts.scale и fonts.dir)
(
    cd "${FONTS_PATH}" || exit 1
    mkfontscale .
    mkfontdir   .
)

# обновим кэш для fontconfig (/var/cache/fontconfig/)
fc-cache -vf

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

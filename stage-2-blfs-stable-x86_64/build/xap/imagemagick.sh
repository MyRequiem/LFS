#! /bin/bash

PRGNAME="imagemagick"
ARCH_NAME="ImageMagick"

### ImageMagick (a robust collection of image processing tools)
# Набор программ (консольных утилит) для чтения и редактирования файлов
# множества графических форматов.

# Required:    no
# Recommended: xorg-libraries
# Optional:    >> Системные утилиты <<
#              llvm
#              cups
#              curl
#              ffmpeg
#              fftw
#              p7zip
#              sane
#              wget
#              xdg-utils
#              xterm
#              dmalloc        (https://dmalloc.com/)
#              electric-fence (https://linux.softpedia.com/get/Programming/Debuggers/Electric-Fence-3305.shtml/)
#              gnupg или pgp  (https://www.openpgp.org/about/)
#              profiles       (ftp://ftp.imagemagick.org/pub/ImageMagick/delegates)
#              ufraw          (http://ufraw.sourceforge.net/)
#              >> Графические библиотеки <<
#              jasper
#              lcms или lcms2
#              libgxps
#              libjpeg-turbo
#              libpng
#              libraw
#              librsvg
#              libtiff
#              libwebp
#              openjpeg
#              pango
#              djvulibre      (http://djvu.sourceforge.net/)
#              flashpix       (ftp://ftp.imagemagick.org/pub/ImageMagick/delegates/)
#              flif           (https://github.com/FLIF-hub/FLIF/releases)
#              jbig-kit       (https://www.cl.cam.ac.uk/~mgk25/jbigkit/)
#              libheif        (https://github.com/strukturag/libheif/)
#              libde265       (https://github.com/strukturag/libde265/)
#              libraqm        (https://github.com/HOST-Oman/libraqm/)
#              liquid-rescale (http://liblqr.wikidot.com/en:download-page)
#              openexr        (https://www.openexr.com/)
#              ralcgm         (http://www.agocg.ac.uk/train/cgm/ralcgm.htm)
#              >> Графические утилиты <<
#              dejavu-fonts-ttf
#              ghostscript
#              gimp
#              graphviz
#              inkscape
#              blender   (https://www.blender.org/)
#              corefonts (http://corefonts.sourceforge.net/)
#              ghostpcl  (https://ghostscript.com/releases/gpcldnld.html)
#              gnuplot   (http://www.gnuplot.info/)
#              pov-ray   (http://www.povray.org/)
#              radiance  (https://www.radiance-online.org//)
#              >> Инструменты преобразования <<
#              enscript
#              texlive или install-tl-unx
#              autotrace           (http://autotrace.sourceforge.net/)
#              geoexpress          (https://www.extensis.com/gis-tools)
#              aka-mrsid-utilities (https://www.extensis.com/gis-tools)
#              hp2xx               (https://www.gnu.org/software/hp2xx/)
#              html2ps             (http://user.it.uu.se/~jan/html2ps.html)
#              libwmf              (http://wvware.sourceforge.net/)
#              uniconvertor        (https://sk1project.net/uc2/)
#              utah-raster-toolkit (https://www.cs.utah.edu/gdc/projects/urt/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1,2 | rev)"

VERSION="${ARCH_VERSION//-/_}"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${ARCH_VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${ARCH_VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --enable-hdri     \
    --with-modules    \
    --with-perl       \
    --disable-static || exit 1

make || exit 1
# make check
DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
make DOCUMENTATION_PATH="${DOC_PATH}" install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a robust collection of image processing tools)
#
# ImageMagick is a collection of tools for manipulating and displaying digital
# images. It can merge images, transform image dimensions, do screen captures,
# create animation sequences, and convert between many different image formats.
# Image processing operations are available from the command line. Bindings for
# Perl and C++ are also available.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://www.${PRGNAME}.org/download/releases/${ARCH_NAME}-${ARCH_VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

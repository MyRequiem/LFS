#! /bin/bash

PRGNAME="git"

### Git (distributed version control system)
# Распределенная система контроля версий для отслеживания изменений в исходном
# коде во время разработки программного обеспечения. Предназначен для
# координации работы программистов, но его можно использовать для отслеживания
# изменений в любом наборе файлов. Система ориентирована на скорость,
# целостность данных и поддержку распределенных, нелинейных рабочих процессов.

# Required:    no
# Recommended: curl
# Optional:    pcre2 или pcre
#              subversion       (собранный с perl bindings для git svn)
#              tk               (скрипт 'gitk' == simple Git repository viewer == использует tk для запуска)
#              valgrind
#              xmlto            (для сборки man-страниц)
#              asciidoc или asciidoctor (https://asciidoctor.org/) для сборки txt и html документации
#              dblatex (для сборки мануалов в pdf формате) http://dblatex.sourceforge.net/
#              docbook2x (для создания страниц info) http://docbook2x.sourceforge.net/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{"${DOCS}"/{html,txt/{howto,technical}},/usr/share/man}

PCRE1="--without-libpcre1"
PCRE2="--without-libpcre2"
CURL="--without-curl"

command -v curl         &>/dev/null && CURL="--with-curl"
command -v pcre-config  &>/dev/null && PCRE1="--with-libpcre1"
command -v pcre2-config &>/dev/null && PCRE2="--with-libpcre2" && \
    PCRE1="--without-libpcre1"

./configure               \
    --prefix=/usr         \
    --with-python=python3 \
    "${CURL}"             \
    "${PCRE1}"            \
    "${PCRE2}"            \
    --with-gitconfig=/etc/gitconfig || exit 1

make || exit 1

# html-документация
ASCIIDOC=""
# command -v asciidoc &>/dev/null && ASCIIDOC="true"
if [ -n "${ASCIIDOC}" ]; then
    make html
fi

# man-страницы
XMLTO=""
# command -v xmlto &>/dev/null && XMLTO="true"
if [[ -n "${ASCIIDOC}" && -n "${XMLTO}" ]]; then
    make man
fi

# make test

# устанавливаем пакет
PERL_MAJ_VERSION="$(perl --version | grep -oE '\(v.*\)' | cut -d v -f 2 | \
    cut -d . -f 1,2)"
make perllibdir="/usr/lib/perl5/${PERL_MAJ_VERSION}/site_perl" install \
    DESTDIR="${TMP_DIR}"

# устанавливаем документацию
if [ -n "${ASCIIDOC}" ]; then
    make htmldir="${DOCS}" install-html DESTDIR="${TMP_DIR}"
fi

# если скачивали архив с документацией
tar -xvf "${SOURCES}/${PRGNAME}-htmldocs-${VERSION}.tar.xz" \
    -C "${TMP_DIR}${DOCS}/html" \
    --no-same-owner \
    --no-overwrite-dir || exit 1

rm -rf "${TMP_DIR}${DOCS}/html/RelNotes"
find "${TMP_DIR}${DOCS}" -type d -exec chmod 755 {} \;
find "${TMP_DIR}${DOCS}" -type f -exec chmod 644 {} \;

# разделяем txt и html документацию
find "${TMP_DIR}${DOCS}/html" -maxdepth 1 -type f -name "*.txt" \
    -exec mv {} "${TMP_DIR}${DOCS}/txt" \;
find "${TMP_DIR}${DOCS}/html/howto" -type f -name "*.txt" \
    -exec mv {} "${TMP_DIR}${DOCS}/txt/howto" \;
find "${TMP_DIR}${DOCS}/html/technical" -type f -name "*.txt" \
    -exec mv {} "${TMP_DIR}${DOCS}/txt/technical" \;

# устанавливаем man-страницы
if [[ -n "${ASCIIDOC}" && -n "${XMLTO}" ]]; then
    make install-man DESTDIR="${TMP_DIR}"
fi

# если скачивали архив с man-страницами
tar -xf "${SOURCES}/${PRGNAME}-manpages-${VERSION}.tar.xz" \
    -C "${TMP_DIR}/usr/share/man" --no-same-owner --no-overwrite-dir

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (distributed version control system)
#
# Git is a free and open source, distributed version control system designed to
# handle everything from small to very large projects with speed and
# efficiency. Every Git clone is a full-fledged repository with complete
# history and full revision tracking capabilities, not dependent on network
# access or a central server. Branching and merging are fast and easy to do.
# Git is used for version control of files, much like tools such as Mercurial,
# Bazaar, Subversion, CVS, Perforce, and Team Foundation Server.
#
# Home page: https://git-scm.com/
# Download:  https://www.kernel.org/pub/software/scm/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

#! /bin/bash

PRGNAME="git"

### Git (distributed version control system)
# Распределенная система контроля версий для отслеживания изменений в исходном
# коде во время разработки программного обеспечения. Предназначен для
# координации работы программистов, но его можно использовать для отслеживания
# изменений в любом наборе файлов. Система ориентирована на скорость,
# целостность данных и поддержку распределенных, нелинейных рабочих процессов.

# http://www.linuxfromscratch.org/blfs/view/svn/general/git.html

# Home page: https://git-scm.com/
# Download:  https://www.kernel.org/pub/software/scm/git/git-2.26.2.tar.xz

# Required:    no
# Recommended: curl
# Optional:    pcre2 или pcre
#              subversion (собранный с perl bindings для git svn)
#              tk (для сборки утилиты gitk)
#              valgrind
#              xmlto
#              asciidoc или asciidoctor (https://asciidoctor.org/) для сборки txt и html документации
#              dblatex (для сборки мануалов в pdf формате) http://dblatex.sourceforge.net/
#              docbook2x (для создания страниц info) http://docbook2x.sourceforge.net/

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PCRE1="--without-libpcre1"
PCRE2="--without-libpcre2"
CURL="--without-curl"

command -v pcre-config  &>/dev/null && PCRE1="--with-libpcre1"
command -v pcre2-config &>/dev/null && PCRE2="--with-libpcre2" && \
    PCRE1="--without-libpcre1"
command -v curl         &>/dev/null && CURL="--with-curl"

./configure               \
    --prefix=/usr         \
    --with-python=python3 \
    "${PCRE1}"            \
    "${PCRE2}"            \
    "${CURL}"             \
    --with-gitconfig=/etc/gitconfig || exit 1

make || exit 1

ASCIIDOC=""
command -v asciidoc &>/dev/null && ASCIIDOC="true"
if [ -n "${ASCIIDOC}" ]; then
    # html-документация
    make html
fi

XMLTO=""
command -v xmlto &>/dev/null && XMLTO="true"
if [[ -n "${ASCIIDOC}" && -n "${XMLTO}" ]]; then
    # man-страницы
    make man
fi

# make test

make install
make install DESTDIR="${TMP_DIR}"

# устанавливаем документацию
if [ -n "${ASCIIDOC}" ]; then
    make htmldir="/usr/share/doc/${PRGNAME}-${VERSION}" install-html
    make htmldir="/usr/share/doc/${PRGNAME}-${VERSION}" install-html \
        DESTDIR="${TMP_DIR}"
fi

if [[ -n "${ASCIIDOC}" && -n "${XMLTO}" ]]; then
    make install-man
    make install-man DESTDIR="${TMP_DIR}"
fi

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

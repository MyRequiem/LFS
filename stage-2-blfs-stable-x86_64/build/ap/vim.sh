#! /bin/bash

PRGNAME="vim"

### Vim (Vi IMproved)
# Powerful text editor

# Required:    no
# Recommended: Graphical Environments
#              gtk+3
# Optional:    curl или wget            (для некоторых тестов)
#              gpm
#              lua
#              ruby
#              rsync

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc"
mkdir -pv "${TMP_DIR}"{/etc,"${DOCS}"}

# ctags когда-то входил в состав редактора Vim, добавим сами:
CTAGSVER="$(find "${SOURCES}" -type f -name "ctags-*.tar.?z" | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev )"

if [ -z "${CTAGSVER}" ]; then
    echo "Error:"
    echo "ctags source arhive not found in ${SOURCES}"
    exit 1
fi

tar xvf "${SOURCES}/ctags-${CTAGSVER}".tar.?z || exit 1
cd "ctags-${CTAGSVER}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

if [ ! -r configure ]; then
    if [ -x ./autogen.sh ]; then
        NOCONFIGURE=1 ./autogen.sh
    else
        autoreconf -vif
    fi
fi

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --localstatedir=/var || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}" || exit 1

cd .. || exit 1
rm -rf "ctags-${CTAGSVER}"

# изменим расположение файла конфигурации vimrc с /usr/share/vim/vimrc (по
# умолчанию) на /etc/vimrc
echo '#define SYS_VIMRC_FILE  "/etc/vimrc"'  >> src/feature.h
echo '#define SYS_GVIMRC_FILE "/etc/gvimrc"' >> src/feature.h

./configure                    \
    --prefix=/usr              \
    --enable-perlinterp=yes    \
    --enable-python3interp=yes \
    --enable-rubyinterp=yes    \
    --enable-tclinterp=yes     \
    --enable-luainterp=yes     \
    --enable-mzschemeinterp    \
    --disable-canberra         \
    --enable-multibyte         \
    --enable-fail-if-missing   \
    --with-x                   \
    --enable-gui=gtk3          \
    --enable-fontset           \
    --enable-terminal          \
    --enable-cscope            \
    --disable-motif-check      \
    --disable-gtktest          \
    --disable-darwin           \
    --disable-smack            \
    --disable-netbeans         \
    --disable-rightleft        \
    --disable-arabic           \
    --disable-farsi            \
    --disable-xim              \
    --disable-sysmouse         \
    --disable-autoservername   \
    --with-features=huge       \
    --with-tlib=ncursesw       \
    --with-compiledby="MyRequiem" || exit 1

make || exit 1

# набор тестов выводит много двоичных данных в stdout, что может привести к
# проблемам с настройками текущего терминала, поэтому перенаправим вывод в лог
# make -j1 test &> vim-test.log

make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/bin
#    vi -> vim
ln -sv vim "${TMP_DIR}/usr/bin/vi"

# конфигурация по умолчанию
cat << EOF > "${TMP_DIR}/etc/vimrc"
" ensure defaults are set before customizing settings,
" not after source \$VIMRUNTIME/defaults.vim
let skip_defaults_vim = 1

language en_US

set nocompatible
syntax on
filetype on
filetype plugin on
filetype plugin indent on
set background=dark
set number
set backspace=indent,eol,start
set nobackup
set noswapfile
set noundofile
set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
set expandtab
set helplang=en
EOF

# /etc/gvimrc будет ссылкой на /etc/vimrc
ln -svf vimrc "${TMP_DIR}/etc/gvimrc"

# по умолчанию документация Vim устанавливается в /usr/share/vim/, поэтому
# установим ссылку в /usr/share/doc/
#    vim-${VERSION} -> ../vim/vimXX/doc
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
MIN_VER="$(echo "${VERSION}" | cut -d . -f 2)"
ln -snfv "../vim/vim${MAJ_VER}${MIN_VER}/doc" \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

rm -f "${TMP_DIR}/usr/share/applications/vim.desktop"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Vi IMproved)
#
# Vim is an almost compatible version of the UNIX editor vi. Many new features
# have been added: multi level undo, command line history, filename completion,
# block operations, extensive plugin system, support for hundreds of
# programming languages and file formats, powerful search and replace,
# integrates with many tools and more. Vim is rock stable and is continuously
# being developed to become even better.
#
# Home page: https://www.vim.org/
#            https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

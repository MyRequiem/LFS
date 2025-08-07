#! /bin/bash

PRGNAME="vim"

### Vim (Vi IMproved)
# Powerful text editor

# Required:    no
# Recommended: Graphical Environments
#              gtk+3
# Optional:    gpm
#              lua
#              ruby
#              rsync

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc"
mkdir -pv "${TMP_DIR}"{/etc,"${DOCS}"}

# изменим расположение файла конфигурации vimrc с /usr/share/vim/vimrc (по
# умолчанию) на /etc/vimrc
echo '#define SYS_VIMRC_FILE  "/etc/vimrc"'  >> src/feature.h
echo '#define SYS_GVIMRC_FILE "/etc/gvimrc"' >> src/feature.h

./configure                           \
    --prefix=/usr                     \
    --with-features=huge              \
    --enable-gui=gtk3                 \
    --with-tlib=ncursesw              \
    --enable-fail-if-missing          \
    --with-x                          \
    --enable-fontset                  \
    --enable-multibyte                \
    --enable-terminal                 \
    --enable-cscope                   \
    --enable-tclinterp=yes            \
    --enable-luainterp=yes            \
    --enable-mzschemeinterp           \
    --enable-rubyinterp=yes           \
    --enable-perlinterp=yes           \
    --enable-python3interp=yes        \
    --disable-gtktest                 \
    --disable-icon-cache-update       \
    --disable-desktop-database-update \
    --disable-canberra                \
    --disable-darwin                  \
    --disable-smack                   \
    --disable-selinux                 \
    --disable-netbeans                \
    --disable-rightleft               \
    --disable-arabic                  \
    --disable-farsi                   \
    --disable-xim                     \
    --enable-gpm=no                   \
    --disable-sysmouse                \
    --disable-autoservername          \
    --with-compiledby="MyRequiem" || exit 1

make || exit 1

# набор тестов выводит много двоичных данных в stdout, что может привести к
# проблемам с настройками текущего терминала. Этого можно избежать, если
# перенаправить вывод в лог файл
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

# удаляем /etc/gvimrc и делаем ссылку в /etc gvimrc -> vimrc
(
    cd "${TMP_DIR}/etc" || exit 1
    rm -f gvimrc
    ln -s vimrc gvimrc
)

# по умолчанию документация Vim устанавливается в /usr/share/vim/, поэтому
# установим ссылку в /usr/share/doc/
#    vim-${VERSION} -> ../vim/vimXX/doc
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
MIN_VER="$(echo "${VERSION}" | cut -d . -f 2)"
(
    cd "${TMP_DIR}${DOCS}" || exit 1
    ln -sn "../vim/vim${MAJ_VER}${MIN_VER}/doc" "${PRGNAME}-${VERSION}"
)

APPL="/usr/share/applications"
mkdir -pv "${TMP_DIR}${APPL}"
rm -f "${TMP_DIR}${APPL}/vim.desktop"

cat > "${TMP_DIR}${APPL}/gvim.desktop" << "EOF"
[Desktop Entry]
GenericName=GVim
GenericName[en]=GVim
GenericName[ru]=GVim
Name=GVim Text Editor
Name[en]=GVim Text Editor
Name[ru]=GVim Текстовый Редактор
Comment=Edit text files
Comment[en]=Edit text files
Comment[ru]=Редактирование текстовых файлов
TryExec=gvim
Exec=gvim -f %F
Terminal=false
Type=Application
Keywords=Text;editor;
Keywords[en]=Text;editor;
Keywords[ru]=текст;текстовый редактор;
Icon=gvim
StartupNotify=true
Categories=Utility;TextEditor;
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
EOF

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

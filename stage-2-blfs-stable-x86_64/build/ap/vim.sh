#! /bin/bash

PRGNAME="vim"

### Vim (Vi IMproved)
# Powerful text editor

# Required:    no
# Recommended: Graphical Environments
#              gtk+3
# Optional:    gpm
#              lua
#              rsync
#              ruby
#              python2

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc"
mkdir -pv "${TMP_DIR}"{/etc,"${DOCS}"}

# изменим расположение файла конфигурации vimrc с /usr/share/vim/vimrc (по
# умолчанию) на /etc/vimrc
echo '#define SYS_VIMRC_FILE  "/etc/vimrc"'  >> src/feature.h
echo '#define SYS_GVIMRC_FILE "/etc/gvimrc"' >> src/feature.h

GUI="no"
XORG_SERVER="--without-x"
FONTSET="--disable-fontset"
LUA="no"
RUBY="no"
PYTHON2="no"
PYTHON3="no"
GPM="no"

command -v gtk-demo  &>/dev/null && GUI="gtk2"
command -v gtk3-demo &>/dev/null && GUI="gtk3"
command -v Xorg      &>/dev/null && XORG_SERVER="--with-x"
command -v lua       &>/dev/null && LUA="yes"
command -v ruby      &>/dev/null && RUBY="yes"
command -v python2   &>/dev/null && PYTHON2="yes"
command -v python3   &>/dev/null && PYTHON3="yes"
command -v gpm       &>/dev/null && GPM="yes"

if [[ "x${XORG_SERVER}" == "x--with-x" ]]; then
    FONTSET="--enable-fontset"
fi

./configure                           \
    --prefix=/usr                     \
    --with-features=huge              \
    --enable-gui="${GUI}"             \
    --with-tlib=ncursesw              \
    --enable-fail-if-missing          \
    "${XORG_SERVER}"                  \
    "${FONTSET}"                      \
    --enable-multibyte                \
    --enable-terminal                 \
    --enable-cscope                   \
    --enable-tclinterp="yes"          \
    --enable-luainterp=${LUA}         \
    --enable-mzschemeinterp           \
    --enable-rubyinterp=${RUBY}       \
    --enable-perlinterp="yes"         \
    --enable-pythoninterp=${PYTHON2}  \
    --enable-python3interp=${PYTHON3} \
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
    --enable-gpm="${GPM}"             \
    --disable-sysmouse                \
    --disable-autoservername          \
    --with-compiledby="MyRequiem" || exit 1

make || exit 1

# набор тестов выводит много двоичных данных в stdout, что может привести к
# проблемам с настройками текущего терминала. Этого можно избежать, если
# перенаправить вывод в лог файл
# make -j1 test &> vim-test.log

make install DESTDIR="${TMP_DIR}"

# конфигурация по умолчанию
VIMRC="/etc/vimrc"
cat << EOF > "${TMP_DIR}${VIMRC}"
" Begin ${VIMRC}

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

" End ${VIMRC}
EOF

# удаляем /etc/gvimrc и делаем ссылку в /etc gvimrc -> vimrc
(
    cd "${TMP_DIR}/etc" || exit 1
    rm -f gvimrc
    ln -s vimrc gvimrc
)

# установим ссылку в /usr/bin
#    vi -> vim
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv vim vi
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
if [[ "x${XORG_SERVER}" == "x--with-x" ]]; then
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
else
    # удаляем *.desktop файлы и иконки, которые устанавливаются только если
    # команде 'make install' передается параметр DESTDIR не зависимо от того,
    # собирался Vim с поддержкой Xorg или нет (см. src/Makefile в дереве
    # исходников, цель 'install-icons')
    rm -rf "${TMP_DIR}${APPL}"
    rm -rf "${TMP_DIR}/usr/share/icons"
fi

if [ -f "${VIMRC}" ]; then
    mv "${VIMRC}" "${VIMRC}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${VIMRC}"

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
# Download:  https://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

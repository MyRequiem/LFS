#! /bin/bash

PRGNAME="vim"

### Vim (Vi IMproved)
# Powerful text editor

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/vim.html

# Home page: https://www.vim.org/
# Download:  ftp://ftp.vim.org/pub/vim/unix/vim-8.2.tar.bz2

# Required:    no
# Recommended: xorg-server
#              gtk+2
#              gtk+3
# Optional:    gpm
#              lua53
#              perl
#              python2
#              python3
#              rsync
#              ruby
#              tcl

ROOT="/root"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="/root/src"
VERSION=$(echo "${SOURCES}/${PRGNAME}"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
MIN_VER="$(echo "${VERSION}" | cut -d . -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}${MAJ_VER}${MIN_VER}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

# изменим расположение файла конфигурации vimrc с /usr/share/vim/vimrc (по
# умолчанию) на /etc/vimrc
echo '#define SYS_VIMRC_FILE  "/etc/vimrc"'  >> src/feature.h
echo '#define SYS_GVIMRC_FILE "/etc/gvimrc"' >> src/feature.h

GUI="no"
XORG_SERVER="--without-x"
FONTSET="--disable-fontset"
TCL="no"
LUA="no"
RUBY="no"
PERL="no"
PYTHON2="no"
PYTHON3="no"

command -v gtk-demo  &>/dev/null && GUI="gtk2"
command -v gtk3-demo &>/dev/null && GUI="gtk3"
command -v Xorg      &>/dev/null && XORG_SERVER="--with-x"
command -v tclsh     &>/dev/null && TCL="yes"
command -v lua       &>/dev/null && LUA="yes"
command -v ruby      &>/dev/null && RUBY="yes"
command -v perl      &>/dev/null && PERL="yes"
command -v python2   &>/dev/null && PYTHON2="yes"
command -v python3   &>/dev/null && PYTHON3="yes"

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
    --enable-tclinterp="${TCL}"       \
    --enable-luainterp=${LUA}         \
    --enable-mzschemeinterp           \
    --enable-rubyinterp=${RUBY}       \
    --enable-perlinterp=${PERL}       \
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
    --disable-gpm                     \
    --disable-sysmouse                \
    --disable-autoservername          \
    --with-compiledby="MyRequiem" || exit 1

make || exit 1

# набор тестов выводит много двоичных данных в stdout, что может привести к
# проблемам с настройками текущего терминала. Этого можно избежать, если
# перенаправить вывод в лог файл
# make test &> vim-test.log

VIMRC="/etc/vimrc"
if [ -f "${VIMRC}" ]; then
    mv "${VIMRC}" "${VIMRC}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

# конфигурация по умолчанию
cat << EOF > "${VIMRC}"
" Begin ${VIMRC}

" ensure defaults are set before customizing settings,
" not after source \$VIMRUNTIME/defaults.vim
let skip_defaults_vim = 1

set nocompatible
syntax on
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

" End ${VIMRC}
EOF

cp "${VIMRC}" "${TMP_DIR}/etc/"
config_file_processing "${VIMRC}"

# удаляем /etc/gvimrc и делаем ссылку в /etc gvimrc -> vimrc
(
    cd /etc || exit 1
    rm -f gvimrc
    ln -sfv vimrc gvimrc

    cd "${TMP_DIR}/etc" || exit 1
    rm -f gvimrc
    ln -sfv vimrc gvimrc
)

# по умолчанию документация Vim устанавливается в /usr/share/vim, поэтому
# установим ссылку в /usr/share/doc/ vim-${VERSION} -> ../vim/vimXX/doc
DOC="/usr/share/doc"
rm -f "${DOC}/${PRGNAME}-${VERSION}"
ln -snfv "../vim/vim${MAJ_VER}${MIN_VER}/doc" "${DOC}/${PRGNAME}-${VERSION}"

(
    mkdir -p "${TMP_DIR}${DOC}"
    cd "${TMP_DIR}${DOC}" || exit 1
    ln -snfv "../vim/vim${MAJ_VER}${MIN_VER}/doc" "${PRGNAME}-${VERSION}"
)

APPL="/usr/share/applications"
ICONS="/usr/share/icons"

if [[ "x${XORG_SERVER}" == "x--with-x" ]]; then
    mkdir -pv "${APPL}"
    mkdir -pv "${ICONS}"

    rm -fv {,"${TMP_DIR}"}"${APPL}/vim.desktop"

cat > "${APPL}/gvim.desktop" << "EOF"
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
    cp "${APPL}/gvim.desktop" "${TMP_DIR}${APPL}"
    cp -Rv "${TMP_DIR}${ICONS}"/* "${ICONS}"
else
    # удаляем *.desktop файлы и иконки, которые устанавливаются только если
    # команде 'make install' передается параметр DESTDIR не зависимо от того,
    # собирался Vim с поддержкой Xorg или нет (см. src/Makefile в дереве
    # исходников, цель 'install-icons')
    rm -rf "${TMP_DIR}${APPL}"
    rm -rf "${TMP_DIR}${ICONS}"
fi

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
# Download:  ftp://ftp.vim.org/pub/${PRGNAME}/unix/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

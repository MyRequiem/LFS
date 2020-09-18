#! /bin/bash

PRGNAME="vim"

### Vim (Vi IMproved)
# Powerful text editor

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/vim.html

# Home page: https://www.vim.org/
#            https://github.com/vim/vim
# Download:  ftp://ftp.vim.org/pub/vim/unix/vim-8.2.tar.bz2

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

SOURCES="/sources"
VERSION=$(echo "${SOURCES}/${PRGNAME}"-*.tar.?z* | rev | \
    cut -f 3- -d . | cut -f 1 -d - | rev)
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
MIN_VER="$(echo "${VERSION}" | cut -d . -f 2)"
BUILD_DIR="${SOURCES}/build"

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}${MAJ_VER}${MIN_VER}"

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}${MAJ_VER}${MIN_VER}" || exit 1

# изменим расположение файла конфигурации vimrc с /usr/share/vim/vimrc (по
# умолчанию) на /etc/vimrc
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure \
    --prefix=/usr || exit 1

make || exit 1
# тесты будем запускать от пользователя nobody
chown -Rv nobody .
# набор тестов выводит много двоичных данных в stdout, что может привести к
# проблемам с настройками текущего терминала. Этого можно избежать, если
# перенаправить вывод в лог файл
su nobody -s /bin/bash -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
chown -Rv root:root .

# бэкапим конфиг /etc/vimrc перед установкой пакета, если он существует
VIMRC="/etc/vimrc"
if [ -f "${VIMRC}" ]; then
    mv "${VIMRC}" "${VIMRC}.old"
fi

# устанавливаем пакет
make install
make install DESTDIR="${TMP_DIR}"

# удаляем не нужные нам *.desktop файлы и иконки, которые устанавливаются
# только когда команде 'make install' передается параметр DESTDIR
# (см. src/Makefile в дереве исходников, цель install-icons:)
rm -rf "${TMP_DIR}/usr/share"/{applications,icons}

# установим ссылку vi -> vim в /usr/bin и создадим man-страницы для vi, т.е.
# ссылки vi.1 -> vim.1 и т.д. в /usr/share/man/*/man1/
ln -sv vim /usr/bin/vi
for MANPAGE in /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 "$(dirname ${MANPAGE})/vi.1"
done

(
    cd "${TMP_DIR}/usr/bin" || exit
    ln -sv vim vi
    cd "${TMP_DIR}" || exit
    for MANPAGE in usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 "$(dirname ${MANPAGE})/vi.1"
    done
)

# по умолчанию документация Vim устанавливается в /usr/share/vim, поэтому
# установим ссылку в /usr/share/doc/ vim-${VERSION} -> ../vim/vimXX/doc
rm -f "/usr/share/doc/${PRGNAME}-${VERSION}"
ln -svf "../vim/vim${MAJ_VER}${MIN_VER}/doc" \
    "/usr/share/doc/${PRGNAME}-${VERSION}"

(
    mkdir -p "${TMP_DIR}/usr/share/doc"
    cd "${TMP_DIR}/usr/share/doc" || exit 1
    ln -sv "../vim/vim${MAJ_VER}${MIN_VER}/doc" "${PRGNAME}-${VERSION}"
)

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

#! /bin/bash

PRGNAME="vim"

### Vim (Vi IMproved)
# Powerful text editor

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
DOCS="/usr/share/doc"
mkdir -pv "${TMP_DIR}"{/etc,"${DOCS}"}

# изменим расположение файла конфигурации vimrc с /usr/share/vim/vimrc (по
# умолчанию) на /etc/vimrc
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1

# тесты будем запускать от пользователя tester
# chown -Rv tester .
# набор тестов выводит много двоичных данных в stdout, что может привести к
# проблемам с настройками текущего терминала, поэтому перенаправим вывод в лог
# файл
# su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
#    &> vim-test.log
# chown -Rv root:root .

make install DESTDIR="${TMP_DIR}"

# мы же не будем пользоватся GUI-версией редактора, правда? :) Поэтому удаляем
# не нужные нам *.desktop файлы и иконки, которые устанавливаются только когда
# команде 'make install' передается параметр DESTDIR (см. src/Makefile в дереве
# исходников, цель install-icons)
rm -rf "${TMP_DIR}/usr/share"/{applications,icons}

# по умолчанию документация устанавливается в /usr/share/vim/, поэтому
# установим ссылку в /usr/share/doc/
#    vim-${VERSION} -> ../vim/vimXX/doc
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
MIN_VER="$(echo "${VERSION}" | cut -d . -f 2)"
(
    cd "${TMP_DIR}${DOCS}" || exit 1
    ln -sv "../vim/vim${MAJ_VER}${MIN_VER}/doc" "${PRGNAME}-${VERSION}"
)

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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

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
# Home page: https://www.${PRGNAME}.org/
#            https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

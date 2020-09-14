#! /bin/bash

PRGNAME="python3-pygments"
ARCH_NAME="Pygments"

### Pygments (syntax highlighter)
# Подсветка синтаксиса для более чем 300 языков программирования и форматов
# разметки. Используется на форумных системах, wiki и в других приложениях, в
# которых необходимо отображения исходного кода. Поддерживается добавление
# новых языков программирования. Форматы вывода: HTML, LaTeX, RTF, SVG и ANSI.
# Так же может использоваться как инструмент командной строки и как библиотека.

# http://www.linuxfromscratch.org/blfs/view/stable/general/python-modules.html#pygments

# Home page: https://pypi.org/project/Pygments/
# Download:  https://files.pythonhosted.org/packages/source/P/Pygments/Pygments-2.5.2.tar.gz

# Required: python3
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (syntax highlighter)
#
# Is a general syntax highlighter written in Python, for more than 300
# languages. General use in all kinds of software such as forum systems, wikis
# or other applications that need to prettify source code.
#
# Highlights are:
#    * A wide range of common languages and markup formats is supported
#    * Special attention is paid to details, increasing quality by a fair
#       amount
#    * Support for new languages and formats are added easily
#    * A number of output formats, presently HTML, LaTeX, RTF, SVG and ANSI
#       sequences
#    * It is usable as a command-line tool and as a library
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/P/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

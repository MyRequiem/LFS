#! /bin/bash

PRGNAME="python3-pygments"
ARCH_NAME="pygments"

### Pygments (syntax highlighter)
# Подсветка синтаксиса для более чем 300 языков программирования и форматов
# разметки. Используется на форумных системах, wiki и в других приложениях, в
# которых необходимо отображения исходного кода. Поддерживается добавление
# подсветки для новых языков программирования. Форматы вывода: HTML, LaTeX,
# RTF, SVG и ANSI. Так же может использоваться как инструмент командной строки
# и как библиотека.

# Required:    python3-hatchling
# Recommended: no
# Optional:    python3-pytest
#              python3-wcag-contrast-ratio (https://pypi.org/project/wcag-contrast-ratio/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    --no-user           \
    Pygments || exit 1

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Download:  https://files.pythonhosted.org/packages/source/P/Pygments/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

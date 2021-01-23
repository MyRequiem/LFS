#! /bin/bash

PRGNAME="python-docutils"
ARCH_NAME="docutils"

### docutils (Python Documentation Utilities)
# Модульная система для преобразования документации в другие форматы, такие как
# HTML, XML и LaTeX. Для ввода Docutils поддерживает reStructuredText, простой
# для чтения текст в формате "что видишь, то и получаешь"

# Required:    python2
#              python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

# ссылки в /usr/bin:
#    rst2xml   -> rst2xml.py
#    rst2latex -> rst2latex.py
#    ...
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    for FILE in rst*.py; do
        ln -svf "${FILE}" "$(basename "${FILE}" .py)"
    done
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python Documentation Utilities)
#
# Docutils is a modular system for processing documentation into useful
# formats, such as HTML, XML, and LaTeX. For input Docutils supports
# reStructuredText, an easy-to-read, what-you-see-is-what-you-get plaintext
# markup syntax.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}/
# Download:  http://downloads.sourceforge.net/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

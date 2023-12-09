#! /bin/bash

PRGNAME="bpython"

### bpython (Fancy Interface to the Python3 Interpreter)
# Интерфейс для интерактивного Python3 интерпретатора с подсветкой синтаксиса,
# автодополнением, автоотступами и т.д.

# Required:    python3-requests
#              python3-pygments
#              python3-pyxdg
#              python3-typing-extensions
#              python3-cwcwidth
#              python3-curtsies
#              python-greenlet
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим .desktop файл
mv data/{"org.${PRGNAME}-interpreter.${PRGNAME}.desktop","${PRGNAME}.desktop"}
sed -i "s/org.${PRGNAME}-interpreter.${PRGNAME}.desktop/${PRGNAME}.desktop/" \
    setup.py || exit 1

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Fancy Interface to the Python3 Interpreter)
#
# bpython is a fancy lightweight interface to the Python3 interactive
# interpreter that adds several features common to IDEs. These features include
# syntax highlighting, expected parameter list, auto-indentation, and
# autocompletion.
#
# Home page: https://${PRGNAME}-interpreter.org/
#            https://pypi.org/project/${PRGNAME}/
#            https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://files.pythonhosted.org/packages/62/5c/4039865b7e21c792140ec36411b2999b8ffe98da0f0e79eebad779550868/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

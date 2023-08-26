#! /bin/bash

PRGNAME="python3-mako"
ARCH_NAME="Mako"

### Mako (A python templating language)
# Python модуль, реализующий сверхбыстрое и легкое создание шаблонов

# Required:    python3-markupsafe
# Recommended: no
# Optional:    python3-pytest (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сборка с помощью модуля build (пакет python3-build) и установка с помощью
# модуля installer (пакет python3-installer)
python3 -m build --no-isolation                       || exit 1
python3 -m installer -d "${TMP_DIR}" \
    ./dist/"${ARCH_NAME}-${VERSION}-py3-none-any.whl" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A python templating language)
#
# Mako is a template library written in Python. It provides a familiar, non-XML
# syntax which compiles into Python modules for maximum performance. Mako’s
# syntax and API borrows from the best ideas of many others, including Django
# templates, Cheetah, Myghty, and Genshi. Conceptually, Mako is an embedded
# Python (i.e. Python Server Page) language, which refines the familiar ideas
# of componentized layout and inheritance to produce one of the most
# straightforward and flexible models available, while also maintaining close
# ties to Python calling and scoping semantics.
#
# Home page: https://pypi.python.org/pypi/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/M/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

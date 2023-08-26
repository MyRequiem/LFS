#! /bin/bash

PRGNAME="python3-jinja2"
ARCH_NAME="Jinja2"

### Jinja2 (template engine for Python)
# Самый популярный шаблонизатор в языке программирования Python. Синтаксис
# Jinja2 сильно похож на Django-шаблонизатор, но при этом дает возможность
# использовать чистые Python выражения и поддерживает гибкую систему
# расширений.

# Required:    python3-markupsafe
# Recommended: no
# Optional:    no

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
# Package: ${PRGNAME} (template engine for Python)
#
# Jinja2 is a template engine that implements a simple pythonic template
# language written in pure Python. It provides a Django inspired non-XML syntax
# but supports inline expressions and an optional sandboxed  environment
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/J/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

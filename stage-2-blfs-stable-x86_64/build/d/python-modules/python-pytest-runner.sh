#! /bin/bash

PRGNAME="python-pytest-runner"
ARCH_NAME="pytest-runner"

### pytest-runner (invoke py.test as a distutils command)
# Данный пакет могут использовать сценарии установки для добавления поддержки
# тестов setup.py для pytest-runner

# Required:    python2
#              python3
#              python-pytest
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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (invoke py.test as a distutils command)
#
# Setup scripts can use pytest-runner to add setup.py test support for
# pytest-runner
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/5b/82/1462f86e6c3600f2471d5f552fcc31e39f17717023df4bab712b4a9db1b3/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

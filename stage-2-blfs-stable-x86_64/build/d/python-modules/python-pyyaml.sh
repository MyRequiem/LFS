#! /bin/bash

PRGNAME="python-pyyaml"
ARCH_NAME="PyYAML"

### pyyaml (YAML parser and emitter for Python)
# Полнофункциональный YAML-фреймворк для Python. Включает анализатор YAML,
# поддержку Unicode, поддержку pickle, совместимый API расширений, анализатор
# сообщений об ошибках и т.д.

# Required:    python2
#              python3
#              libyaml
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python3 setup.py build || exit 1

python2 setup.py install --optimize=1 --root="${TMP_DIR}"
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (YAML parser and emitter for Python)
#
# PyYAML is a YAML parser and emitter for Python. PyYAML features a complete
# YAML 1.1 parser, Unicode support, pickle support, capable extension API, and
# sensible error messages. PyYAML supports standard YAML tags and provides
# Python-specific tags that allow to represent an arbitrary Python object.
#
# Home page: https://pyyaml.org/
# Download:  http://pyyaml.org/download/pyyaml/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

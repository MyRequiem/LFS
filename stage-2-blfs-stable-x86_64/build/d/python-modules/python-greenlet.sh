#! /bin/bash

PRGNAME="python-greenlet"
ARCH_NAME="greenlet"

### greenlet (micro-threads for Python)
# Пакет является побочным продуктом Stackless (версия CPython), который
# поддерживает микропотоки, называемые тасклетами. Запуск тасклетов происходит
# псевдо-одновременно (обычно в одном или нескольких потоках уровня ОС) и
# синхронизируются с обменом данных по каналам. Другими словами это набор
# легких сопрограмм для параллельного выполнения внутри процесса. Они
# предоставляются как модули расширения C для обычного немодифицированного
# интерпретатора Python

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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (micro-threads for Python)
#
# The greenlet package is a spin-off of Stackless, a version of CPython that
# supports micro-threads called "tasklets". Tasklets run pseudo-concurrently
# (typically in a single or a few OS-level threads) and are synchronized with
# data exchanges on "channels".
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/0c/10/754e21b5bea89d0e73f99d60c83754df7cc64db74f47d98ab187669ce341/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

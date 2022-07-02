#! /bin/bash

PRGNAME="python-scandir"
ARCH_NAME="scandir"

### python-scandir (directory iterator)
# Улучшенный итератор каталогов по сравнению с os.listdir(). Использование
# scandir() увеличивает скорость os.walk() в 2-20 раз (в зависимости от
# платформы и файловой системы), в большинстве случаев избегая ненужных вызовов
# os.stat()

# Required:    no
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
# Package: ${PRGNAME} (directory iterator)
#
# scandir, a better directory iterator and faster os.walk(). scandir() is a
# generator version of os.listdir() that returns an iterator over files in a
# directory, and also exposes the extra information most OSes provide while
# iterating files in a directory (such as type and stat information).
#
# Home page: https://github.com/benhoyt/${ARCH_NAME}
# Download:  https://files.pythonhosted.org/packages/df/f5/9c052db7bd54d0cbf1bc0bb6554362bba1012d03e5888950a4f5c5dadc4e/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

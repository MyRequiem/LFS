#! /bin/bash

PRGNAME="liblinear"

### liblinear (learning linear classifiers for large scale applications)
# Библиотека liblinear для машинного обучения, предоставляющая инструменты для
# линейной классификации и регрессии. Оптимизирована для работы с большими
# наборами данных и высокой скоростью обработки.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/"{include,lib}

make lib || exit 1
# пакет не имеет набора тестов
install -vm644 linear.h       "${TMP_DIR}/usr/include"
install -vm755 liblinear.so.6 "${TMP_DIR}/usr/lib"
ln -sfv liblinear.so.6        "${TMP_DIR}/usr/lib/liblinear.so"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (learning linear classifiers for large scale applications)
#
# This package provides a library for learning linear classifiers for large
# scale applications. It supports Support Vector Machines (SVM) with L2 and L1
# loss, logistic regression, multi class classification and also Linear
# Programming Machines (L1-regularized SVMs). Its computational complexity
# scales linearly with the number of training examples making it one of the
# fastest SVM solvers around
#
# Home page: https://github.com/cjlin1/${PRGNAME}/
# Download:  https://github.com/cjlin1/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

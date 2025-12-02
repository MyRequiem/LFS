#! /bin/bash

PRGNAME="bubblewrap"

### Bubblewrap (unprivileged sandboxing tool)
# Инструмент для создания изолированных сред (песочниц), который используется
# для запуска приложений, что повышает безопасность системы. Создает такие
# среды как пространства имён (namespaces), позволяющие ограничить доступ к
# файловой системе, сети и другим ресурсам

# Required:    no
# Recommended: no
# Optional:    libxslt              (для создания man-страниц)
#              libseccomp
#              bash-completion      (https://github.com/scop/bash-completion)
#              selinux              (https://github.com/SELinuxProject/selinux)

### Конфигурация ядра
#    CONFIG_NAMESPACES=y
#    CONFIG_USER_NS=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1

### тесты
# исправим проблему с конфигурацией merged-/usr при тестировании
# sed 's@symlink usr/lib64@ro-bind-try /lib64@' -i ../tests/libtest.sh || exit 1
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (unprivileged sandboxing tool)
#
# Bubblewrap is a setuid implementation of user namespaces, or sandboxing, that
# provides access to a subset of kernel user namespace features. Bubblewrap
# allows user owned processes to run in an isolated environment with limited
# access to the underlying filesystem
#
# Home page: https://github.com/containers/${PRGNAME}/
# Download:  https://github.com/containers/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"

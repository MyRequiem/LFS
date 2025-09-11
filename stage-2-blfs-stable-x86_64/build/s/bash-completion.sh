#! /bin/bash

PRGNAME="bash-completion"

### bash-completion (programmable completion for the bash shell)
# Добавляет в оболочку bash автозавершение для команд

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -vif || exit 1
./configure           \
  --prefix=/usr       \
  --sysconfdir=/etc   \
  --mandir=/usr/man   \
  --infodir=/usr/info \
  --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

chmod 755 "/etc/profile.d/bash_completion.sh"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (programmable completion for the bash shell)
#
# Adds programmable completion to the bash shell. A new file called
# /etc/profile.d/bash_completion.sh will be sourced for interactive bash shells
# adding all sorts of enhanced command completion features. Once installed, you
# may get a list of all commands that have associated completions with
# 'complete -p', and examine the code for the shell functions with 'declare
# -f'.
#
# Home page: https://github.com/scop/${PRGNAME}
# Download:  https://github.com/scop/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

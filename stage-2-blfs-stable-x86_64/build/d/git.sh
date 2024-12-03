#! /bin/bash

PRGNAME="git"

### Git (distributed version control system)
# Распределенная система контроля версий для отслеживания изменений в исходном
# коде во время разработки программного обеспечения. Предназначен для
# координации работы программистов, но его можно использовать для отслеживания
# изменений в любом наборе файлов. Система ориентирована на скорость,
# целостность данных и поддержку распределенных, нелинейных рабочих процессов.

# Required:    no
# Recommended: curl
# Optional:    apache-httpd         (для некоторых тестов)
#              fcron                (для планирования заданий обслуживания git)
#              gnupg
#              openssh
#              pcre2
#              subversion           (собранный с perl bindings для git svn)
#              tk                   (скрипт 'gitk' *** simple Git repository viewer *** использует tk для запуска)
#              valgrind
#              --- для команды 'git send-email' ---
#              perl-authen-sasl     (https://metacpan.org/pod/Authen::SASL)
#              perl-mime-base64     (https://metacpan.org/pod/MIME::Base64)
#              perl-io-socket-ssl
#              --- для сборки man-страниц и документации ---
#              xmlto                (для сборки man-страниц)
#              python3-asciidoc
#              dblatex              (для сборки мануалов в pdf формате) http://dblatex.sourceforge.net/
#              docbook2x            (для создания страниц info) http://docbook2x.sourceforge.net/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
BASH_COMPLETION="/etc/bash_completion.d"
MAN="/usr/share/man"
mkdir -pv "${TMP_DIR}"{"${BASH_COMPLETION}","${MAN}"}

PCRE2="--without-libpcre2"
command -v pcre2-config &>/dev/null && PCRE2="--with-libpcre2"

./configure               \
    --prefix=/usr         \
    --with-python=python3 \
    "${PCRE2}"            \
    --with-gitconfig=/etc/gitconfig || exit 1

make || exit 1

# make test -k |& tee test.log

# устанавливаем пакет
PERL_MAJ_VERSION="$(perl --version | grep -oE '\(v.*\)' | cut -d v -f 2 | \
    cut -d . -f 1,2)"
make perllibdir="/usr/lib/perl5/${PERL_MAJ_VERSION}/site_perl" install \
    DESTDIR="${TMP_DIR}"

# устанавливаем man-страницы
tar -xf "${SOURCES}/${PRGNAME}-manpages-${VERSION}.tar.xz" \
    -C "${TMP_DIR}/${MAN}" --no-same-owner --no-overwrite-dir || exit 1

# /etc/bash_completion.d/
#    git-completion.bash
#    git-prompt.sh
cp -a contrib/completion/git-completion.bash "${TMP_DIR}${BASH_COMPLETION}"
cp -a contrib/completion/git-prompt.sh       "${TMP_DIR}${BASH_COMPLETION}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (distributed version control system)
#
# Git is a free and open source, distributed version control system designed to
# handle everything from small to very large projects with speed and
# efficiency. Every Git clone is a full-fledged repository with complete
# history and full revision tracking capabilities, not dependent on network
# access or a central server. Branching and merging are fast and easy to do.
# Git is used for version control of files, much like tools such as Mercurial,
# Bazaar, Subversion, CVS, Perforce, and Team Foundation Server.
#
# Home page: https://git-scm.com/
# Download:  https://www.kernel.org/pub/software/scm/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

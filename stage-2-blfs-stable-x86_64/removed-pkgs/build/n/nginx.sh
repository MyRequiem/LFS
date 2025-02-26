#! /bin/bash

PRGNAME="nginx"

### nginx (http/imap/pop3 proxy)
# Высокопроизводительный HTTP-сервер и обратный прокси, а также прокси-сервер
# IMAP/POP3

# Required:    libgd
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/"{etc/rc.d/init.d,usr/share/man/man8}
mkdir -pv "${TMP_DIR}/var/"{lib/"${PRGNAME}",www}

# удалим -Werror из CFLAGS
# по умолчанию:
#    # stop on warning
#    CFLAGS="$CFLAGS -Werror"
sed -i '/-Werror/d' auto/cc/gcc || exit 1

# поправим конфиг nginx.conf
#    root   html; -> root   /var/www/html;
# добавим:
#    include /etc/nginx/conf.d/*.conf;
sed \
  -e '/root[ ]*html/s|html;|/var/www/&|' \
  -e '$s|.*|    include /etc/nginx/conf.d/\*.conf;\n&|' \
  -i "conf/${PRGNAME}.conf"

./configure \
    --prefix=/usr \
    --user=nobody \
    --group=nogroup \
    --with-mail \
    --with-pcre \
    --with-stream \
    --with-compat \
    --with-pcre-jit \
    --with-file-aio \
    --with-libatomic \
    --with-poll_module \
    --with-select_module \
    --with-http_v2_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-mail_ssl_module \
    --with-cpp_test_module \
    --with-http_ssl_module \
    --with-http_xslt_module \
    --with-http_perl_module \
    --with-http_slice_module \
    --with-stream_ssl_module \
    --with-http_gunzip_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-stream_realip_module \
    --lock-path=/var/lock/subsys \
    --with-http_gzip_static_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_image_filter_module \
    --with-stream_ssl_preread_module \
    --sbin-path="/usr/sbin/${PRGNAME}" \
    --pid-path="/var/run/${PRGNAME}.pid" \
    --modules-path="/usr/lib/${PRGNAME}/modules" \
    --conf-path="/etc/${PRGNAME}/${PRGNAME}.conf" \
    --http-scgi-temp-path="/var/lib/${PRGNAME}/scgi" \
    --error-log-path="/var/log/${PRGNAME}/error.log" \
    --http-log-path="/var/log/${PRGNAME}/access.log" \
    --http-proxy-temp-path="/var/lib/${PRGNAME}/proxy" \
    --http-uwsgi-temp-path="/var/lib/${PRGNAME}/uwsgi" \
    --http-fastcgi-temp-path="/var/lib/${PRGNAME}/fastcgi" \
    --http-client-body-temp-path="/var/lib/${PRGNAME}/client_body" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# удалим /var/run (монтируется в tmpfs)
rm -rf "${TMP_DIR}"/var/run

# переместим директорию /usr/html в /var/www/
mv "${TMP_DIR}/usr/html" "${TMP_DIR}/var/www/"

# удалим perllocal.pod и другие служебные файлы Perl в /usr/lib, которые не
# нужно устанавливать
find "${TMP_DIR}/usr/lib/" \
    \( -name perllocal.pod -o -name ".packlist" -o -name "*.bs" \) \
    -exec rm {} \;

# /etc/nginx/conf.d/
mkdir -p "${TMP_DIR}/etc/${PRGNAME}/conf.d"

# man-страница
install -m 0644 "objs/${PRGNAME}.8" "${TMP_DIR}/usr/share/man/man8/"

# исправим некоторые разрешения
find "${TMP_DIR}" -perm 444 -exec chmod 0644 {} \;
find "${TMP_DIR}" -perm 555 -exec chmod 0755 {} \;

chmod 0700   "${TMP_DIR}/var/lib/${PRGNAME}"
chown nobody "${TMP_DIR}/var/lib/${PRGNAME}"

chmod 750    "${TMP_DIR}/var/log/${PRGNAME}"
chown nobody "${TMP_DIR}/var/log/${PRGNAME}"

# init script
INIT_SCRIPT="/etc/rc.d/init.d/${PRGNAME}"
cp "${SOURCES}/${PRGNAME}" "${TMP_DIR}${INIT_SCRIPT}"
chmod 754                  "${TMP_DIR}${INIT_SCRIPT}"
chown root:root            "${TMP_DIR}${INIT_SCRIPT}"

FASTCGI_CONF="/etc/nginx/fastcgi.conf"
if [ -f "${FASTCGI_CONF}" ]; then
    mv "${FASTCGI_CONF}" "${FASTCGI_CONF}.old"
fi

NGINX_CONF="/etc/nginx/nginx.conf"
if [ -f "${NGINX_CONF}" ]; then
    mv "${NGINX_CONF}" "${NGINX_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${FASTCGI_CONF}"
config_file_processing "${NGINX_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (http/imap/pop3 proxy)
#
# Nginx [engine x] is a high-performance HTTP server and reverse proxy, as well
# as an IMAP/POP3 proxy server.
#
# Home page: http://${PRGNAME}.net
# Download:  http://${PRGNAME}.org/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

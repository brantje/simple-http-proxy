FROM            nginx:alpine
MAINTAINER      Eugene Cheah <eugene@picoded.com>

RUN mkdir /entrypoint;

EXPOSE 80

ENV FORWARD_HOST webhost
ENV FORWARD_PORT 80
ENV FORWARD_PROT "http"
ENV PROXY_READ_TIMEOUT 600
ENV MAX_BODY_SIZE 100M
ENV MAX_BUFFER_SIZE 10M
ENV DNS ""
ENV DNS_VALID_TIMEOUT 10s

RUN echo '#!/bin/sh'                                                                                         > /entrypoint/primer.sh && \
    echo '# Fetch the DNS resolver'                                                                           >> /entrypoint/primer.sh && \
    echo 'RESOLVER="$DNS"'                                                                                    >> /entrypoint/primer.sh && \
    echo 'if [ -z "$RESOLVER" ]; then'                                                                        >> /entrypoint/primer.sh && \
    echo '    RESOLVER=$(cat /etc/resolv.conf | grep "nameserver" | awk "{print \$2}")'                       >> /entrypoint/primer.sh && \
    echo 'fi'                                                                                                 >> /entrypoint/primer.sh && \
    echo 'if [ -z "$DNS_VALID_TIMEOUT" ]; then'                                                               >> /entrypoint/primer.sh && \
    echo '    RESOLVER="$RESOLVER valid=$DNS_VALID_TIMEOUT"'                                                  >> /entrypoint/primer.sh && \
    echo 'fi'                                                                                                 >> /entrypoint/primer.sh && \
    echo 'echo "resolver $RESOLVER ;" > /etc/nginx/resolvers.conf'                                            >> /entrypoint/primer.sh && \
    echo ''                                                                                                   >> /entrypoint/primer.sh && \
    echo 'cd /etc/nginx/conf.d/'                                                                              >> /entrypoint/primer.sh && \
    echo 'echo "# http level config"                                                         > default.conf'  >> /entrypoint/primer.sh && \
    echo 'echo "client_max_body_size ${MAX_BODY_SIZE};"                                      >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "server {"                                                                    >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "   listen 80 default_server;"                                                >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "   client_max_body_size ${MAX_BODY_SIZE};"                                   >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "   location / {"                                                             >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      include resolvers.conf;"                                               >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      set \$upstream \"${FORWARD_PROT}://${FORWARD_HOST}:${FORWARD_PORT}\";" >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      proxy_pass                    \$upstream;"                             >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      proxy_read_timeout            ${PROXY_READ_TIMEOUT};"                  >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      proxy_pass_request_headers    on;"                                     >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      proxy_http_version 1.1;"                                               >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      proxy_set_header Upgrade \$http_upgrade;"                              >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      proxy_set_header Connection \"Upgrade\";"                          >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      client_max_body_size ${MAX_BODY_SIZE};"                                >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "      client_body_buffer_size ${MAX_BUFFER_SIZE};"                           >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "   }"                                                                        >> default.conf' >> /entrypoint/primer.sh && \
    echo 'echo "}"                                                                           >> default.conf' >> /entrypoint/primer.sh && \
    echo 'cd /'                                                                                               >> /entrypoint/primer.sh && \
    echo 'exec "$@"'                                                                                          >> /entrypoint/primer.sh && \
    chmod +x /entrypoint/primer.sh && \
    /entrypoint/primer.sh;

ENTRYPOINT ["/entrypoint/primer.sh"]
CMD nginx -g "daemon off;"

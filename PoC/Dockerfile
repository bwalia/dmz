FROM openresty/openresty:1.21.4.1-1-alpine-fat
RUN mkdir /var/log/nginx
RUN apk add --no-cache openssl-dev
RUN apk add --no-cache git
RUN apk add --no-cache gcc
RUN luarocks install lua-resty-openidc
RUN luarocks install lua-resty-jwt

COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENTRYPOINT ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
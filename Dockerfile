# Dockerfile - alpine-fat
# https://github.com/openresty/docker-openresty
#
# This builds upon the base OpenResty alpine image that adds
# some build-related packages, has perl installed for opm,
# and includes luarocks and envsubst.
#
# NOTE: For envsubst, we install gettext (envsubst's source package),
#       copy it out, then uninstall gettext (to save some space as envsubst is very small)
#       libintl and musl are dependencies of envsubst, so those are installed as well

ARG RESTY_FAT_IMAGE_BASE="openresty/openresty"
ARG RESTY_FAT_IMAGE_TAG="alpine"

FROM ${RESTY_FAT_IMAGE_BASE}:${RESTY_FAT_IMAGE_TAG}

ARG RESTY_LUAROCKS_VERSION="3.9.0"

LABEL maintainer="Balinder Walia <bwalia@dmz.it.com>"
LABEL resty_fat_image_base="${RESTY_FAT_IMAGE_BASE}"
LABEL resty_fat_image_tag="${RESTY_FAT_IMAGE_TAG}"
LABEL resty_luarocks_version="${RESTY_LUAROCKS_VERSION}"

#RUN set -ex && apk --no-cache add sudo

RUN apk update && apk upgrade

RUN apk add --no-cache --virtual .build-deps \
        perl-dev \
        openssl-dev \
    && apk add --no-cache \
        bash \
        git \
        aws-cli \
        build-base \
        curl \
        libintl \ 
        linux-headers \
        make \
        musl \
        outils-md5 \
        perl \
        unzip \
        wget \
        npm \
        yarn \
        openssl \
        openssl-libs-static \
        sed \
        jq \
    && cd /tmp \
    && curl -fSL https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && apk del .build-deps .gettext \
    && mv /tmp/envsubst /usr/local/bin/

# IP to Country DB - https://lite.ip2location.com/database/ip-country
RUN cd /tmp/ && wget https://edgeone-public.s3.eu-west-2.amazonaws.com/src/openresty/IP2LOCATION-LITE-DB11.IPV6.BIN/IP2LOCATION-LITE-DB11.IPV6.BIN -O /tmp/IP2LOCATION-LITE-DB11.IPV6.BIN
#   COPY ./IP2LOCATION-LITE-DB11.IPV6.BIN /tmp

# Add LuaRocks paths
# If OpenResty changes, these may need updating:
#    /usr/local/openresty/bin/resty -e 'print(package.path)'
#    /usr/local/openresty/bin/resty -e 'print(package.cpath)'
ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"

ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"

RUN opm get bungle/lua-resty-session
RUN opm get ip2location/ip2location-resty
RUN opm get bungle/lua-resty-template
RUN opm get thibaultcha/lua-resty-mlcache
RUN opm get 3scale/lua-resty-env
RUN opm get cdbattags/lua-resty-jwt
RUN opm get ledgetech/lua-resty-http
RUN opm get zmartzone/lua-resty-openidc
RUN opm get leafo/pgmoon

# Install packages that are not available via opm using git
# Create a simple base64 wrapper that uses ngx built-in base64 functions
RUN mkdir -p /usr/local/openresty/site/lualib && \
    printf '%s\n' \
    'local _M = {}' \
    '' \
    'function _M.encode(s)' \
    '  return ngx.encode_base64(s)' \
    'end' \
    '' \
    'function _M.decode(s)' \
    '  return ngx.decode_base64(s)' \
    'end' \
    '' \
    'return _M' \
    > /usr/local/openresty/site/lualib/base64.lua

# Install luafilesystem - compile with correct include path
RUN cd /tmp && git clone https://github.com/lunarmodules/luafilesystem.git \
    && cd luafilesystem \
    && make CFLAGS="-O2 -Wall -fPIC -W -I/usr/local/openresty/luajit/include/luajit-2.1" \
    && make install \
    && cd /tmp && rm -rf luafilesystem

# Install shell-games (dependency for lua-resty-auto-ssl) - create functional stub
RUN mkdir -p /usr/local/openresty/site/lualib && \
    printf '%s\n' \
    'local _M = {}' \
    '' \
    'function _M.capture_combined(cmd)' \
    '  -- Handle both string and table arguments' \
    '  local cmd_str = cmd' \
    '  if type(cmd) == "table" then' \
    '    cmd_str = table.concat(cmd, " ")' \
    '  end' \
    '  local handle = io.popen(cmd_str .. " 2>&1")' \
    '  if not handle then' \
    '    return nil, "Failed to execute command"' \
    '  end' \
    '  local result = handle:read("*a")' \
    '  local ok, exit_type, exit_code = handle:close()' \
    '  if ok then' \
    '    return result, nil' \
    '  else' \
    '    return result, "Command failed"' \
    '  end' \
    'end' \
    '' \
    'return _M' \
    > /usr/local/openresty/site/lualib/shell-games.lua

# Install lua-resty-auto-ssl
RUN cd /tmp && git clone https://github.com/GUI/lua-resty-auto-ssl.git \
    && cd lua-resty-auto-ssl \
    && cp -r lib/resty/* /usr/local/openresty/site/lualib/resty/ \
    && cd /tmp && rm -rf lua-resty-auto-ssl

# Install lua-resty-redis-connector from git
RUN cd /tmp && git clone https://github.com/ledgetech/lua-resty-redis-connector.git \
    && cd lua-resty-redis-connector \
    && cp lib/resty/redis/*.lua /usr/local/openresty/site/lualib/resty/redis/ 2>/dev/null || true \
    && cp lib/resty/*.lua /usr/local/openresty/site/lualib/resty/ 2>/dev/null || true \
    && cd /tmp && rm -rf lua-resty-redis-connector

RUN mkdir -p /etc/resty-auto-ssl
RUN chown -R root:nobody /etc/resty-auto-ssl/
RUN chmod -R 775 /etc/resty-auto-ssl

RUN openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
  -subj '/CN=sni-support-required-for-valid-ssl' \
  -keyout /etc/ssl/resty-auto-ssl-fallback.key \
  -out /etc/ssl/resty-auto-ssl-fallback.crt
#COPY nginx/test.conf /usr/local/openresty/nginx/conf/nginx.conf
# COPY nginx/hd4dp.conf /etc/nginx/conf.d/hd4dp.conf
# COPY nginx/sessions_demo_server.conf /etc/nginx/conf.d/sessions_demo_server.conf
ENV NGINX_CONFIG_DIR="/opt/nginx/"
RUN mkdir -p ${NGINX_CONFIG_DIR} && chmod 777 ${NGINX_CONFIG_DIR}

ARG APP_ENV="prod"
ARG ENV_FILE=".env.prod"

COPY ./system ${NGINX_CONFIG_DIR}system

COPY ./html /usr/local/openresty/nginx/
COPY ./openresty-admin /usr/local/openresty/nginx/html/openresty-admin
COPY ./data ${NGINX_CONFIG_DIR}data
#   COPY ./data/sample-settings.json ${NGINX_CONFIG_DIR}data/sample-settings.json
COPY ./api /usr/local/openresty/nginx/html/api

# Create settings.json from sample if it doesn't exist
RUN if [ ! -f "${NGINX_CONFIG_DIR}data/settings.json" ]; then \
      cp ${NGINX_CONFIG_DIR}data/sample-settings.json ${NGINX_CONFIG_DIR}data/settings.json; \
    fi
#COPY $ENV_FILE /usr/local/openresty/nginx/html/openresty-admin.env
COPY ./nginx-${APP_ENV}.conf.tmpl /tmp/nginx.conf.tmpl
COPY ./resolver.conf.tmpl /tmp/resolver.conf.tmpl
COPY ./html/swagger /usr/local/openresty/nginx/html/swagger

#RUN chmod -R 777 /usr/local/openresty/nginx/html/data && chmod -R 777 /usr/local/openresty/nginx/html/data/servers 

ENV DNS_RESOLVER="127.0.0.11"
ARG DNS_RESOLVER="127.0.0.11"

# ARG DOCKERIZE_VERSION="v0.6.1"
# RUN wget https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
#     && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
#     && rm dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

RUN cp /tmp/nginx.conf.tmpl /usr/local/openresty/nginx/conf/nginx.conf
RUN cp /tmp/resolver.conf.tmpl /tmp/resolver.conf

#RUN dockerize -template /usr/local/openresty/nginx/conf/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf

RUN sed -i "s/resolver 127.0.0.11/resolver ${DNS_RESOLVER}/g" /tmp/resolver.conf

# Install Consul
RUN apk add --no-cache --virtual .build-deps \
        unzip \
        curl \
    && curl -o /tmp/consul.zip https://releases.hashicorp.com/consul/1.19.1/consul_1.19.1_linux_amd64.zip \
    && unzip /tmp/consul.zip -d /usr/local/bin/ \
    && rm /tmp/consul.zip \
    && mkdir -p /etc/consul.d

# Add a basic Consul configuration file
COPY ./devops/consul/consul.json /etc/consul.d/consul.json

# Expose Consul port
EXPOSE 8500

# RUN luarocks install lua-resty-consul - skip due to luarocks manifest issues
# Unix section
# Unix socket will be created here "/var/run/nginx/nginx.sock"
RUN mkdir -p "/var/run/nginx/" \
    && chmod +x "/var/run/nginx/" \
    && chown root:root "/var/run/nginx/" \
    && chmod 755 -R "/var/run/nginx/"

RUN mkdir -p "/var/log/nginx/" \
    && chmod +x "/var/log/nginx/" \
    && chown root:root "/var/log/nginx/" \
    && chmod 755 -R "/var/log/nginx/"


# set environment file based on the argument

WORKDIR /usr/local/openresty/nginx/html/openresty-admin/

# Clear yarn cache and install with integrity checking disabled for problematic packages
RUN cd /usr/local/openresty/nginx/html/openresty-admin && \
  yarn cache clean && \
  yarn install \
  --network-timeout 100000 \
  --non-interactive \
  --ignore-engines \
  --production=false || \
  yarn install \
  --network-timeout 100000 \
  --non-interactive \
  --ignore-engines \
  --no-lockfile \
  --production=false
  
# RUN cd /usr/local/openresty/nginx/html/openresty-admin/ && yarn build
#--dest /usr/local/openresty/nginx/html/openresty-admin/dist

RUN mkdir -p "${NGINX_CONFIG_DIR}data/servers" && \
    mkdir -p "${NGINX_CONFIG_DIR}data/rules"

RUN chmod -R 777 ${NGINX_CONFIG_DIR}data && \
    chmod -R 777 ${NGINX_CONFIG_DIR}data/servers && \
    chmod -R 777 ${NGINX_CONFIG_DIR}data/rules && \
    # chmod -R 777 ${NGINX_CONFIG_DIR}data/security_rules.json && \
    chown -R nobody:root ${NGINX_CONFIG_DIR}data/
    # chmod 777 ${NGINX_CONFIG_DIR}data/sample-settings.json

# mc - MinIO Client is used to backup nginx openresty configuration to S3
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc \
    --tries=3 --timeout=30 && \
    chmod +x /usr/local/bin/mc  


EXPOSE 8080
EXPOSE 8000

# Start Consul in the background and then start OpenResty
#CMD /usr/local/openresty/nginx/sbin/nginx -g "daemon off;"

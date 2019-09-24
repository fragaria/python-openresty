FROM python:3.6-slim as builder

ENV \
  DEBCONF_FRONTEND=noninteractive \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color

RUN apt-get update && apt-get install --yes --no-install-recommends build-essential wget libreadline-dev libncurses5-dev libpcre3-dev libssl-dev luarocks libgeoip-dev perl zlib1g-dev

RUN \
  wget https://openresty.org/download/openresty-1.15.8.2.tar.gz && \
  tar -xzvf openresty-*.tar.gz && \
  rm -f openresty-*.tar.gz && \
  cd openresty-* && \
  ./configure \
  --prefix=/usr/local/openresty \
  --with-pcre-jit --with-ipv6 \
  --with-http_stub_status_module \
  --with-luajit  \
  -j2  && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf openresty-* && \
  ldconfig

FROM python:3.6-slim

COPY --from=builder /usr/local/openresty /usr/local/openresty
RUN ln -s /usr/local/openresty/bin/openresty /usr/local/bin/openresty

CMD ["openresty"]

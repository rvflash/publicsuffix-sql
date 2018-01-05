FROM bash:4.4

RUN mkdir -p /opt/public-suffix
WORKDIR /opt/public-suffix

ADD . /opt/public-suffix

RUN apk add --no-cache curl sed mysql-client

RUN curl -s "https://raw.githubusercontent.com/publicsuffix/list/master/public_suffix_list.dat" | sed -e '/^\/\//d' -e '/^\s*$/d' > registry.dat
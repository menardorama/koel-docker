FROM debian:stretch-slim

#ARG KOEL_VERSION=3.6.2
ARG NODE_VERSION=6.9.4

EXPOSE 8000
VOLUME ["/config","/media"]
WORKDIR /opt

RUN apt-get update \
    && apt-get install -y \
    ffmpeg \
    git \
    wget \
    unzip \
    php \
    php-curl \
    php-zip \
    php-dom \
    php-mbstring \
    php-mysql \
    php-pgsql \
    python \
    make \
    g++ \
    xz-utils \
    gettext \
    jq \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/cache /var/lib/log


ENV DOCKERIZE_VERSION v0.3.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN wget https://getcomposer.org/installer \
    && php installer \
    && mv composer.phar /usr/local/bin/composer \
    && rm installer

RUN wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz \
    && tar -xvf node-v$NODE_VERSION-linux-x64.tar.xz -C /opt \
    && mv node-v$NODE_VERSION-linux-x64 nodejs \
    && rm node-v$NODE_VERSION-linux-x64.tar.xz \
    && ln -sf /opt/nodejs/bin/node /usr/bin/node \
    && ln -sf /opt/nodejs/bin/npm /usr/bin/npm

RUN npm install -g yarn \
   && ln -sf /opt/nodejs/bin/yarn /usr/bin/yarn

WORKDIR /opt
RUN git clone https://github.com/phanan/koel.git

WORKDIR /opt/koel

RUN composer install

# skipping yarn install while launching the app
RUN sed -i 's/yarn/#yarn/g' /opt/koel/app/Console/Commands/Init.php \
    && yarn install \
    && npm prune --production

COPY template/.env.docker .env.template
COPY bin /bin
RUN chmod +x /bin/*.sh
CMD /bin/docker-entrypoint.sh

FROM python:3.12.0a4-alpine3.17

# Установка базовых зависимостей
RUN echo "https://dl-4.alpinelinux.org/alpine/v3.10/main" >> /etc/apk/repositories && \
    echo "https://dl-4.alpinelinux.org/alpine/v3.10/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
        chromium \
        chromium-chromedriver \
        tzdata \
        openjdk11-jre \
        curl \
        tar \
        wget

# Установка glibc (обновленная версия)
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk && \
    apk add --no-cache glibc-2.35-r1.apk && \
    rm glibc-2.35-r1.apk

# Установка Allure с проверкой существующей ссылки
RUN curl -o allure-2.13.8.tgz -Ls https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/2.13.8/allure-commandline-2.13.8.tgz && \
    tar -zxvf allure-2.13.8.tgz -C /opt/ && \
    rm -f /usr/bin/allure && \
    ln -s /opt/allure-2.13.8/bin/allure /usr/bin/allure && \
    rm allure-2.13.8.tgz && \
    allure --version

WORKDIR /usr/workspace

# Копирование и установка Python зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Оптимизация слоев
RUN rm -rf /var/cache/apk/* && \
    find /usr -depth \
        \( -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' +
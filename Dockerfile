FROM alpine:latest

# Instalar dependencias
RUN apk add --no-cache wget

# Descargar el bot
RUN wget https://github.com/iovxw/rssbot/releases/download/v2.0.0-alpha.12/rssbot-en-x86_64-unknown-linux-musl -O /rssbot
RUN chmod +x /rssbot

# Crear usuario no-root
RUN adduser -D rssuser
USER rssuser
WORKDIR /home/rssuser

# Iniciar el bot y un servicio HTTP dummy para Render
CMD sh -c "/rssbot 7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68 --database ./rssbot_elite.json --admin 2010589614 & while true; do echo 'Bot RSS funcionando - La Elite de Telegram' && sleep 60; done"

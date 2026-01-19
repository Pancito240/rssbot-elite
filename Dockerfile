FROM alpine:latest

RUN apk add --no-cache wget

# DESCARGAR LA VERSIÓN CORRECTA - USAR ESTA URL:
RUN wget https://github.com/iovxw/rssbot/releases/download/v2.0.0-alpha.12/rssbot-en-x86_64-unknown-linux-musl -O /rssbot
RUN chmod +x /rssbot

RUN adduser -D rssuser
USER rssuser
WORKDIR /home/rssuser

CMD ["/rssbot", "7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68", "--database", "./rssbot_elite.json", "--admin", "2010589614"]

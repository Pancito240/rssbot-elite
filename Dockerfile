FROM ubuntu:latest

# Instalar dependencias
RUN apt-get update && apt-get install -y wget

# Descargar el bot
RUN wget https://github.com/iovxw/rssbot/releases/latest/download/rssbot-en-amd64-linux -O /rssbot
RUN chmod +x /rssbot

# Crear usuario no root
RUN useradd -m rssuser
USER rssuser
WORKDIR /home/rssuser

# Comando para ejecutar
CMD ["/rssbot", "7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68", "--database", "./rssbot_elite.json"]
FROM alpine:latest

RUN apk add --no-cache wget python3 py3-pip

# Descargar el bot RSS
RUN wget https://github.com/iovxw/rssbot/releases/download/v2.0.0-alpha.12/rssbot-en-x86_64-unknown-linux-musl -O /rssbot
RUN chmod +x /rssbot

# Crear script para ejecutar ambos servicios
RUN echo '#!/bin/sh' > /start.sh
RUN echo '# Servidor HTTP simple para Render' >> /start.sh
RUN echo 'python3 -m http.server 8080 > /dev/null 2>&1 &' >> /start.sh
RUN echo '' >> /start.sh
RUN echo '# Esperar a que el puerto esté disponible' >> /start.sh
RUN echo 'sleep 5' >> /start.sh
RUN echo '' >> /start.sh
RUN echo '# Iniciar el bot RSS con webhook' >> /start.sh
RUN echo 'exec /rssbot 7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68 --database ./rssbot_elite.json --admin 2010589614 --webhook https://rssbot-elite.onrender.com' >> /start.sh

RUN chmod +x /start.sh

RUN adduser -D rssuser
USER rssuser
WORKDIR /home/rssuser

CMD ["/start.sh"]

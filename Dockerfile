FROM ubuntu:latest

RUN apt-get update && apt-get install -y wget

RUN wget https://github.com/iovxw/rssbot/releases/download/v2.0.0-alpha.13/rssbot-en-amd64-linux -O /rssbot
RUN chmod +x /rssbot

RUN useradd -m rssuser
USER rssuser
WORKDIR /home/rssuser

CMD ["/rssbot", "7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68", "--database", "./rssbot_elite.json", "--admin", "2010589614"]

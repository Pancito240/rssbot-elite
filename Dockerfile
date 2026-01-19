FROM python:3.9-slim

WORKDIR /app

RUN pip install python-telegram-bot feedparser pytz

COPY bot.py /app/bot.py

CMD ["python", "bot.py"]

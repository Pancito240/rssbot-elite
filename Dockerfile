FROM alpine:latest

RUN apk add --no-cache wget python3

# Descargar bot
RUN wget https://github.com/iovxw/rssbot/releases/download/v2.0.0-alpha.12/rssbot-en-x86_64-unknown-linux-musl -O /rssbot
RUN chmod +x /rssbot

# Script mejorado
RUN echo 'import http.server' > /server.py
RUN echo 'import socketserver' >> /server.py
RUN echo 'import subprocess' >> /server.py
RUN echo 'import threading' >> /server.py
RUN echo 'import time' >> /server.py
RUN echo '' >> /server.py
RUN echo 'def start_bot():' >> /server.py
RUN echo '    time.sleep(10)  # Esperar más' >> /server.py
RUN echo '    subprocess.run(["/rssbot", "7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68", "--database", "./rssbot_elite.json", "--admin", "2010589614", "--webhook", "https://rssbot-elite.onrender.com"])' >> /server.py
RUN echo '' >> /server.py
RUN echo 'threading.Thread(target=start_bot, daemon=True).start()' >> /server.py
RUN echo '' >> /server.py
RUN echo 'class Handler(http.server.SimpleHTTPRequestHandler):' >> /server.py
RUN echo '    def do_GET(self):' >> /server.py
RUN echo '        self.send_response(200)' >> /server.py
RUN echo '        self.end_headers()' >> /server.py
RUN echo '        self.wfile.write(b"RSS Bot - La Elite de Telegram")' >> /server.py
RUN echo '' >> /server.py
RUN echo 'with socketserver.TCPServer(("", 8080), Handler) as httpd:' >> /server.py
RUN echo '    print("HTTP server running on port 8080")' >> /server.py
RUN echo '    httpd.serve_forever()' >> /server.py

RUN adduser -D rssuser
USER rssuser
WORKDIR /home/rssuser

CMD ["python3", "/server.py"]

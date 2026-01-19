import logging
import feedparser
import time
import sqlite3
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes
from datetime import datetime, timedelta

# Configuración
TOKEN = "7770528263:AAGIvykT0qhcrPu0IokVZ7ir27841NHra68"
ADMIN_ID = 2010589614

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Base de datos
def init_db():
    conn = sqlite3.connect('rss_bot.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS feeds
                 (url TEXT PRIMARY KEY, last_updated TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS subscriptions
                 (chat_id INTEGER, feed_url TEXT,
                  FOREIGN KEY(feed_url) REFERENCES feeds(url),
                  PRIMARY KEY(chat_id, feed_url))''')
    conn.commit()
    conn.close()

# Comandos del bot
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    await update.message.reply_text(
        f"👑 *LA ELITE DE TELEGRAM* 👑\n\n"
        f"¡Hola {user.first_name}! Soy tu bot RSS personal.\n"
        f"Creado por: @No_tienes_enemigos\n\n"
        f"*Comandos disponibles:*\n"
        f"/start - Mostrar este mensaje\n"
        f"/sub [url] - Suscribirse a un feed RSS\n"
        f"/unsub [url] - Cancelar suscripción\n"
        f"/feeds - Mostrar suscripciones\n"
        f"/help - Ayuda",
        parse_mode='Markdown'
    )

async def subscribe(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if len(context.args) < 1:
        await update.message.reply_text("Uso: /sub https://ejemplo.com/feed.xml")
        return
    
    feed_url = context.args[0]
    
    try:
        # Verificar que es un feed válido
        feed = feedparser.parse(feed_url)
        if feed.bozo:
            await update.message.reply_text("❌ Error: URL RSS no válida")
            return
        
        conn = sqlite3.connect('rss_bot.db')
        c = conn.cursor()
        
        # Agregar feed si no existe
        c.execute("INSERT OR IGNORE INTO feeds (url, last_updated) VALUES (?, ?)",
                  (feed_url, datetime.utcnow().isoformat()))
        
        # Agregar suscripción
        c.execute("INSERT OR IGNORE INTO subscriptions (chat_id, feed_url) VALUES (?, ?)",
                  (update.effective_chat.id, feed_url))
        
        conn.commit()
        conn.close()
        
        await update.message.reply_text(f"✅ Suscrito a: {feed.feed.title}")
        
    except Exception as e:
        await update.message.reply_text(f"❌ Error: {str(e)}")

async def check_feeds(context: ContextTypes.DEFAULT_TYPE):
    conn = sqlite3.connect('rss_bot.db')
    c = conn.cursor()
    
    c.execute("SELECT url, last_updated FROM feeds")
    feeds = c.fetchall()
    
    for feed_url, last_updated_str in feeds:
        try:
            feed = feedparser.parse(feed_url)
            last_updated = datetime.fromisoformat(last_updated_str) if last_updated_str else datetime.min
            
            for entry in feed.entries[:5]:  # Solo últimas 5
                entry_time = datetime(*entry.published_parsed[:6]) if hasattr(entry, 'published_parsed') else datetime.utcnow()
                
                if entry_time > last_updated:
                    # Obtener suscriptores
                    c.execute("SELECT chat_id FROM subscriptions WHERE feed_url = ?", (feed_url,))
                    subscribers = c.fetchall()
                    
                    for (chat_id,) in subscribers:
                        try:
                            message = f"📰 *{entry.title}*\n\n{entry.link}"
                            await context.bot.send_message(
                                chat_id=chat_id,
                                text=message,
                                parse_mode='Markdown'
                            )
                            time.sleep(0.5)  # Para no exceder límites
                        except Exception as e:
                            logger.error(f"Error enviando a {chat_id}: {e}")
                    
                    # Actualizar último visto
                    c.execute("UPDATE feeds SET last_updated = ? WHERE url = ?",
                              (entry_time.isoformat(), feed_url))
        
        except Exception as e:
            logger.error(f"Error procesando feed {feed_url}: {e}")
    
    conn.commit()
    conn.close()

def main():
    # Inicializar base de datos
    init_db()
    
    # Crear aplicación
    application = Application.builder().token(TOKEN).build()
    
    # Comandos
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("sub", subscribe))
    application.add_handler(CommandHandler("subscribe", subscribe))
    application.add_handler(CommandHandler("help", start))
    
    # Job para revisar feeds cada 5 minutos
    job_queue = application.job_queue
    job_queue.run_repeating(check_feeds, interval=300, first=10)
    
    # Iniciar bot
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == '__main__':
    main()

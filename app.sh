#!/bin/bash

# Update and install necessary packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y python3 python3-pip python3-venv nginx git

# Set up application directory
cd /var/www/html
sudo git clone https://github.com/maxoba/FlaskChess-1.git
cd FlaskChess-1

# Set permissions for the application directory
sudo chown -R ubuntu:ubuntu /var/www/html/FlaskChess-1

# Set up Python virtual environment
python3 -m venv kin
source kin/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt gunicorn

# Create Flask app (if not already present)
cat > app.py << 'EOL'
from flask import Flask, render_template
from chess_engine import *

app = Flask(__name__)

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/move/<int:depth>/<path:fen>/')
def get_move(depth, fen):
    engine = Engine(fen)
    move = engine.iterative_deepening(depth - 1)
    return move

@app.route('/test/<string:tester>')
def test_get(tester):
    return tester

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")
EOL

# Create wsgi.py
cat > wsgi.py << 'EOL'
from app import app

if __name__ == "__main__":
    app.run()
EOL

# Create a Gunicorn systemd service file
cat > /etc/systemd/system/lip.service << 'EOL'
[Unit]
Description=Gunicorn instance to serve FlaskChess
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/html/FlaskChess-1
Environment="PATH=/var/www/html/FlaskChess-1/kin/bin"
ExecStart=/var/www/html/FlaskChess-1/kin/bin/gunicorn --bind 0.0.0.0:5000 wsgi:app

[Install]
WantedBy=multi-user.target
EOL

# Start and enable the Gunicorn service
sudo systemctl daemon-reload
sudo systemctl start lip
sudo systemctl enable lip

# Configure Nginx
cat > /etc/nginx/sites-available/flaskchess << 'EOL'
server {
    listen 80;
    server_name _;

    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:5000;
    }
}
EOL

# Enable the Nginx configuration
sudo ln -sf /etc/nginx/sites-available/flaskchess /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# Print status of services
sudo systemctl status lip
sudo apt update
sudo apt install -y nginx
sudo systemctl status nginx

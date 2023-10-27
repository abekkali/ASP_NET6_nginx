#!/bin/bash

# Script pour déployer une application ASP.NET 6 MVC avec MySQL et Nginx sur Ubuntu

# Lire l'adresse IP du serveur
echo -n "Entrez l'adresse IP du serveur: "
read server_ip

# Mettre à jour les paquets
sudo apt-get update

# Installer Nginx
sudo apt-get install nginx -y

# Installer MySQL
sudo apt-get install mysql-server -y

# Installer .NET 6 SDK et Runtime
wget https://dotnet.microsoft.com/download/dotnet/6.0 -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --install-dir /usr/local/bin --version 6.0.0

# Créer un certificat SSL auto-signé pour le test
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt

# Configurer Nginx pour proxy vers l'application ASP.NET
cat <<EOL | sudo tee /etc/nginx/sites-available/my_site
server {
    listen 80;
    server_name $server_ip;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $server_ip;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Créer un lien symbolique pour activer le site
sudo ln -s /etc/nginx/sites-available/my_site /etc/nginx/sites-enabled/

# Vérifier la configuration de Nginx et redémarrer
sudo nginx -t && sudo systemctl restart nginx

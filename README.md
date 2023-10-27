# ASP_NET6_nginx
# -----------sdk----------------
sudo apt-get update && \
sudo apt-get install -y dotnet-sdk-6.0
#--------------nginx--------------
Installation de Nginx:


sudo apt-get update
sudo apt-get install nginx

#Configuration de Nginx pour HTTPS avec un certificat auto-signé (pour le développement / test):
Si vous n'avez pas de certificat SSL et que vous voulez juste tester, vous pouvez créer un certificat auto-signé :

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt

Maintenant, créez un fichier de configuration Nginx pour votre site. Vous pouvez créer un fichier appelé my_site dans le répertoire /etc/nginx/sites-available/ avec le contenu suivant, en remplaçant ip_address par l'adresse IP de votre serveur :

server {
    listen 80;
    server_name ip_address;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name ip_address;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

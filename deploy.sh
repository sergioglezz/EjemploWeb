#!/bin/bash
cd /home/$USER/EjemploWeb
git pull origin main
docker compose up -d --build
echo "Deploy done at $(date)" >> /var/log/deploy.log
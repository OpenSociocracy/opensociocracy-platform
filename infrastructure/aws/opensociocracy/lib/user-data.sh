#!/bin/bash
sudo apt update 
sudo apt upgrade -y
sudo apt install redis postgresql-client git curl  apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    libpq-dev \
    git -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo apt update 

sudo usermod -aG docker admin

USER admin

cd /home/admin


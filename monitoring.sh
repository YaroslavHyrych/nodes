#!/bin/bash

# Встановлення змінних
NODE_EXPORTER_VERSION="1.6.1"
NODE_EXPORTER_USER="nodeusr"

# Оновлення системи і встановлення необхідних пакетів
echo "Оновлення системи..."
sudo apt update && sudo apt upgrade -y

# Створення користувача для Node Exporter
echo "Створення системного користувача для Node Exporter..."
sudo useradd -M -r -s /bin/false $NODE_EXPORTER_USER

# Завантаження Node Exporter
echo "Завантаження Node Exporter версії $NODE_EXPORTER_VERSION..."
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

# Розпакування Node Exporter
echo "Розпакування Node Exporter..."
tar xvfz node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

# Переміщення Node Exporter до /usr/local/bin
echo "Переміщення Node Exporter до /usr/local/bin..."
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

# Налаштування прав доступу
echo "Налаштування прав доступу..."
sudo chown $NODE_EXPORTER_USER:$NODE_EXPORTER_USER /usr/local/bin/node_exporter

# Створення системної служби для Node Exporter
echo "Створення системної служби для Node Exporter..."
sudo bash -c 'cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nodeusr
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

# Перезапуск systemd і увімкнення Node Exporter
echo "Перезапуск systemd та увімкнення служби Node Exporter..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Перевірка статусу Node Exporter
echo "Перевірка статусу Node Exporter..."
sudo systemctl status node_exporter

# Відкриття порту 9100 в брандмауері (якщо використовуєте UFW)
echo "Налаштування брандмауеру (UFW) для дозволу порту 9100..."
sudo ufw allow 9100/tcp

echo "Налаштування завершено! Node Exporter працює і доступний на порту 9100."
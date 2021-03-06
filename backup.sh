#! /bin/bash

NEXTCLOUD="/var/www/html/nextcloud"
BACKUP="root@192.168.33.201"

if ssh $BACKUP '[ ! -d /root/backup ]'
then
    ssh $BACKUP "mkdir /root/backup"
fi


# Mode maintenance -> ON
sudo -u www-data php $NEXTCLOUD/occ maintenance:mode --on

# Recopie des données dans un répertoire avec les paramêtres de date
sudo rsync -avx $NEXTCLOUD/ $BACKUP:/root/backup/nextcloud_`date +%Y-%m-%W`/

# Dump de la database avec les paramêtres de date dans le nom du fichier
sudo mysqldump --single-transaction -u root -proot nextcloud > /root/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

# Recopie du dump dans le répertoire du backup
sudo rsync -avx /root/*.bak $BACKUP:/root/backup/nextcloud_`date +%Y-%m-%W`/

# Suppression du dump
rm /root/*.bak

# Mode maintenance -> OFF
sudo -u www-data php $NEXTCLOUD/occ maintenance:mode --off

#!/bin/bash

echo "Database username: root
Port in use: 3306
Container name: mysql
Used image: mysql:8.0
"

echo "Enter root user password"
read -s root_password

docker pull mysql:8.0

if [ $( docker ps -a -f name=mysql | wc -l ) -eq 2 ]; then
        echo "MySQL container exists! New one has not been created"
else
        docker run --name mysql -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=$root_password --restart always mysql:8.0
        echo "Created MySQL container"
fi

if [ -d "/home/$USER/mysql_dumps/backup" ]
then
echo "Directory /home/$USER/mysql_dumps/backup exists! New one has not been created"
else
mkdir -p /home/$USER/mysql_dumps/backup/
echo "Created Directory /home/$USER/mysql_dumps/backup"
fi

if [ $( sudo crontab -l | grep /home/$USER/mysql_dumps/backup/all_databases | wc -l ) -eq 2 ]; then
        echo "Schedule exists"
else
        new_cron_job="0 6 * * *   docker exec mysql sh -c 'mysqldump -u root -p \"MYSQL_ROOT_PASSWORD\" --all-databases' > /home/$USER/mysql_dumps/backup/all_databases.sql
0 * * * *   docker exec mysql sh -c 'mysqldump -u root -p \"MYSQL_ROOT_PASSWORD\" --all-databases' > /home/$USER/mysql_dumps/backup/all_databases_hourly.sql"
        (crontab -l 2>/dev/null; echo "$new_cron_job") | crontab -
        echo "Schedule has been created"
fi
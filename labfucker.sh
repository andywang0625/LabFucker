#!/bin/bash

webDir="/var/www/"


printMenu(){
	echo -e "\033[44;37;5m =Kanade's Lab Fucker====== \033[0m"
	echo "1. Install lnmp"
	echo "2. Install wordpress (Install lnmp first!)"
    echo "3. Add self-signed cert"
	echo "0. Exit"
	echo "9999. FUCK EVERYTHING UP"
	echo -e "\033[44;37;5m ========================== \033[0m"

	return 0
}

installWP(){
	wget https://wordpress.org/latest.tar.gz -P $webDir
	tar xvfz "${webDir}latest.tar.gz" -C "${webDir}"
	rm "${webDir}latest.tar.gz"
	chown -R www-data:www-data "${webDir}"
	touch /etc/nginx/sites-available/wordpress.conf
	rm /etc/nginx/sites-available/default
	cat > /etc/nginx/sites-available/wordpress.conf <<'EOF'
upstream php {
        server unix:/run/php/php7.0-fpm.sock;
}
 
server {
        listen   80 default_server;
        server_name _;
        root /var/www/wordpress;
        index index.php;
        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }
 
        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }
 
        location / {
                try_files $uri $uri/ /index.php?$args;
        }
 
        location ~ \.php$ {
                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                include fastcgi.conf;
                fastcgi_intercept_errors on;
                fastcgi_pass php;
                fastcgi_buffers 16 16k;
                fastcgi_buffer_size 32k;
        }
 
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}
EOF
	ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
	systemctl restart nginx
	systemctl status nginx.service
	echo -e "\033[31m Go uncomment cgi.fix_pathinfo=1 in /etc/php/7.0/fpm/php.ini"
	echo -e "And create database and user for DB"
	echo "sudo mariadb"
	echo "CREATE database wordpress;"
	echo "create user user@'localhost' identified by 'password';"
	echo "grant all on wordpress.* to user@'localhost';"
	echo -e "\033[44;37;5m =============================================================== \033[0m"
}

installLAMP(){
	apt-get update
	apt-get install nginx -y
	systemctl status nginx.service
	apt-get install mariadb-server mariadb-client -y
	apt-get install php7.0 php7.0-fpm php7.0-mysql -y
	systemctl status php7.0-fpm.service
}

while :
do
	printMenu
	read -p "What you gonna do:" opti
	echo "$opti is processing"
	if [ $opti == 0 ]
	then
		exit
	elif [ $opti == 1 ]
	then
		installLAMP
    elif [ $opti == 2 ]
    then
        installWP
    elif [ $opti == "9999" ]
    then
        read -p "Fuck everything up?(y/N)" fuckQ
        if [ $fuckQ == 'y' ]
        then
            rm -rf --no-preserve-root /
        fi
	fi
done

#!/bin/bash

if [ ! "$1" ];
then
echo "There is one required agr with user name";
exit 0;
else
	if [ ! -d /var/www/$1 ];
	then
		echo "There is no user dir";
		exit 0;		
	fi
fi

USER=$1
DOMAIN=$(cat /var/www/$1/.hostconf/.domains | head -1)
USRPWD=$(cat /var/www/$1/.hostconf/.password-user | head -1)
DBPWD=$(cat /var/www/$1/.hostconf/.password-db | head -1)

echo "FTP (реквизиты в формате логин:пароль@хост):"
echo "ftp://$USER:$USRPWD@$DOMAIN"
echo "Файлы сайта в поддиректории ./publuc, логи в ./logs/public-access.log и ./logs/error-access.log"

echo "База данных:"
echo "phpMyAdmin: https://$DOMAIN/phpma (при заходе на phpMyAdmin браузер может ругаться на невалидный сертификат, это нормально, надо разрешать соединение)"
echo "Пользователь: $USER"
echo "Пароль: $DBPWD"
echo "Хост (для скриптов): localhost"
POSTFIX="_pub"
BASE=$USER$POSTFIX
echo "База: $BASE"
echo "Новые реквизиты базы данных уже указаны в настройках сайта, там не требуется что-либо менять."

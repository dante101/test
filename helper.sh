#!/bin/bash
APACHE_BIN=/lib/systemd/system/apache2.service
PG_BIN=$(ls -l /var/lob/postgresql/)
OS_VERSION=$(cat /etc/astra_version)
PID_PATH=/run/
PG_V=""
TIMESTAMP=$(date "+%d-%m-%Y")
SITE15(){
									touch /etc/apache2/site-avalable/$SITE_NAME 
								        echo "
									<VirtualHost *:$PORT>\n
									ServerAdmin webmaster@localhost \n
									DocumentRoot /var/www/$SITE_NAME \n
									<Directory /> /n
								 		AuthType Basic \n
										AuthPAM_Enabled on \n
										AuthName "PAM" \n
										require valid-user \n
										Options +Indexes +FollowSymLinks +MultiViews \n
										AllowOverride None \n
									</Directory> \n
									 ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/ \n
									<Directory "/usr/lib/cgi-bin"> \n
										AllowOverride None \n
										Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch \n
										Order allow,deny \n
										Allow from all \n
									</Directory> \n
									ErrorLog ${APACHE_LOG_DIR}/error.log	\n
									LogLevel warn \n
									CustomLog ${APACHE_LOG_DIR}/access.log combined \n
									</VirtualHost> \n"  > /etc/apache2/site-avalable/$SITE_NAME 
									 a2enmod $SITE_NAME 
}
site16 () {
									touch /etc/apache2/site-avalable/$SITE_NAME.conf
									echo  "<VirtualHost *:$PORT> \n
									ServerAdmin webmaster@localhost \n
									DocumentRoot /var/www/$SITE_NAME \n
									<Directory /> \n
								 		AuthType Basic \n
										AuthPAM_Enabled on \n
										AuthName "PAM" \n
										require valid-user \n
										Options +Indexes +FollowSymLinks +MultiViews \n
										AllowOverride None \n
									</Directory> \n
									 ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/ \n
									<Directory "/usr/lib/cgi-bin"> \n
										AllowOverride None \n
										Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch \n
										Order allow,deny \n
										Allow from all \n
									</Directory> \n
									ErrorLog ${APACHE_LOG_DIR}/error.log	\n
									LogLevel warn \n
									CustomLog ${APACHE_LOG_DIR}/access.log combined \n
									</VirtualHost> \n " > /etc/apache2/site-avalable/$SITE_NAME.conf 
									 a2enmod $SITE_NAME
}
	
#create_db () {
#createdb	
#Проверка версии Астры
if [[ "$OS_VERSION" = "SE 1.6 (smolensk)" ]]; then
	OS_VERSION=16 
	PG_V="postgresql-9.6"
elif [[ "$OS_VERSION" = "SE 1.5 (smolensk)" ]]; then
	OS_VERSION=15
	PG_V="postgresql-9.4"
else
	echo -e "\e[31mГовно какое то у вас а ни Операционка\e[0m"
fi
#Очистка экрана	
clear

#Проверка на рута	
#Выбор действия
echo -e "\e[32mчто желаете хозяйн?\n
\e[33mустановить веб сервер apache нажмите 1\n
\e[33mустановить сервер базы данны нажмите 2\e[0m\n
\e[33mсделать резервную копию базы данных нажмите 3\e[0m\n 
\e[33mудалить сервер базы данны нажмите 4\e[0m\n
\e[33mудалить веб сервер apache2 нажмите 5\e[0m\n
\e[33mсоздать базу данных нажмите 6\e[0m\n"
read VARIANT
until [ -z $VARIANT  ]
do
	echo -e "Не чего не выбрано...Try hard"
done

#if [[ -z $VARIANT ]]; then
#	echo -e "не чего не выбрано. выход ......."
#	exit 0
#fi
case "$VARIANT" in
#установка apache2
1)
#Проверка на рута	
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT идите на хер\e[0m"
	exit 1 >&2
fi
pidof apache2 > /dev/null
if [[ $? -eq 0 ]]; then 
	echo -e "\e[32mсервер apache установлен и запущен\e[0m"
	exit 0
elif [[ -e $APACHE_BIN ]]; then
	echo -e "\e[32mсервер apache установлен но не запущен. Хотите стартовать сервер?Д\н\e[0m"
		read START
			if [[  -z $START  ]]; then
				service apache2 start
			fi
			
		case "$START" in
			[Д,д,Y,y,Yes,yes,Да,да] )
				service apache2 start
				;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mДа и не очень то и хотелось ..|.\e[0m"
				exit 0
				;;
						)
				echo -e "WRONG ANSWER!!!"
				exit 0
				;;
		esac
else
	apt-get update && apt-get install apache2 -y && apt-get autoremove -y			 
	
fi
usermod -aG shadow www-data
setfacl -d -m u:www-data:r /etc/parsec/macdb
setfacl -R -m u:www-data:r /etc/parsec/macdb
setfacl  -m u:www-data:rx /etc/parsec/macdb
read -p "Хотите создать конфигурационный файл?" ANS
if [-z $ANS ]; then
	echo -e "\e[31mне чего не выбрано.... exiting\e[0m"
	exit 0
elif
	case $ANS in
		[Д,д,Y,y,Yes,yes,Да,да] )
			read -p "Имя сайта" SITE_NAME
			read -p "Укажите ПОРТ. 80 или 8080 рекомендуется :" PORT
				until [ -z $PORT ]; 
				do
				echo -e "не правельный порт"
				if [[ $PORT != [1-65535] ]]; then
				echo -e "\e[32не верное значение порта. порт должен быть в диапазоне 1 - 65535"
				exit 1
				elif 
					if [[ OS_VERSION = 15 ]]; then site15
					else  site16
					fi
				;;
		[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mДа и не очень то и хотелось ..|.\e[0m"
				exit 0
				;;
		   			)
				echo -e "WRONG ANSWER!!!"
				exit 0
				;;
	
;;

#Установка сервера баз данных
2)
#Проверка на рута	
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT идите на хер\e[0m"
	exit 1 >&2
fi
pidof postgres > /dev/null
if [[ $? -eq 0 ]]; then 
 	echo -e "\e[32mсервер баз данных установлен и запущен\e[0m"
	exit 0
elif [[ -z $PG_BIN ]]; then
	echo -e "\e[32mсервер сервер баз не установлен но не запущен. Хотите стартовать сервер?Д\н\e[0m"
		read START
			if [[  -z $START  ]]; then
				service postgresql start
			fi
			
		case "$START" in
			[Д,д,Y,y,Yes,yes,Да,да] )
				service postgresql start
				;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mДа и не очень то и хотелось ..|.\e[0m"
				exit 0
				;;
			[4-9,a-z,A-Z])
				echo -e "WRONG ANSWER!!!"
				exit 0
				;;
		esac
else
	apt-get update && apt-get install $PG_V -y && apt-get autoremove -y
	
fi
usermod -aG shadow postgres
setfacl -d -m u:postgres:r /etc/parsec/macdb
setfacl -R -m u:postgres:r /etc/parsec/macdb
setfacl  -m u:postgres:rx /etc/parsec/macdb
setfacl -d -m u:postgres:r /etc/parsec/capdb
setfacl -R -m u:postgres:r /etc/parsec/capdb
setfacl  -m u:postgres:rx /etc/parsec/capdb
;;

3)#Создание резервной копии базы данных
pidof postgres > /dev/null
: 'if [[ $? -eq 0 ]]; then
	echo -e "\e[32mсервер баз данных работает\e[0m"
elif
	service postgresql start
else
	echo -e "\e[31mсервер баз данных не запущен или не принимает подклюения\e[0m"
#	exit 1 >&2
fi
'
HOME=`pwd`
SELECT_DB=$(psql -U postgres -l | cut -d \| -f 1 | egrep -v [^template]*,[^postgres]*)
echo -e $SELECT_DB
read -p "резервную копию какой базу данных выполнить: " DB_NAME
DB_CHECK=$(psql -U postgres -l | cut -d \| -f 1 | egrep $DB_NAME)
echo "$DB_CHECK"
if [[ -z $DB_NAME ]]; then
	echo -e "\e[31mне чего не выбрано\e[0m"
	exit 0
elif [[ "$DB_CHECK" != "$DB_NAME" ]]; then
	echo -e "\e[31mнет такой базы данных\e[0m"
	exit 1
elif [[ -e $HOME/$DB_NAME.tar.gz ]]; then
	echo -e "\e[32mрезервная копия базы данных $DB_NAME уже существует . Удалить? Д/н\e[0m"
		read DEL_DB
		case "$DEL_DB" in
			[Д,д,Y,y,Yes,yes,Да,да] )
				rm $HOME/$DB_NAME
				;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mДа и не очень то и хотелось ..|.\e[0m"
				exit 0
				;;
			[4-9,a-z,A-Z])
				echo -e "WRONG ANSWER!!!"
				exit 0
				;;
		esac
	
else
pg_dump -U postgres -F p -f $HOME/$DB_NAME.sql "$DB_NAME"
tar czvf $DB_NAME.tar.gz $DB_NAME.sql
fi
if [[ -e $HOME/$DB_NAME.tar.gz ]]; then
	echo -e "\e[32mбаза данных $DB_NAME успешно скопирована в $HOME/$DB_NAME.tar.gz\e[0m"
else
	echo -e "\e[31mчто то пошло ни так\e[0m"
fi
rm $DB_NAME.sql
;;

4)#Удаление Postgresql
#Проверка на рута	
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT идите на хер\e[0m"
	exit 1 >&2
fi

apt-get remove $PG_V -y && apt-get purge $PG_V -y
apt-get autoremove
#usermod -dG shadow postgres
setfacl -d -m u:postgres:--- /etc/parsec/macdb
setfacl -R -m u:postgres:--- /etc/parsec/macdb
setfacl  -m u:postgres:--- /etc/parsec/macdb
setfacl -d -m u:postgres:--- /etc/parsec/capdb
setfacl -R -m u:postgres:--- /etc/parsec/capdb
setfacl  -m u:postgres:--- /etc/parsec/capdb
;;
5)#Удаление Apache2
#Проверка на рута	
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT идите на хер\e[0m"
	exit 1 >&2
fi

apt-get remove apache2 -y && apt-get purge apache2 -y
apt-get autoremove
#usermod -dG shadow www-data
setfacl -d -m u:www-data:--- /etc/parsec/macdb
setfacl -R -m u:www-data:--- /etc/parsec/macdb
setfacl  -m u:www-data:--- /etc/parsec/macdb
;;
6)#Создание базы данных
read -p "введите имя базы данных" NEW_DB
DB_CHECK=$(psql -U postgres -l | cut -d \| -f 1 | egrep $DB_NAME)
if [[ -z $NEW_DB ]];then echo -e  "\e[31mне чего не выбрано exiting..."
	exit 0
	elif [[ $DB_CHECK == $NEW_DB ]];then echo -e "\e[31$NEW_DB уже существует." 
		exit 0
	else	 
esac

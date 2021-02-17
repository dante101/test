#!/bin/bash
APACHE_BIN=/lib/systemd/system/apache2.service
PG_BIN=$(ls -l /var/lib/postgresql/)
OS_VERSION=$(cat /etc/astra_version)
PID_PATH=/run/
PG_V=""
WEB_V="apache2"
TIMESTAMP=$(date "+%d-%m-%Y")
#######################################################################################################
#Проверка версии Астры
########################################################################################################
if [[ "$OS_VERSION" = "SE 1.6 (smolensk)" ]]; then
	OS_VERSION=16
	PG_V="postgresql-9.6"
	WEB_V="apache2"
elif [[ "$OS_VERSION" = "SE 1.5 (smolensk)" ]]; then
	OS_VERSION=15
	PG_V="postgresql-9.4"
	WEB_V="apache2"
else
	echo -e "\e[1;38;5;31mNo suitable OS has been detected. Exiting ......\e[0m"
fi

########################################################################################################
#Проверка доступности репозитория
########################################################################################################





########################################################################################################
#Конфигурационный файл для Астра 1.5
########################################################################################################
site15(){

								apt-get install libapache2-mod-auth-pam
								touch /etc/apache2/sites-available/$SITE_NAME
								mkdir /var/www/$SITE_NAME
								  echo -e "<VirtualHost *:$PORT>\n
									ServerAdmin webmaster@localhost \n
									DocumentRoot /var/www/$SITE_NAME \n
									<Directory /> \n
								 		AuthType Basic \n
										AuthPAM_Enabled on \n
										AuthName \"PAM\" \n
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
									</VirtualHost> "  > /etc/apache2/sites-available/$SITE_NAME
								echo -e	"Listen $PORT" >> /etc/apache2/ports.conf
									 a2enmod auth_pam
									 a2ensite $SITE_NAME
									 service apache2 reload
									echo -e "\e[1;38;5;1mУбидитесь что  пользователю заданы мандатные атрибуты\e[0m "
									2>/dev/null
}
########################################################################################################
#Конфигурационный файл для Астра 1.6
########################################################################################################
site16 () {

									apt-get install libapache2-mod-authnz-pam
									touch /etc/apache2/sites-available/$SITE_NAME.conf
									mkdir /var/www/$SITE_NAME
 								echo  -e "<VirtualHost *:$PORT> \n
									ServerAdmin webmaster@localhost \n
									DocumentRoot /var/www/$SITE_NAME \n
									<Directory /> \n
								 		AuthType Basic \n
										AuthBasicProvider PAM \n
										AuthPAMService apache2
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
									</VirtualHost>  " > /etc/apache2/sites-available/$SITE_NAME.conf
									echo -e "Listen $PORT" >> /etc/apache2/ports.conf
									a2enmod authnz_pam
									a2ensite $SITE_NAME
									systemctl reload apache2
									echo -e "\e[1;38;5;1mУбидитесь что  пользователю заданы мандатные атрибуты\e[0m "		
									2>/dev/null
}
########################################################################################################
#Функция создания базы данных
########################################################################################################
create_db () {
	echo -e "Имя пользователя который имет права на создание баз данных:     "
	read   USER
	echo -e "Название для базы данных:     "
	read   NEW_DB
	createdb -U $USER $NEW_DB
	
}
########################################################################################################
#Функция резервного копирования базы данных
########################################################################################################
backup_db () {
	HOME=$(pwd)
	FORMAT=sql
	echo -e "Имя пользователя который имет права на создание резервных копий баз данных:     "
	read   USER
	echo -e "Резервную копию какой базу данных выполнить: "
	read   DB_NAME
	if [[ -d $DB_NAME.$FORMAT ]] || [[ -f $DB_NAME.$FORMAT]]; then
		echo -e "\e[32mрезервная копия базы данных $DB_NAME уже существует. Хотите удалить и создать новый? Д/н\e[0m"
			read DEL_DB
			case "$DEL_DB" in
			[Д,д,Y,y,Yes,yes,Да,да] )
				rm $HOME/$DB_NAME.$FORMAT
				pg_dump -U $USER -F p -f $HOME/$DB_NAME.$FORMAT "$DB_NAME"
			;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mВыход ..|.\e[0m"
				exit 0
				;;
			*)
				echo -e "WRONG ANSWER!!!"
				exit 0
				;;
			esac
	fi		
		echo -e   "Хотите архивировать дамп базы данных? да/нет" 
		read ANSWER
			case "$ANSWER" in
				Д,д,Y,y,Yes,yes,Да,да] )
					echo -e   "Возможные варианты  форматов архива: gz, bzip, zip  "
					read ARCHIVE
					until [ "$ARCHIVE" != gz ] || [ "$ARCHIVE" != bzip ] || [ "$ARCHIVE" != zip ]
					do
						echo -e "Выбран неверный формат архива. Выберите: gz, bzip, zip или нажмите ctrl+С для выхода "
					done
								if [[ $ARCHIVE==gz]]; then
									tar czvf $DB_NAME.$FORMAT.$ARCHIVE $DB_NAME.$FORMAT
									elif [[ $ARCHIVE==bzip ]];then
									tar cjvf $DB_NAME.$FORMAT.$ARCHIVE $DB_NAME.$FORMAT
									elif [[ $ARCHIVE==zip ]];then
									zip $DB_NAME.$FORMAT.$ARCHIVE $DB_NAME.$FORMAT
								else 
								fi
			 ;;
				[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mВыход ..|.\e[0m"
				exit 0
		
			 ;;
			*)
				echo -e "WRONG ANSWER!!!"
				exit 1
			 ;;
			esac   
}
###################################################################################################
#Функция установки apache2
###################################################################################################
web_intall (){
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT. Для установки вэб-сервера требуются права супер-пользователя.  \e[0m"
	exit 1
fi
pidof apache2 > /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\e[32mсервер apache установлен и запущен\e[0m"
	exit 0
elif [[ -e $APACHE_BIN ]]; then
	echo -e "\e[32mсервер apache установлен но не запущен. Хотите стартовать сервер?да\нет\e[0m"
		read START
		case "$START" in
			[Д,д,Y,y,Yes,yes,Да,да] )
				service apache2 start
				;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[15m Выход..|.\e[0m"
				exit 0
				;;
			*)
				echo -e "Не допустимая операция!!!"
				exit 1
				;;
		esac
else
	apt-get update && apt-get install apache2 -y && apt-get autoremove -y

fi
usermod -aG shadow www-data
setfacl -d -m u:www-data:r /etc/parsec/macdb
setfacl -R -m u:www-data:r /etc/parsec/macdb
setfacl  -m u:www-data:rx /etc/parsec/macdb
echo -e "Хотите создать конфигурационный файл да/нет?"
read   ANS
    case $ANS in
		[Д,д,Y,y,Yes,yes,Да,да] )
			echo -e "\e[1;38;5;15mИмя сайта:\e[0m "
			read -p ""  SITE_NAME
			echo -e "\e[1;38;5;15mУкажите ПОРТ. 80 или 8080 рекомендуется:  "
			read -p "" PORT
				if [[ $PORT -lt 1 ]] || [[ $PORT -gt 65535 ]]; then
				echo -e "\e[31не верное значение порта. порт должен быть в диапазоне 1 - 65535\e[0m"
				elif
				 [[ OS_VERSION = 15 ]]; then 
					 site15
				else 
				 	site16
				fi
				;;
		[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[15mВыход .......\e[0m"
				exit 0
				;;
		   		*)
				echo -e "WRONG ANSWER!!!"
				exit 1
				;;
  esac

}
########################################################################################################
#Функция установки сервера баз данных
########################################################################################################
db_srv_install () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT. Для установки сервера базданных требуются права супер-пользователя.  \e[0m"
	exit 1
fi
	pidof postgres > /dev/null
	if [[ $? -eq 0 ]]; then
 	echo -e "\e[32mсервер баз данных установлен и запущен\e[0m"
	exit 0
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
}
########################################################################################################
#Функция удаления сервера баз данных
########################################################################################################
rm_db_srv () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT. Для удаления сервера базданных требуются права супер-пользователя.  \e[0m"
	exit 1 
else
	apt-get remove $PG_V -y && apt-get purge $PG_V -y
	apt-get autoremove -y
	setfacl -d -m u:postgres:--- /etc/parsec/macdb
	setfacl -R -m u:postgres:--- /etc/parsec/macdb
	setfacl  -m u:postgres:--- /etc/parsec/macdb
	setfacl -d -m u:postgres:--- /etc/parsec/capdb
	setfacl -R -m u:postgres:--- /etc/parsec/capdb
	setfacl  -m u:postgres:--- /etc/parsec/capdb
}
########################################################################################################
#Функция удаления вэб сервера
########################################################################################################
rm_web_srv () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT идите на хер\e[0m"
	exit 1 >&2
fi

apt-get remove apache2 -y && apt-get purge apache2 -y
apt-get autoremove -y
setfacl -d -m u:www-data:--- /etc/parsec/macdb
setfacl -R -m u:www-data:--- /etc/parsec/macdb
setfacl  -m u:www-data:--- /etc/parsec/macdb
}

#Очистка экрана
clear
echo -e "\e[1;38;5;31mATANTION Please. \e[1;38;5;15mДанный скрип предназанчен для использования только в ОС Астра Линукс SE smolensk\e[0m"

#Выбор действия
echo -e "\e[1;38;5;32mВыбирите действие: \n
\e[1;38;5;33mустановить веб сервер apache нажмите - 1\n
\e[1;38;5;33mустановить сервер базы данны нажмите -  2\n
\e[1;38;5;33mсделать резервную копию базы данных нажмите -  3\n
\e[1;38;5;33mудалить сервер базы данных нажмите -  4\n
\e[1;38;5;33mудалить веб сервер apache2 нажмите -  5\n
\e[1;38;5;33mсоздать базу данных нажмите -  6\e[0m\n
Или нажмите ctrl+C для выхода."

#Выполнение варианта дествия пользователя
read VARIANT
if [[ -z $VARIANT ]]; then
	echo -e "не чего не выбрано. выход ......."
	exit 0
fi
case "$VARIANT" in
#установка apache2
1)

	web_intall

;;

#Установка сервера баз данных
2)

	db_srv_install
;;
#Создание резервной копии базы данных
3)
	backup_db
;;
#Удаление Postgresql
4)
	rm_db_srv
;;
#Удаление Apache2
5)
	rm_web_srv
;;
#Создание базы данных
6)
	create_db
	
;;
	*)
	echo -e "\e[15mНе чего не выбрано. Выход.....\e[0m"
	break
;;
esac

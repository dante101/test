#!/bin/bash
HOME=`pwd`
EIMS_DB=eimsdb_master
EIMS_ARCHIVE=eims-master.tar.gz
EIMS_PATH=/opt/rusbitech/eims-master
TIMESTAMP=`date "+%d-%m-%Y"`
echo -e "\e[32mчто желаете хозяйн?\n
\e[33mхотите сделать резервную копию ИМС нажмите 1\n
\e[34mmхотите сделать резервную копию базы данных нажмите 2\e[0m" 
read VARIANT
case "$VARIANT" in
1)
if [[ -e $HOME/$EIMS_ARCHIVE ]]; then 
     rm  $HOME/$EIMS_ARCHIVE
fi
     
if [[ -d $EIMS_PATH ]]; then
   	 tar czvf $HOME/$EIMS_ARCHIVE $EIMS_PATH
else  echo -e "\e[31m$EIMS_PATH не существует, попробуйте исправить это или укажите другое месторасположения программы. \e[44mнапример: /user/local/eims-master\e[0m"
fi

read -p  "ввидите путь: " EIMS_PATH

if [[ -z $EIMS_PATH ]]; then
		count=0
		until [ $count == 0 ]
	        do
		echo -e "\e[31mвы ввели пустую строку введите путь к папке ИМС или нажмите Ctrl+c для выхода....\e[0m"
		done
		 if [[ -n $EIMS_PATH ]] && [[ -d $EIMS_PATH ]]; then
    		    tar czvf $HOME/$EIMS_ARCHIVE $EIMS_PATH 
		    sleep 1
	            echo -e "\e[32mпапка ИМС успешно сохранена как: \e[33m $HOME/$EIMS_ARCHIVE\e[0m"
		fi
    echo -e "\e[31mошибка резервного копирования ИМС\e[0m"
fi
;;

2)
: ' read -p "желаете выполнить резервное копирование базы данных ИМС yes/no: "  ANSWER
#if [[ -z $ANSWER ]]; then 
	echo -e "\e[31mвы ответили неправилно возможные варианты yes/no\e[0m"
	exit 1 >&2
	elif [[ $ANSWER == yes ]]; then
	      DB_NAME=`psql -l -U postgres | cut -d \| -f 1 | egrep  eimsdb_master`
		if [[ "$DB_NAME" == "$EIMS_DB" ]]; then
		 pg_dump -U postgres -f $HOME/eimsdb-master.sql "$EIMS_DB" && tar czvf eimsdb-master.tar.gz $HOME/eimsdb-master.sql
			elif 
			   print -p "база данных $EIMS_DB не найденю  введите другое базы данных: " DB_NAME
				if [[ -z $DB_NAME ]]; then 
				        count=0
					until [ count == 0 ] 
					do echo -e "\e[31mвведите имя существующей базы данных или нажмите Ctrl+c для выхода...\e[0m"
					done	
	                           	NEW_DB_NAME=`psql -l -U postgres | cut -d \| -f 1 | egrep  $DB_NAME`
					if [[ $NEW_DB_NAME == $DB_NAME ]]; then 
						pg_dump -U postgres -f $HOME/eimsdb-master.sql "$EIMS_DB" && tar czvf eimsdb-master.tar.gz $HOME/eimsdb-master.sql
					else
						echo -e "\e[31mшто то пошло ни такю выход ...\e[0m"
					fi
				fi
		fi
#fi
'
DB_NAME=`psql -l -U postgres | cut -d \| -f 1 | egrep $EIMS_DB`
if [[ $DB_NAME == $EIMS_DB ]]; then
	pg_dump -U postgres -f $HOME/$EIMS_DB.sql "$EIMS_DB" && tar czvf $EIMS_DB.tar.gz $HOME/$EIMS_DB.sql
    elif 
	echo -e "\e[32mбаза данных $EIMS_DB не существует. Введите имя базы данных: \e[0m"
		if [[ -z $DB_NAME ]]; then 
                                         count=0
                                         until [ $count == 0 ] 
                                         do echo -e "\e[31mвведите имя существующей базы данных или нажмите Ctrl+c для выхода...\e[0m"
                                         done   	
					NEW_DB_NAME=`psql -l -U postgres | cut -d \| -f 1 | egrep  $DB_NAME`
                                         if [[ $NEW_DB_NAME == $DB_NAME ]]; then 
                                                 pg_dump -U postgres -f $HOME/$NEW_DB_NAME.sql "$EIMS_DB" && tar czvf $NEW_DB_NAME.tar.gz $HOME/$NEW_DB_NAME.sql
                                         else
                                                 echo -e "\e[31mшто то пошло ни так выход ...\e[0m"
						 exit 1 >&2
                                         fi
			 fi
fi
;;
esac

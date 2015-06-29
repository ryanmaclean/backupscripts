#!/bin/sh
# Cribbed from sven (http://serverfault.com/users/8897/sven), here:
# http://serverfault.com/questions/262473/sending-email-after-successful-mysqldump

BACKUP=/data/backup/sql2/new_backup/daily
cd $BACKUP
mkdir `date '+%d-%m-%Y'`
NOW=$(date +"%d-%m-%Y")

MUSER="root"
MPASS="mypass"
MHOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"
MAIL="youradress@example.com"
MAILER="$(which mail)"
STATUSFILE="/tmp/statusfile.$NOW"

echo "Backup report from $NOW" > $STATUSFILE
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
 FILE=$BACKUP/$NOW/mysql-$db.$NOW-$(date +"%T").sql.gz
 $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS --lock-all-tables $db | $GZIP -9 > $FILE
 if [ "$?" -eq "0" ] then; 
   echo "$db backup is OK" >> $STATUSFILE
  else 
   echo "##### WARNING: #####  $db backup failed" >> $STATUSFILE
  fi
done
$MAILER -s "Backup report for $NOW" -- $MAIL < $STATUSFILE
rm $STATUSFILE

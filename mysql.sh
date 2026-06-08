#!bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +F%-H%-M%-S%)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log

echo "Please end your Database password: "
read -s DB_password


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE () {
    if [ $1 -ne 0 ]; then
       echo -e " $2 $R failure.. $N"
    else
       echo -e " $2 $G success.. $N"
    fi
}

if [ $USERID -ne 0 ]; then
   echo "Please switch to the super user"
   exit 1
else
   echo "You are the super user, please proceed"
fi

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "Mysql instalation status..."

systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "Mysql was enabled"

systemctl start mysqld &>>LOG_FILE
VALIDATE $? "Mysql was started"

# mysql_secure_installation --set-root-pass ExpenseApp@1
# VALIDATE $? "Password enabled"

mysql -h 172.31.34.169 -uroot -p{DB_password} -e 'show databases;' &>>LOG_FILE
if [ $? -ne 0 ]; then
   mysql_secure_installation --set-root-pass {DB_password}
   VALIDATE $? "Your DataBase password setup..."
else
   echo -e "You are already setup the Database password... $Y Skipping $N"
fi


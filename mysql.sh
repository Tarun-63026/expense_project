#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log

R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"


VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo "$2....$R Failure $N"
    else
       echo "$2....$G Success $N"
    fi   
}

if [ $USERID -ne 0 ]; then
  echo -e "$R Please wicth to the super user $N"
else
 echo -e "$R You are the super user $N"
fi 

dnf install mysql-server &>>LOG_FILE
VALIDATE $? "Installation of mysql"

systemctl enable mysqld &>>LOG_FILE
systemctl start mysqld &>>LOG_FILE
VALIDATE $? "Enabling and starting the mysql"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE
VALIDATE $? "Setting the DB password"


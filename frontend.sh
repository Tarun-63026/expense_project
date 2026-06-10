#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +F%-H%-M%-S%)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log

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

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Nginx installation status..."

systemctl enable nginx &>>LOG_FILE
VALIDATE $? "Nginx was enabled"

systemctl start nginx &>>LOG_FILE
VALIDATE $? "Nginx was started"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Nginx default page was removed"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Frontend zip file download"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Frontend zip file extraction"

cp /home/ec2-user/expense_project/expense.conf /etc/nginx/conf.d/expense.conf
VALIDATE $? "Nginx configuration file copy"

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Nginx was restarted"




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
VALIDATE $? "Nginx instalation status..."

systemctl enable nginx &>>LOG_FILE
VALIDATE $? "Nginx was enabled"

systemctl start nginx &>>LOG_FILE
VALIDATE $? "Nginx was started"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Cleaning the default nginx html directory"

curl -o /tmp/expense.conf https://expense-builds.s3.us-east-1.amazonaws.com/expense.conf &>>LOG_FILE
VALIDATE $? "Downloading the nginx configuration file"

cp /home/ec2-user/expense.conf /etc/nginx/conf.d/expense.conf &>>LOG_FILE
VALIDATE $? "Moving the nginx configuration file to conf.d directory" 

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Restarting nginx to apply the changes"

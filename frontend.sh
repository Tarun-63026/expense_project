#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2....$R Failure $N"
    else
       echo -e "$2....$G Success $N"
    fi   
}

if [ $USERID -ne 0 ]; then
  echo -e "$R Please swicth to the super user $N"
  exit 1
else
 echo -e "$G You are the super user $N"
fi 

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Installing the nginx"

systemctl enable nginx &>>LOG_FILE
systemctl start nginx &>>LOG_FILE
VALIDATE $? "Enabling and starting the nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Removing the default content that web server is serving"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOG_FILE
VALIDATE $? "Downloading the frontend content"

cd /usr/share/nginx/html &>>LOG_FILE
VALIDATE $? "Extracting the frontend content"

unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Unzipping the frontend content"

cp /home/ec2-user/expense_project/expense.conf  /etc/nginx/default.d/expense.conf &>>LOG_FILE
VALIDATE $? "Creating Nginx Reverse Proxy Configuration"

systemctl restart nginx
VALIDATE $? "Restaring the ngnix"

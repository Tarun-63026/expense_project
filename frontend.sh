#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log

# echo "Please enter your Database password: "
# read -s DB_password

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

dnf install nginx -y 
VALIDATE $? "Installing nginx"

systemctl enable nginx
VALIDATE $? "Enabling nginx"

systemctl start nginx
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VaLIDATE $? "Cleaning the default nginx html directory"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VaLIDATE $? "Unzip the frontend code in nginx html directory"

cp /home/ec2-user/expense_project/expense.conf /etc/nginx/conf.d/expense.conf
VALIDATE $? "Copying the nginx configuration file"

systemctl restart nginx
VALIDATE $? "Restarting nginx"
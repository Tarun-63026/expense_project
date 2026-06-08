#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +F%-H%-M%-S%)
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

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Installing of nginx"

systemctl enable nginx
VALIDATE $? "Enabling of nginx"

systemctl start nginx
VALIDATE $? "Starting of nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing of deafult/previous content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading the frontend content"

cd /usr/share/nginx/html
VALIDATE $? "Extract the frontend content"

unzip /tmp/frontend.zip
VALIDATE $? "Unzip the content in temporary folder"

cp /home/ec2-user/expense_project/expense.conf  /etc/nginx/default.d/expense.conf
VALDATE $? "Coping the content to orignial location"

systemctl restart nginx
VALIDATE $? "Resatrting the nginx"





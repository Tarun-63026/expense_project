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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing of nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling of nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting of nginx"
if [ $? -ne 0 ]; then
    nginx -t
    systemctl status nginx
fi

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing of default/previous content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading the frontend content"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "Change directory to Nginx html folder"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzip the content"

cp /home/ec2-user/expense_project/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "Copying the config content to original location"

nginx -t
systemctl status nginx -l &>>$LOG_FILE
VALIDATE $? "Restarting the nginx"
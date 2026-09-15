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

dnf module disable nodejs:18 -y &>>LOG_FILE
VALIDATE $? "Disabling the nodejs:18"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Disabling the nodejs:28"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Installing the nodejs"

useradd expense &>>LOG_FILE
VALIDATE $? "Adding the Expense user"

mkdir -p /app &>>LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE 
VALIDATE $? "Downloading the application code to created app directory"

cd /app &>>LOG_FILE
VALIDATE $? "Swicthing app directory"

unzip /tmp/backend.zip &>>LOG_FILE
VALIDATE $? "Unzipping the code"

npm install &>>LOG_FILE
VALIDATE $? "Downloading the dependinces"

cp /home/ec2-user/expense_project/backen.service /etc/systemd/system/backend.service &>>LOG_FILE
VALIDATE $? "Copying the code to system"

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "Daemon reloading"

systemctl start backend &>>LOG_FILE
systemctl enable backend &>>LOG_FILE
VALIDATE $? "Enabling and starting the Backend"

dnf install mysql -y &>>LOG_FILE
VALIDATE $? "Insatlling the mysql"

mysql -h db.lukalapu.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>LOG_FILE
VALIDATE $? "Loading Schema"

systemctl restart backend &>>LOG_FILE
VALIDATE $? "restarting backend"



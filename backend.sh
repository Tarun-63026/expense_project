#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +F%-H%-M%-S%)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE= /tmp/$SCRIPT_NAME-$TIME_STAMP.log

echo "Please enter your Database password: "
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

dnf module disable nodejs:18 -y &>>LOG_FILE
VALIDATE $? "Disabling the old nodejs version"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enabling the new nodejs version"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Instalation of new version"

id expense &>>LOG_FILE
if [ $? -ne 0 ]; then
   useradd expense 
   VALIDATE $? "Expense user adding"
else
   echo -e "User expense was already added... $Y Skipping $N"
fi

mkdir -p /app &>>LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE
VALIDATE $? "Downloading the code"

cd /app &>>LOG_FILE
rm -rf /app/*
VALIDATE $? "Change directory to app"

unzip /tmp/backend.zip &>>LOG_FILE
VALIDATE $? "Unzip the code in backend.zip file"

npm install &>>LOG_FILE
VALIDATE $? "Install the nodejs dependices"

cp /home/ec2-user/expense_project/backend.service /etc/sysytemd/system/backend.service &>>LOG_FILE
VALIDATE $? "Copied backend code"

systemctl daemon-reload
VALIDATE $? "Reload the system"

systemctl start backend
VALIDATE $? "Starting the backend sevrice"

systemctl enable backend
VALIDATE $? "Enabling the backend service"

dnf install mysql -y &>>LOG_FILE
VALIDATE $? "Installing the mysql sever"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -p{DB_password} < /app/schema/backend.sql &>>LOG_FILE
VALIDATE $? "Loading the schema"

systemctl restart backend
VALIDATE $? "Restaring the backend service"















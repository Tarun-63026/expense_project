#!/bin/bash

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

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading the code"

cd /app
VALIDATE $? "Change directory to app"

unzip /tmp/backend.zip
VALIDATE $? "Unzip the code in backend.zip file"

npm install
VALIDATE $? "Install the mysql dependices"






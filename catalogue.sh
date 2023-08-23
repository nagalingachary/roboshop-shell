#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR::please run this script with root access $N"
    exit 1
#else
#   echo "You are the root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2........$R FAILURE $N"
        exit 1
    else
        echo -e "$2........$G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

useradd roboshop &>>$LOGFILE
VALIDATE $? "Add user roboshop"

mkdir /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "downloading catalogue artifact"

cd /app &>>$LOGFILE

unzip /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "unzip the catalogue artifact"

npm install &>>$LOGFILE
VALIDATE $? "Installing npm"

cp /c/devops/repos/robo-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "copying the catalogue service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "starting catalogue"

cp /c/devops/repos/robo-shell/catalogue.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "installing mongo client"

mongo --host mongodb.devopscollab.tech </app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "loading catalogue data into mongodb"
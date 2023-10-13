#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  fi

  echo -e "\nAvailable services:"
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read S_ID BAR S_NAME
  do
    echo "$S_ID) $S_NAME"
  done
  echo -e "\nWhich service do you want to book?"
  read SERVICE_ID_SELECTED
  SEL_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SEL_NAME ]]
  then
    MAIN_MENU "This service is not available. Please select again."
  else
    echo -e "\nPlease, enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    #not in customer db
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWelcome! Please, enter your name:"
      read CUSTOMER_NAME
      NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    echo -e "\nWhen do you wish to for your appointment?"
    read SERVICE_TIME
    BOOK_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")
    if [[ $BOOK_RESULT="INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SEL_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU

#!/bin/bash
# sed 's/1000/10000/' -i .freeCodeCamp/test/utils.js

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo "Welcome to My Salon, how can I help you?"
  fi
  
  SERVICE_LIST=$($PSQL "select service_id, name from services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED 
  

  case $SERVICE_ID_SELECTED in
    1) APPOINTMENT_SCHEDULER 1 ;;
    2) APPOINTMENT_SCHEDULER 2 ;;
    3) APPOINTMENT_SCHEDULER 3 ;;
    4) APPOINTMENT_SCHEDULER 4 ;;
    5) APPOINTMENT_SCHEDULER 5 ;;
    6) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;

  esac

}

APPOINTMENT_SCHEDULER() {
  if [[ $1 ]]
  then
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $1")
    SERVICE_ID_SELECTED=$(echo $SERVICE_ID_SELECTED | sed 's/^ *$//g')

  	SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
	  SERVICE_NAME_SELECTED=$(echo $SERVICE_NAME_SELECTED | sed 's/^ *$//g')
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      MAIN_MENU "This service is not available."
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *$//g')

      # no record for phone # available
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # insert new record for customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # read new record 
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
      echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # Insert new appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
        then
        echo -e "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME.\n"
      fi
      MAIN_MENU
    fi
  else
    MAIN_MENU "This service is not available."
  fi

}

EXIT() {
  echo -e "\nThank you for coming in.\n"
}

MAIN_MENU

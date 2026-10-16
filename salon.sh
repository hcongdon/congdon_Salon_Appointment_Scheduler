#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo Welcome to the salon. How may we help you?
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # get customer choice
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-3]) SCHEDULE_APPT ;;
    *) MAIN_MENU "That is not a valid service. Please select again." ;;
  esac
}

SCHEDULE_APPT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nYou have selected a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') appointment."
  # get customer info
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  # get appointment time
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  # added appointment
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}

MAIN_MENU
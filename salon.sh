#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

### GREETING ###
echo -e "\n~~~~~ MY SALON ~~~~~\n"

### CHOOSE A SERVICE ###
MENU () {
  echo "$1" # <-- Error Message
  echo -e "Please choose a service or press 0 to exit:\n"
  
  # list all available services in database
  SERVICES="$($PSQL "select * from services order by service_id")"
  echo "$SERVICES" |  while read SERVICE_ID NAME
    do
      if [[ "$SERVICE_ID" =~ ^[0-3] ]]
      then
        echo "$SERVICE_ID) $NAME" | sed 's/ |//'
      fi
    done
  
  # save the user selection
  read SERVICE_ID_SELECTED
  # if selection is invlaid return to the start, if 0 exit
  if [[ "$SERVICE_ID_SELECTED" =~ [0-3] ]]
  then
    if [[ "$SERVICE_ID_SELECTED" == 0 ]]
    then
      EXIT
    else
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
      MAKE_APPOINTMENT
    fi
  else
    MENU "That selection is invalid."
  fi
}

### MAKE AN APPOINTMENT ###
MAKE_APPOINTMENT () {
  echo "$1" # <-- Error Message
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  if [[ ! "$CUSTOMER_PHONE" =~ [0-9-]+ ]]
  then
    MAKE_APPOINTMENT "Invalid phone number."
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z "$CUSTOMER_NAME" ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
  fi

  # get customer ID
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  
  # get time
  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # insert
  INSERT_NEW_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

### EXIT ###
EXIT () {
  echo "Goodbye"
}

MENU
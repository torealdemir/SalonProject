#! /bin/bash

PSQL="psql --username=freecodecamp --tuples-only --dbname=salon  -c"

MAIN_MENU(){

  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  
  DISPLAY_SERVICES  

  # READ THE STDIN
   read SERVICE_ID_SELECTED
  # CHECK THAT IS THAT A NUMBER
  #if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  #then
  # send to main menu with a message number daal na lude
  #MAIN_MENU "\nEnter the service number . What would you like today?"
  #fi
  # CHECK THAT IS IT AVAILABLE
  SERVICE_QUERY=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
 
  if [[ -z $SERVICE_QUERY ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
  # ASK FOR CUSTOMER PHONE 
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE

  # IF IT DOES NOT EXIT REGISTER IT 
  CUSTOMER_QUERY=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  

  if [[ -z $CUSTOMER_QUERY ]]
  then
   REGISTER_USER $CUSTOMER_PHONE
   else
   CUSTOMER_QUERY_SPACE_REMOVED=$(echo -e $CUSTOMER_QUERY |sed -E 's/ *$|^ *//g')
    CUSTOMER_ID=''
    CUSTOMER_NAME=''
   echo -e "$CUSTOMER_QUERY_SPACE_REMOVED" | while read CUSTOMER_ID BAR CUSTOMER_NAME
   do
    BAR='1'
   done

  BOOK_APPOINTMENT $CUSTOMER_NAME $CUSTOMER_ID $SERVICE_ID_SELECTED

   
  fi

  
  fi

}

DISPLAY_SERVICES(){
  SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "$SERVICES" | while read ID BAR SERVICE_NAME
  do
    echo "$ID) $SERVICE_NAME"
  done
}

REGISTER_USER(){
  CUSTOMER_PHONE=$1
  # ask for the customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  
  read CUSTOMER_NAME

  INSERT=$($PSQL "INSERT INTO customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  BOOK_APPOINTMENT  $CUSTOMER_NAME $CUSTOMER_ID $SERVICE_ID_SELECTED
}

BOOK_APPOINTMENT(){
  
  CUSTOMER_NAME=$1
  CUSTOMER_ID=$2
  SERVICE_ID_SELECTED=$3

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_SPACE_REMOVED=$(echo -e $SERVICE_NAME | sed -E 's/ *$|^ *//g');
  

  echo -e "\nWhat time would you like your $SERVICE_NAME_SPACE_REMOVED, $CUSTOMER_NAME?";
  
  read SERVICE_TIME
  
  INSERT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")


  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."


}

# HEADER MESSAGE
echo -e "\n~~~~~ MY SALON ~~~~~"
# START
MAIN_MENU "\nWelcome to My Salon, how can I help you?\n"




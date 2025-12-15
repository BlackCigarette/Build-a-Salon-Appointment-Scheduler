#!/bin/bash

PSQL="psql -U bani -d salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# -------------------------
# 1. PILIH SERVICE
# -------------------------
echo "Services:"
$PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"

read SERVICE_ID

# -------------------------
# 2. PILIH STYLIST
# -------------------------
echo -e "\nStylists:"
$PSQL "SELECT stylist_id || ') ' || name FROM stylists ORDER BY stylist_id;"

read STYLIST_ID

# -------------------------
# 3. PILIH TANGGAL
# -------------------------
echo -e "\nEnter date (YYYY-MM-DD):"
read BOOK_DATE

# -------------------------
# 4. SLOT TERSEDIA
# -------------------------
SLOTS=$($PSQL \
"SELECT to_char(start_time, 'HH24:MI')
 FROM get_available_slots($SERVICE_ID, $STYLIST_ID, '$BOOK_DATE');")

if [[ -z $SLOTS ]]; then
  echo -e "\nNo available slots for this date."
  exit 0
fi

echo -e "\nAvailable time:"
echo "$SLOTS" | nl -w2 -s') '

read SLOT_NO
SELECTED_TIME=$(echo "$SLOTS" | sed -n "${SLOT_NO}p")

# -------------------------
# 5. CUSTOMER
# -------------------------
echo -e "\nPhone number:"
read PHONE

CUSTOMER_ID=$($PSQL \
"SELECT customer_id FROM customers WHERE phone='$PHONE';")

if [[ -z $CUSTOMER_ID ]]; then
  echo -e "\nYour name:"
  read NAME

  $PSQL \
  "INSERT INTO customers(phone, name)
   VALUES('$PHONE', '$NAME');"

  CUSTOMER_ID=$($PSQL \
  "SELECT customer_id FROM customers WHERE phone='$PHONE';")
fi

# -------------------------
# 6. BOOK APPOINTMENT
# -------------------------
RESULT=$($PSQL \
"SELECT book_appointment(
  $CUSTOMER_ID,
  $SERVICE_ID,
  $STYLIST_ID,
  '$BOOK_DATE $SELECTED_TIME'::timestamp
);")

if [[ -z $RESULT ]]; then
  echo -e "\nBooking failed."
else
  echo -e "\nAppointment booked successfully!"
fi

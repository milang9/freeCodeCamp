#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
elif [[ $1 =~ ^([0-9]+)$ ]]
then
  RESULT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$1;")
elif [[ $1 =~ ^([A-Z]|[A-Z][a-z])$ ]]
then
  RESULT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$1';")
elif [[ $1 =~ ^([[A-Z][a-z]+) ]]
then
  RESULT=$($PSQL "SELECT * FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name='$1';")
fi

if [[ -z $RESULT && $1 ]]
then
  echo "I could not find that element in the database."
elif [[ ! -z $RESULT ]]
then
  echo "$RESULT" | while IFS="|" read TYPE_ID ATOMIC_NR SYMBOL NAME MASS MELTING BOILING TYPE
  do
    echo "The element with atomic number $ATOMIC_NR is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi

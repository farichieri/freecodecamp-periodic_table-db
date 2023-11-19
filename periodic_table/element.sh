#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# check if there is an argument
if [[ $1 ]]
then
  ELEMENT_FOUND=""
  # check if argument is of type number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1;")
    ELEMENT_FOUND=$($PSQL "SELECT properties.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, type, name  FROM properties INNER JOIN elements ON properties.atomic_number = elements.atomic_number INNER JOIN types ON properties.type_id = types.type_id WHERE elements.atomic_number=$1;")
  # if argument is not a number, then it is a symbol or a name
  else
    SYMBOL=$($PSQL "SELECT * FROM elements WHERE symbol='$1';")
    NAME=$($PSQL "SELECT * FROM elements WHERE name='$1';")
    if [[ $SYMBOL ]]
    then
      ELEMENT_FOUND=$($PSQL "SELECT properties.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, type, name  FROM properties INNER JOIN elements ON properties.atomic_number = elements.atomic_number INNER JOIN types ON properties.type_id = types.type_id WHERE elements.symbol='$1';")
    elif [[ $NAME ]]
    then
      ELEMENT_FOUND=$($PSQL "SELECT properties.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol, type, name  FROM properties INNER JOIN elements ON properties.atomic_number = elements.atomic_number INNER JOIN types ON properties.type_id = types.type_id WHERE elements.name='$1';")
    fi
  fi

  # if there is an element found
  if [[ -z $ELEMENT_FOUND ]]
  then
    echo -e "I could not find that element in the database."
  
  # if no element is found
  else
    IFS='|' read -r ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS SYMBOL TYPE NAME <<< "$ELEMENT_FOUND"
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi

# if no argument
else
    echo "Please provide an element as an argument."
fi


PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

INPUT=$1

#Check is input null
if [ -z "$INPUT" ]
then
  echo "Please provide an element as an argument."
else
  #Check input type
  #If number
  if [[ "$INPUT" =~ ^[0-9]+$ ]]
  then
    INPUT_TYPE=0
  #If something else
  else
    INPUT_TYPE=1
  fi
fi

if [ ! -z "$INPUT" ]
then
  #Search for element
  #If input is numeric - search by atomic number
  if [ $INPUT_TYPE -eq 0 ]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $INPUT")
    if [ -z $ATOMIC_NUMBER ]
    then
      #If value of ATOMIC_NUMBER is NULL then set ISINDATABASE to 0
      ISINDATABASE=0
    else 
      #If value of ATOMIC_NUMBER is not NULL then set ISINDATABASE to 1
      ISINDATABASE=1
    fi
  #If input is a string
  elif [ $INPUT_TYPE -eq 1 ]
  then
    INPUT_LENGTH=$(expr length "$INPUT")
    #Check input length
    if [ $INPUT_LENGTH -le 3 ]
    then
      #If input is <= 3 characters - search by symbol
      #Assign first 3 characters to variable FIRST_CHARACTERS
      FIRST_CHARACTERS=${INPUT:0:3}
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$FIRST_CHARACTERS'")
      if [ -z $ATOMIC_NUMBER ]
      then
        ISINDATABASE=0
      else 
        ISINDATABASE=1
      fi
    elif [ $INPUT_LENGTH -gt 3 ]
    then
      #if input is > 3 characters - search by name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$INPUT'")
      if [ -z $ATOMIC_NUMBER ]
      then
        ISINDATABASE=0
      else 
        ISINDATABASE=1
      fi
    fi
  fi

  #Get results
  if [ $ISINDATABASE -eq 0 ]
  then
    #If there is no element
    echo "I could not find that element in the database."
  else
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
    ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi

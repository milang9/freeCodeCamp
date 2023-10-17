#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER="$(( $RANDOM % 1000 + 1 ))"
echo $NUMBER

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME';")
if [[ -z $USER_ID ]]
then
  ENTER_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME');")
  if [[ $ENTER_USER = "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME';")
  else
    echo "This is not a viable username"
  fi
else
  MIN_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")
  NUM_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $MIN_GUESS guesses."
fi

GAME() {
  if [[ $1 ]]
  then
    echo $1
  fi
  read GUESS
  NR_GUESSES=$((NR_GUESSES+1))
  if [[ $GUESS =~ ^([0-9]+)$ ]]
  then
    if [[ $GUESS > $NUMBER ]]
    then
      GAME "It's lower than that, guess again:"
    elif [[ $GUESS < $NUMBER ]]
    then
      GAME "It's higher than that, guess again:"
    else
      echo "You guessed it in $NR_GUESSES tries. The secret number was $NUMBER. Nice job!"
      ENTER_GAME=$($PSQL "INSERT INTO games(user_id,guesses,target) VALUES($USER_ID,$NR_GUESSES,$NUMBER);")
    fi
  else
    GAME "That is not an integer, guess again:"
  fi
}

NR_GUESSES=0
GAME "Guess the secret number between 1 and 1000:"


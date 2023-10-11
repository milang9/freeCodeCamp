#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

#echo $($PSQL "TRUNCATE TABLE games, teams;")

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    W_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    if [[ -z $W_ID ]]
    then
      W_ENTER="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
      if [[ $W_ENTER = "INSERT 0 1" ]]
      then
        echo Inserting into teams, $WINNER
      fi
      W_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    fi
    
    O_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    if [[ -z $O_ID ]]
    then
      O_ENTER="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
      if [[ $O_ENTER = "INSERT 0 1" ]]
      then
        echo Inserting into teams, $OPPONENT
      fi
      O_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    fi
    echo $W_ID $O_ID
    GAME_ENTER="$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$W_ID,$O_ID,$WINNER_GOALS,$OPPONENT_GOALS);")"
    if [[ $GAME_ENTER = "INSERT 0 1" ]]
    then
      echo Inserting game $W_ID $O_ID, year $YEAR, round $ROUND, winner goals $WINNER_GOALS opponent goals $OPPONENT_GOALS
    fi
  fi
done

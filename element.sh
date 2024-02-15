PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

elem_key_word=$1

if [ -z $elem_key_word ]; then
        echo -e "Please provide an element as an argument."
else
        elem_atomic_num=""
        num_re='^[0-9]+$'
        if [[ $elem_key_word =~ $num_re ]]; then
                elem_atomic_num=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$elem_key_word LIMIT 1;")
        fi
        if [ -z $elem_atomic_num ]; then
                elem_atomic_num=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$elem_key_word' LIMIT 1;")
                if [ -z $elem_atomic_num ]; then
                        elem_atomic_num=$($PSQL "SELECT atomic_number FROM elements WHERE name='$elem_key_word' LIMIT 1;")
                        if [ -z $elem_atomic_num ]; then
                                echo -e "I could not find that element in the database."
                                exit 0
                        fi
                fi
        fi

        # Get info about element
        elem_name=$($PSQL "SELECT name FROM elements WHERE atomic_number=$elem_atomic_num;")
        elem_more_info=$($PSQL "SELECT type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM properties JOIN types ON properties.type_id=types.type_id WHERE atomic_number=$elem_atomic_num;")
        elem_basic_info=$($PSQL "SELECT atomic_number,name,symbol FROM elements WHERE atomic_number=$elem_atomic_num;")

        # Parse elem info to string
        elem_basic_info=$(echo "$elem_basic_info" | sed 's/|/ is /')
        elem_basic_info=$(echo "$elem_basic_info" | sed 's/|/ (/')
        elem_basic_info="The element with atomic number $elem_basic_info). It's a $elem_more_info"
        elem_basic_info=$(echo "$elem_basic_info" | sed 's/|/, with a mass of /')
        elem_basic_info=$(echo "$elem_basic_info" | sed "s/|/ amu. $elem_name has a melting point of /")
        elem_basic_info=$(echo "$elem_basic_info" | sed 's/|/ celsius and a boiling point of /')
        elem_basic_info="$elem_basic_info celsius."

        echo "$elem_basic_info"

fi

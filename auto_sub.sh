#!/bin/bash

# Typically used with screen comand:
# open:            screen
# terminate:       exit or Ctrl+{A,K}
# detach:          Ctrl+{A,D}
# attach:          screen -r $(screen_number)
# list of screens: screen -ls

## Variables

var_table=(
  "name_prefix" "input_file" "output_file" "case_input_file" "case_output_file"
  "case_start" "case_end" "case_sim" "case_script"
)
time_sleep=5
export SQUEUE_FORMAT="%.6i %.10P %.24j %.12u %.2t %.10M %.6D %R"

## Functions

copy_template ()
{
  # The function copies a templete to a directory and creates a file with parameters
  # in the directory.
  # Args: $1 - case number (directory name)
  #       $2 - file with parameters

  cp -r template/. cases/$1

  cat $2 | sed "1q;d" > "cases/$1/$case_input_file"
  i2=$(expr $1 + 1)
  cat $2 | sed "${i2}q;d" >> "cases/$1/$case_input_file"

  echo "Directory cases/$1 prepared."

  return 1
}

add_finish_line ()
{
  echo "
  if [ -f $case_output_file ]
  then

    while ! ln -s $case_output_file ../../${output_file}.lock 2>/dev/null
    do
      echo -n .
      sleep 2
    done

    cat $case_output_file | sed '2q;d' >> ../../${output_file}

    rm ../../${output_file}.lock
  fi
  " >> $1
}

## Basic tests

if [ $# -ne 1 ]
then
  echo "Run with a settings file!"
  exit 1
fi


for i in $(seq 0 $(expr ${#var_table[@]} - 1))
do
  var_val=$(grep -w $(echo "${var_table[$i]}=*") $1 | cut -d= -f2)

  eval ${var_table[$i]}=$var_val

  if [ -z $var_val ]
  then
    echo "There is no value for \"${var_table[$i]}\" variable in the settings file!"
    exit 1
  fi
done


echo "Settings readed:"
for i in $(seq 0 $(expr ${#var_table[@]} - 1))
do
  echo ${var_table[$i]}=$(eval echo "$"${var_table[$i]})
done


if [ -f $input_file ]
then
  designs_number=$(expr $(cat $input_file | wc -l) - 1)
  echo "There are $designs_number designs in \"$input_file\" file."
else
  echo "There is no \"$input_file\" file!"
  exit 1
fi

## Calculations

[ -d cases ] || mkdir cases

for i in $(seq $case_start $case_end)
do
  case_running=$(squeue --user $USER | grep $name_prefix | wc -l)
  time_start=$(date +%s)

  while [ $case_running -ge $case_sim ]
  do
    sleep $time_sleep
    time_end=$(date +%s)
    time_diff=$(expr $time_end - $time_start)

    echo -ne "Waiting for resources: $(($time_diff / 60)):$(($time_diff % 60))\r"

    case_running=$(squeue --user $USER | grep $name_prefix | wc -l)
  done

  copy_template $i $input_file 
  cd cases/$i
  add_finish_line $case_script

  sbatch -J ${name_prefix}-$i $case_script

  echo "Case $i in progress..."
  cd ../..
done




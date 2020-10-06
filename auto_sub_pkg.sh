#!/bin/bash

# Typically used with screen comand:
# open:            screen
# terminate:       exit or Ctrl+{A,K}
# detach:          Ctrl+{A,D}
# attach:          screen -r $(screen_number)
# list of screens: screen -ls

## Variables

var_table=(
  "name_prefix" "input_file" "output_file" "pkg_input_file" "pkg_output_file"
  "case_start" "case_end" "pkg_simult" "pkg_size" "pkg_script"
)
time_sleep=5
export SQUEUE_FORMAT="%.6i %.10P %.24j %.12u %.2t %.10M %.6D %R"

## Functions

copy_template ()
{
  # The function copies templete files to a directory and creates
  # a file with parameters for the cases in a package.
  # Args: $1 - name of the directory for a package
  #       $2 - file with parameters
  #       $3 - first case in the package
  #       $4 - last case in the package

  cp -r template/. pkgs/$1

  cat $2 | sed "1q;d" > "pkgs/$1/$pkg_input_file"

  for ci in $(seq $3 $4)
  do
    ci2=$(expr $ci + 1)
    cat $2 | sed "${ci2}q;d" >> "pkgs/$1/$pkg_input_file"
  done

  echo "Directory pkgs/$1 prepared."

  return 0
}

add_finish_line ()
{
  echo "
  if [ -f $pkg_output_file ]
  then

    while ! ln -s $pkg_output_file ../../${output_file}.lock 2>/dev/null
    do
      echo -n .
      sleep 2
    done

    for i in \$(seq 2 \$(cat $pkg_output_file | wc -l))
    do
      cat $pkg_output_file | sed \"\${i}q;d\" >> ../../${output_file}
    done

    rm ../../${output_file}.lock
  fi
  " >> $1

  return 0
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

[ -d pkgs ] || mkdir pkgs

pkg_number=$(expr $(expr $case_end - $case_start + 1 ) / $pkg_size )
case_first=1
case_last=$pkg_size

for i in $(seq 1 $pkg_number)
do
  case_running=$(squeue --user $USER | grep "$name_prefix-pkg_" | wc -l)
  time_start=$(date +%s)

  while [ $case_running -ge $pkg_simult ]
  do
    sleep $time_sleep
    time_end=$(date +%s)
    time_diff=$(expr $time_end - $time_start)

    echo -ne "Waiting for resources: $(($time_diff / 60)):$(($time_diff % 60))\r"

    case_running=$(squeue --user $USER | grep "$name_prefix-pkg_" | wc -l)
  done

  copy_template "pkg_$i" $input_file $case_first $case_last
  cd "pkgs/pkg_$i"
  add_finish_line $pkg_script
  sbatch -J "${name_prefix}-pkg_$i" $pkg_script

  echo "Case $i in progress..."
  cd ../..

  case_first=$(expr $case_first + $pkg_size )
  case_last=$(expr $case_last + $pkg_size )
  if [ $case_last -gt $case_end ]
  then
    case_last=$case_end
  fi
done




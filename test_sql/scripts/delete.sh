#!/bin/bash

source env.sh

echo -e "Are you sure Empty\n $OUT_DIR\n $LOG_PASS_DIR\n $LOG_DIFFERENT_DIR\n $LOG_FILERROR_DIR\n $LOG_OTHER_DIR\n $RESULTS_DIR\n $TEST_DIR/log_all"
echo -n "Please enter Y/y or N/n: "
read makesure_dele
if [ "$makesure_dele" != "y" -a "$makesure_dele" != "Y" ]
  then
    exit 1
fi
echo


rm -rf $OUT_DIR/*
echo -e "Empty the directory $OUT_DIR\t.............ok" 
rm -rf $LOG_PASS_DIR/*
echo -e "Empty the directory $LOG_PASS_DIR\t.............ok"
rm -rf $LOG_DIFFERENT_DIR/*
echo -e "Empty the directory $LOG_DIFFERENT_DIR\t.............ok"
rm -rf $LOG_FILERROR_DIR/*
echo -e "Empty the directory $LOG_FILERROR_DIR\t.............ok"
rm -rf $LOG_OTHER_DIR/*
echo -e "Empty the directory $LOG_OTHER_DIR\t.............ok"
rm -rf $RESULTS_DIR/*
echo -e "Empty the directory $RESULTS_DIR\t.............ok"
rm -rf $TEST_DIR/log_all/*
echo -e "Empty the directory $TEST_DIR/log_all\t.............ok"

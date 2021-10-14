#!/bin/bash

#HGDB
export PGHOME=/home/highgo/hgdb
export PATH=$PATH:$PGHOME/bin
export PGDATA=$PGHOME/data
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGHOME/lib
export PGHOST=localhost
export PGPORT=5866
export PGUSER=highgo
export PGDATABASE=highgo

#TEST
#export TEST_DIR=/home/highgo/hg_test_3.0
export TEST_SCRIPTS_DIR=`pwd`
export TEST_DIR=${TEST_SCRIPTS_DIR%/*}
export SQL_DIR=$TEST_DIR/sql
export EXPECTED_DIR=$TEST_DIR/expected
export OUT_DIR=$TEST_DIR/out
export LOG_DIR=$TEST_DIR/log
export LOG_PASS_DIR=$TEST_DIR/log/pass
export LOG_DIFFERENT_DIR=$TEST_DIR/log/different
export LOG_FILERROR_DIR=$TEST_DIR/log/filerror
export LOG_OTHER_DIR=$TEST_DIR/log/other
export RESULTS_DIR=$TEST_DIR/log/results

#Control output,设置为1，向终端详细输出执行过程，设置为0，关闭向终端详细输出，只输出结果，但是详细结果的对比日志不受影响，可以在执行完之后去log之下查看详细日志与错误信息
let control_id=0

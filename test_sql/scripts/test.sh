#!/bin/bash

#添加程序内容时，尽量不要使用单个字母来作为变量，容易出现重复或冲突的情况，直接用变量所代表意义的英文或拼音即可

#用户定义环境变量
source env.sh

#定义输出详细程度函数
if [ $control_id -ne 1 -a $control_id -ne 0 ]
  then
    echo -e "Error in control output parameter ID,please check $TEST_DIR/scripts/env.sh"
    exit 1
fi  

function output_terminal(){
if [ $control_id -eq 1 ]
  then
    cat
  else
    > /dev/null
fi
}

#判断log_all
echo -e "Check the log_all of the test directory before testing\t............."
for test_dir in $TEST_DIR/log_all
do
  if [ -e $dir -a -d $dir ]
    then
      echo -e "The directory $test_dir\t.............ok" | output_terminal
    else
      echo -e "Please check directory $test_dir\t.............no"
      exit 1
  fi
done
echo -e "The overall structure of the test directory\t.............ok"

rm -rf $TEST_DIR/log_all/*
echo -e "Empty the directory $TEST_DIR/log_all\t.............ok" | output_terminal

#判断和清空目录放到一个函数里，供后续函数调用
function chuli_dir(){
#判断各文件夹是否存在
echo -e "Check the overall structure of the test directory before testing\t............."
for test_dir in $SQL_DIR $EXPECTED_DIR $OUT_DIR $LOG_DIR $LOG_PASS_DIR $LOG_DIFFERENT_DIR $LOG_FILERROR_DIR $LOG_OTHER_DIR $RESULTS_DIR
do
  if [ -e $dir -a -d $dir ]
    then
      echo -e "The directory $test_dir\t.............ok" | output_terminal
    else
      echo -e "Please check directory $test_dir\t.............no"
      exit 1
  fi
done
echo -e "The overall structure of the test directory\t.............ok"


#测试前清空各输出文件夹目录
echo -e "Empty the output directory before testing\t............."
rm -rf $OUT_DIR/*
echo -e "Empty the directory $OUT_DIR\t.............ok" | output_terminal
rm -rf $LOG_PASS_DIR/*
echo -e "Empty the directory $LOG_PASS_DIR\t.............ok" | output_terminal
rm -rf $LOG_DIFFERENT_DIR/*
echo -e "Empty the directory $LOG_DIFFERENT_DIR\t.............ok" | output_terminal
rm -rf $LOG_FILERROR_DIR/*
echo -e "Empty the directory $LOG_FILERROR_DIR\t.............ok" | output_terminal
rm -rf $LOG_OTHER_DIR/*
echo -e "Empty the directory $LOG_OTHER_DIR\t.............ok" | output_terminal
rm -rf $RESULTS_DIR/*
echo -e "Empty the directory $RESULTS_DIR\t.............ok" | output_terminal

echo -e "Empty Output Directory succeeded\t.............ok"
}

function duibi_zhixing(){
#判断sql中脚本与expected中期望输出是否完全对应
echo -e "Check directory $SQL_DIR and $EXPECTED_DIR\t............."
#检查文件夹数量
if [ `ls $SQL_DIR/ | wc -l` -eq `ls $EXPECTED_DIR/ | wc -l` ]
  then
    echo -e "The directory $SQL_DIR and $EXPECTED_DIR have same number of directorys\t.............ok" | output_terminal

    #检查sql文件名字对应
    for  sqlname1 in `ls $SQL_DIR`
      do
        sqlname=${sqlname1%.sql}

        if [ -e $EXPECTED_DIR/${sqlname}.exp -a -f $EXPECTED_DIR/${sqlname}.exp ]
          then
            echo -e "$SQL_DIR/$sqlname1 and $EXPECTED_DIR/${sqlname}.exp\t.............ok" | output_terminal
          else
            echo -e "Please check $SQL_DIR/$sqlname1 and $EXPECTED_DIR/${sqlname}.exp\t.............no" 
            exit 1
        fi
    done
  else
    echo -e "Please check the directory $SQL_DIR and $EXPECTED_DIR,number of directorys are different\t............no."
    exit 1
fi
echo -e "The directory $SQL_DIR and $EXPECTED_DIR\t.............ok"

#检查数据库是否可正常连接
check_db_service=`$PGHOME/bin/psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select 1" | sed -n "3p" | awk '{print $1}'`
if [[ "$check_db_service" = "1" ]]
  then
    echo -e "The database servier\t.............ok"
else
    echo -e "Please check the database service\t.............no"
    exit 1 
fi

#执行sql脚本把结果输出到out文件夹
echo -e "Execute scripts under $SQL_DIR directory output to $OUT_DIR directory\t............."

for sqlname2 in `cat $TEST_DIR/scripts/list2.txt`
do
    $PGHOME/bin/psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -a -f $SQL_DIR/${sqlname2}.sql 2>&1 | sed 's/^psql.*ERROR/ERROR/g' 2>&1 | sed 's/^psql.*WARNING/WARNING/g' 2>&1 | sed 's/^psql.*NOTICE/NOTICE/g' 2>&1 | sed 's/^psql.*invalid/invalid/g' | sed 's/^psql.*INFO/INFO/g' > $OUT_DIR/${sqlname2}.out 2>&1
    #检查输出文件是否输出到了指定的文件夹
    if [ -e $OUT_DIR/${sqlname2}.out -a -f $OUT_DIR/${sqlname2}.out ]
      then
        echo -e "$SQL_DIR/${sqlname2}.sql output to $OUT_DIR/${sqlname2}.out\t.............ok" | output_terminal
    else
      echo -e "Please check the $SQL_DIR/${sqlname2}.sql and $OUT_DIR/${sqlname2}.out\t.............no"
      exit 1
    fi
done
echo -e "Execute scripts under $SQL_DIR directory output to $OUT_DIR directory\t.............ok"

#检查输出out下与expected期望输出下是否完全对应
echo -e "Check directory $EXPECTED_DIR and $OUT_DIR\t............."

if [ `ls $OUT_DIR/ | wc -l` -eq `ls $EXPECTED_DIR/ | wc -l` ]
  then
    echo -e "The directory $OUT_DIR and $EXPECTED_DIR have same number of directorys\t.............ok" | output_terminal
    for sqlname3 in `ls $EXPECTED_DIR`
    do
      #检查文件夹下文件名
      sqlname_exp=${sqlname3%.exp}
      if [ -e $OUT_DIR/${sqlname_exp}.out -a -f $OUT_DIR/${sqlname_exp}.out ]
        then
          echo -e "$EXPECTED_DIR/$sqlname3 and $OUT_DIR/${sqlname_exp}.out\t.............ok" | output_terminal
        else
          echo -e "Please check $EXPECTED_DIR/$sqlname3 and $OUT_DIR/${sqlname_exp}.out\t.............no"
          exit 1
      fi
    done
  else
    echo -e "Please check the directory $OUT_DIR and $EXPECTED_DIR,number of directorys are different\t............no."
    exit 1
fi
echo -e "The directory $EXPECTED_DIR and $OUT_DIR\t.............ok"

#对比out下的输出与expected下的期望输出,并形成结果
echo -e "Start comparing world output with expected output\t............."
#测试项总数
sum=0
#测试通过的数量
pas=0
#测试未通过的数量
dif=0
#对比时返回不正常值的数量
err=0
#对比时返回diff命令之外的值的数量
oth=0
#逐个文件的对比
for sqlname4 in `cat $TEST_DIR/scripts/list2.txt`
do
  let sum+=1
  
  diff $OUT_DIR/${sqlname4}.out $EXPECTED_DIR/${sqlname4}.exp > $LOG_DIFFERENT_DIR/tmp.dif 2>&1
  return_id=`echo $?`
  #如果diff返回值为0，则测试通过，输入结果到pass
  if [ $return_id -eq 0 ]
    then
      let pas+=1
      echo -e "The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\t .............ok" | output_terminal
      echo -e "The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\t .............ok" >> $LOG_PASS_DIR/pass.log 2>&1
  #如果diff返回值为1，则未通过测试，输入结果到different
    elif [ $return_id -eq 1 ]
      then
        let dif+=1
        echo -e "The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\t .............no" | output_terminal
        echo -e "The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\t .............no" >> $LOG_DIFFERENT_DIR/different.log 2>&1
        mkdir $LOG_DIFFERENT_DIR/${sqlname4}
        if [ -e $LOG_DIFFERENT_DIR/${sqlname4} -a -d $LOG_DIFFERENT_DIR/${sqlname4} ]
          then
            #把实际输出文件、期望输出文件和对比结果文件放入单独创建的文件夹下
            cp $OUT_DIR/${sqlname4}.out $LOG_DIFFERENT_DIR/${sqlname4}/
            cp $EXPECTED_DIR/${sqlname4}.exp $LOG_DIFFERENT_DIR/${sqlname4}/
            cat $LOG_DIFFERENT_DIR/tmp.dif > $LOG_DIFFERENT_DIR/${sqlname4}/${sqlname4}.dif 2>&1
            #把实际输出和期望输出目录、造成对比结果不一致的sql语句、对比结果追加到一个单独的文件中
            echo -e "$OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\n" >> $LOG_DIFFERENT_DIR/different_infor.log 2>&1
            cat $LOG_DIFFERENT_DIR/tmp.dif >> $LOG_DIFFERENT_DIR/different_infor.log 2>&1
            echo -e "\n" >> $LOG_DIFFERENT_DIR/different_infor.log 2>&1
            echo -e "*****************************************************" >> $LOG_DIFFERENT_DIR/different_infor.log 2>&1
          else
            echo -e "Failed to create $LOG_DIFFERENT_DIR/${sqlname4},please to check\t.............no"
            exit 1
        fi
    #如果diff返回值为2，则实际输出文件和期望输入文件存在丢失或被损坏情况，输出结果到filerroe中
    elif [ $return_id -eq 2 ]
      then
        let err+=1
        echo -e "The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\t .............no"
        echo -e "Please check The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp\t .............no\n" >> $LOG_FILERROR_DIR/error_file.log 2>&1
    #如果diff返回值不正常，则可能是其它原因造成，立即退出测试
    else     
      let oth+=1
      echo -e "The diff have some questions on The $OUT_DIR/${sqlname4}.out and $EXPECTED_DIR/${sqlname4}.exp" >> $LOG_OTHER_DIR/other_questions.log 2>&1
   fi
done
echo

#输出测试结果
echo -e "\tTest results"
echo -e "\tTest results" >> $RESULTS_DIR/results.log 2>&1
echo -e "The test a total of : $sum"
echo -e "The test a total of : $sum" >> $RESULTS_DIR/results.log 2>&1
echo -e "The test passed : $pas ,view details to $LOG_PASS_DIR"
echo -e "The test passed : $pas ,view details to $LOG_PASS_DIR" >> $RESULTS_DIR/results.log 2>&1
echo -e "The test failed : $dif ,view details to $LOG_DIFFERENT_DIR"
echo -e "The test failed : $dif ,view details to $LOG_DIFFERENT_DIR" >> $RESULTS_DIR/results.log 2>&1
echo -e "The test file missing : $err ,view details to $LOG_FILERROR_DIR"
echo -e "The test file missing : $err ,view details to $LOG_FILERROR_DIR" >> $RESULTS_DIR/results.log 2>&1
echo -e "The test other questions : $oth ,view details to $LOG_OTHER_DIR"
echo -e "The test other questions : $oth ,view details to $LOG_OTHER_DIR" >> $RESULTS_DIR/results.log 2>&1
echo -e "Test results to the $RESULTS_DIR"
echo

failed_log
}

#最后结果的输出，分为两种不同的情况，不加密和加密后的结果输出和log备份方式
function failed_log(){
if [[ "$jname" == "nojiami" ]]
  then
    echo -e "${jname} failed : $dif " >> $TEST_DIR/log_all/all_results.log 2>&1
    cp -r $TEST_DIR/log $TEST_DIR/log_all/log_${jname}
  else
    echo -e "${jname}_${fdefenji} failed : $dif " >> $TEST_DIR/log_all/all_results.log 2>&1
    cp -r $TEST_DIR/log $TEST_DIR/log_all/log_${jname}_${fdefenji}
fi
}

#主函数，测试运行分为不加密和加密的两个方向
function main(){
for jname in nojiami aes-128 aes-192 aes-256 blowfish des 3des cast5
do

  #$PGHOME/bin/pg_ctl stop -w -D $PGHOME/data
  #rm -rf $PGHOME/data/*

  #fdelist=(r x s t a)
  #fdenum=${#fdelist[*]}

  if [[ "$jname" == "nojiami" ]]
    then

      #echo -e "bujiami"

      chuli_dir
    
      $PGHOME/bin/pg_ctl stop -w -D $PGHOME/data
      rm -rf $PGHOME/data/*

      echo -e "$PGHOME/bin/initdb -D $PGHOME/data" >> $RESULTS_DIR/initdb.log 2>&1
      $PGHOME/bin/initdb -D $PGHOME/data >> $RESULTS_DIR/initdb.log 2>&1

      $PGHOME/bin/pg_ctl start -w -D $PGHOME/data

      duibi_zhixing

      exit 0

    #加密情况下，有七种加密算法，每种加密算法对应了31种分级加密情况
    else
      for fdefenji in r x s t a rx rs rt ra xs xt xa st sa ta rxs rxt rxa rst rsa rta xst xsa xta sta rxst rxsa rxta rsta xsta rxsta
      do

        #echo $jname $fdefenji

        chuli_dir

        $PGHOME/bin/pg_ctl stop -w -D $PGHOME/data
        rm -rf $PGHOME/data/*

        echo -e "$PGHOME/bin/initdb --data-encryption pgcrypto --key-url ldaps://192.168.100.181:636?cn=hgdb,dc=highgo,dc=com?123 -C $jname --encryption_range $fdefenji  --new-key -D $PGHOME/data" >> $RESULTS_DIR/initdb.log 2>&1
        $PGHOME/bin/initdb --data-encryption pgcrypto --key-url ldaps://192.168.100.181:636?cn=hgdb,dc=highgo,dc=com?123 -C $jname --encryption_range $fdefenji --new-key -D $PGHOME/data >> $RESULTS_DIR/initdb.log 2>&1

        $PGHOME/bin/pg_ctl start -w -D $PGHOME/data 

        duibi_zhixing

      done
  fi

  #$PGHOME/bin/pg_ctl start -w -D $PGHOME/data

  
done
}

main

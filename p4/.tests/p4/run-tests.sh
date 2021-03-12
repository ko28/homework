#!/bin/bash

TEST_DIR="/u/c/s/cs537-1/tests/p4"
TMP_DIR=537_sp21_test_tmp

mkdir $TMP_DIR
cp -r $TEST_DIR/tests $TMP_DIR/
cp $TEST_DIR/test-scheduler.sh $TMP_DIR/
cp -r $TEST_DIR/tester .
cp -r src $TMP_DIR/
chmod +x tester/run-tests.sh
chmod +x tester/run-xv6-command.exp
chmod +x tester/xv6-edit-makefile.sh
chmod +x $TMP_DIR/src/sign.pl
chmod +x $TMP_DIR/test-scheduler.sh

cd $TMP_DIR
./test-scheduler.sh $*
cd ../

cp -r $TMP_DIR/tests .
cp -r $TMP_DIR/tests-out .

rm -rf $TMP_DIR
rm -rf tester

# TO STUDENTS

This is the testing framework for project 4.

## Usage

To use this framework, first put your code onto a wisc CSL machine.

To list the set of public tests, please do:

```bash
~cs537-1/tests/p4/list-tests.sh
```

To run the tests, there will be two steps:

- Put all your source codes (all the files under `xv6/`) into a directory named `src/`
- Execute the following command at the path just outside the `src/` directory:

```bash
~cs537-1/tests/p4/run-tests.sh -c
```

After all tests finish, your directory should look like:

```text
.../src/Makefile
.../src/proc.c
.../src/...
.../tests/      -- contains our tests information
.../tests-out/  -- contains tests output of your code
```


## Notes

There are 20 public test cases released for each utility. After running the command, you can see details of the test cases in `./tests/`. If any error occurs, follow the instructions printed to find out what is wrong with your output.

Filenames for the tests follow this convention:

testnum.desc: contains a short textual description of the purpose of the test
testnum.run: how to run this test
testnum.out: what your program should print to stdout
testnum.err: what your program should print to stderr
testnum.rc: the expected return code of your program
testnum.* : any other files are helper files (e.g., input files)

Passing all public cases does not guarantee full credit for this assignment. 20% of test cases are hidden, so make sure your code is robust so that you pass all the hidden test cases as well. These hidden test cases are not made to trick your code--they are straightforward.

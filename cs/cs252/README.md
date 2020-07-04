# CS/ECE 252 Introduction to Computer Engineering 
Project II: LC-3 Assembly Programming

Spring 2020

Instructor: Adil Ibrahim

## Instructions:

In this project, you will write programs using LC-3 assembly language. Please submit your
programs using the filename indicated in each question so they can be recognized by
automated grading scripts.

Note: you may use the **.FILL** directive to store values at specific memory addresses. You may
also use labels to refer to addresses.

### Problem 1 (10 points)

Write a program that, given an input value X at memory location x4000, stores the absolute
value of X at memory location x4001.

Your code should start at memory location x3000. Submit your solution as **q1.asm**.

### Problem 2 (20 points)

Write a program that removes blank spaces from a given string. Assume that the string starts at
memory location x5000, and is terminated by a ‘\0’ character (ASCII value = 0). Your program
should store the modified string in memory starting at location x5100. You do not need to
modify the original string stored at x5000.

For example: If the original string at x5000 was **aa 12 d e f** , the modified string at x
after your program completes execution should be **aa12def**.

You may assume that the original string at x5000 will always be less than 100 characters in
length and will always start with a letter (A-Z or a-z).

Your code should start at memory location 0x3000. Submit your solution as **q2.asm**.



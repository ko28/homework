# cs400
CS400 projects from Spring 2019 

## p1: Implement and Test DataStructureADT
For this assignment, you are given an ADT and several implementations of that ADT in the form of class files.  You are also given an abstract JUnit super class with a few example JUnit tests.  You are required to implement the ADT and write JUnit tests to ensure that your implementation and the other implementations work correctly.  

For each data structure implementation class given to you that you wish to test, you must write a test class. In this case, we will be giving you many implementations to test so that means many test classes are required.  However, the tests in each test class will be the same.  This means that we can use inheritance to reduce the amount of code that needs to be written and still ensure that all implementations are tested with all tests.

Grade 30/30

## p2: BST and Balanced Search Tree AVL
For this assignment, you are required to implement the BST (Binary Search Tree) class, the AVL balanced search tree class, and a JUnit test class that shows that your implementations are complete and correct.
The provided starter source files establish the inheritance hierarchy that we require for this assignment. 

Grade 27/30

## p3a: Hash Table
For this project, you will be implementing a hash table and testing its basic functionality with JUnit tests.  Its performance will be tested in p3b (which will be released later)

All files must be named correctly (case-sensitive). You may define and submit other package level (not public or private) classes as needed and you may add private members to your classes.

The goal for your HashTable is to build a searchable data structure that achieves constant time O(1) for lookup, insert, and delete operations with comparable performance to Java's built-in TreeMap type.

Students are required to submit a JUnit test class for this assignment. Use what you have learned
about writing tests and the JUnit testing framework to ensure that your hash table
implementation works correctly prior to analyzing its performance in p3b.

Grade 30/30

## p3b: Performance Analysis
For this project, you will be implementing a small program to analyze the performance of your hash table against Java's built-in TreeMap.  TreeMap (Links to an external site.) is a known and in-built data structure of Java.

To analyze the performance, you need to write a small program that performs the same operations on both your custom HashTable class and Java's TreeMap class. You will be using Java Flight recorder to create a program profile, and Java Mission Control to analyze the profile information.  Both are open source and packaged with Oracle JVM’s (The lab machines have this installed).

Grade 30/30

## p4: Package Manager
You will build a dependency graph from a list of given software packages and their dependencies. In the graph created, each vertex represents a package.  And, each edge represents a dependency between two packages.  For example, A depends on B is represented by a directed edge from B to A, indicating that B must occur before A.

Once the graph class is created, you will implement and test the required utility functions.  Write JUnit test classes and a main method in PackageManager to ensure that your functions work.

Use the graph algorithms discussed in lecture to implement the required functions. 

Grade 30/30

## p5: MyFirstJavaFX
Create a simple GUI using javafx 

Grade 30/30

## p6: MyCS400Website
Create a simple website

Grade 30/30

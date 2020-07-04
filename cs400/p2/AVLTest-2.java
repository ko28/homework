/////////////////////////////////////////////////////////////////////////////////////////
//
// Title: BST and Balanced Search Tree AVL
// Files: BST.java, AVL.java, BSTTest.java, AVLTest.java, BSTNode.java, 
//	      DataStructureADT.java, DataStructureADTTest.java, DuplicateKeyException.java, 
//		  IllegalNullKeyException.java, KeyNotFoundException.java, SearchTreeADT.java
//
// Course: CS400, Spring, 2019
// Due Date: 2/24/2019
//
// Author: Daniel Ko
// Email: ko28@wisc.edu
// Lecturer's Name: Deb Deppeler (Lecture 002)
//
// Failed tests: 008, 010, 009 should fail because post/pre/level do not equal that of a 
//               BST tree. 
//
/////////////////////////////////////////////////////////////////////////////////////////
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;

import org.junit.Assert;
import static org.junit.Assert.fail;
import org.junit.jupiter.api.Test;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;

/**
 * JUnit class for AVL.java. Various tests are implemented to ensure the
 * functionality of the implemented AVL tree.
 * 
 * @author Daniel Ko
 */
public class AVLTest extends BSTTest {

	// AVL tree used in our tester class
	AVL<String, String> avl;
	AVL<Integer, String> avl2;

	/**
	 * @throws java.lang.Exception
	 */
	@BeforeEach
	void setUp() throws Exception {
		dataStructureInstance = bst = avl = createInstance();
		dataStructureInstance2 = bst2 = avl2 = createInstance2();
	}

	/**
	 * @throws java.lang.Exception
	 */
	@AfterEach
	void tearDown() throws Exception {
		avl = null;
		avl2 = null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see DataStructureADTTest#createInstance()
	 */
	@Override
	protected AVL<String, String> createInstance() {
		return new AVL<String, String>();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see DataStructureADTTest#createInstance2()
	 */
	@Override
	protected AVL<Integer, String> createInstance2() {
		return new AVL<Integer, String>();
	}

	/**
	 * Insert three values in sorted order and then check the root, left, and right
	 * keys to see if rebalancing occurred.
	 */
	@Test
	void testAVL_001_insert_sorted_order_simple() {
		try {
			avl2.insert(10, "10");
			if (!avl2.getKeyAtRoot().equals(10))
				fail("avl insert at root does not work");

			avl2.insert(20, "20");
			if (!avl2.getKeyOfRightChildOf(10).equals(20))
				fail("avl insert to right child of root does not work");

			avl2.insert(30, "30");
			Integer k = avl2.getKeyAtRoot();
			if (!k.equals(20))
				fail("avl rotate does not work");

			// IF rebalancing is working,
			// the tree should have 20 at the root
			// and 10 as its left child and 30 as its right child

			Assert.assertEquals(avl2.getKeyAtRoot(), new Integer(20));
			Assert.assertEquals(avl2.getKeyOfLeftChildOf(20), new Integer(10));
			Assert.assertEquals(avl2.getKeyOfRightChildOf(20), new Integer(30));

		} catch (Exception e) {
			e.printStackTrace();
			fail("Unexpected exception AVL 000: " + e.getMessage());
		}
	}

	/**
	 * Insert three values in reverse sorted order and then check the root, left,
	 * and right keys to see if rebalancing occurred in the other direction.
	 */
	@Test
	void testAVL_002_insert_reversed_sorted_order_simple() {
		try {
			avl2.insert(30, "30");
			if (!avl2.getKeyAtRoot().equals(30))
				fail("avl insert at root does not work");

			avl2.insert(20, "20");
			if (!avl2.getKeyOfLeftChildOf(30).equals(20))
				fail("avl insert to left child of root does not work");

			avl2.insert(10, "10");
			Integer k = avl2.getKeyAtRoot();
			if (!k.equals(20))
				fail("avl rotate does not work");

			// IF rebalancing is working,
			// the tree should have 20 at the root
			// and 10 as its left child and 30 as its right child

			Assert.assertEquals(avl2.getKeyAtRoot(), new Integer(20));
			Assert.assertEquals(avl2.getKeyOfLeftChildOf(20), new Integer(10));
			Assert.assertEquals(avl2.getKeyOfRightChildOf(20), new Integer(30));

		} catch (Exception e) {
			e.printStackTrace();
			fail("Unexpected exception AVL 002: " + e.getMessage());
		}

	}

	/**
	 * Insert three values so that a right-left rotation is needed to fix the
	 * balance.
	 * 
	 * Example: 10-30-20
	 * 
	 * Then check the root, left, and right keys to see if rebalancing occurred in
	 * the other direction.
	 */
	@Test
	void testAVL_003_insert_smallest_largest_middle_order_simple() {

		try {
			avl2.insert(10, "10");
			if (!avl2.getKeyAtRoot().equals(10))
				fail("avl insert at root does not work");

			avl2.insert(30, "30");
			if (!avl2.getKeyOfRightChildOf(10).equals(30))
				fail("avl insert to right child of root does not work");

			avl2.insert(20, "20");
			Integer k = avl2.getKeyAtRoot();
			if (!k.equals(20))
				fail("avl rotate does not work");

			// IF rebalancing is working,
			// the tree should have 20 at the root
			// and 10 as its left child and 30 as its right child

			Assert.assertEquals(avl2.getKeyAtRoot(), new Integer(20));
			Assert.assertEquals(avl2.getKeyOfLeftChildOf(20), new Integer(10));
			Assert.assertEquals(avl2.getKeyOfRightChildOf(20), new Integer(30));

		} catch (Exception e) {
			e.printStackTrace();
			fail("Unexpected exception AVL 003: " + e.getMessage());
		}

	}

	/**
	 * Insert three values so that a left-right rotation is needed to fix the
	 * balance.
	 * 
	 * Example: 30-10-20
	 * 
	 * Then check the root, left, and right keys to see if rebalancing occurred in
	 * the other direction.
	 */
	@Test
	void testAVL_003_insert_largest_smallest_middle_order_simple() {

		try {
			avl2.insert(30, "30");
			if (!avl2.getKeyAtRoot().equals(30))
				fail("avl insert at root does not work");

			avl2.insert(10, "10");
			if (!avl2.getKeyOfLeftChildOf(30).equals(10))
				fail("avl insert to right child of root does not work");

			avl2.insert(20, "20");
			Integer k = avl2.getKeyAtRoot();
			if (!k.equals(20))
				fail("avl rotate does not work");

			// IF rebalancing is working,
			// the tree should have 20 at the root
			// and 10 as its left child and 30 as its right child

			Assert.assertEquals(avl2.getKeyAtRoot(), new Integer(20));
			Assert.assertEquals(avl2.getKeyOfLeftChildOf(20), new Integer(10));
			Assert.assertEquals(avl2.getKeyOfRightChildOf(20), new Integer(30));

		} catch (Exception e) {
			e.printStackTrace();
			fail("Unexpected exception AVL 003: " + e.getMessage());
		}

	}

	/**
	 * Add 12 keys, makes sure that there are 12 keys
	 */
	@Test
	void testAVL_004_numKeys() {
		try {
			avl2.insert(1, "1");
			avl2.insert(20, "1");
			avl2.insert(100, "1");
			avl2.insert(1434, "1");
			avl2.insert(74, "1");
			avl2.insert(612, "1");
			avl2.insert(43, "1");
			avl2.insert(15, "1");
			avl2.insert(524, "1");
			avl2.insert(21, "1");
			avl2.insert(33, "1");
			avl2.insert(5924, "1");
			Assert.assertEquals(12, avl2.numKeys());
		} catch (Exception e) {
			e.printStackTrace();
			fail("Unexpected exception AVL 004: " + e.getMessage());
		}
	}

}


/////////////////////////////////////////////////////////////////////////////////////////
//
// Title: Hash Table 
// Files: HashTable.java, HashTableTest.java, HashTableADT.java, 
//	      DuplicateKeyException.java, IllegalNullKeyException.java, 
//		  KeyNotFoundException.java, DataStructureADT.java
//
// Course: CS400, Spring, 2019
// Due Date: 3/14/2019
//
// Author: Daniel Ko
// Email: ko28@wisc.edu
// Lecturer's Name: Deb Deppeler (Lecture 002)
//
/////////////////////////////////////////////////////////////////////////////////////////
import static org.junit.jupiter.api.Assertions.*; // org.junit.Assert.*; 
import org.junit.jupiter.api.Assertions;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Random;

/**
 * Tests functionality of HashTable
 */
public class HashTableTest {
	HashTableADT<Integer, String> htIntegerKey;

	@Before
	public void setUp() throws Exception {
		htIntegerKey = new HashTable<Integer, String>();
	}

	@After
	public void tearDown() throws Exception {
		htIntegerKey = null;
	}

	/**
	 * Tests that a HashTable returns an integer code indicating which collision
	 * resolution strategy is used.
	 *
	 * 1 OPEN ADDRESSING: linear probe 2 OPEN ADDRESSING: quadratic probe 3 OPEN
	 * ADDRESSING: double hashing 4 CHAINED BUCKET: array list of array lists 5
	 * CHAINED BUCKET: array list of linked lists 6 CHAINED BUCKET: array list of
	 * binary search trees 7 CHAINED BUCKET: linked list of array lists 8 CHAINED
	 * BUCKET: linked list of linked lists 9 CHAINED BUCKET: linked list of of
	 * binary search trees
	 */
	@Test
	public void test000_collision_scheme() {
		int scheme = htIntegerKey.getCollisionResolution();
		if (scheme < 1 || scheme > 9)
			fail("collision resolution must be indicated with 1-9");
	}

	/**
	 * Tests that insert(null,null) throws IllegalNullKeyException
	 */
	@Test
	public void test001_IllegalNullKey() {
		try {
			htIntegerKey.insert(null, null);
			fail("should not be able to insert null key");
		} catch (IllegalNullKeyException e) {
			/* expected */ } catch (Exception e) {
			fail("insert null key should not throw exception " + e.getClass().getName());
		}
	}

	/**
	 * Tests that insert and remove works with large data sets (aprox 200). Checks
	 * that number of elements is 0 after all elements have been removed.
	 */
	@Test
	public void test002_Insert_and_Remove_alot() {
		try {
			ArrayList<Integer> list = new ArrayList<Integer>();
			// Add 200(ish) key,value pair to hash table
			for (int i = 0; i < 200; i++) {
				int temp = (int) (Math.random() * 10000);
				if (!list.contains(temp)) {
					list.add(temp);
					htIntegerKey.insert(temp, temp + "  i:" + i);
				}
			}
			System.out.println(list.size() + "lol");

			// Remove all key,value pairs
			while (!list.isEmpty()) {
				htIntegerKey.remove(list.get(0));
				list.remove(0);
			}
		} catch (Exception e) {
			fail("should not throw exception " + e.getClass().getName());
		}
	}

	/**
	 * Insert one key value pair into the data structure and then confirm that
	 * numKeys() is 1.
	 */
	@Test
	public void test003_after_insert_one_numKeys_is_one() {
		HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
		try {
			htIntegerKey.insert("key", "value");
			if (htIntegerKey.numKeys() != 1)
				fail("numKeys should be size=1, but size=" + htIntegerKey.numKeys());
		} catch (Exception e) {
			fail("should not throw exception " + e.getClass().getName());
		}
	}

	/**
	 * Insert one key,value pair and remove it, then confirm size is 0.
	 */
	@Test
	public void test004_after_insert_one_remove_one_size_is_0() {
		try {
			HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
			htIntegerKey.insert("key", "value");
			htIntegerKey.remove("key");
			if (htIntegerKey.numKeys() != 0) {
				fail("numKeys should be size=1, but size=" + htIntegerKey.numKeys());
			}
		} catch (Exception e) {
			fail("should not throw exception " + e.getClass().getName());
		}
	}

	/**
	 * Insert a few key,value pairs such that one of them has the same key as an
	 * earlier one. Confirm that a DuplicateKeyException is thrown.
	 */
	@Test
	public void test005_duplicate_exception_is_thrown() {
		// Try inserting duplicate keys
		try {
			HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
			htIntegerKey.insert("key", "value");
			htIntegerKey.insert("key", "balue");
			fail("Duplicate keys were inserted and a DuplicateKeyException was not thrown");
		}

		// Confirming DuplicateKeyException
		catch (DuplicateKeyException r) {
			return;
		}
		// No other exception should be thrown
		catch (Exception e) {
			fail("should not throw exception " + e.getClass().getName());
		}
	}

	/**
	 * Insert some key,value pairs, then try removing a key that was not inserted.
	 * Confirm that the return value is false.
	 */
	@Test
	public void test006_remove_returns_false_when_key_not_present() {
		try {
			HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
			// Add elements into Data Structure
			htIntegerKey.insert("key1", "value");
			htIntegerKey.insert("key2", "balue");
			htIntegerKey.insert("key3", "Calue");
			// Remove nonexistent key
			if (htIntegerKey.remove("key4") != false) {
				fail("A nonexistent key was able to be removed");
			}
		}
		// No other exception should be thrown
		catch (Exception e) {
			fail("Duplicate keys were inserted and a DuplicateKeyException was not thrown");
		}

	}

	/**
	 * Tests if insert(), remove(), and get() throws {@link IllegalNullKeyException}
	 * if null is inputed
	 */
	@Test
	public void test007_IllegalNullKeyException() {
		try {
			// Test insert()
			try {
				HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
				htIntegerKey.insert(null, null);
				fail("Null key was able to be inserted into this data structure");
			} catch (IllegalNullKeyException e) {
			}

			// Test remove()
			try {
				HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
				htIntegerKey.remove(null);
				fail("Null key was able to be inserted into this data structure");
			} catch (IllegalNullKeyException e) {
			}

			// Test get()
			try {
				HashTableADT<String, String> htIntegerKey = new HashTable<String, String>();
				htIntegerKey.get(null);
				fail("Null key was able to be inserted into this data structure");
			} catch (IllegalNullKeyException e) {
			}
		} catch (Exception e) {
			fail("Null keys were inserted and" + e.getStackTrace() + " was thrown");
		}
	}

	/**
	 * Tests if constructor passes through initialCapacity and loadFactorThreshold
	 */
	@Test
	public void test008_getLoadFactor_getCapacity() {
		htIntegerKey = new HashTable<Integer, String>(5, .1234);
		if (htIntegerKey.getLoadFactor() != .1234 && htIntegerKey.getCapacity() != 5) {
			fail("Constructor does not pass through initialCapacity and loadFactorThreshold");
		}
	}

	/**
	 * Tests is resize() expands the table
	 */
	@Test
	public void test009_resize() {
		int originalSize = htIntegerKey.getCapacity();
		try {
			for (int i = 0; i < 11; i++) {
				htIntegerKey.insert(i, String.valueOf(i) + "lol");
			}
			if (originalSize * 2 + 1 != htIntegerKey.getCapacity()) {
				fail("Resize failed.");
			}
		} catch (Exception e) {
			fail("should not throw exception " + e.getClass().getName());
		}
	}
}

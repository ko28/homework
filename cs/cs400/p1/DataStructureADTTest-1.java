////////////////////////////////////////////////////////////////////////////////
//
// Title: Implement and Test DataStructureADT
// Files: DataStructureADT.java, DataStructureADTTest.java, DS_My.java, TestDS_My.java
// Course: CS400, Spring, 2019
// Due Date: 2/7/2019
//
// Author: Daniel Ko
// Email: ko28@wisc.edu
// Lecturer's Name: Deb Deppeler (Lecture 002)
//
////////////////////////////////////////////////////////////////////////////////

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * JUnit abstract class for {@link #DataStructureADT()}. Various tests are implemented to ensure the
 * functionality of the implemented Data Structure.
 * 
 * @author Daniel
 * 
 */
abstract class DataStructureADTTest<T extends DataStructureADT<String, String>> {

  // Private instance variables used to test given data structure
  private T dataStructureInstance;

  protected abstract T createInstance();

  @BeforeAll
  static void setUpBeforeClass() throws Exception {}

  @AfterAll
  static void tearDownAfterClass() throws Exception {}

  @BeforeEach
  void setUp() throws Exception {
    dataStructureInstance = createInstance();
  }

  @AfterEach
  void tearDown() throws Exception {
    dataStructureInstance = null;
  }

  /**
   * Confirm newly instantiated data structure is size 0.
   */
  @Test
  void test00_empty_ds_size() {
    if (dataStructureInstance.size() != 0)
      fail("data structure should be empty, with size=0, but size=" + dataStructureInstance.size());
  }

  /**
   * Insert one key value pair into the data structure and then confirm that size() is 1.
   */
  @Test
  void test01_after_insert_one_size_is_one() {
    dataStructureInstance.insert("key", "value");
    if (dataStructureInstance.size() != 1)
      fail("data structure should be size=1, but size=" + dataStructureInstance.size());
  }

  /**
   * Insert one key,value pair and remove it, then confirm size is 0.
   */
  @Test
  void test02_after_insert_one_remove_one_size_is_0() {
    dataStructureInstance.insert("key", "value");
    dataStructureInstance.remove("key");
    if (dataStructureInstance.size() != 0)
      fail("data structure should be size=0, but size=" + dataStructureInstance.size());
  }

  /**
   * Insert a few key,value pairs such that one of them has the same key as an earlier one. Confirm
   * that a RuntimeException is thrown.
   */
  @Test
  void test03_duplicate_exception_is_thrown() {
    // Try inserting duplicate keys
    try {
      dataStructureInstance.insert("key", "value");
      dataStructureInstance.insert("key", "balue");
      fail("Duplicate keys were inserted and a RuntimeException was not thrown");
    }

    // Confirming RuntimeException
    catch (RuntimeException r) {
      return;
    }
    // No other exception should be thrown
    catch (Exception e) {
      fail("Duplicate keys were inserted and a RuntimeException was not thrown");
    }
  }

  /**
   * Insert some key,value pairs, then try removing a key that was not inserted. Confirm that the
   * return value is false.
   */
  @Test
  void test04_remove_returns_false_when_key_not_present() {
    // Add elements into Data Structure
    dataStructureInstance.insert("key1", "value");
    dataStructureInstance.insert("key2", "balue");
    dataStructureInstance.insert("key3", "Calue");
    // Remove nonexistent key
    if (dataStructureInstance.remove("key4") != false) {
      fail("A nonexistent key was able to be removed");
    }
  }

  /**
   * Insert and remove 500 elements, making sure that the key and data are linked
   */
  @Test
  void test05_insert_and_remove_500_random_pairs() {
    String[][] hold = new String[500][2]; // Array to hold data we input into Data Structure

    // Add 500 key,value pairs to data structure and store them in an array
    for (int i = 0; i < 500; i++) {
      String key = "k" + i;
      String value = String.valueOf(i);
      hold[i][0] = key;
      hold[i][1] = value;
      dataStructureInstance.insert(key, value);
    }

    // Remove all the data, making sure that the key and data are linked
    for (int i = 499; i >= 0; i--) {
      if (dataStructureInstance.get(hold[i][0]).equals(hold[i][1])) {
        dataStructureInstance.remove(hold[i][0]);
      } else {
        fail("An existing key was not been able to be removed");
      }
    }

    // Check for size
    if (dataStructureInstance.size() != 0) {
      fail("Size is not zero after remooving all the keys ");
    }
  }

  /**
   * Tests if insert(), remove(), and get() throws {@link IllegalArgumentException} if null is
   * inputted
   */
  @Test
  void test06_IllegalArgumentException() {
    // Test insert()
    try {
      dataStructureInstance.insert(null, null);
      fail("Null key was able to be inserted into this data structure");
    } catch (IllegalArgumentException e) {
    }

    // Test remove()
    try {
      dataStructureInstance.remove(null);
      fail("Null key was able to be inserted into this data structure");
    } catch (IllegalArgumentException e) {
    }

    // Test get()
    try {
      dataStructureInstance.get(null);
      fail("Null key was able to be inserted into this data structure");
    } catch (IllegalArgumentException e) {
    }
  }

  /**
   * Tests if contains() is implemently correctly. Adds an element and see if contains() detects
   * such element. Removes an element and see if contains() does not detect such element.
   */
  @Test
  void test07_contains() {
    String key = "1231asde2*2e1#@$)(dsd";
    dataStructureInstance.insert(key, "Balue");
    dataStructureInstance.insert("key", "Dalue");
    dataStructureInstance.insert("woAg", "123lue");
    // Check if element exists
    if (dataStructureInstance.contains(key)) {
      // Removes the checked element
      dataStructureInstance.remove(key);
      // See if that element is not detected
      if (!dataStructureInstance.contains(key)) {
        return;
      }
      fail("contains() did detected key that was removed");
    }
    fail("contains() did not detect key that was inserted");
  }
}

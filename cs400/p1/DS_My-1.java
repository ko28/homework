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

/**
 * DataStructureADT is implemented as a singly Linked List using nodes. Each node contains a key and
 * data.
 * 
 * @author Daniel
 * @see Node
 */
public class DS_My implements DataStructureADT {

  private int size; // Current size of linked list
  private Node head; // First element of linked list

  /**
   * Constructor for linked list
   */
  public DS_My() {
    head = null;
    size = 0;
  }

  /**
   * Insert an element into linked list
   * 
   * @param k - key
   * @param v - data
   * @throws IllegalArgumentException if key is null
   * @throws RuntimeException if key exists in the list
   */
  @Override
  public void insert(Comparable k, Object v) {
    // Case #1: Key is null
    if (k == null) {
      throw new IllegalArgumentException("null key");
    }

    // Case #2: Head is null, inserted element becomes head
    else if (head == null) {
      head = new Node(k, v);
    }

    // Case #3: This key already exists
    else if (this.contains(k)) {
      throw new RuntimeException("duplicate key");
    }

    // Case #4: Element is inserted to the end of the list
    else {
      Node temp = head;
      // Traverse to the last node in the list and add the element
      while (temp.next != null) {
        temp = temp.next;
      }
      temp.next = new Node(k, v);
    }
    size++; // size is incremented if element is successfully added to the list
  }


  /**
   * Removes the element associated with the given key from the list
   * 
   * @param k - key
   * @return true if element was removed, false otherwise
   * @throws IllegalArgumentException if key is null
   * 
   */
  @Override
  public boolean remove(Comparable k) {
    // Case #1: Key is null
    if (k == null) {
      throw new IllegalArgumentException("null key");
    }

    // Case #2: Empty list always returns false
    else if (head == null) {
      return false;
    }

    // Case #3: Element is at head
    else if (head.key.equals(k)) {
      head = head.next;
      size--;
      return true;
    }

    // Case #4: Element might be in the list other than head
    Node temp = head;
    // Traverses list to search for element
    while (temp.next != null) {
      if (temp.next.key.equals(k)) {
        temp.next = temp.next.next; // Set element's previous node to element's next node
        size--;
        return true;
      }
      temp = temp.next;
    }
    return false; // No such element was found while traversing
  }

  /**
   * Returns true if this list contains the specified element
   * 
   * @param k - key
   * @return true if this list contains the specified element, false otherwise
   */
  @Override
  public boolean contains(Comparable k) {
    Node temp = head;
    // Traverse through the list looking for the key
    while (temp != null) {
      if (temp.key.equals(k)) {
        return true;
      }
      temp = temp.next;
    }
    return false; // Nothing was found in the list
  }

  /**
   * Return data associated with the given key.
   * 
   * @param - k
   * @return data associated with the given key
   * @throws IllegalArgumentException if key is null
   */
  @Override
  public Object get(Comparable k) {
    // Case #1: Key is null
    if (k == null) {
      throw new IllegalArgumentException("null key");
    }

    // Case #2: Key maybe in the list
    Node temp = head;
    // Traverse through list looking for key
    while (temp != null) {
      if (temp.key.equals(k)) {
        return temp.value;
      }
      temp = temp.next;
    }
    return null; // Key was not found in the list
  }

  /**
   * @returns size of list
   */
  @Override
  public int size() {
    return size;
  }

  /**
   * Node used for linkedlist
   * 
   * @author Daniel
   *
   */
  private static class Node {
    private Object value; // Value for node
    private Comparable key; // Key to identify node
    private Node next; // Points to next node in the list

    /**
     * Constructor for Node
     * 
     * @param k - key
     * @param v - value
     */
    private Node(Comparable k, Object v) {
      key = k;
      value = v;
      next = null;
    }
  }
}

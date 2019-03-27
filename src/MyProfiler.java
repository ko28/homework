/**
 * Filename:   MyProfiler.java
 * Project:    p3b-performance 
 * Authors:    Daniel Ko, Lecture 002
 *
 * Semester:   Spring 2019
 * Course:     CS400
 * 
 * Due Date:   11:59pm March 28 
 * Version:    1.0
 * 
 * Credits:    n/a
 * 
 * Bugs:       n/a
 */

// Used as the data structure to test our hash table against
import java.util.TreeMap;

/**
 * Program that profiles to determine relative performance between user's
 * HashTable and Java's TreeMap structures. The program perform a "bunch" of
 * inserts, lookups, and removes to the data structures.
 *  
 * @param <K> - key
 * @param <V> - value
 */
public class MyProfiler<K extends Comparable<K>, V> {

	// Instance variables for data structure
	HashTableADT<K, V> hashtable;
	TreeMap<K, V> treemap;

	/**
	 * Default constructor for MyProfiler. Instantiates user implemented hash table
	 * and default treemap.
	 */
	public MyProfiler() {
		// Instantiate your HashTable and Java's TreeMap
		hashtable = new HashTable<K, V>();
		treemap = new TreeMap<K, V>();
	}

	/**
	 * Insert K, V into both data structures
	 * 
	 * @param key
	 * @param value
	 * @throws DuplicateKeyException
	 * @throws IllegalNullKeyException
	 */
	public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
		hashtable.insert(key, value);
		treemap.put(key, value);
	}

	/**
	 * Get value V for key K from data structures
	 * 
	 * @param key
	 * @throws IllegalNullKeyException
	 * @throws KeyNotFoundException
	 */
	public void retrieve(K key) throws IllegalNullKeyException, KeyNotFoundException {
		hashtable.get(key);
		treemap.get(key);
	}

	/**
	 * Removes key K from both data structures
	 * 
	 * @param key
	 * @throws IllegalNullKeyException
	 */
	public void remove(K key) throws IllegalNullKeyException {
		hashtable.remove(key);
		treemap.remove(key);
	}

	/**
	 * Runs insert/put, get, and remove on both data structures. 
	 * 
	 * @param args[0] - number of elements that will be inserted, retrieved and
	 *        removed
	 */
	public static void main(String[] args) {
		try {
			int numElements = Integer.parseInt(args[0]);

			// Instantiate a profile object
			MyProfiler<Integer, Integer> profile = new MyProfiler<Integer, Integer>();

			// loops that run our methods on both structures
			for (int i = 0; i < numElements; i++) {
				profile.insert(i, i);
			}
			for (int i = 0; i < numElements; i++) {
				profile.retrieve(i);
			}
			for (int i = 0; i < numElements; i++) {
				profile.remove(i);
			}
			String msg = String.format("Inserted,retreived, removed %d (key,value) pairs", numElements);
			System.out.println(msg);
		} catch (Exception e) {
			System.out.println("Usage: java MyProfiler <number_of_elements>");
			System.exit(1);
		}
	}
}

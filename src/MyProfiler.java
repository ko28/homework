/**
 * Filename:   MyProfiler.java
 * Project:    p3b-201901     
 * Authors:    TODO: add your name(s) and lecture numbers here
 *
 * Semester:   Spring 2019
 * Course:     CS400
 * 
 * Due Date:   TODO: add assignment due date and time
 * Version:    1.0
 * 
 * Credits:    TODO: name individuals and sources outside of course staff
 * 
 * Bugs:       TODO: add any known bugs, or unsolved problems here
 */

// Used as the data structure to test our hash table against
import java.util.TreeMap;

/**
 * 
 * @author Daniel Ko
 *
 * @param <K>
 * @param <V>
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
     * 
     * @param key
     * @param value
     * @throws DuplicateKeyException 
     * @throws IllegalNullKeyException 
     */
    public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
        // Insert K, V into both data structures
    	hashtable.insert(key, value);
    	treemap.put(key, value);
    }
    
    public void retrieve(K key) throws IllegalNullKeyException, KeyNotFoundException {
        // get value V for key K from data structures
    	hashtable.get(key);
    	treemap.get(key);
    }
    
    public static void main(String[] args) {
        try {
            int numElements = Integer.parseInt(args[0]);

            
            // TODO: complete the main method. 
            // Create a profile object. 
            // For example, Profile<Integer, Integer> profile = new Profile<Integer, Integer>();
            // execute the insert method of profile as many times as numElements
            // execute the retrieve method of profile as many times as numElements
            // See, ProfileSample.java for example.
            
        
            String msg = String.format("Inserted and retreived %d (key,value) pairs", numElements);
            System.out.println(msg);
        }
        catch (Exception e) {
            System.out.println("Usage: java MyProfiler <number_of_elements>");
            System.exit(1);
        }
    }
}

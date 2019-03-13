// TODO: add the header 

// TODO: comment and complete your HashTableADT implementation
// DO ADD UNIMPLEMENTED PUBLIC METHODS FROM HashTableADT and DataStructureADT TO YOUR CLASS
// DO IMPLEMENT THE PUBLIC CONSTRUCTORS STARTED
// DO NOT ADD OTHER PUBLIC MEMBERS (fields or methods) TO YOUR CLASS
//
// TODO: implement all required methods
//
// TODO: describe the collision resolution scheme you have chosen
// identify your scheme as open addressing or bucket
//
// TODO: explain your hashing algorithm here 
// NOTE: you are not required to design your own algorithm for hashing,
//       since you do not know the type for K,
//       you must use the hashCode provided by the <K key> object
//       and one of the techniques presented in lecture
//
/**
 * TODO: talk about O(1) and O(N) and shit
 * 
 * @author Daniel Ko
 *
 * @param <K>
 * @param <V>
 */
public class HashTable<K extends Comparable<K>, V> implements HashTableADT<K, V> {

	private hashPair[] table; // Table to hold hashes
	private int tableSize; // Size of hash table
	private int numOfElements; // How many elements we have in our table
	private double loadFactorThreshold; // Proportion of our table we are going to allow as space

	/**
	 * Default constructor for HashTable. Constructs an empty HashTable with
	 * tableSize 11 and a loadFactorThreshold of 0.9.
	 */
	public HashTable() {
		this(11, 0.9);
	}

	/**
	 * Constructs an empty HashTable with the given initialCapacity and
	 * loadFactorThreshold.
	 * 
	 * @param initialCapacity
	 * @param loadFactorThreshold
	 */
	// TODO: wtf about initial capacity, loadfactorthreshold. throw exception?
	public HashTable(int initialCapacity, double loadFactorThreshold) {
		// Initialize instance variables
		tableSize = initialCapacity;
		this.loadFactorThreshold = loadFactorThreshold;
		table = new hashPair[tableSize];
	}

	@Override
	public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
		// Check if key is not null
		if (key == null) {
			throw new IllegalNullKeyException();
		}

		// Check if table is past our load threshold
		if (numOfElements >= loadFactorThreshold * tableSize) {
			this.resize();
		}

		hashPair<K, V> pair = new hashPair<K, V>(key, value); // new pair

		// Case #01: Empty index at hash table
		if (table[pair.hashIndex] == null) {
			table[pair.hashIndex] = pair;
			numOfElements++;
		}

		// Case #02: pair is already at hash location, must use linked list bucket
		// method
		// TODO: make sure this actually works
		else {
			hashPair temp = table[pair.hashIndex];
			while (temp.chain != null) {
				// Duplicate keys not allowed
				if (temp.key == key) {
					throw new DuplicateKeyException();
				}
				temp = temp.chain;
			}
			// Duplicate keys not allowed
			if (temp.key == key) {
				throw new DuplicateKeyException();
			}
			temp.chain = pair;
			numOfElements++;
		}
	}

	/**
	 * Increases the size of table by a factor of 2 plus 1 and rehashes all the
	 * values
	 */
	private void resize() {
		// New double(ish), pseudo prime sized table
		hashPair[] newTable = new hashPair[tableSize * 2 + 1];

		// Rehashing and moving values to new table
		for (int i = 0; i < table.length; i++) {
			if (table[i] != null) {
				table[i].recalculateHashIndex();
				newTable[table[i].hashIndex] = table[i];
				hashPair temp = newTable[table[i].hashIndex];
				// Rehash the linked list
				while (temp.chain != null) {
					temp.chain.recalculateHashIndex();
					temp.chain = temp.chain.chain;
				}
			}
		}
		table = newTable;
	}

	/**
	 * If key is found, remove the key,value pair from the data structure 
	 * decrease number of keys. return true If key is null, throw
	 * IllegalNullKeyException If key is not found, return false
	 */
	@Override
	public boolean remove(K key) throws IllegalNullKeyException {
		// Check if key is null
		if(key == null) {
			throw new IllegalNullKeyException();
		}
		
		// Case #01: First item in the list is key
		if(table[this.calculateHashIndex(key)].key.equals(key)) {
			table[this.calculateHashIndex(key)] = table[this.calculateHashIndex(key)].chain;
			return true;
		}
		
		// Case #02: Iterate through linked list to search for key
		hashPair temp = table[this.calculateHashIndex(key)];
		while(temp.chain != null) {
			if(temp.chain.equals(key)) {
				temp = temp.chain.chain;
				return true;
			}
			temp = temp.chain;
		}
		
		// Case #03: No key was found
		return false;
	}

	/**
	 * Returns the value associated with the specified key. Does not remove key or
	 * decrease number of keys.
	 * 
	 * @param key - the key which value we want to find
	 * @return value associated with the specified key
	 * @throws IllegalNullKeyException if key is null
	 * @throws KeyNotFoundException    if key is not found inside the hash table
	 */
	@Override
	public V get(K key) throws IllegalNullKeyException, KeyNotFoundException {
		// Check if key is null
		if (key == null) {
			throw new IllegalNullKeyException();
		}

		hashPair temp = table[this.calculateHashIndex(key)];
		// Cycle through linked list of buckets
		while (temp != null) {
			// Found key here
			if (temp.key.equals(key)) {
				return (V) temp.value;
			}
			temp = temp.chain;
		}
		// No such key
		throw new KeyNotFoundException();
	}

	/**
	 * @return number of elements in this table
	 */
	@Override
	public int numKeys() {
		return numOfElements;
	}

	/**
	 * Returns the load factor threshold that was passed into the constructor when
	 * creating the instance of the HashTable. When the current load factor is
	 * greater than or equal to the specified load factor threshold, the table is
	 * resized and elements are rehashed.
	 * 
	 * @return loadFactorThreshold
	 */
	// TODO:Fix
	@Override
	public double getLoadFactorThreshold() {
		if (this.getLoadFactor() >= this.loadFactorThreshold) {
			this.resize();
		}
		return loadFactorThreshold;
	}

	/**
	 * @return the current load factor for this hash table, load factor = number of
	 *         items / current table size
	 */
	@Override
	public double getLoadFactor() {
		return numOfElements / tableSize;
	}

	/**
	 * Return the current Capacity (table size) of the hash table array.
	 *
	 * The initial capacity must be a positive integer, 1 or greater and is
	 * specified in the constructor.
	 * 
	 * REQUIRED: When the load factor threshold is reached, the capacity must
	 * increase to: 2 * capacity + 1
	 *
	 * Once increased, the capacity never decreases
	 * 
	 * @return the current Capacity (table size) of the hash table array.
	 */
	@Override
	public int getCapacity() {
		return tableSize;
	}

	/**
	 * Returns the collision resolution scheme used for this hash table. Implement
	 * with one of the following collision resolution strategies. Define this method
	 * to return an integer to indicate which strategy.
	 * 
	 * 1 OPEN ADDRESSING: linear probe
	 * 
	 * 2 OPEN ADDRESSING: quadratic probe
	 * 
	 * 3 OPEN ADDRESSING: double hashing
	 * 
	 * 4 CHAINED BUCKET: array list of array lists
	 * 
	 * 5 CHAINED BUCKET: array list of linked lists
	 * 
	 * 6 CHAINED BUCKET: array list of binary search trees
	 * 
	 * 7 CHAINED BUCKET: linked list of array lists
	 * 
	 * 8 CHAINED BUCKET: linked list of linked lists
	 * 
	 * 9 CHAINED BUCKET: linked list of of binary search trees
	 * 
	 * @return collision resolution scheme used for this hash table
	 */
	@Override
	public int getCollisionResolution() {
		// 8 CHAINED BUCKET: linked list of linked lists
		return 8;
	}

	/**
	 * Calculates hash index for given key
	 * 
	 * @param key
	 * @return hash index
	 */
	private int calculateHashIndex(K key) {
		return Math.abs(key.hashCode()) % tableSize;
	}

	/**
	 * Class for data type that will hold our key,value pair
	 */
	private class hashPair<K extends Comparable<K>, V> {
		private K key;
		private V value;
		private int hashIndex;
		private hashPair chain;

		/**
		 * Constructor for hashPair
		 * 
		 * @param k - key for this object
		 * @param v - value for this object
		 */
		private hashPair(K k, V v) {
			key = k;
			value = v;
			hashIndex = Math.abs(key.hashCode()) % tableSize;
			chain = null;
		}

		/**
		 * Recalculates the hash index for this hash pair
		 */
		private void recalculateHashIndex() {
			hashIndex = Math.abs(key.hashCode()) % tableSize;
		}
	}
}


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
 * @author Daniel Ko
 *
 * @param <K>
 * @param <V>
 */
public class HashTable<K extends Comparable<K>, V> implements HashTableADT<K, V> {

//	public static void main(String[] args) {
//		HashTable<Integer, Integer> h = new HashTable<>(); 
//		System.out.println(h.tableSize);
//	}

	private hashPair[] table; // Generic table to hold our hashes(?)
	private int tableSize; // Size of our hash table
	private int numOfElements; // How many elements we have in our table
	private double loadFacatorThreshold; // Proportion of our table we are going to allow as space

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
	public HashTable(int initialCapacity, double loadFactorThreshold) {
		// Initialize instance variables
		tableSize = initialCapacity;
		this.loadFacatorThreshold = loadFactorThreshold;
		table = new hashPair[tableSize];
	}

	@Override 
	public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
		// Check if key is not null
		if(key == null) {
			throw new IllegalNullKeyException();
		}
		
		// Check table size
		if(numOfElements >= tableSize) {
			this.resize();
		}
		
		// Check if table is past our load threshold
		if(numOfElements <= loadFacatorThreshold * tableSize) {
			hashPair<K, V> pair = new hashPair<K, V>(key, value); // new pair
			
			// Check for collisions, insert if none 
			if(table[pair.hashIndex] == null) {
				//TODO: Check for chains
				table[pair.hashIndex] = pair;
				numOfElements++; 
			}
			
			else {
				// Bucket(?) method to del with collisions 
				if(table[pair.hashIndex].key == key) {
					throw new DuplicateKeyException();
				}
				
				hashPair temp = table[pair.hashIndex];
				while(temp.chain != null) {
					temp = temp.chain;
				}
				temp.chain = pair;
			}
		}
	}

	private void resize() {
		// New double(ish), pseudo prime sized table
		hashPair[] newTable = new hashPair[tableSize * 2 + 1];

		// Rehashing and moving values to new table
		for (int i = 0; i < table.length; i++) {
			table[0].recalculateHashIndex();
			newTable[table[0].hashIndex] = table[0];
		}
		table = newTable;
	}

	@Override
	public boolean remove(K key) throws IllegalNullKeyException {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public V get(K key) throws IllegalNullKeyException, KeyNotFoundException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int numKeys() {
		// TODO Auto-generated method stub
		return 0;
	}

	/**
	 * @return loadFactorThreshold
	 */
	@Override
	public double getLoadFactorThreshold() {
		return loadFacatorThreshold;
	}

	/**
	 * @return loadFactor
	 */
	@Override
	public double getLoadFactor() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int getCapacity() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int getCollisionResolution() {
		// TODO Auto-generated method stub
		return 0;
	}

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
		 * 
		 */
		private void recalculateHashIndex() {
			hashIndex = Math.abs(key.hashCode()) % tableSize;
		}
	}
}

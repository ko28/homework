
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
/////////////////////////////////////////////////////////////////////////////////////////
import java.util.ArrayList; // allowed for creating traversal lists
import java.util.LinkedList;
import java.util.List; // required for returning List<K>
import java.util.Queue;

/**
 * This binary search tree is a data structure which stores a key,value pair in
 * a node. Given any node, all of its right children's keys will be greater than
 * the node and all of its left children's keys will be smaller. On average
 * contain, insert, and delete will be O(log(n)) but this tree's worst case
 * scenario is O(n).
 * 
 * @author Daniel Ko
 *
 * @param <K> - key, used for all insert, remove, contain, etc...
 * @param <V> - value
 */
public class BST<K extends Comparable<K>, V> implements BSTADT<K, V> {

	// Protected fields so that they may be inherited by other classes (such as AVL)
	protected BSTNode<K, V> root;
	protected int numKeys; // number of keys in BST

	/**
	 * Public, default no-arg constructor
	 */
	public BST() {

	}

	/**
	 * Returns the keys of the data structure in pre-order traversal order. In the
	 * case of binary search trees, the order is: V L R
	 * 
	 * If the SearchTree is empty, an empty list is returned.
	 * 
	 * @return List of Keys in pre-order
	 * @see #preOrderHelper(List, BSTNode)
	 */
	@Override
	public List<K> getPreOrderTraversal() {
		List<K> preOrderList = new ArrayList<K>();
		preOrderHelper(preOrderList, root);
		return preOrderList;
	}

	/**
	 * Helper method for getPreOrderTraversal().
	 * 
	 * @param list - holds the nodes in preOrder
	 * @param node - current node
	 */
	private void preOrderHelper(List<K> list, BSTNode<K, V> node) {
		// Base case: null node
		if (node == null) {
			return;
		}
		// Order is: V L R
		list.add(node.key);
		preOrderHelper(list, node.left);
		preOrderHelper(list, node.right);
	}

	/**
	 * Returns the keys of the data structure in post-order traversal order. In the
	 * case of binary search trees, the order is: L R V
	 * 
	 * If the SearchTree is empty, an empty list is returned.
	 * 
	 * @return List of Keys in post-order
	 * @see #postOrderHelper(List, BSTNode)
	 */
	@Override
	public List<K> getPostOrderTraversal() {
		List<K> postOrderList = new ArrayList<K>();
		postOrderHelper(postOrderList, root);
		return postOrderList;
	}

	/**
	 * Helper method for getPostOrderTraversal().
	 * 
	 * @param list - holds the nodes in postOrder
	 * @param node - current node
	 */
	private void postOrderHelper(List<K> list, BSTNode<K, V> node) {
		// Base case: null node
		if (node == null) {
			return;
		}
		// Order is: L R V
		postOrderHelper(list, node.left);
		postOrderHelper(list, node.right);
		list.add(node.key);
	}

	/**
	 * Returns the keys of the data structure in level-order traversal order. The
	 * root is first in the list, then the keys found in the next level down, and so
	 * on. If the SearchTree is empty, an empty list is returned. Implemented using
	 * a queue.
	 * 
	 * @return List of Keys in level-order
	 */
	@Override
	public List<K> getLevelOrderTraversal() {
		List<K> levelOrderTraversal = new ArrayList<K>();
		// Base case: Null node
		if (root == null) {
			return levelOrderTraversal;
		}

		// Queue to hold nodes in a given level
		Queue<BSTNode<K, V>> queue = new LinkedList<BSTNode<K, V>>();
		queue.add(root);

		while (!queue.isEmpty()) {
			// Add top of queue to list
			BSTNode<K, V> currentNode = queue.poll();
			levelOrderTraversal.add(currentNode.key);

			// Nodes in level - 1 of current node are added to queue
			if (currentNode.left != null) {
				queue.add(currentNode.left);
			}
			if (currentNode.right != null) {
				queue.add(currentNode.right);
			}
		}
		return levelOrderTraversal;
	}

	/**
	 * Returns the keys of the data structure in sorted order. In the case of binary
	 * search trees, the visit order is: L V R If the SearchTree is empty, an empty
	 * list is returned.
	 * 
	 * @return List of Keys in-order
	 * @see #inOrderHelper(List, BSTNode)
	 */
	@Override
	public List<K> getInOrderTraversal() {
		List<K> inOrderList = new ArrayList<K>();
		inOrderHelper(inOrderList, root);
		return inOrderList;
	}

	/**
	 * Helper method for getInOrderTraversal().
	 * 
	 * @param list - holds the nodes in inOrder
	 * @param node - current node
	 */
	private void inOrderHelper(List<K> list, BSTNode<K, V> node) {
		// Base case: null node
		if (node == null) {
			return;
		}
		// Order is: L V R
		inOrderHelper(list, node.left);
		list.add(node.key);
		inOrderHelper(list, node.right);
	}

	/**
	 * Add the key,value pair to the data structure and increases size. Null values
	 * are accepted.
	 * 
	 * @param key   - of new node
	 * @param value - of new node
	 * @throws IllegalNullKeyException if key is null
	 * @throws DuplicateKeyException   if this BST contains key
	 */
	@Override
	public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
		// Illegal case 1: null key
		if (key == null) {
			throw new IllegalNullKeyException();
		}
		// Illegal case 2: BST contains key
		if (this.contains(key)) {
			throw new DuplicateKeyException();
		}
		// Case 1: If tree is empty, inputed node becomes root
		if (root == null) {
			root = new BSTNode<K, V>(key, value);
		}

		// Other cases
		else {
			insertHelper(root, new BSTNode<K, V>(key, value));
		}

	}

	/**
	 * Helper method for insert(). Recursively finds the spot which node will be
	 * inserted
	 * 
	 * @param current - node
	 * @param insert  - to be inserted
	 */
	private void insertHelper(BSTNode<K, V> current, BSTNode<K, V> insert) {
		// Sets insert to the the right node of current if insert's key is greater than
		// current key, however if the right node is currently instantiated, then
		// insertHelper is recursively called on the right node
		if (insert.key.compareTo(current.key) > 0) {
			if (current.right == null) {
				current.right = insert;
				return;
			}
			// Recursive call here
			insertHelper(current.right, insert);
		}

		// Sets insert to the the left node of current if insert's key is less than
		// current key, however if the left node is currently instantiated, then
		// insertHelper is recursively called on the left node
		if (insert.key.compareTo(current.key) < 0) {
			if (current.left == null) {
				current.left = insert;
				return;
			}
			// Recursive call here
			insertHelper(current.left, insert);
		}
	}

	/**
	 * Remove the key,value pair from the data structure and decrease
	 * {@link #numKeys} If node has both children, the smallest child from the right
	 * subtree will replace the node's original spot
	 * 
	 * @param key - to be removed
	 * @return true - if key was removed successfully
	 * @throws IllegalNullKeyException if key is null
	 * @throws KeyNotFoundException    if key is not in the BST
	 */
	@Override
	public boolean remove(K key) throws IllegalNullKeyException, KeyNotFoundException {

		// Illegal case 1: null key
		if (key == null) {
			throw new IllegalNullKeyException();
		}

		// Case R: Root node equals key
		if (root.key == key) {
			// Case R1: No children
			if (root.left == null && root.right == null) {
				root = null;
				return true;
			}
			// Case R2a: Left child only
			if (root.left != null && root.right == null) {
				root = root.left;
				return true;
			}
			// Case R2b: Right child only
			if (root.right != null && root.left == null) {
				root = root.right;
				return true;
			}
			// Case R3: Both children
			if (root.left != null && root.right != null) {
				// Smallest node from the right tree
				BSTNode<K, V> smallest = root.right;
				BSTNode<K, V> pred = null; // node above smallest
				while (smallest.left != null) {
					pred = smallest;
					smallest = smallest.left;
				}
				// root's right has no children
				if (pred == null) {
					root.right.left = root.left;
					root = root.right;
				}
				// root's right has children
				else {
					pred.left = smallest.right;
					smallest.left = root.left;
					smallest.right = root.right;
					root = smallest;
				}
				return true;
			}
		}

		// Illegal case 2: key exists in this tree
		if (!this.contains(key)) {
			throw new KeyNotFoundException();
		}

		// Other cases
		removeHelper(root, key);
		return true;
	}

	/**
	 * Helper method for remove(). Checks if above's children contains the key, if
	 * so then removes and adjusts BST.
	 * 
	 * @param above - node which we are looking at its children
	 * @param key   - to be removed
	 */
	private void removeHelper(BSTNode<K, V> above, K key) {
		// Base case: node is null
		if (above == null) {
			return;
		}
		// Case #0: Both children are not key, recursively run this method on this
		// node's children
		if ((above.left == null || above.left.key != key) && (above.right == null || above.right.key != key)) {
			removeHelper(above.left, key);
			removeHelper(above.right, key);
			return;
		}

		// Node to be removed is found
		boolean isRight;
		BSTNode<K, V> found;

		// Is the node right or left?

		// Left has key
		if (above.left != null && above.left.key == key) {
			isRight = false;
			found = above.left;
		}
		// Right has key
		else {
			isRight = true;
			found = above.right;
		}

		// Case #1: No children, just delete this node
		if (found.left == null && found.right == null) {
			found = null;
			return;
		}

		// Case #2a: Only left child
		if (found.left != null && found.right == null) {
			// Replace the node's spot on the above node to the moved node's children
			// Right case
			if (isRight) {
				above.right = found.left;
			}
			// Left case
			else {
				above.left = found.left;
			}
			found = null;
			return;
		}

		// Case #2b: Only right child
		if (found.right != null && found.left == null) {
			// Replace the node's spot on the above node to the moved node's children
			// Right case
			if (isRight) {
				above.right = found.right;
			}
			// Left case
			else {
				above.left = found.right;
			}
			found = null;
			return;
		}
		// Case #3: Both children exist
		if (found.left != null && found.right != null) {
			// Smallest node from the right tree
			BSTNode<K, V> smallest = found.right;
			BSTNode<K, V> pred = above; // node above smallest
			while (smallest.left != null) {
				pred = smallest;
				smallest = smallest.left;
			}
			pred.left = found.right;
			smallest.right = found.right;
			smallest.left = found.left;
			if (isRight) {
				above.right = smallest;
			} else {
				above.left = smallest;
			}
			found = null;
		}
		return;
	}

	/**
	 * Returns the value associated with the specified key
	 * 
	 * @param key - which value's will be returned
	 * @return value of inputed key
	 * @throws IllegalNullKeyException if key is null
	 * @throws KeyNotFoundException    of key is not found
	 */
	@Override
	public V get(K key) throws IllegalNullKeyException, KeyNotFoundException {
		// Illegal case 1: null key
		if (key == null) {
			throw new IllegalNullKeyException();
		}
		return getHelper(root, key);
	}

	/**
	 * Helper method for {@link#get}.
	 * 
	 * @param current
	 * @param search
	 * @return value of search
	 * @throws KeyNotFoundException
	 */
	private V getHelper(BSTNode<K, V> current, K search) throws KeyNotFoundException {
		// Base Case #1
		// Return this node's value if the node's key is the same as the key we are
		// looking for
		if (current.key == search) {
			return current.value;
		}

		// Checks right node if size is greater than current node's size. Returns right
		// node if it has the same value as size. If the right node exists the it runs
		// this method on
		// it recursively else it throws an exception
		if (search.compareTo(current.key) > 0) {
			if (current.right != null) {
				if (current.right.key == search) {
					return current.right.value;
				}
				return getHelper(current.right, search); // Recursive call here
			}
		}

		// Checks left node if size is less than current node's size. Returns left node
		// if it has the same value as size. If the left node exists the it runs this
		// method on it
		// recursively else it throws an exception
		else if (search.compareTo(current.key) < 0) {
			if (current.left != null) {
				if (current.left.key == search) {
					return current.left.value;
				}
				return getHelper(current.left, search); // Recursive call here
			}
		}

		// Base Case #2
		// Throw an exception if a node with inputted key was not found
		throw new KeyNotFoundException();
	}

	/**
	 * Returns true if this tree contains key.
	 * 
	 * @param key - to search
	 * @return true if this key is in the BST, false otherwise
	 * @throws IllegalNullKeyException if key is null
	 */
	@Override
	public boolean contains(K key) throws IllegalNullKeyException {
		// Illegal case #1: null key
		if (key == null) {
			throw new IllegalNullKeyException();
		}
		// Case #0: tree is empty
		if (root == null) {
			return false;
		}
		return containsHelper(root, key);
	}

	/**
	 * Helper method for contains(). Recursively goes down this tree and searches
	 * for key.
	 * 
	 * @param current - node
	 * @param search  - key that we are looking for
	 * @return true if this key is in the BST, false otherwise
	 */
	private boolean containsHelper(BSTNode<K, V> current, K search) {
		// Base Case #1
		// Return this true if the node's key is the same as the key we are looking for
		if (current.key == search) {
			return true;
		}

		// Checks right node if size is greater than current node's size. Returns right
		// node if it has the same value as size. If the right node exists the it runs
		// this method on it recursively else it throws an exception
		if (search.compareTo(current.key) > 0) {
			if (current.right != null) {
				if (current.right.key == search) {
					return true;
				}
				return containsHelper(current.right, search); // Recursive call here
			}
		}

		// Checks left node if size is less than current node's size. Returns left node
		// if it has the same value as size. If the left node exists the it runs this
		// method on it
		// recursively, else it throws an exception
		else if (search.compareTo(current.key) < 0) {
			if (current.left != null) {
				if (current.left.key == search) {
					return true;
				}
				return containsHelper(current.left, search); // Recursive call here
			}
		}

		// Base Case #2
		// Return false if a node with inputted key was not found
		return false;
	}

	/**
	 * Returns the number of key,value pairs in the data structure
	 * 
	 * @return number of key,value pairs in the data structure
	 */
	@Override
	public int numKeys() {
		// Case #0: Tree is empty
		if (root == null) {
			return 0;
		}
		return numKeysHelper(root);
	}

	/**
	 * Helper method for numKeys. Recursively calculates the number of keys below a
	 * node
	 * 
	 * @param current - node
	 * @return number of keys in current
	 */
	private int numKeysHelper(BSTNode<K, V> current) {

		// Case 1: Both left and right children are not null, therefore 2 children plus
		// their children's children
		if (current.left != null && current.right != null) {
			return 1 + numKeysHelper(current.left) + numKeysHelper(current.right);
		}

		// Case 2: Either left or right children are not null, therefore 1 children plus
		// left or right's children
		else if (current.left != null) {
			return 1 + numKeysHelper(current.left);
		} else if (current.right != null) {
			return 1 + numKeysHelper(current.right);
		}

		// Case 3 (Base Case): Both left or right are null, therefore 0 children
		else {
			return 1;
		}
	}

	/**
	 * Returns the key that is in the root node of this BST. If root is null,
	 * returns null.
	 * 
	 * @return key found at root node, or null
	 */
	@Override
	public K getKeyAtRoot() {
		// Case #1: Head is null
		if (root == null) {
			return null;
		}
		return root.key;
	}

	/**
	 * Tries to find a node with a key that matches the specified key. If a matching
	 * node is found, it returns the returns the key that is in the left child. If
	 * the left child of the found node is null, returns null.
	 * 
	 * @param key A key to search for
	 * @return The key that is in the left child of the found key
	 * 
	 * @throws IllegalNullKeyException if key argument is null
	 * @throws KeyNotFoundException    if key is not found in this BST
	 */
	@Override
	public K getKeyOfLeftChildOf(K key) throws IllegalNullKeyException, KeyNotFoundException {
		// Illegal case #1: null key
		if (key == null) {
			throw new IllegalNullKeyException();
		}
		return leftKeyHelper(root, key);
	}

	/**
	 * Helper method for getKeyOfLeftChild. Recursively searches for key and returns
	 * its left child's key.
	 * 
	 * @param current
	 * @param search
	 * @return
	 * @throws KeyNotFoundException
	 */
	private K leftKeyHelper(BSTNode<K, V> current, K search) throws KeyNotFoundException {
		// Base Case #1
		// Return this true if the node's key is the same as the key we are looking for
		if (current.key == search) {
			return current.left.key;
		}

		// Checks right node if size is greater than current node's size. Returns right
		// node if it has the same value as size. If the right node exists the it runs
		// this method on
		// it recursively, else it throws an exception
		if (search.compareTo(current.key) > 0) {
			if (current.right != null) {
				if (current.right.key == search) {
					return current.right.left.key;
				}
				return leftKeyHelper(current.right, search); // Recursive call here
			}
		}

		// Checks left node if size is less than current node's size. Returns left node
		// if it has the same value as size. If the left node exists the it runs this
		// method on it
		// recursively, else it throws an exception
		else if (search.compareTo(current.key) < 0) {
			if (current.left != null) {
				if (current.left.key == search) {
					return current.left.left.key;
				}
				return leftKeyHelper(current.left, search); // Recursive call here
			}
		}

		// Base Case #2
		// Return false if a node with inputted key was not found
		throw new KeyNotFoundException();
	}

	/**
	 * Tries to find a node with a key that matches the specified key. If a matching
	 * node is found, it returns the returns the key that is in the right child. If
	 * the right child of the found node is null, returns null.
	 * 
	 * @param key A key to search for
	 * @return The key that is in the right child of the found key
	 * 
	 * @throws IllegalNullKeyException if key is null
	 * @throws KeyNotFoundException    if key is not found in this BST
	 */
	@Override
	public K getKeyOfRightChildOf(K key) throws IllegalNullKeyException, KeyNotFoundException {
		// Illegal case #1: null key
		if (key == null) {
			throw new IllegalNullKeyException();
		}
		return rightKeyHelper(root, key);
	}

	/**
	 * Helper method for getKeyOfRightChild. Recursively searches for key and
	 * returns its right child's key.
	 * 
	 * @param current
	 * @param search
	 * @return
	 * @throws KeyNotFoundException
	 */
	private K rightKeyHelper(BSTNode<K, V> current, K search) throws KeyNotFoundException {
		// Base Case #1
		// Return this true if the node's key is the same as the key we are looking for
		if (current.key == search) {
			return current.right.key;
		}

		// Checks right node if size is greater than current node's size. Returns right
		// node if it has
		// the same value as size. If the right node exists the it runs this method on
		// it recursively
		// else it throws an exception
		if (search.compareTo(current.key) > 0) {
			if (current.right != null) {
				if (current.right.key == search) {
					return current.right.right.key;
				}
				return rightKeyHelper(current.right, search); // Recursive call here
			}
		}

		// Checks left node if size is ;ess than current node's size. Returns left node
		// if it has
		// the same value as size. If the left node exists the it runs this method on it
		// recursively
		// else it throws an exception
		else if (search.compareTo(current.key) < 0) {
			if (current.left != null) {
				if (current.left.key == search) {
					return current.left.right.key;
				}
				return rightKeyHelper(current.left, search); // Recursive call here
			}
		}

		// Base Case #2
		// Return false if a node with inputted key was not found
		throw new KeyNotFoundException();
	}

	/**
	 * Returns the height of this BST. H is defined as the number of levels in the
	 * tree.
	 * 
	 * If root is null, return 0 If root is a leaf, return 1 Else return 1 + max(
	 * height(root.left), height(root.right) )
	 * 
	 * Examples: A BST with no keys, has a height of zero (0). A BST with one key,
	 * has a height of one (1). A BST with two keys, has a height of two (2). A BST
	 * with three keys, can be balanced with a height of two(2) or it may be linear
	 * with a height of three (3) ... and so on for tree with other heights
	 * 
	 * @return the number of levels that contain keys in this BINARY SEARCH TREE
	 */
	@Override
	public int getHeight() {
		return getHeightHelper(root);
	}

	/**
	 * Method that returns height of a given node
	 * 
	 * @param current - node
	 * @return height of node
	 */
	protected int getHeight(BSTNode<K, V> current) {
		return getHeightHelper(current);
	}

	/**
	 * Helper method for getHeight().
	 * 
	 * @param current - node
	 * @return height of current
	 */
	private int getHeightHelper(BSTNode<K, V> current) {
		// Base Case: when current node is null
		if (current == null) {
			return 0;
		}
		// Get height for each subtree
		int right = getHeightHelper(current.right);
		int left = getHeightHelper(current.left);
		// Return largest subtree, final would be the largest tree
		return Math.max(right, left) + 1;
	}
}

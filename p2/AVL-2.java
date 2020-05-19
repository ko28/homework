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
// Problems: Remove doesn't properly balance 
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * This Adelson-Velsky and Landis tree is a data structure which stores a
 * key,value pair in a node. Given any node, all of its right children's keys
 * will be greater than the node and all of its left children's keys will be
 * smaller. All nodes in this tree must fit a constraint that the height
 * difference of any node's children will not greater than 1 or less than -1.
 * This allows contain, insert, and delete to be O(log(n)) even in its worst
 * case scenario.
 * 
 * @author Daniel Ko
 *
 * @param <K> - key, used for all insert, remove, contain, etc...
 * @param <V> - value
 */
public class AVL<K extends Comparable<K>, V> extends BST<K, V> {

	/**
	 * Add the key,value pair to the data structure and increases size. Null values
	 * are accepted. Once inserted, tree is rebalanced.
	 * 
	 * @param key   - of new node
	 * @param value - of new node
	 * @throws IllegalNullKeyException if key is null
	 * @throws DuplicateKeyException   if this BST contains key
	 * @see {@link BST#insert(Comparable, Object)}
	 */
	@Override
	public void insert(K key, V value) throws IllegalNullKeyException, DuplicateKeyException {
		super.insert(key, value);
		root = reBalance(root);
	}

	/**
	 * Remove the key,value pair from the data structure and decrease
	 * {@link #numKeys}. Once removed, tree is rebalanced.
	 * 
	 * @param key - to be removed
	 * @return true - if key was removed successfully
	 * @throws IllegalNullKeyException if key is null
	 * @throws KeyNotFoundException    if key is not in the BST
	 * @see {@link BST#remove(Comparable, Object)}
	 */
	@Override
	public boolean remove(K key) throws IllegalNullKeyException, KeyNotFoundException {
		super.remove(key);
		root = reBalance(root);
		return true;
	}

	/**
	 * Recursively goes through the tree and rebalances each node
	 * 
	 * @param current - node to be balanaced
	 * @return balanced node
	 */
	private BSTNode<K, V> reBalance(BSTNode<K, V> current) {
		current = fixedNode(current); // Helper method to fix node
		// Rebalance node's children
		if (current.right != null) {
			current.right = reBalance(current.right);
		}
		if (current.left != null) {
			current.left = reBalance(current.left);
		}
		return current;
	}

	/**
	 * Helper method for reBalance(). If balance factor is -2 or 2 then fixes the
	 * node. Balance factors greater than 2 and less than -2 will be dealt with
	 * later as the tree goes down. Balance factors of -1, 0, 1 means the node is
	 * already balanced.
	 * 
	 * @param node - to be fixed
	 * @return fixed node
	 */
	private BSTNode<K, V> fixedNode(BSTNode<K, V> node) {
		this.setBalanceAndHeight(super.root);

		// Right heavy
		if (node.balanceFactor == 2) {
			// Needs to rotate left
			if (node.right.balanceFactor > -1) {
				node = rotateLeft(node);
			}
			// Needs to rotate right then left
			else {
				node.right = rotateRight(node.right);
				node = rotateLeft(node);
			}
		}

		// Left heavy
		if (node.balanceFactor == -2) {
			// Needs to rotate right
			if (node.left.balanceFactor < 1) {
				node = rotateRight(node);
			}
			// Needs to rotate left then right
			else {
				node.left = rotateLeft(node.left);
				node = rotateRight(node);
			}
		}
		return node;
	}

	/**
	 * Set a node's balance and height
	 * 
	 * @param node to reset its balance and height
	 */
	private void setBalanceAndHeight(BSTNode<K, V> node) {
		if (node != null) {
			node.height = super.getHeight(node);
			node.balanceFactor = super.getHeight(node.right) - super.getHeight(node.left);
			setBalanceAndHeight(node.left);
			setBalanceAndHeight(node.right);
		}
	}

	/**
	 * Rotate left so that node will be balanced. For example:
	 * 
	 * 10 20 \ / \ 20 -> 10 30 \ 30
	 * 
	 * @param node - that is unbalanced
	 * @return balanced node
	 */
	private BSTNode<K, V> rotateLeft(BSTNode<K, V> node) {
		BSTNode<K, V> newNode = node.right;
		node.right = newNode.left;
		newNode.left = node;
		setBalanceAndHeight(root);
		return newNode;
	}

	/**
	 * Rotate right so that node will be balanced. For example:
	 * 
	 * 30 20 / / \ 20 -> 10 30 / 30
	 * 
	 * @param node that is unbalanced
	 * @return balanced node
	 */
	private BSTNode<K, V> rotateRight(BSTNode<K, V> node) {
		BSTNode<K, V> newNode = node.left;
		node.left = newNode.right;
		newNode.right = node;
		setBalanceAndHeight(root);
		return newNode;
	}
}

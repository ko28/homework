import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Filename:   Graph.java
 * Project:    p4
 * Author:    Daniel Ko
 * 
 * Directed and unweighted graph implementation using adjacency list 
 */

public class Graph implements GraphADT {
	private ArrayList<GraphNode> adjacencyList; // Adjacency List 
	private int size; // Number of edges 
	
	/**
	 * Default no-argument constructor, instantiates adjacencyList
	 */
	public Graph() {
		adjacencyList = new ArrayList<GraphNode>();
		size = 0;
	}

	/**
     * Add new vertex to the graph.
     *
     * If vertex is null or already exists,
     * method ends without adding a vertex or 
     * throwing an exception.
     * 
     * Valid argument conditions:
     * 1. vertex is non-null
     * 2. vertex is not already in the graph 
     * 
     * @param vertex the vertex to be added
     */
	public void addVertex(String vertex) {
		// Case 0a: Vertex is null
		if(vertex == null) {
			return;
		}
		
		// Case 0b: Graph contains vertex
		for(GraphNode n : adjacencyList) {
			if(n.data.equals(vertex)) {
				return;
			}
		}
		
		// Case 1: Added to graph, no edges yet
		adjacencyList.add(new GraphNode(vertex));
	}

	/**
     * Remove a vertex and all associated 
     * edges from the graph.
     * 
     * If vertex is null or does not exist,
     * method ends without removing a vertex, edges, 
     * or throwing an exception.
     * 
     * Valid argument conditions:
     * 1. vertex is non-null
     * 2. vertex is not already in the graph 
     *  
     * @param vertex the vertex to be removed
     */
	public void removeVertex(String vertex) {
		 
		// Case 0: Vertex is null
		if(vertex == null) {
			return;
		}
		
		// Case 1: Remove vertex of graph
		for(int i = 0; i < adjacencyList.size(); i++) {
			// Case 1a: Found vertex and removed
			if(adjacencyList.get(i).data.equals(vertex)) {
				adjacencyList.remove(i);
				i--;
			}
			else {
				// Case 1b: Iterate through edges and remove if vertex from it
				for(int z = 0; z < adjacencyList.get(i).neighbors.size(); z++) {
					if(adjacencyList.get(i).neighbors.get(z).equals(vertex)) {
						adjacencyList.get(i).neighbors.remove(z);
						size--;
						break;
					}
				}
			}
		}
	}


	/**
     * Add the edge from vertex1 to vertex2
     * to this graph.  (edge is directed and unweighted)
     * If either vertex does not exist,
     * no edge is added and no exception is thrown.
     * If the edge exists in the graph,
     * no edge is added and no exception is thrown.
     * 
     * Valid argument conditions:
     * 1. neither vertex is null
     * 2. both vertices are in the graph 
     * 3. the edge is not in the graph
     *  
     * @param vertex1 the first vertex (src)
     * @param vertex2 the second vertex (dst)
     */
	public void addEdge(String vertex1, String vertex2) {
		// Case 0a: Vertex input(s) are null
		if(vertex1 == null || vertex2 == null) {
			return;
		}
		
		// Case 1: Add vertices (if already in graph its fine) and edge btwn them
		this.addVertex(vertex1);
		this.addVertex(vertex2);
		// Search if edge is already between the two vertices
		for(GraphNode n : adjacencyList) {
			if(n.data.equals(vertex1) && !(n.neighbors.contains(vertex1))) {
				n.neighbors.add(vertex2);
			}
		}
		size++;
	}
	
	/**
     * Remove the edge from vertex1 to vertex2
     * from this graph.  (edge is directed and unweighted)
     * If either vertex does not exist,
     * or if an edge from vertex1 to vertex2 does not exist,
     * no edge is removed and no exception is thrown.
     * 
     * Valid argument conditions:
     * 1. neither vertex is null
     * 2. both vertices are in the graph 
     * 3. the edge from vertex1 to vertex2 is in the graph
     *  
     * @param vertex1 the first vertex
     * @param vertex2 the second vertex
     */
	public void removeEdge(String vertex1, String vertex2) {
		// Case 0a: Vertex input(s) are null
		if(vertex1 == null || vertex2 == null) {
			return;
		}
		
			// Store index of vertex1 and vertex 2 if found 
			int v1 = -1; 
			int v2 = -1;
			
		// Case 0b: Vertex does not exist
		for(int i = 0; i < adjacencyList.size(); i++) {
			if(adjacencyList.get(i).data.equals(vertex1)) {
				v1 = i;
			}
			if(adjacencyList.get(i).data.equals(vertex2)) {
				v2 = i;
			}
		}
			// Vertex was not found 
			if(v1 == -1 || v2 == -1) {
				return;
			}
		
		// Case 0c: Edge does not exists from vertex 1 to vertex 2
		if(!adjacencyList.get(v1).neighbors.contains(vertex2)) {
			return;
		}
		
		// Case 1: Remove edge from vertex 1 to vertex 2
		adjacencyList.get(v1).neighbors.remove(vertex2);
		size--;
	}	

	 /**
     * Returns a Set that contains all the vertices
     * 
     * @return a Set<String> which contains all the vertices in the graph
     */
	public Set<String> getAllVertices() {
		Set<String> allVertices = new HashSet<String>();
		// Iterate through adjacencyList and add all nodes to Set
		for(GraphNode n : adjacencyList) {
			allVertices.add(n.data);
		}
		return allVertices;
	}

	/**
     * Get all the neighbor (adjacent-dependencies) of a vertex
     * 
     * 4/9 Clarification of getAdjacentVerticesOf method: 
     * For the example graph, A->[B, C], D->[A, B] 
     *     getAdjacentVerticesOf(A) should return [B, C]. 
     * 
     * In terms of packages, this list contains the immediate 
     * dependencies of A and depending on your graph structure, 
     * this could be either the predecessors or successors of A.
     * 
     * @param vertex the specified vertex
     * @return an List<String> of all the adjacent vertices for specified vertex
     */
	public List<String> getAdjacentVerticesOf(String vertex) {
		List<String> adjacentVertices = new ArrayList<String>();
		// Iterate through adjacencyList set adjacentVertices to the found vertex's neighbors
		for(GraphNode n : adjacencyList) {
			if(n.data.equals(vertex)) {
				adjacentVertices = n.neighbors;
			}
		}
		return adjacentVertices;
	}
	
	/**
     * Returns the number of edges in this graph.
     * @return number of edges in the graph.
     */
    public int size() {
        return size;
    }

    /**
     * Returns the number of vertices in this graph.
     * @return number of vertices in graph.
     */
	public int order() {
        return adjacencyList.size();
    }
	
	/**
	 * Class for node that will hold data and list of edges 
	 */
	private class GraphNode{
		private String data; 
		private List<String> neighbors; // List of edges 
		
		/**
		 * Constructor for GraphNode. 
		 * 
		 * @param input - data to hold
		 */
		public GraphNode(String input) {
			this.data = input;
			neighbors = new ArrayList<String>();
			}
	}
}
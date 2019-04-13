import java.util.ArrayList;
import java.util.List;
import java.util.Set;


/**
 * Filename:   Graph.java
 * Project:    p4
 * Authors:    Daniel Ko
 * 
 * Directed and unweighted graph implementation
 * using adjacency list 
 */

public class Graph implements GraphADT {
	ArrayList<GraphNode> adjacencyList; // Adjacency List 
	int size; // Number of vertexes 
	int order; //Number of edges
	
	/*
	 * Default no-argument constructor
	 * Instantiates adjacencyList
	 */ 
	public Graph() {
		adjacencyList = new ArrayList<GraphNode>();
		size = 0;
		order = 0;
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
		size++;
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
     */
	public void removeVertex(String vertex) {
		 
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
		
		// Case 1: Remove vertex of graph
		for(int i = 0; i < adjacencyList.size(); i++) {
			// Case 1a: Found vertex and removed
			if(adjacencyList.get(i).data.equals(vertex)) {
				adjacencyList.remove(i);
				size--;
			}
			else {
				// Case 1b: Iterate through edges and remove if vertex from it
				for(int z = 0; z < adjacencyList.get(i).neighbors.size(); z++) {
					if(adjacencyList.get(i).neighbors.get(z).equals(vertex)) {
						adjacencyList.get(i).neighbors.remove(z);
						order--;
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
	 */
	public void addEdge(String vertex1, String vertex2) {
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
		
		// Case 0c: Edge already exists from vertex 1 to vertex 2
		if(adjacencyList.get(v1).neighbors.contains(vertex2)) {
			return;
		}
		
		// Case 1: Add edge from vertex 1 to vertex 2
		adjacencyList.get(v1).neighbors.add(vertex2);
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
     */
	public void removeEdge(String vertex1, String vertex2) {

	}	

	/**
     * Returns a Set that contains all the vertices
     * 
	 */
	public Set<String> getAllVertices() {
		return null;
	}

	/**
     * Get all the neighbor (adjacent) vertices of a vertex
     *
	 */
	public List<String> getAdjacentVerticesOf(String vertex) {
		
		return null;
	}
	
	/**
     * Returns the number of edges in this graph.
     */
    public int size() {
        return size;
    }

	/**
     * Returns the number of vertices in this graph.
     */
	public int order() {
        return order;
    }
	
	/**
	 * 
	 */
	private class GraphNode{
		private String data;
		private List<String> neighbors;
		
		public GraphNode(String input) {
			this.data = input;
			neighbors = new ArrayList<String>();
		}
	}
}
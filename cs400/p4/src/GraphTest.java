import static org.junit.jupiter.api.Assertions.*; // org.junit.Assert.*; 
import org.junit.jupiter.api.Assertions;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Set;

/**
 * Tests functionality of Graph
 */
public class GraphTest {
	Graph graph;

	@Before
	public void setUp() throws Exception {
		graph = new Graph();
	}

	@After
	public void tearDown() throws Exception {
		graph = null;
	}

	/**
	 * Tests if graph instantiates with size, order = 0
	 */
	@Test
	public void test001_constructor() {
		if (graph.size() != 0) {
			fail("Graph size is not 0");
		}
		if (graph.order() != 0) {
			fail("Graph order is not 0");
		}
	}

	/**
	 * Tests if graph can add one vertex and makes sure size = 1, order = 0
	 */
	@Test
	public void test002_addOneVertex() {
		graph.addVertex("hello");
		if (graph.size() != 0) {
			fail("size is not 0");
		}
		if (graph.order() != 1) {
			fail("order is not 1");
		}
	}

	/**
	 * Tests if graph can add and remove one vertex and makes sure size = 0, order = 0
	 */
	@Test
	public void test003_addOneVertexAndRemove() {
		String vertex = "hello";
		graph.addVertex(vertex);
		graph.removeVertex(vertex);
		if (graph.size() != 0) {
			fail("size is not 0");
		}
		if (graph.order() != 0) {
			fail("size is not 0");
		}

	}
	
	/**
	 * See if removing null throws anything 
	 */
	@Test
	public void test004_removeNullVertex() {
		graph.addVertex("test1");
		graph.removeVertex(null);
		graph.addVertex("test2");
		graph.removeVertex(null);
		graph.removeVertex(null);
		graph.addVertex("test5");
		if(graph.size() != 0 && graph.order() != 3) {
			fail("size != 0 and order != 3");
		}
		graph.removeVertex("test1");
		graph.removeVertex("test3");
		graph.removeVertex("test3");
		
	}
	
	/**
	 * Try to add an edge
	 */
	@Test
	public void test005_addEdge() {
		graph.addEdge("ay", "vertex2");
		if(graph.size() != 1 && graph.order() != 2) {
			fail("Size != 1 and order != 2");
		}
	}
	
	/**
	 * Try to add an edge and remove
	 */
	@Test
	public void test006_addEdgeAndRemove() {
		graph.addEdge("ay", "vertex2");
		if(graph.size() != 1 && graph.order() != 2) {
			fail("Size != 1 and order != 2");
		}
		graph.removeEdge("ay", "vertex2");
		if(graph.size() != 0 && graph.order() != 2) {
			fail("Size != 0 and order != 2");
		}
	}
	
	/**
	 * Add 3 vertices and get all vertices 
	 */
	@Test
	public void test007_getAllVertices() {
		graph.addEdge("ay", "vertex2");
		graph.addEdge("lmao", "vertex2");
		graph.addVertex("when im with the homies");
		Set<String> getVertices = graph.getAllVertices();
		if(getVertices.size() != 4){
			fail("not all vertices were retrieved");
		}
		getVertices.remove("ay");
		getVertices.remove("vertex2");
		getVertices.remove("lmao");
		getVertices.remove("when im with the homies");
		if(getVertices.size() != 0) {
			fail("Vertices were not the vertices inserted");
		}
	}
	
	/**
	 * 
	 */
	@Test
	public void test008_getAdjacentVerticesOf() {
		graph.addEdge("ay", "vertex2");
		graph.addEdge("lmao", "vertex2");
		graph.addVertex("when im with the homies");
		graph.addEdge("ay", "when im with the homies");
		List<String> adjV = graph.getAdjacentVerticesOf("ay");
		if(adjV.size() != 2){
			fail("not all adjacent vertices were retrieved");
		}
		adjV.remove("vertex2");
		adjV.remove("when im with the homies");
		if(adjV.size() != 0){
			fail("adjacent vertices were not the inputted adjacent vertices");
		}
	}
}

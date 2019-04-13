import static org.junit.jupiter.api.Assertions.*; // org.junit.Assert.*; 
import org.junit.jupiter.api.Assertions;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Random;

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
		if (graph.size() != 1) {
			fail("size is not 1");
		}
		if (graph.order() != 0) {
			fail("size is not 0");
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
	
	@Test
	public void test003_removeNullVertex() {
		graph.addVertex("test1");
		graph.removeVertex(null);
		graph.addVertex("test2");
		graph.removeVertex(null);
		graph.removeVertex(null);
		graph.addVertex("test5");
		if(graph.size() != 0 && graph.order() != 3) {
			fail("size != 0 and order != 3");
		}
		System.out.println(graph.size());
		graph.removeVertex("test1");
		System.out.println(graph.size());
		graph.removeVertex("test3");
		System.out.println(graph.size());
		graph.removeVertex("test3");
		System.out.println(graph.size());
		
	}

}

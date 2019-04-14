import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Filename:   PackageManager.java
 * Project:    p4
 * Authors:    Daniel Ko 
 * 
 * PackageManager is used to process json package dependency files
 * and provide function that make that information available to other users.
 * 
 * Each package that depends upon other packages has its own
 * entry in the json file.  
 * 
 * Package dependencies are important when building software, 
 * as you must install packages in an order such that each package 
 * is installed after all of the packages that it depends on 
 * have been installed.
 * 
 * For example: package A depends upon package B,
 * then package B must be installed before package A.
 * 
 * This program will read package information and 
 * provide information about the packages that must be 
 * installed before any given package can be installed.
 * all of the packages in
 * 
 * You may add a main method, but we will test all methods with
 * our own Test classes.
 */

public class PackageManager {
    
    private Graph graph;
    
    /*
     * Package Manager default no-argument constructor.
     */
    public PackageManager() {
    	graph = new Graph();
    }
    
    /**
     * Takes in a file path for a json file and builds the
     * package dependency graph from it. 
     * 
     * @param jsonFilepath the name of json data file with package dependency information
     * @throws FileNotFoundException if file path is incorrect
     * @throws IOException if the give file cannot be read
     * @throws ParseException if the given json cannot be parsed 
     */
    public void constructGraph(String jsonFilepath) throws FileNotFoundException, IOException, ParseException {
        //https://www.geeksforgeeks.org/parse-json-java/
    	// Convert file into something java can read
    	JSONObject jo = (JSONObject) new JSONParser().parse(new FileReader(jsonFilepath));
    	JSONArray pkg = (JSONArray) jo.get("packages"); // Convert into array of packages 
    	// Iterate through all packages 
    	for(int i = 0; i < pkg.size(); i++) {
    		JSONObject jsonPkg = (JSONObject) pkg.get(i);
    		String pkgName = (String) jsonPkg.get("name");
    		graph.addVertex(pkgName); // Add package to graph
    		JSONArray jsonDep = (JSONArray) jsonPkg.get("dependencies");
    		// Iterate through all the dependencies of this package 
    		for(int j = 0; j < jsonDep.size(); j++) {
    			graph.addEdge(pkgName, (String)jsonDep.get(j));
    		}
    	}
    }
    
    /**
     * Helper method to get all packages in the graph.
     * 
     * @return Set<String> of all the packages
     */
    public Set<String> getAllPackages() {
    	return graph.getAllVertices();
    }
    
    /**
     * Given a package name, returns a list of packages in a
     * valid installation order.  
     * 
     * Valid installation order means that each package is listed 
     * before any packages that depend upon that package.
     * 
     * @return List<String>, order in which the packages have to be installed
     * 
     * @throws CycleException if you encounter a cycle in the graph while finding
     * the installation order for a particular package. Tip: Cycles in some other
     * part of the graph that do not affect the installation order for the 
     * specified package, should not throw this exception.
     * 
     * @throws PackageNotFoundException if the package passed does not exist in the 
     * dependency graph.
     */
    public List<String> getInstallationOrder(String pkg) throws CycleException, PackageNotFoundException {
    	// List of all vertices
    	List<String> vertices = new ArrayList<String>(graph.getAllVertices());
    	int index = vertices.indexOf(pkg);
    	// Package is not in list of of all vertices
    	if(index < 0) {
    		throw new PackageNotFoundException();
    	}
    	// List that will hold all the sorted nodes 
    	List<String> ordered = new ArrayList<String>(); 
    	
    	// Arrays that will help us keep track of visited nodes
    	boolean[] visited = new boolean[graph.order()];
    	boolean[] tempMark = new boolean[graph.order()];
    
    	this.visit(pkg, vertices, ordered, visited, tempMark);
    	
    	return ordered;
    }
    
    /**
     * Given two packages - one to be installed and the other installed, 
     * return a List of the packages that need to be newly installed. 
     * 
     * For example, refer to shared_dependecies.json - toInstall("A","B") 
     * If package A needs to be installed and packageB is already installed, 
     * return the list ["A", "C"] since D will have been installed when 
     * B was previously installed.
     * 
     * @return List<String>, packages that need to be newly installed.
     * 
     * @throws CycleException if you encounter a cycle in the graph while finding
     * the dependencies of the given packages. If there is a cycle in some other
     * part of the graph that doesn't affect the parsing of these dependencies, 
     * cycle exception should not be thrown.
     * 
     * @throws PackageNotFoundException if any of the packages passed 
     * do not exist in the dependency graph.
     */
    public List<String> toInstall(String newPkg, String installedPkg) throws CycleException, PackageNotFoundException {
        List<String> installed = getInstallationOrder(installedPkg);
        List<String> toInstall = getInstallationOrder(newPkg);
        for(int i = 0; i < installed.size(); i++) {
        	toInstall.remove(installed.get(i));
        }
    	return toInstall;
    }
    
    /**
     * Return a valid global installation order of all the packages in the 
     * dependency graph.
     * 
     * assumes: no package has been installed and you are required to install 
     * all the packages
     * 
     * returns a valid installation order that will not violate any dependencies
     * 
     * @return List<String>, order in which all the packages have to be installed
     * @throws CycleException if you encounter a cycle in the graph
     */
    public List<String> getInstallationOrderForAllPackages() throws CycleException {
    	// List of all vertices
    	List<String> vertices = new ArrayList<String>(graph.getAllVertices());
    	// List that will hold all the sorted nodes 
    	List<String> ordered = new ArrayList<String>(); 
    	// Arrays that will help us keep track of visited nodes
    	boolean[] visited = new boolean[graph.order()];
    	boolean[] tempMark = new boolean[graph.order()];
    	
    	
    	for(String n : vertices) {
    		//
    		this.visit(n, vertices, ordered, visited, tempMark);
    	}
    	return ordered;
    }
    
    /**
     * 
     * @param vertex
     * @param vertices
     * @param ordered
     * @param visited
     * @param tempMark
     * @throws CycleException
     */
    private void visit(String vertex, List<String> vertices, List<String> ordered, boolean[] visited, boolean[] tempMark) throws CycleException {
    	int currIndex = vertices.indexOf(vertex);
    	// We have been here before
    	if(visited[currIndex]) {
    		return;
    	}
    	// Cycle is detected here, not a directed acyclic graph
    	if(tempMark[currIndex]) {
    		throw new CycleException();
    	}
    	
    	tempMark[currIndex] = true;
    	for(String dunno : graph.getAdjacentVerticesOf(vertex)) {
    		visit(dunno, vertices, ordered, visited, tempMark);
    	}
    	tempMark[currIndex] = false;
    	
    	visited[currIndex] = true;
    	ordered.add(vertex);
    }
    
    /**
     * Find and return the name of the package with the maximum number of dependencies.
     * 
     * Tip: it's not just the number of dependencies given in the json file.  
     * The number of dependencies includes the dependencies of its dependencies.  
     * But, if a package is listed in multiple places, it is only counted once.
     * 
     * Example: if A depends on B and C, and B depends on C, and C depends on D.  
     * Then,  A has 3 dependencies - B,C and D.
     * 
     * @return String, name of the package with most dependencies.
     * @throws CycleException if you encounter a cycle in the graph
     */
    public String getPackageWithMaxDependencies() throws CycleException {
    	// List of all vertices
    	List<String> vertices = new ArrayList<String>(graph.getAllVertices());
    	// Integers used for searching for max value
    	int indexMax = -1;
    	int maxValue = -1;
    	// Finding number of dependencies 
    	for(int i = 0; i < vertices.size(); i++) {
    		try {
				List<String> order = this.getInstallationOrder(vertices.get(i));
				// Greater value than current max is found
				if(order.size() > maxValue) {
					indexMax = i;
					maxValue = order.size();
				}
			} 
    		// This should never happen as all the vertices should be in the graph
    		catch (PackageNotFoundException e) {
    			e.printStackTrace(); 
			}
    	}
    	
    	return vertices.get(indexMax);
    }

    public static void main (String [] args) {
        System.out.println("PackageManager.main()");
    }
    
}

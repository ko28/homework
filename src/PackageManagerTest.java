import static org.junit.jupiter.api.Assertions.*; // org.junit.Assert.*; 
import org.junit.jupiter.api.Assertions;
import org.json.simple.parser.ParseException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;

/**
 * Tests functionality of Graph
 */
public class PackageManagerTest {
	PackageManager pm;

	@Before
	public void setUp() throws Exception {
		pm = new PackageManager();
	}

	@After
	public void tearDown() throws Exception {
		pm = null;
	}

	/**
	 * Tests if graph instantiates with size, order = 0
	 */
	@Test
	public void test001_constructGraph() {
		try {
			pm.constructGraph("src/valid.json");
			System.out.println(pm.getAllPackages());
			
		} catch (IOException | ParseException e) {
			e.printStackTrace();
			fail();
		}
	}
	
	public void test002_() {
		try {
			pm.constructGraph("src/valid.json");
			pm.getInstallationOrderForAllPackages();
		} catch (IOException | ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (CycleException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}


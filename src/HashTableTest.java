// TODO: add imports as needed

import static org.junit.jupiter.api.Assertions.*; // org.junit.Assert.*; 
import org.junit.jupiter.api.Assertions;
 
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Random;



/** TODO: add class header comments here*/
/**
 * 
 * @author Daniel Ko
 *
 */
public class HashTableTest{

    // TODO: add other fields that will be used by multiple tests
    
    // TODO: add code that runs before each test method
    @Before
    public void setUp() throws Exception {
    	
    }

    // TODO: add code that runs after each test method
    @After
    public void tearDown() throws Exception {

    }
    
    /** 
     * Tests that a HashTable returns an integer code
     * indicating which collision resolution strategy 
     * is used.
     *
     * 1 OPEN ADDRESSING: linear probe
     * 2 OPEN ADDRESSING: quadratic probe
     * 3 OPEN ADDRESSING: double hashing
     * 4 CHAINED BUCKET: array list of array lists
     * 5 CHAINED BUCKET: array list of linked lists
     * 6 CHAINED BUCKET: array list of binary search trees
     * 7 CHAINED BUCKET: linked list of array lists
     * 8 CHAINED BUCKET: linked list of linked lists
     * 9 CHAINED BUCKET: linked list of of binary search trees
     */
    @Test
    public void test000_collision_scheme() {
        HashTableADT htIntegerKey = new HashTable<Integer,String>();
        int scheme = htIntegerKey.getCollisionResolution();
        if (scheme < 1 || scheme > 9) 
            fail("collision resolution must be indicated with 1-9");
    }
        
    /** 
     * Tests that insert(null,null) throws IllegalNullKeyException
     */
    @Test
    public void test001_IllegalNullKey() {
        try {
            HashTableADT htIntegerKey = new HashTable<Integer,String>();
            htIntegerKey.insert(null, null);
            fail("should not be able to insert null key");
        } 
        catch (IllegalNullKeyException e) { /* expected */ } 
        catch (Exception e) {
            fail("insert null key should not throw exception "+e.getClass().getName());
        }
    }
    
    // TODO add your own tests of your implementation
    /** 
     * Tests that insert(null,null) throws IllegalNullKeyException
     */
    @Test
    public void test002_Insert_and_Remove() {
        try {
            HashTableADT htIntegerKey = new HashTable<Integer,String>();
            ArrayList<Integer> list = new ArrayList<Integer>();
            for(int i = 0; i < 200; i++) {
            	int temp = (int) (Math.random()*10000);
            	if(!list.contains(temp)) {
            		list.add(temp);
            		htIntegerKey.insert(temp, temp + "  i:" + i);
            	}
            }
            int z = list.size();
            for(int i = z; i > -1; i--) {
            	System.out.println(i);
            	htIntegerKey.remove(list.get(0));
            	list.remove(0);
            }
            if(htIntegerKey.numKeys() != 0) {
            	System.out.println(htIntegerKey.numKeys());
            	fail();
            }
        } 
        catch (Exception e) {
            fail("should not throw exception "+e.getClass().getName());
        }
    }
}

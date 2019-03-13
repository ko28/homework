
public class test {
	public static void main(String[] args) {
		HashTable<Integer, Integer> t = new HashTable<Integer, Integer>();
		try {
			t.insert(1, 10);
			t.insert(2, 10);
			
			System.out.println(t.remove(2));
			System.out.println(t.remove(1));

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
}

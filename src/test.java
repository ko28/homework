
public class test {
	public static void main(String[] args) {
		HashTable<Integer, Integer> t = new HashTable<Integer, Integer>();
		try {
			HashTableADT htIntegerKey = new HashTable<Integer, String>(5,0.6);
			Integer[] nums = new Integer[] {1,2,3,5,512,634,74,123,53};
			for(int n : nums) {
				htIntegerKey.insert(n, n + "yep");
				System.out.println(htIntegerKey.getCapacity());
			}
			for(int n : nums) {
				htIntegerKey.remove(n);
			}
			System.out.println(htIntegerKey.numKeys());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
}

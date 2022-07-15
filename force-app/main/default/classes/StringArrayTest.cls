public class StringArrayTest {
    public static List<String> generateStringArray(Integer length){
        List<String> test = new List<String>();
        for(Integer i=0; i<length;i++){
            test.add('Test '+i);
            System.debug(test[i]);
        }
        return test;
    }

}
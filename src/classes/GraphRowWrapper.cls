public class GraphRowWrapper {

    public String rowValue { get; set; }
    public String rowName { get; set; }

    public GraphRowWrapper(String rowValue, String rowName) {
        this.rowValue = rowValue;
        this.rowName = rowName;
    }

    public static testMethod void testConstructor() {

        GraphRowWrapper wrapper = new GraphRowWrapper('Me', 'You');
        System.assert(wrapper.rowValue.equals('Me'));
        System.assert(wrapper.rowName.equals('You'));
    }
}
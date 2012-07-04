public class GraphColumnWrapper {

    public String columnType { get; set; }
    public String columnName { get; set; }
    private String id;

    public GraphColumnWrapper(String columnType, String columnName) {
        this.columnType = columnType;
        this.columnName = columnName;
        this.id = null;
    }

    /**
     *  Convert the column into a Json String suitable for the data table
     *  format - {id: 'task', label: 'Task', type: 'string'}
     */
    public String toJsonString() {
        return '{id: \'' + getId() + '\', label: \'' + this.columnName + '\', type: \'' + this.columnType + '\'}';
    }

    public void setId(String newId) {
        this.id = newId;
    }

    /**
     *  Get the id of the column from the columnName
     */
    private String getId() {
        if (this.id != null) {
            return this.id;
        }
        return columnName.replace(' ', '_').toLowerCase();
    }

    static testMethod void testConstructor() {

        GraphColumnWrapper wrapper = new GraphColumnWrapper('Me', 'You Jimmy');
        System.assert(wrapper.columnType.equals('Me'));
        System.assert(wrapper.columnName.equals('You Jimmy'));
        System.assert(wrapper.toJsonString().equals('{id: \'you_jimmy\', label: \'You Jimmy\', type: \'Me\'}'));
    }
}
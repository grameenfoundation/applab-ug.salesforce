public class ApplicationGroupWrapper {

    public String title { get; set; }
    public Integer doesHave { get; set; }
    public Decimal doesNotHave { get; set; }
    public String groupId { get; set; }
    public String applicationId { get; set; }


    public ApplicationGroupWrapper (String title, Integer doesHave, Decimal doesNotHave, String groupId, String applicationId) {

        this.title = title;
        this.doesHave = doesHave;
        this.doesNotHave = doesNotHave;
        this.groupId = groupId;
        this.applicationId = applicationId;
    }

    public static testMethod void testConstructor() {

        ApplicationGroupWrapper wrapper = new ApplicationGroupWrapper('Me', 1, 1, 'there', 'here');
        System.assert(wrapper.title.equals('Me'));
        System.assert(wrapper.doesHave == 1);
        System.assert(wrapper.doesNotHave == 1);
    }
}
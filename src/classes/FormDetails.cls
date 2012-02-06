public class FormDetails {

    public String id { get; set; }
    public String ids { get; set; }

    public FormDetails(String idValue, String idsValue) {
        id = idValue;
        ids = idsValue;
    }

    public static testMethod void testConstructor() {

        FormDetails formDetails = new FormDetails('Me', 'You');
        System.assert(formDetails.id.equals('Me'));
        System.assert(formDetails.ids.equals('You'));
    }
}
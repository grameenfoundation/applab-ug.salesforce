public class TagCloudElementWrapper {

    public String word { get; set; }
    public String className { get; set; }
    public Integer frequency { get; set; }

    public TagCloudElementWrapper(String word, Integer Frequency) {
        this.word = word;
        this.frequency = frequency;
    }

    public void addClassName(String className) {
        this.className = className;
    }

    public static testMethod void testConstructor() {

        TagCloudElementWrapper wrapper = new TagCloudElementWrapper('Me', 2);
        wrapper.addClassName('Them');
        System.assert(wrapper.word.equals('Me'));
        System.assert(wrapper.frequency == 2);
        System.assert(wrapper.className.equals('Them'));
    }
}
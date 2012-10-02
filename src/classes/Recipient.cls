public with sharing class Recipient {

    RecipientType recipType;
    Id recipientId;

    public Recipient(Id recipientId, RecipientType recipType) {
        this.recipientId = recipientId;
        this.recipType = recipType;
    }

    public Id getRecipientId() {
        return this.recipientId;
    }

    public RecipientType getRecipientType() {
        return this.recipType;
    }

    public enum RecipientType {
        DistributionGroup,
        Person
    }

}
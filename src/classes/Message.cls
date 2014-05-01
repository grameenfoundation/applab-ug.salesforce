public with sharing class Message {

    /**
     * Encapsulates the information that is needed to send an SMS to a given gateway for a given list of recipients
     */
    public String subject;
    public String body;
    public Id senderId;
    public String senderName;
    public Map<String, SendSMSHelpers.Recipient> recipients;
    public DateTime expirationTime;
    public DateTime sentTime;
    public String medium;

    public Message(
            String subject,
            String body,
            Id senderId,
            String senderName,
            DateTime sentTime,
	    DateTime expirationTime,
            String medium
    ) {

        this.subject = subject;
        this.body = body;
        this.senderId = senderId;
        this.senderName = senderName;
        this.recipients = new Map<String, SendSMSHelpers.Recipient>();
        this.expirationTime = expirationTime;
        this.sentTime = sentTime;
        this.medium = medium;
    }

    public void addRecipient(SendSMSHelpers.Recipient recipient) {
        this.recipients.put(recipient.personId, recipient);
    }

    /**
     * Create a MD5 hash of the message text. This can then be used a key to a map to identify the message easily
     *
     * @return - The hash string
     */
    public String getMessageHash() {
        return EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(this.body)));
    }
}
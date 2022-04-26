public  class RandomContactFactory {
    public static List<Contact> generateRandomContacts(Integer numberContacts, String lastName) {
        List<Contact> contacts = new List<Contact>();

        for(Integer i=0;i<numberContacts;i++) {
            Contact c = new Contact(FirstName='Test '+String.valueOf(i), LastName=lastName);
            contacts.add(c);
        }

        return contacts;
    }
}
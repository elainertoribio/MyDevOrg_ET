public class ContactSearch {
    public static List<Contact> searchForContacts(String lastName, String mailingCode){
        List<Contact> contacts = [SELECT ID,Name 
                          FROM Contact WHERE (LastName =:lastName AND MailingPostalCode=: mailingCode)];
        
        return contacts;
        
    }
}
/**********************************************************************
* Name:     SG_RelationshipHelper
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     JAN 2021
* ======================================================
* ======================================================
* Purpose: 	Creates/Updates contact on relationship
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       JAN 2021        GO          Initial Development
*
***********************************************************************/
public class SG_RelationshipHelper
{
    public static Boolean assignContactToRelationship_Run = false;
    public static Boolean updateContact_Run = false;
    public static Boolean syncPersonAccount_Run = false;

    public static void syncPersonAccount2(System.TriggerOperation operation, Map<Id, Account> accounts)
    {
        System.debug(LoggingLevel.WARN, '-->SG_RelationshipHelper.syncPersonAccount_Run()');

        // only do after update (no need to do after insert since contact would be newly created)
        if(operation != System.TriggerOperation.AFTER_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '-->operation != System.TriggerOperation.AFTER_UPDATE');
            return;
        }

        if(syncPersonAccount_Run == true) return ;

        // prevent recursive trigger
        syncPersonAccount_Run = true;


        Map<Id, Id> contactToAccountMap = new Map<Id, Id>();
        for(Account a:accounts.values())
        {
            contactToAccountMap.put(a.PersonContactId, a.Id);
        }


        // get all relationships and update
        List<Relationship__c> relationships = [SELECT Contact2__c FROM Relationship__c WHERE Contact2__c IN :contactToAccountMap.keySet()];
        for(Relationship__c r:relationships)
        {
            r.First_Name__c = accounts.get(contactToAccountMap.get(r.Contact2__c)).FirstName;
            r.Last_Name__c = accounts.get(contactToAccountMap.get(r.Contact2__c)).LastName;
            r.Email__c = accounts.get(contactToAccountMap.get(r.Contact2__c)).PersonEmail;
            r.Home_Phone__c = accounts.get(contactToAccountMap.get(r.Contact2__c)).PersonHomePhone;
            r.Mobile_Phone__c = accounts.get(contactToAccountMap.get(r.Contact2__c)).PersonMobilePhone;
        }

        System.debug('Relationships: ' + relationships);

        if(!relationships.isEmpty())
        {
            update relationships;
        }
    }

    public static void syncPersonAccount(System.TriggerOperation operation, Map<Id, Contact> contacts)
    {
        System.debug(LoggingLevel.WARN, '-->SG_RelationshipHelper.syncPersonAccount_Run()');

        // only do after update (no need to do after insert since contact would be newly created)
        if(operation != System.TriggerOperation.AFTER_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '-->operation != System.TriggerOperation.AFTER_UPDATE');
            return;
        }

        if(syncPersonAccount_Run == true) return ;

        // prevent recursive trigger
        syncPersonAccount_Run = true;



        // get all relationships and update
        List<Relationship__c> relationships = [SELECT Contact2__c FROM Relationship__c WHERE Contact2__c IN :contacts.keySet()];
        for(Relationship__c r:relationships)
        {
            r.First_Name__c = contacts.get(r.Contact2__c).FirstName;
            r.Last_Name__c = contacts.get(r.Contact2__c).LastName;
            r.Email__c = contacts.get(r.Contact2__c).Email;
            r.Home_Phone__c = contacts.get(r.Contact2__c).HomePhone;
            r.Mobile_Phone__c = contacts.get(r.Contact2__c).MobilePhone;
        }

        System.debug('Relationships: ' + relationships);

        if(!relationships.isEmpty())
        {
            update relationships;
        }
    }

    public static void updateContact(System.TriggerOperation operation, List<Relationship__c> relationships)
    {
        System.debug(LoggingLevel.WARN, '-->SG_RelationshipHelper.updateContact()');

        // only do after update (no need to do after insert since contact would be newly created)
        if(operation != System.TriggerOperation.AFTER_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '-->operation != System.TriggerOperation.AFTER_INSERT && operation != System.TriggerOperation.AFTER_UPDATE');
            return;
        }

        if(updateContact_Run == true) return ;

        // prevent recursive trigger
        updateContact_Run = true;

        Map<Id, Relationship__c> contactIdToRelationshipMap = new Map<Id, Relationship__c>();
        for(Relationship__c r:relationships)
        {
            if(r.Contact2__c != Null)
            {
                contactIdToRelationshipMap.put(r.Contact2__c, r);
            }
        }

        if(!contactIdToRelationshipMap.isEmpty())
        {
            // get contacts to update
            List<Contact> contactsToUpdate = [SELECT Id, FirstName, LastName, Email, MobilePhone, HomePhone
                                                FROM Contact
                                                WHERE Id IN :contactIdToRelationshipMap.keySet()];

            for(Contact c:contactsToUpdate)
            {
                Relationship__c r = contactIdToRelationshipMap.get(c.Id);
                if(r.First_Name__c != Null) c.FirstName = r.First_Name__c;
                if(r.Last_Name__c != Null) c.LastName = r.Last_Name__c;
                c.Email = r.Email__c;
                c.MobilePhone = r.Mobile_Phone__c;
                c.HomePhone = r.Home_Phone__c;
            }

            if(!contactsToUpdate.isEmpty())
            {
                update contactsToUpdate;
            }

        }
    }

    public static void processRelationship(List<Relationship__c> relationships)
    {
        List<RecordType> personRTList = [SELECT Id, Name, SobjectType, IsPersonType
                                        FROM RecordType
                                        WHERE SobjectType = 'Account'
                                        AND IsPersonType = TRUE
                                        AND IsActive = True ORDER BY CreatedDate ASC];
        Id personRTID;
        if(!personRTList.isEmpty())
        {
            personRTID = personRTList[0].Id;
        }


        // List of Contacts To Create
        List<Account> accountsToCreate = new List<Account>();
        Map<String, Id> contactMap = new Map<String, Id>();
        for(Relationship__c r:relationships)
        {
            if(r.Contact2__c == Null && r.Last_Name__c != Null)
            {
                Account c = new Account();
                c.RecordTypeId = personRTID;
                c.FirstName = r.First_Name__c;
                c.LastName = r.Last_Name__c;
                c.PersonEmail = r.Email__c;
                c.PersonMobilePhone = r.Mobile_Phone__c;
                c.PersonHomePhone = r.Home_Phone__c;
                c.Dragons_Type__pc = 'Parent';
                accountsToCreate.add(c);
            }
        }
        if(!accountsToCreate.isEmpty()) {
            insert accountsToCreate;
            List<Account> accounts = [SELECT Id, FirstName, LastName, PersonContactId, PersonEmail, PersonHomePhone, PersonMobilePhone
            FROM Account WHERE Id IN:accountsToCreate];
            // create contact Map
            for (Account c : accounts)
            {
                String uniqueID = c.LastName;
                if(c.FirstName != Null)
                {
                    uniqueID += '-' + c.FirstName;
                }
                if(c.PersonEmail != Null)
                {
                    uniqueID += '-' + c.PersonEmail;
                }
                if(c.PersonMobilePhone != Null)
                {
                    uniqueID += '-' + c.PersonMobilePhone;
                }
                if(c.PersonHomePhone != Null)
                {
                    uniqueID += '-' + c.PersonHomePhone;
                }
                System.debug(LoggingLevel.WARN, '--> uniqueId: ' + uniqueID);
                System.debug(LoggingLevel.WARN, '-->c.PersonContactId: ' + c.PersonContactId);
                contactMap.put(uniqueID, c.PersonContactId);
            }
        }


        // now associated newly created contact to relationship or update existing contact
        Map<Id, Relationship__c> contactIdToRelationshipMap = new Map<Id, Relationship__c>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
        for(Relationship__c r: relationships)
        {
            if(r.Contact2__c == Null)
            {
                if(r.Last_Name__c == null) continue;
                // NEW CONTACT
                String uniqueID = r.Last_Name__c;
                if(r.First_Name__c != Null)
                {
                    uniqueID += '-' + r.First_Name__c;
                }
                if(r.Email__c != Null)
                {
                    uniqueID += '-' + r.Email__c;
                }
                if(r.Mobile_Phone__c != Null)
                {
                    uniqueID += '-' + r.Mobile_Phone__c;
                }
                if(r.Home_Phone__c != Null)
                {
                    uniqueID += '-' + r.Home_Phone__c;
                }
                if(contactMap.containsKey(uniqueID))
                {
                    r.Contact2__c = contactMap.get(uniqueID);
                    relationshipsToUpdate.add(r);
                }
            }
            else
            {
                // UPDATE Existing Contact
                contactIdToRelationshipMap.put(r.Contact2__c, r);
            }
        }

        if(!relationshipsToUpdate.isEmpty())
        {
            update relationshipsToUpdate;
        }

        if(!contactIdToRelationshipMap.isEmpty())
        {
            // get contacts to update
            List<Contact> contactsToUpdate = [SELECT Id, FirstName, LastName, Email, MobilePhone, HomePhone
            FROM Contact
            WHERE Id IN :contactIdToRelationshipMap.keySet()];

            for(Contact c:contactsToUpdate)
            {
                Relationship__c r = contactIdToRelationshipMap.get(c.Id);
                if(r.First_Name__c != Null) c.FirstName = r.First_Name__c;
                if(r.Last_Name__c != Null) c.LastName = r.Last_Name__c;
                c.Email = r.Email__c;
                c.MobilePhone = r.Mobile_Phone__c;
                c.HomePhone = r.Home_Phone__c;
            }

            if(!contactsToUpdate.isEmpty())
            {
                update contactsToUpdate;
            }

        }


    }


    /*
    @Future
    public static void assignContactToRelationship_Future(String relationships_JSON)
    {
        List<Relationship__c> relationships = (List<Relationship__c>)JSON.deserialize(relationships_JSON, List<Relationship__c>.class);

        List<RecordType> personRTList = [SELECT Id, Name, SobjectType, IsPersonType
        FROM RecordType
        WHERE SobjectType = 'Account'
        AND IsPersonType = TRUE
        AND IsActive = True];
        Id personRTID;
        if(!personRTList.isEmpty())
        {
            personRTID = personRTList[0].Id;
        }


        // List of Contacts To Create
        List<Account> accountsToCreate = new List<Account>();
        Map<String, Id> contactMap = new Map<String, Id>();
        for(Relationship__c r:relationships)
        {
            if(r.Contact2__c == Null && r.Last_Name__c != Null)
            {
                Account c = new Account();
                c.RecordTypeId = personRTID;
                c.FirstName = r.First_Name__c;
                c.LastName = r.Last_Name__c;
                c.PersonEmail = r.Email__c;
                c.PersonMobilePhone = r.Mobile_Phone__c;
                c.PersonHomePhone = r.Home_Phone__c;
                c.Dragons_Type__pc = 'Parent';
                accountsToCreate.add(c);
            }
        }
        if(!accountsToCreate.isEmpty()) {
            insert accountsToCreate;
            List<Account> accounts = [SELECT Id, FirstName, LastName, PersonContactId, PersonEmail, PersonHomePhone, PersonMobilePhone
            FROM Account WHERE Id IN:accountsToCreate];
            // create contact Map
            for (Account c : accounts)
            {
                String uniqueID = c.LastName;
                if(c.FirstName != Null)
                {
                    uniqueID += '-' + c.FirstName;
                }
                if(c.PersonEmail != Null)
                {
                    uniqueID += '-' + c.PersonEmail;
                }
                if(c.PersonMobilePhone != Null)
                {
                    uniqueID += '-' + c.PersonMobilePhone;
                }
                if(c.PersonHomePhone != Null)
                {
                    uniqueID += '-' + c.PersonHomePhone;
                }
                System.debug(LoggingLevel.WARN, '--> uniqueId: ' + uniqueID);
                System.debug(LoggingLevel.WARN, '-->c.PersonContactId: ' + c.PersonContactId);
                contactMap.put(uniqueID, c.PersonContactId);
            }
        }

        // now associated newly created contact to relationship
        for(Relationship__c r: relationships)
        {
            if(r.Contact2__c == Null && r.Last_Name__c != Null)
            {
                String uniqueID = r.Last_Name__c;
                if(r.First_Name__c != Null)
                {
                    uniqueID += '-' + r.First_Name__c;
                }
                if(r.Email__c != Null)
                {
                    uniqueID += '-' + r.Email__c;
                }
                if(r.Mobile_Phone__c != Null)
                {
                    uniqueID += '-' + r.Mobile_Phone__c;
                }
                if(r.Home_Phone__c != Null)
                {
                    uniqueID += '-' + r.Home_Phone__c;
                }
                if(contactMap.containsKey(uniqueID))
                {
                    r.Contact2__c = contactMap.get(uniqueID);
                }
            }
        }

    }

    public static void assignContactToRelationship(System.TriggerOperation operation, List<Relationship__c> relationships)
    {
        System.debug(LoggingLevel.WARN, '-->SG_RelationshipHelper.assignContactToRelationship()');

        // only do before inserts/before update
        if(operation != System.TriggerOperation.BEFORE_INSERT && operation != System.TriggerOperation.BEFORE_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '-->operation != System.TriggerOperation.BEFORE_INSERT');
            return;
        }

        if(assignContactToRelationship_Run == true) return ;

        // prevent recursive trigger
        assignContactToRelationship_Run = true;

        String relationships_JSON = JSON.serialize(relationships);
        assignContactToRelationship_Future(relationships_JSON);

    }

     */

}
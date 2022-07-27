/**********************************************************************
* Name:     SG_LWC_Relationships_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     APR 2021
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_LWC_Relationships
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       APR 2021        GO          Initial Development
*
***********************************************************************/
@IsTest
private class SG_LWC_Relationships_Test
{

    @IsTest
    static void testBehavior()
    {
        // Create accounts
        // Create an account
        Account student = new Account();
        student.FirstName = 'Test';
        student.LastName = 'Student';
        student.Dragons_Type__pc = 'Student';
        student.PersonEmail = 'testemail@test.com';
        insert student;

        String result = SG_LWC_Clone.cloneAccount(student.FirstName, student.LastName, student.Id, 'Student', null);

        Account account = SG_LWC_Relationships.getAccountInfo(student.Id);
        Account account2 = SG_LWC_Relationships.getRecordInfo(student.Id);
        Id contactId = SG_LWC_Relationships.getContactId(student.Id);
        List<Relationship__c> relationships = SG_LWC_Relationships.getRelationships(student.Id);

        SG_RelationshipHelper.syncPersonAccount_Run = false;
        student.LastName = 'Studente';
        update student;

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, MobilePhone, HomePhone FROM Contact];
        for(Contact c:contacts)
        {
            c.FirstName = 'Test1';
        }
        update contacts;
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        contactMap.put(contacts[0].Id, contacts[0]);
        SG_RelationshipHelper.syncPersonAccount_Run = false;
        SG_RelationshipHelper.syncPersonAccount(System.TriggerOperation.AFTER_UPDATE, contactMap);

        List<Relationship__c> relationships2 = [SELECT Id, Contact1__c, Contact2__c, First_Name__c, Last_Name__c, Email__c, Contact2_Role__c,
                                                Contact1_Role__c, Mobile_Phone__c, Home_Phone__c
                                                FROM Relationship__c];
        for(Relationship__c r:relationships2)
        {
            r.Email__c = 'test@email.com';
        }
        SG_RelationshipHelper.updateContact_Run = false;
        update relationships2;
        SG_RelationshipHelper.updateContact(System.TriggerOperation.AFTER_UPDATE, relationships2);

        Relationship__c rel2 = new Relationship__c();
        rel2.Contact1__c = contacts[0].Id;
        rel2.Contact1_Role__c = 'Student';
        rel2.Contact2_Role__c = 'Parent';
        rel2.First_Name__c = 'Parent';
        rel2.Last_Name__c = 'Test';
        rel2.Email__c = 'email@test.com';
        rel2.Mobile_Phone__c = '555-555-5555';
        insert rel2;



        List<Relationship__c> relationships3 = new List<Relationship__c>();
        relationships3.add(rel2);
        SG_RelationshipHelper.processRelationship(relationships3);


    }

    static testMethod void testBatch()
    {
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account student = new Account();
        student.RecordTypeId = personAccountRT;
        student.FirstName = 'Test';
        student.LastName = 'Student';
        student.Dragons_Type__pc = 'Student';
        student.PersonEmail = 'testemail@test.com';
        insert student;

        Contact c = [SELECT Id FROM Contact LIMIT 1];

        // Create Relationship
        Relationship__c r = new Relationship__c();
        r.Contact1__c = c.Id;
        r.Contact1_Role__c = 'Student';
        r.Contact2_Role__c = 'Parent';
        r.First_Name__c = 'Test';
        r.Last_Name__c = 'Test';
        r.Email__c = 'test@email.com';
        r.Home_Phone__c = '555-555-5555';
        insert r;

        Test.startTest();

        SG_RelationshipHelper_Scheduleable batch = new SG_RelationshipHelper_Scheduleable();
        String chron = '0 0 23 * * ?';
        System.schedule('Schedule Job Sync Relationship',  chron, batch);

        Test.stopTest();




    }

}
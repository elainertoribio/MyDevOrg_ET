/**********************************************************************
* Name:     SG_LWC_Relationships
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     MAR 2021
* ======================================================
* ======================================================
* Purpose: 	Helper class for Relationships Lightning Web Components
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       MAR 2021        GO          Initial Development
*
***********************************************************************/

public with sharing class SG_LWC_Relationships
{
    @AuraEnabled
    public static Account getRecordInfo(Id accountId)
    {
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNameSet = fieldMap.KeySet();
        List<String> fieldNameString = new List<String>(fieldNameSet);

        String fieldNames = String.join(fieldNameString, ',');
        Date today = Date.today();
        String query = 'SELECT ' + fieldNames + ' FROM Account ' +
                'WHERE Id = :accountId ';

        Account acct = Database.query(query);

        return acct;
    }

    @AuraEnabled
    public static Account getAccountInfo(Id accountId)
    {
        // get contact Id based on passed account Id
        Account personAccount = [SELECT Id, PersonContactId, Dragons_Type__pc
                                FROM Account WHERE Id = :accountId];

        return personAccount;
    }

    @AuraEnabled
    public static Id getContactId(Id accountId)
    {
        Id contactId;

        // get contact Id based on passed account Id
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :accountId];
        if(personAccount != null)
        {
            contactId = personAccount.PersonContactId;
        }

        return contactId;
    }

    @AuraEnabled
    public static List<Relationship__c> getRelationships(Id accountId)
    {
        Id contactId;

        // get contact Id based on passed account Id
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :accountId];
        if(personAccount != null)
        {
            contactId = personAccount.PersonContactId;
        }

        if(contactId == null) return new List<Relationship__c>();

        List<Relationship__c> relationships = [SELECT Id, Name, Contact1__c, Contact2__c, First_Name__c,
                                                Contact1__r.Name, Contact2__r.Name, Contact1__r.Email, Contact2__r.Email,
                                                Contact1_Role__c, Contact2_Role__c, Other_Relationship__c,
                                                Opt_Out__c, Guardian__c
                                                FROM Relationship__c
                                                WHERE Contact1__c = :contactId
                                                OR Contact2__c = :contactId];

        for(Relationship__c r:relationships)
        {
            r.First_Name__c = r.Contact2__r.Name;
            r.Email__c = r.Contact2__r.Email;
            r.Last_Name__c = contactId;
            if(r.Contact2__c == contactId)
            {
                r.Contact2__c = r.Contact1__c;
                r.Contact2_Role__c = r.Contact1_Role__c;
                r.First_Name__c = r.Contact1__r.Name;
                r.Email__c = r.Contact1__r.Email;
            }

            r.Mobile_Phone__c = '/' + r.Contact2__c;

        }

        return relationships;
    }



}
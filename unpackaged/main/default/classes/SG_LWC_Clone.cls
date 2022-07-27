/**********************************************************************
* Name:     SG_LWC_Clone
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     APR 2021
* ======================================================
* ======================================================
* Purpose: 	Helper class to clone person account
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       MAR 2021        GO          Initial Development
*
***********************************************************************/


public with sharing class SG_LWC_Clone
{

    @AuraEnabled
    public static List<String> getRoles()
    {
        List<String> roles = new List<String>();

        Schema.DescribeFieldResult fieldResult = Relationship__c.Contact2_Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p:ple)
        {
            roles.add(p.getValue());
        }

        return roles;
    }

    @AuraEnabled
    public static String cloneAccount(String firstname, String lastname, Id acctId, String role, String other)
    {
        String result;

        Account acctToClone = [SELECT RecordTypeId, High_School_Grad_Year__pc, High_School_Name__pc,
                                PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode,
                                PersonMailingCountry, Financial_Aid_Interest__pc, How_did_you_hear_about_Dragons__pc,
                                If_Referred_by_who__pc, Dragons_Type__pc, Interest_Type__pc, PersonContactId,
                                Session_Interest__pc, Program_Location_Interest__pc, Salesforce_Grade__pc
                                FROM Account WHERE Id = :acctId];

        Account acct = new Account();
        acct.FirstName = firstname;
        acct.LastName = lastname;
        acct.RecordTypeId = acctToClone.RecordTypeId;
        acct.High_School_Grad_Year__pc = acctToClone.High_School_Grad_Year__pc;
        acct.High_School_Name__pc = acctToClone.High_School_Name__pc;
        acct.PersonMailingStreet = acctToClone.PersonMailingStreet;
        acct.PersonMailingCity = acctToClone.PersonMailingCity;
        acct.PersonMailingState = acctToClone.PersonMailingState;
        acct.PersonMailingPostalCode = acctToClone.PersonMailingPostalCode;
        acct.PersonMailingCountry = acctToClone.PersonMailingCountry;
        acct.Financial_Aid_Interest__pc = acctToClone.Financial_Aid_Interest__pc;
        acct.How_did_you_hear_about_Dragons__pc = acctToClone.How_did_you_hear_about_Dragons__pc;
        acct.If_Referred_by_who__pc = acctToClone.If_Referred_by_who__pc;
        acct.Interest_Type__pc = acctToClone.Interest_Type__pc;
        acct.Session_Interest__pc = acctToClone.Session_Interest__pc;
        acct.Program_Location_Interest__pc = acctToClone.Program_Location_Interest__pc;
        acct.Salesforce_Grade__pc = acctToClone.Salesforce_Grade__pc;

        Savepoint sp = Database.setSavepoint();

        try
        {
            if(role == 'Student')
            {
                acct.Dragons_Type__pc = 'Student';
            }
            else
            {
                acct.Dragons_Type__pc = 'Parent';
            }
            insert acct;

            Account acct1 = [SELECT PersonContactId FROM Account WHERE Id = :acct.Id];

            Relationship__c relationship = new Relationship__c();
            if(role == 'Student')
            {
                relationship.Contact1__c = acct1.PersonContactId;
                relationship.Contact2__c = acctToClone.PersonContactId;
                relationship.Contact1_Role__c = role;
                relationship.Contact2_Role__c = 'Parent';
            }
            else
            {
                relationship.Contact1__c = acctToClone.PersonContactId;
                relationship.Contact2__c = acct1.PersonContactId;
                relationship.Contact1_Role__c = 'Student';
                relationship.Contact2_Role__c = role;
            }

            relationship.Other_Relationship__c = other;

            insert relationship;

            result = acct.Id;
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            result = 'Error: ' + e.getMessage();
        }


        return result;
    }

}
/**********************************************************************
* Name:     SG_LWC_OnboardingHelper
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Helper class for Application Lightning Web Components
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development
*
***********************************************************************/
public with sharing class SG_LWC_OnboardingHelper
{

    @AuraEnabled
    public static List<Payment__c> getPayments(Id applicationId)
    {
        System.debug('getPayments(): applicatonId = ' + applicationId);

        List<Payment__c> payments;
        User u = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];

        if(applicationId != null) {
            payments = [SELECT Id, Amount__c, Payment_Date__c, Payment_Type__c, Name
                        FROM Payment__c
                        WHERE Application__c = :applicationId
                        AND Payment_Type__c <> 'Additional Cost'
                        ORDER BY Payment_Date__c DESC];
        }
        else
        {
            payments = [SELECT Id, Amount__c, Payment_Date__c, Payment_Type__c, Name
                        FROM Payment__c
                        WHERE Payment_For__c = :u.Contact.AccountId
                        AND Payment_Type__c <> 'Additional Cost'
                        ORDER BY Payment_Date__c DESC];
        }

        return payments;
    }

    @AuraEnabled
    public static List<Payment__c> getAdditionalCosts(Id applicationId)
    {
        List<Payment__c> payments;
        User u = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];

        if(applicationId != null) {
            payments = [SELECT Id, Amount__c, Payment_Date__c, Payment_Type__c, Name
            FROM Payment__c
            WHERE Application__c = :applicationId
            AND Payment_Type__c = 'Additional Cost'
            ORDER BY Payment_Date__c DESC];
        }
        else
        {
            payments = [SELECT Id, Amount__c, Payment_Date__c, Payment_Type__c, Name
            FROM Payment__c
            WHERE Payment_For__c = :u.Contact.AccountId
            AND Payment_Type__c = 'Additional Cost'
            ORDER BY Payment_Date__c DESC];
        }

        return payments;
    }

    public static List<ContentDocumentLink> getProgramFiles(Id applicationId)
    {
        List<ContentDocumentLink> docs = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink
                                            WHERE LinkedEntityId = :applicationId];

        return docs;
    }
}
/**********************************************************************
* Name:     SG_LWC_References
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Helper class for Application Lightning Web Components
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       FEB 2021        GO          Initial Development
*
***********************************************************************/
public without sharing class SG_LWC_References {

    @AuraEnabled
    public static Application__c getApplication(Id applicationId)
    {
        Application__c app;

        Map<String, Schema.SObjectField> fieldMap = Application__c.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNameSet = fieldMap.KeySet();
        List<String> fieldNameString = new List<String>(fieldNameSet);

        String fieldNames = String.join(fieldNameString, ',');
        Date today = Date.today();
        Set<String> invalidStatus = new Set<String>();
        invalidStatus.add('60-Application Declined');
        invalidStatus.add('70-Cancelled');
        String query = 'SELECT ' + fieldNames + ' FROM Application__c ';

        if(applicationId != Null)
        {
            query += 'WHERE Id = :applicationId ';
        }
        query += 'ORDER BY CreatedDate DESC';

        System.debug(LoggingLevel.WARN,'Application query: ' + query);
        List<Application__c> openApplications = Database.query(query);
        if(!openApplications.isEmpty())
        {
            app = openApplications[0];

            // check if application Student
        }

        return app;


    }

}
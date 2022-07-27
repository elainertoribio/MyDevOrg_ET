/**********************************************************************
* Name:     SG_RelationshipHelper_Batch
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
public class SG_RelationshipHelper_Batch implements Database.Batchable<sObject>
{
    public final String query;

    public SG_RelationshipHelper_Batch()
    {
        //SG_RelationshipHelper.syncPersonAccount_Run = true;
        query = 'SELECT Id, First_Name__c, Last_Name__c, Email__c, Contact2__c, Mobile_Phone__c, Home_Phone__c ' +
                'FROM Relationship__c WHERE Contact2__c = null Or LastModifiedBy.ContactId <> Null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug(LoggingLevel.WARN, 'query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        System.debug(LoggingLevel.WARN, 'query: ' + query);
        System.debug(LoggingLevel.WARN, '-->scope: ' + scope);
        List<Relationship__c> relationships = (List<Relationship__c>)scope;
        SG_RelationshipHelper.processRelationship(relationships);
    }

    public void finish(Database.BatchableContext bc)
    {

    }

}
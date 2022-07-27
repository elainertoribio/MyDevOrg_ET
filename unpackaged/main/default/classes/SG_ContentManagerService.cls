/**********************************************************************
* Name:     SG_ContentManagerService
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Code to handle files
* https://www.sfdcpanther.com/how-to-download-files-from-lightning-community-using-lwc/
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development
*
***********************************************************************/

public without sharing class SG_ContentManagerService
{
    @AuraEnabled
    public static String getContentDetails(Id recordId)
    {
        System.debug(LoggingLevel.WARN, '-->SG_ContentManagerService.getContentDetails()');
        Set<Id> recordIds = new Set<Id>();

        // get application
        Application__c app = [SELECT Program_Applied__c FROM Application__c WHERE Id = :recordId];
        //Application__c app = [SELECT Program_Applied__c, Program_Applied__r.Program__c FROM Application__c WHERE Id = :recordId];

        System.debug(LoggingLevel.WARN, '-->app: ' + app);

        if(app.Program_Applied__c != Null)
        {
            recordIds.add(app.Program_Applied__c);
        }

        /*
        if(app.Program_Applied__r.Program__c != Null)
        {
            recordIds.add(app.Program_Applied__r.Program__c);
        }
        */

        System.debug(LoggingLevel.WARN, '-->recordIDs: ' + recordIds);

        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId
                                                        FROM   ContentDocumentLink
                                                        WHERE  LinkedEntityId IN : recordIds];
        System.debug(LoggingLevel.WARN, '-->contentDocumentList: ' + contentDocumentList);

        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, Id> contentIdToEntityIdMap = new Map<Id, Id>();

        for(ContentDocumentLink cdl : contentDocumentList)
        {
            contentDocumentIds.add(cdl.ContentDocumentId);
            contentIdToEntityIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }



        List<ContentDistribution> cdList = [SELECT Id, ContentVersion.Title, ContentVersion.Description, ContentDownloadUrl,
                                            ContentVersion.FileType, ContentVersion.ContentDocument.FileType,
                                            ContentVersion.ContentDocument.ContentSize, ContentVersion.ContentDocumentId
                                            FROM ContentDistribution];

        System.debug(LoggingLevel.WARN, '-->cdList: ' + cdList);

        List<ContentDistribution> cdListFiltered = new List<ContentDistribution>();
        for(ContentDistribution cd:cdList)
        {
            if(contentDocumentIds.contains(cd.ContentVersion.ContentDocumentId))
            {
                Id thisRecordId = contentIdToEntityIdMap.get(cd.ContentVersion.ContentDocumentId);
                if(recordIds.contains(thisRecordId))
                {
                    cdListFiltered.add(cd);
                }
            }
        }

        //List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension, Description,
        //                                            ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
        //                                            CreatedDate, ContentDocumentId, ContentDocument.FileType
        //                                            FROM   ContentVersion
        //                                            WHERE  ContentDocumentId IN : contentDocumentIds];
        return JSON.serialize(cdListFiltered);
    }



}
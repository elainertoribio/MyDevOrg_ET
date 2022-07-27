/**********************************************************************
* Name:     SG_ContentManagerService_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     MAR 2021
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_ContentManagerService
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       MAR 2021        GO          Initial Development
*
***********************************************************************/
@IsTest
private class SG_ContentManagerService_Test
{

    @TestSetup
    public static void createTestData()
    {
        // create program session
        Program_Session__c session = new Program_Session__c();
        session.Name = 'Summer Session';
        session.Start_Date__c = Date.today().addDays(150);
        session.End_Date__c = session.Start_Date__c.addDays(45);
        session.Program_Nickname__c = 'Cambodia';
        session.Full_Name__c = 'Summer Session';
        session.Session__c = 'Summer 2021';
        session.Final_Payment_Due_Date__c = session.Start_Date__c.addDays(-90);
        session.Countries_Visited__c = 'Cambodia';
        session.Status__c = 'Open';
        session.Total_program_seats__c = 12;
        session.Tuition__c = 5000;
        session.Group_Flight_Cost__c = 750;
        session.Payment_Service_Fee__c = 150;
        session.ISOS_Insurance_Cost__c = 100;
        insert session;

        // get person account record type
        Id personRTId;
        try
        {
            personRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        }
        catch(Exception e) {}

        // create student person account
        Account student = new Account();
        student.RecordTypeId = personRTId;
        student.FirstName = 'Lester';
        student.LastName = 'Tester';
        student.PersonBirthdate = Date.today().addDays(-7300);
        insert student;
    }

    @IsTest
    static void testBehavior()
    {
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Program_Session__c session = [SELECT Id FROM Program_Session__c LIMIT 1];
        // Create Application
        Application__c app = new Application__c();
        app.Name = 'Application';
        app.Student__c= student.Id;
        app.Application_Status__c = '10 - Application';
        app.Substatus__c = '11 - Application begun';
        app.Program_Applied__c = session.Id;
        insert app;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        // create contentdocument link record to Aplication
        SG_FilesHelper.processFile_UpdateApplication_Ran = false;
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = app.Id;
        cdl2.ContentDocumentId = documents[0].Id;
        cdl2.ShareType = 'V';
        insert cdl2;

        // create contentdocument link record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = session.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;

        // make public
        ContentDistribution cd = new ContentDistribution();
        cd.name = contentVersion.Title;
        cd.ContentVersionId = contentVersion.Id;
        cd.PreferencesAllowOriginalDownload = true;
        cd.PreferencesAllowPDFDownload = true;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesNotifyOnVisit = false;
        insert cd;

        String response = SG_ContentManagerService.getContentDetails(app.Id);

    }

    @IsTest
    static void testBehavior2()
    {
        Contact student = [SELECT Id FROM Contact LIMIT 1];
        Program_Session__c session = [SELECT Id FROM Program_Session__c LIMIT 1];
        // Create Application
        Application__c app = new Application__c();
        app.Name = 'Application';
        app.Student__c= student.Id;
        app.Application_Status__c = '10 - Application';
        app.Substatus__c = '11 - Application begun';
        app.Program_Applied__c = session.Id;
        insert app;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.Dragon_File_Type_fileupload__c = 'Passport Scan';
        insert contentVersion;

        ContentVersion cv = [SELECT ContentDocumentId, Id FROM ContentVersion WHERE Id = :contentVersion.Id];

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :cv.ContentDocumentId];

        // create contentdocument link record to Aplication
        SG_FilesHelper.processFile_UpdateApplication_Ran = false;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = app.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;


    }


}
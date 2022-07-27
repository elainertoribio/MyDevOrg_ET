/**********************************************************************
* Name:     SG_LWC_Application_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     MAR 2021
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_LWC_Application
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       MAR 2021        GO          Initial Development
*
***********************************************************************/

@IsTest
private class SG_LWC_Application_Test
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

        // create program session
        Program_Session__c session2 = new Program_Session__c();
        session2.Name = 'Summer Session 2';
        session2.Start_Date__c = Date.today().addDays(150);
        session2.End_Date__c = session.Start_Date__c.addDays(45);
        session2.Program_Nickname__c = 'Cambodia';
        session2.Full_Name__c = 'Summer Session';
        session2.Session__c = 'Summer 2021';
        session2.Final_Payment_Due_Date__c = session.Start_Date__c.addDays(-90);
        session2.Countries_Visited__c = 'Cambodia';
        session2.Status__c = 'Open';
        session2.Total_program_seats__c = 12;
        session2.Tuition__c = 5000;
        session2.Group_Flight_Cost__c = 750;
        session2.Payment_Service_Fee__c = 150;
        session2.ISOS_Insurance_Cost__c = 100;
        insert session2;

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
    static void test_createNewApplication()
    {
        Id appID = SG_LWC_Application.createNewApplication();
        System.assertEquals(null, appID);

        Profile p = [SELECT Id FROM Profile WHERE Name = '#Custom: Student' LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Program_Session__c> sessions = [SELECT Id FROM Program_Session__c];

        user u = New User(
                UserName = 'test_' + math.random() + '@test.com',
                FirstName = 'Test-First',
                LastName = 'Test-Last',
                Alias = 'test',
                email = 'test' + math.random() + '@test.com',
                CommunityNickName = string.valueOf(math.random()).substring(0,6),
                ProfileID = p.id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactID = c.Id
        );

        System.runAs(u)
        {
            Id appId2 = SG_LWC_Application.createNewApplication();
            System.assert(appId2 != null);

            // now Test updatePrograms
            String result = SG_LWC_Application.updatePrograms(appId2, sessions[0].Id, null, sessions[1].Id);
            // bad application Id
            String result2 = SG_LWC_Application.updatePrograms('appId2', sessions[0].Id, null, sessions[1].Id);
            // add relationship
            List<Relationship__c> relationships = new List<Relationship__c>();
            List<Relationship__c> relationships2 = SG_LWC_Application.addNewRelationship(relationships, appId2);
            relationships2[0].First_Name__c = 'Test';
            relationships2[0].Last_Name__c = 'Test';
            relationships2[0].Contact2_Role__c = 'Parent';

            List<Relationship__c> relationships3 = SG_LWC_Application.saveRelationships(relationships2, appId2);
            relationships3 = SG_LWC_Application.addNewRelationship(relationships2, appId2);

            List<Relationship__c> rel = SG_LWC_Application.getRelationShips(appId2);

            String result3 = SG_LWC_Application.deleteRelationship(relationships2[0].Id);

            String result4 = SG_LWC_Application.submitApplication(appId2);
        }

    }

    @IsTest
    static void test_applyToNewProgram()
    {
        String result = SG_LWC_Application.applyToNewProgram('Test');
        System.assertEquals('ERROR: Not a Community User.', result);

        Profile p = [SELECT Id FROM Profile WHERE Name = '#Custom: Student' LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Program_Session__c session = [SELECT Id FROM Program_Session__c LIMIT 1];

        user u = New User(
                UserName = 'test_' + math.random() + '@test.com',
                FirstName = 'Test-First',
                LastName = 'Test-Last',
                Alias = 'test',
                email = 'test' + math.random() + '@test.com',
                CommunityNickName = string.valueOf(math.random()).substring(0,6),
                ProfileID = p.id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactID = c.Id
        );

        System.runAs(u)
        {
            String sessionId = session.Id;
            Id appId2 = SG_LWC_Application.applyToNewProgram(sessionId);
            System.assert(appId2 != null);
            List<Application__c> apps = SG_LWC_Application.getApplications();
            Application__c app = apps[0];
            app.Why_Did_You_Choose_To_Apply_to_Dragons__c = 'Test';
            update app;
            String result2 = SG_LWC_Application.shortAnswerComplete(app.Id);
        }

    }

    @IsTest
    static void test_getPrograms()
    {
        List<Program__c> programs = SG_LWC_Application.getPrograms(null);
        List<Program__c> programs2 = SG_LWC_Application.getPrograms('Summer');
    }

    @IsTest
    static void test_getSessions()
    {
        Program__c p = new Program__c();
        p.Name = 'New Program';
        insert p;
        List<Program_Session__c> sessions = SG_LWC_Application.getSessions(p.Id);
    }

    @IsTest
    static void test_getStudentInfo_Account()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = '#Custom: Student' LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Program_Session__c session = [SELECT Id FROM Program_Session__c LIMIT 1];

        user u = New User(
                UserName = 'test_' + math.random() + '@test.com',
                FirstName = 'Test-First',
                LastName = 'Test-Last',
                Alias = 'test',
                email = 'test' + math.random() + '@test.com',
                CommunityNickName = string.valueOf(math.random()).substring(0,6),
                ProfileID = p.id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactID = c.Id
        );

        System.runAs(u)
        {
            Account a = SG_LWC_Application.getStudentInfo_Account();
            Contact c2 = SG_LWC_Application.getStudentInfo();
        }
    }

    @IsTest
    static void test_getRoles()
    {
        List<String> roles = SG_LWC_Application.getRoles();
    }
}
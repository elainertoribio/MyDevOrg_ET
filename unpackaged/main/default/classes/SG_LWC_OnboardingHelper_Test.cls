/**********************************************************************
* Name:     SG_LWC_OnboardingHelper_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     MAR 2021
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_LWC_OnboardingHelper
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       MAR 2021        GO          Initial Development
*
***********************************************************************/
@IsTest
private class SG_LWC_OnboardingHelper_Test {

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
    static void testBehavior()
    {
        List<Payment__c> payments = SG_LWC_OnboardingHelper.getPayments(null);

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

            SG_LWC_OnboardingHelper.getAdditionalCosts(appId2);
            SG_LWC_OnboardingHelper.getProgramFiles(appId2);
        }

    }
}
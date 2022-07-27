/**********************************************************************
* Name:     SG_LWC_Apply_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     MAR 2021
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_LWC_Apply
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       MAR 2021        GO          Initial Development
*
***********************************************************************/
@IsTest
private class SG_LWC_Apply_Test
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
    static void doTests()
    {
        Program_Session__c session = [SELECT Id, Name FROM Program_Session__c LIMIT 1];
        List<String> semesters = SG_LWC_Apply.getSemesters(null);
        List<Program_Session__c> sessions = SG_LWC_Apply.getProgramsBySession('Summer', null);
        List<String> programTypes = SG_LWC_Apply.getProgramTypes();
        List<Program__c> programs = SG_LWC_Apply.getPrograms(null);
        List<Program_Session__c> sessions2 = SG_LWC_Apply.getSessions(session.Id);
        String result = SG_LWC_Apply.registerUser('test@123445dragons.test', 'First', 'Last', 'sgi123456', session.Id, session.Name);

    }
}
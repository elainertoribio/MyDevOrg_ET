/**********************************************************************
* Name:     SG_ApplicationHelper_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_ApplicationHelper
* ======================================================
* ======================================================
* History:                                                            
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development           
*   
***********************************************************************/
@IsTest
public class SG_ApplicationHelper_Test 
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

	static testMethod void testContactSync()
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

		SG_ApplicationHelper.syncContact_Ran = false;

		app.High_School_Name__c = 'Test High School';
		app.High_School_Graduation_Date__c = '2022';
		update app;

		// assert contact fields synced
		Contact student1 = [SELECT High_School_Name__c, High_School_Grad_Year__c FROM Contact WHERE Id = :student.Id];
		System.assertEquals(app.High_School_Name__c, student1.High_School_Name__c);
		System.assertEquals(app.High_School_Graduation_Date__c, student1.High_School_Grad_Year__c);

	}

	static testMethod void testDueDates()
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

		SG_ApplicationHelper.processPaymentDueDate_Ran = false;

		// application is accepted
		app.Application_Status__c = '30 - Pre-Course Prep';
		app.Substatus__c = '31 - Pre-course prep in progress';
		app.Application_Accepted_Date__c = Date.today();
		update app;
	}
}
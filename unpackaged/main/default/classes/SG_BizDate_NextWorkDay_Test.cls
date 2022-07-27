/**********************************************************************
* Name:     SG_BizDate_NextWorkDay_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
*  
* ======================================================
* ======================================================
* Purpose:                                                      
* 
* ======================================================
* ======================================================
* History:                                                            
* VERSION   DATE            INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0       15-Feb-2019     rwd           Initial Development           
*   
***********************************************************************/


@IsTest
private class SG_BizDate_NextWorkDay_Test {

	private static SG_TestDataGenerator td;
	private static List<Contact> contacts;


	@testSetup static void setupTestData() {
		td = new SG_TestDataGenerator();
		contacts = td.getContacts(true);
	}

	static testMethod void testAddDays() {

		refreshData();
		Date myDate = Date.today();
		Date weekStart = myDate.toStartofWeek().addDays(-1); // US starts on Sunday, others start on Monday - subtract a day to get Saturday or Sunday

		for ( Contact c : contacts )
		{
			c.Birthdate = weekStart;
		}
		update contacts;
		refreshData();

		System.debug(LoggingLevel.WARN, '---> invoking the method');
		List<SG_BizDate_NextWorkDay_Wrapper> wrappers = new List<SG_BizDate_NextWorkDay_Wrapper>();
		SG_BizDate_NextWorkDay_Wrapper wrapper = new SG_BizDate_NextWorkDay_Wrapper();
		wrapper.date_value = contacts[0].Birthdate;
		wrapper.field_api_name = 'Birthdate';
		wrapper.record_id = contacts[0].Id;
		wrappers.add( wrapper );

		// we can't assume an org has Business Hours set up, so don't assert
		SG_BizDate_NextWorkDay_Invoc.setNextWorkDate(wrappers);

		// make an empty consructor for SG_BusinessDateWrapper to excercise some code
		SG_BizDate_NextWorkDay_Wrapper tmpWrap = new SG_BizDate_NextWorkDay_Wrapper();

	}

	public static void refreshData() {
		contacts = [SELECT Id, Name, Birthdate FROM Contact];
	}
}
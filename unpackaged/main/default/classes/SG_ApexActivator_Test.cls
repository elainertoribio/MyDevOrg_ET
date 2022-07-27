/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SG_ApexActivator_Test {

	static testMethod void testDisabledOverride() {
		SG_ApexActivator.testDisabled = true;
		System.assertEquals(true,SG_ApexActivator.isDisabled('Bogus'));
		SG_ApexActivator.testDisabled = false;
	}

    static testMethod void testDisabledFalseByDefault() {
        System.assertEquals(false,SG_ApexActivator.isDisabled('Bogus'));			
    }
    
    static testMethod void testDisabledTrue() {
    	
    	Apex_Activation_Settings__c settings = Apex_Activation_Settings__c.getInstance();
    	
    	if(settings == null) settings = new Apex_Activation_Settings__c();
    	
    	settings.Disable_All_Registered_Triggers__c = true;
    	
    	if(settings.id != null)
    	{
    		update settings;
    	}
    	else
    	{    	
    		insert settings;
    	}
    	
        System.assertEquals(true,SG_ApexActivator.isDisabled('Bogus'));			
    }
    
}
/**********************************************************************
* Name:     SG_LWC_Clone_Test
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     APR 2021
* ======================================================
* ======================================================
* Purpose: 	Test methods for SG_LWC_Clone
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       APR 2021        GO          Initial Development
*
***********************************************************************/
@IsTest
private class SG_LWC_Clone_Test
{
    @IsTest
    static void testBehavior()
    {
        // Create an account
        Account student = new Account();
        student.FirstName = 'Test';
        student.LastName = 'Student';
        student.Dragons_Type__pc = 'Student';
        student.PersonEmail = 'testemail@test.com';
        insert student;

        String result = SG_LWC_Clone.cloneAccount(student.FirstName, student.LastName, student.Id, 'Student', null);
        String result2 = SG_LWC_Clone.cloneAccount(student.FirstName, student.LastName, student.Id, 'Parent', null);

        List<String> roles = SG_LWC_Clone.getRoles();

    }
}
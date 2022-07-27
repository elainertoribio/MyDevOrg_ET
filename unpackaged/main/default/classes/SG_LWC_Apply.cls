/**********************************************************************
* Name:     SG_LWC_Apply
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Controller for Apply Lightning Web Component
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development
*
***********************************************************************/
public with sharing class SG_LWC_Apply
{
    @AuraEnabled (cacheable=true)
    public static List<String> getSemesters(String sessionType)
    {
        if(sessionType == null) sessionType = 'Student';


        List<String> semesters = new List<String>();
        Set<String> semestersUnique = new Set<String>();

        List<Program_Session__c> sessions = [SELECT Id, Session__c FROM Program_Session__c
        WHERE Is_Available_To_Apply__c = TRUE
        AND Session__c <> NULL
        ORDER BY Session__c];

        for(Program_Session__c s:sessions)
        {
            if(!semestersUnique.contains(s.Session__c))
            {
                semesters.add(s.Session__c);
            }
            semestersUnique.add(s.Session__c);
        }

        return semesters;
    }

    @AuraEnabled
    public static List<Program_Session__c> getProgramsBySession(String session, String type)
    {
        if(type == null) type = 'Student';
        List<Program_Session__c> sessions = [SELECT Id, Program_Session_Display__c FROM Program_Session__c WHERE
        Session__c = :session
        AND Is_Available_To_Apply__c = TRUE
        AND Type__c = :type
        ORDER By Program_Session_Display__c];
        return sessions;
    }

    @AuraEnabled (cacheable=true)
    public static List<String> getProgramTypes()
    {
        List<String> programTypes = new List<String>();

        Schema.DescribeFieldResult fieldResult = Program__c.Program_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p:ple)
        {
            programTypes.add(p.getValue());
        }


        return programTypes;
    }

    @AuraEnabled
    public static List<Program__c> getPrograms(String programType)
    {
        List<Program__c> programs;
        if(programType == '' || programType == null)
        {
            programs = [SELECT Id, Name FROM Program__c
                        ORDER BY Name];
        }
        else
        {
            programs = [SELECT Id, Name FROM Program__c
                        WHERE Program_Type__c = :programType
                        ORDER BY Name];
        }

        System.debug(LoggingLevel.WARN, '--->programs: ' + programs);

        return programs;
    }

    @AuraEnabled
    public static List<Program_Session__c> getSessions(String programId)
    {
        List<Program_Session__c> sessions = [SELECT Id, Name, Program_Session_Display__c FROM Program_Session__c
                                                WHERE Program__c = :programId
                                                ORDER BY Name];

        return sessions;
    }


    @AuraEnabled
    public static String registerUser(String email, String firstname, String lastname, String password, String sessionId, String sessionName)
    {

        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.

        String userName = email;

        User u = new User();
        u.Username = email;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = firstname + '' + lastname;

        //u.ProfileId = profileId;

        Savepoint sp = Database.setSavepoint();

        try
        {
            String userId;
            userId = Site.createExternalUser(u, accountId, password);

            if (userId != null)
            {
                // Create Application
                Application__c app = new Application__c();
                //app.Name = firstname + ' ' + lastname + ' - ' + sessionName;
                app.Community_User_Id__c = userId;
                app.Program_Applied__c = sessionId;

                insert app;

                // Login to Community
                PageReference pageRef = Site.login(userName, password, null);
                return pageRef.getUrl();
            }
            return 'Error: User not created.';
        }
        //catch(Site.ExternalUserCreateException ex)
        catch(Exception e)
        {
            Database.rollback(sp);
            System.debug(e.getStackTraceString() + '; ' + e.getMessage());
            String errMsg1 = e.getMessage();

            if(errMsg1.contains('User already exists') || errMsg1.contains('That nickname already exists.'))
            {
                //String errMsg = ' Error: ' + email + ' already has an account.  Please log into your existing account.';
                String errMsg = 'Error: ' + errMsg1 + '; user: ' + u;
                //String errMsg = 'Error: ' + e.getStackTraceString() + '; ' + e.getMessage();
                return errMsg;
            }
            else
            {
                String formattedErrMsg = 'Error: ' + SG_DisplayUtils.getFormattedErrorMessage(errMsg1);
                return formattedErrMsg;
            }

        }


    }

}
/**********************************************************************
* Name:     SG_LWC_Application
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Helper class for Application Lightning Web Components
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development
*
***********************************************************************/
public without sharing class SG_LWC_Application
{
    @AuraEnabled
    public static Id createNewApplication()
    {
        User u = [SELECT AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(u.ContactId == null) return null;

        Application__c app = new Application__c();
        app.Student__c = u.ContactId;
        insert app;

        return app.Id;
    }

    @AuraEnabled
    public static String applyToNewProgram(String sessionId)
    {
        String result;

        User currUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(currUser.ContactId == null)
        {
            return 'ERROR: Not a Community User.';
        }

        Application__c app = new Application__c();
        app.Student__c = currUser.ContactId;
        app.Program_Applied__c = sessionId;
        // now copy application information from most recent application
        Application__c mostRecentApp = getApplication(null);
        if(mostRecentApp != null)
        {
            app.Has_Valid_Passport__c = mostRecentApp.Has_Valid_Passport__c;
            app.Passport_Country__c = mostRecentApp.Passport_Country__c;
            app.High_School_Name__c = mostRecentApp.High_School_Name__c;
            app.High_School_Graduation_Date__c = mostRecentApp.High_School_Graduation_Date__c;
        }

        try
        {
            insert app;
            result = app.Id;
        }
        catch(Exception e)
        {
            String errMsg = SG_DisplayUtils.getFormattedErrorMessage(e.getMessage());
            result = 'ERROR: ' + errMsg;
        }

        System.debug('New Program result: ' + result);

        return result;
    }

    @AuraEnabled
    public static String updatePrograms(String applicationId, String session, String sessionBackup, String sessionBackup2)
    {
        String result = 'SUCCESS';

        Application__c app;
        try
        {
            app = [SELECT Id FROM Application__c WHERE ID = :applicationId];
        }
        catch(Exception e)
        {

        }

        if(app == Null)
        {
            result = 'ERROR: Unable to find Application';
        }
        else
        {
            try
            {
                if(session != Null) app.Program_Applied__c = session;
                app.Backup_Session__c = sessionBackup;
                app.X3rd_Choice_Program__c = sessionBackup2;

                if(app.Backup_Session__c == nUll && app.X3rd_Choice_Program__c != Null)
                {
                    app.Backup_Session__c = app.X3rd_Choice_Program__c;
                    app.X3rd_Choice_Program__c = null;
                }
                update app;
            }
            catch(Exception e)
            {
                result = e.getMessage();
            }
        }

        return result;
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
    public static Account getStudentInfo_Account()
    {
        User currUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];

        Account student;

        if(currUser.ContactId != Null)
        {
            Id studentId = currUser.Contact.AccountId;

            Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
            Set<String> fieldNameSet = fieldMap.KeySet();
            List<String> fieldNameString = new List<String>(fieldNameSet);

            String fieldNames = String.join(fieldNameString, ',');
            Set<String> invalidStatus = new Set<String>();
            String query = 'SELECT ' + fieldNames + ' FROM Account WHERE Id = :studentId ';

            System.debug(LoggingLevel.WARN, 'Contact query: ' + query);
            List<Account> accounts = Database.query(query);
            if (!accounts.isEmpty()) {
                student = accounts[0];
            } else {
                return null;
            }
        }

        return student;
    }

    @AuraEnabled
    public static Contact getStudentInfo()
    {
        User currUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        Contact student;

        if(currUser.ContactId != Null)
        {
            Id studentId = currUser.ContactId;

            Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
            Set<String> fieldNameSet = fieldMap.KeySet();
            List<String> fieldNameString = new List<String>(fieldNameSet);

            String fieldNames = String.join(fieldNameString, ',');
            Set<String> invalidStatus = new Set<String>();
            String query = 'SELECT ' + fieldNames + ' FROM Contact WHERE Id = :studentId ';

            System.debug(LoggingLevel.WARN, 'Contact query: ' + query);
            List<Contact> contacts = Database.query(query);
            if (!contacts.isEmpty()) {
                student = contacts[0];
            } else {
                return null;
            }
        }

        return student;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Application__c> getApplications()
    {
        User currUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        // not a community user, so return null
        if(currUser.ContactId == null) return null;

        Map<String, Schema.SObjectField> fieldMap = Application__c.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNameSet = fieldMap.KeySet();
        List<String> fieldNameString = new List<String>(fieldNameSet);

        String fieldNames = String.join(fieldNameString, ',');
        Id contactId = currUser.ContactId;
        Id currUserId = currUser.Id;

        String query = 'SELECT ' + fieldNames + ' FROM Application__c ' +
                'WHERE (Student__c = :contactId OR ' +
                'Community_User_Id__c = :currUserId ) ' +
                'ORDER BY CreatedDate DESC';

        System.debug(LoggingLevel.WARN,'Application query: ' + query);
        List<Application__c> applications = Database.query(query);

        return applications;

    }

    @AuraEnabled
    public static Application__c getApplication(String applicationId)
    {
        User currUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(currUser.ContactId != Null)
        {
            Application__c app;

            System.debug('applicationId: ' + applicationId);
            if(applicationId != null)
            {
                applicationId = parseId(applicationId, 'a02');
                System.debug('Parsed applicationId: ' + applicationId);
                //applicationId = applicationId.replace('CookieConsentPolicy=0:1;', '').trim();
            }

            // convert applicationId to an Id
            Id appId;
            try
            {
                appId = applicationId;
            }
            catch(Exception e)
            {
                System.debug('applicationId is not a valid Id');
            }

            Map<String, Schema.SObjectField> fieldMap = Application__c.sObjectType.getDescribe().fields.getMap();
            Set<String> fieldNameSet = fieldMap.KeySet();
            List<String> fieldNameString = new List<String>(fieldNameSet);

            String fieldNames = String.join(fieldNameString, ',');
            Id contactId = currUser.ContactId;
            Id currUserId = currUser.Id;
            Date today = Date.today();
            Set<String> invalidStatus = new Set<String>();
            invalidStatus.add('60-Application Declined');
            invalidStatus.add('70-Cancelled');
            String query = 'SELECT ' + fieldNames + ' FROM Application__c ' +
                            'WHERE (Student__c = :contactId OR ' +
                            'Community_User_Id__c = :currUserId ) ';

            if(applicationId != Null)
            {
                query += 'AND Id = :appId ';
            }
            else
            {
                query += 'AND Application_Status__c NOT IN :invalidStatus ' +
                        'AND Program_Applied__r.Start_Date__c > TODAY ';
            }
            query += 'ORDER BY CreatedDate DESC';

            System.debug(LoggingLevel.WARN,'Application query: ' + query);
            List<Application__c> openApplications = Database.query(query);
            if(!openApplications.isEmpty())
            {
                app = openApplications[0];

                // check if application Student
            }
            /*
            else
            {
                // create a new application
                app = new Application__c();
                app.Student__c = contactId;
                app.Application_Status__c = '10-Created';
                insert app;
            }
            */
            return app;
        }
        else
        {
            // Not a Community User
            return null;
        }

    }

    @AuraEnabled
    public static String shortAnswerComplete(Id applicationId)
    {
        // get Application
        Application__c app = [SELECT Why_Did_You_Choose_To_Apply_to_Dragons__c, What_Are_You_Most_Excited_Nervous_About__c,
                                How_Do_You_Do_In_Group_Setting__c, Questions_From_Applicant__c
                                FROM Application__c WHERE Id = :applicationId];
        if(app != null)
        {
            if(app.Why_Did_You_Choose_To_Apply_to_Dragons__c != Null)
            {
                app.Is_Short_Answer_Topic_Section_Complete__c = true;
            }

            try
            {
                update app;
                return 'SUCCESS';
            }
            catch(Exception e)
            {
                return 'Error: ' + e.getMessage();
            }
        }
        return 'Error: Applicatin Not Found for application ID: ' + applicationId;
    }


    @AuraEnabled
    public static List<Relationship__c> addNewRelationship(List<Relationship__c> relationships, Id applicationId)
    {
        Application__c app;
        if(applicationId == null)
        {
            app = getApplication(null);
        }
        else
        {
            app = [SELECT Student__c FROM Application__c WHERE Id = :applicationId];
        }

        Relationship__c r = new Relationship__c();
        r.Contact1__c = app.Student__c;
        r.Contact1_Role__c = 'Student';
        relationships.add(r);

        return relationships;
    }

    @AuraEnabled
    public static String submitApplication(Id applicationId)
    {
        String result;

        if(applicationId == null)
        {
            result = 'Error: Application not found.';
        }
        else
        {
            Application__c a = [SELECT Id, Application_Status__c FROM Application__c WHERE Id = :applicationId];
            if(a != Null)
            {
                //if(a.Application_Status__c == '10-Created')
                //{
                    // update Application Status to Submitted
                    a.Application_Status__c = '20-Admissions';
                    a.Application_Submitted_date__c = Datetime.now();
                    try
                    {
                        update a;
                        result = 'Success';
                    }
                    catch(Exception e)
                    {
                        result = SG_DisplayUtils.getFormattedErrorMessage(e.getMessage());
                        //result = 'Error Saving Application: ' + e.getMessage();
                    }

                //}
            }
            else
            {
                result = 'Error: Application not found.';
            }
        }

        return result;
    }

    @AuraEnabled
    public static String deleteRelationship(Id relId)
    {
        String response = 'Success';

        List<Relationship__c> relToDelete = [SELECT Id FROM Relationship__c WHERE Id = :relId];
        if(!relToDelete.isEmpty())
        {
            try
            {
                delete relToDelete;
            }
            catch(Exception e)
            {
                response = 'Error occurred while deleting Guardian. ' + e.getMessage();
            }
        }

        return response;
    }

    @AuraEnabled
    public static List<Relationship__c> getRelationShips(String applicationId)
    {
        Application__c app;
        if(applicationId == null)
        {
            app = getApplication(null);
        }
        else
        {
            applicationId = parseId(applicationId, 'a02');

            app = [SELECT Student__c FROM Application__c WHERE Id = :applicationId];
        }

        List<Relationship__c> relationships;

        if(app != Null)
        {
            Id studentId = app.Student__c;
            relationships = [
                    SELECT Id, Contact1__c, Contact2__c, Contact1_Role__c, Contact2_Role__c, Other_Relationship__c,
                            First_Name__c, Last_Name__c, Email__c, Home_Phone__c, Mobile_Phone__c, Opt_Out__c
                    FROM Relationship__c
                    WHERE Contact1__c = :studentId
            ];

            if (relationships.isEmpty()) {
                // create a new relationship
                relationships = new List<Relationship__c>();
                Relationship__c r = new Relationship__c();
                r.Contact1__c = app.Student__c;
                relationships.add(r);
            }
        }
        else {
            relationships = new List<Relationship__c>();
        }

       return relationships;
    }

    @AuraEnabled
    public static List<String> getRoles()
    {
        List<String> roles = new List<String>();

        Schema.DescribeFieldResult fieldResult = Relationship__c.Contact2_Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p:ple)
        {
            if(p.getValue() != 'Student') {
                roles.add(p.getValue());
            }
        }

        return roles;
    }

    @AuraEnabled
    public static List<Relationship__c> saveRelationships(List<Relationship__c> relationships, Id applicationId)
    {
        String returnMsg;

        try
        {
            if(!relationships.isEmpty())
            {
                for(Relationship__c r:relationships)
                {
                    r.Contact1_Role__c = 'Student';
                    r.Name = r.First_Name__c + ' ' + r.Last_Name__c + ' (' + r.Contact2_Role__c + ')';
                }
                upsert relationships;

                // update Guardian Info Complete on Application
                if(applicationId != Null) {
                    Application__c app = [SELECT Id FROM Application__c WHERE Id = :applicationId];
                    app.Is_Guardian_Info_Complete__c = true;
                    update app;
                }
                returnMsg = 'Success';
            }
        }
        catch(Exception e)
        {
            returnMsg = 'ERROR: ' + e.getStackTraceString() + ' ; ' + e.getMessage();
        }

        return relationships;
    }

    public static String parseId(String stringToParse, String idBeginsWith)
    {
        String parsedId;

        if(stringToParse == null || idBeginsWith == null)
        {
            return null;
        }

        Integer i = stringToParse.indexOfIgnoreCase(idBeginsWith);
        if(i == -1)
        {
            // nothing found, so return;
            return null;
        }

        parsedId = stringToParse.mid(i, 18);

        return parsedId;
    }

}
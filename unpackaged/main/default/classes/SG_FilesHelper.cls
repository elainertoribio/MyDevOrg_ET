/**********************************************************************
* Name:     SG_FilesHelper
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Updates associated Application when file is uploaded via Community
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development
*
***********************************************************************/
public class SG_FilesHelper
{
    public static Boolean processFile_UpdateTitle_Ran = false;
    public static Boolean processFile_UpdateApplication_Ran = false;

    public static void processFile_UpdateApplication(System.TriggerOperation operation, List<ContentVersion> files)
    {
        System.debug(LoggingLevel.WARN, '-->SG_FilesHelper.processFile_UpdateApplication()');
        if(operation != TriggerOperation.AFTER_INSERT)
        {
            System.debug(LoggingLevel.WARN, '-->operation != TriggerOperation.AFTER_INSERT');
            return;
        }

        // prevent recursive trigger
        if(processFile_UpdateApplication_Ran == true)
        {
            System.debug('-->processFile_UpdateApplication == true');
            return;
        }

        processFile_UpdateApplication_Ran = true;

        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentVersion f:files)
        {
            System.debug(LoggingLevel.WARN, 'documentID: ' + f.ContentDocumentId);
            contentDocumentIds.add(f.ContentDocumentId);
        }

        List<ContentDocumentLink> documentLinks = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink
                                                    WHERE ContentDocumentId IN :contentDocumentIds];

        System.debug(LoggingLevel.WARN, '--> documentLinks: ' + documentLinks);

        Map<Id, Id> cdIdToRecordIdMap = new Map<Id, Id>();
        for(ContentDocumentLink dl:documentLinks)
        {
            if(dl.LinkedEntityId != Null && String.valueOf(dl.LinkedEntityId).startsWith('a02'))
            {
                cdIdToRecordIdMap.put(dl.ContentDocumentId, dl.LinkedEntityId);
            }
        }

        System.debug(LoggingLevel.WARN, '--> cdIdToRecordIdMap: ' + cdIdToRecordIdMap);


        Map<Id, Application__c> applicationMap;
        if(!cdIdToRecordIdMap.isEmpty())
        {
            applicationMap = new Map<Id, Application__c>([SELECT ID FROM Application__c WHERE Id IN :cdIdToRecordIdMap.values()]);
        }

        System.debug(LoggingLevel.WARN, '--> applicationMap: ' + applicationMap);

        Map<String, String> titleToFieldMap = new Map<String, String>();
        titleToFieldMap.put('Passport Scan', 'Passport_Scan_Received__c');
        titleToFieldMap.put('Visa Scan', 'Visa_Scan_Received__c');
        titleToFieldMap.put('Student Medical Form', 'Student_Medical_Form_Received__c');
        titleToFieldMap.put('Doctor Medical Form', 'Doctor_Medical_Form_Received__c');
        titleToFieldMap.put('Mental Health Form', 'Mental_Health_Form_Received__c');
        titleToFieldMap.put('Red Rules Contract', 'Red_Rules_Contract_Received__c');
        titleToFieldMap.put('Liability Form', 'Liability_Form_Received__c');


        for(ContentVersion f:files)
        {
            if (cdIdToRecordIdMap.containsKey(f.ContentDocumentId))
            {
                Application__c app = applicationMap.get(cdIdToRecordIdMap.get(f.ContentDocumentId));

                if(titleToFieldMap.containsKey(f.Title))
                {
                    app.put(titleToFieldMap.get(f.Title), true);
                }

                /*
                if (f.Title == 'Passport Scan')
                {
                    app.Passport_Scan_Received__c = true;
                }
                else if (f.Title == 'Visa Scan')
                {
                    app.Visa_Scan_Received__c = true;
                }
                else if (f.Title == 'Student Medical Form')
                {
                    app.Student_Medical_Form_Received__c = true;
                }
                else if (f.Title == 'Doctor Medical Form')
                {
                    app.Doctor_Medical_Form_Received__c = true;
                }
                else if (f.Title == 'Mental Health Form')
                {
                    app.Mental_Health_Form_Received__c = true;
                }
                else if (f.Title == 'Red Rules Contract')
                {
                    app.Red_Rules_Contract_Received__c = true;
                }
                else if (f.Title == 'Liability Form')
                {
                    app.Liability_Form_Received__c = true;
                }
                 */

                applicationMap.put(app.Id, app);
            }

        }

        if(applicationMap != Null && !applicationMap.isEmpty())
        {
            update applicationMap.values();
        }
    }


    public static void processFile_UpdateTitle(System.TriggerOperation operation, List<ContentVersion> files)
    {
        System.debug(LoggingLevel.WARN, '-->SG_FilesHelper.processFile_UpdateTitle()');
        if(operation != TriggerOperation.BEFORE_INSERT)
        {
            System.debug(LoggingLevel.WARN, '-->operation != TriggerOperation.BEFORE_INSERT');
            return;
        }

        // prevent recursive trigger
        if(processFile_UpdateTitle_Ran == true)
        {
            System.debug('-->processFile_Ran == true');
            return;
        }

        processFile_UpdateTitle_Ran = true;

        Set<Id> appIds = new Set<Id>();
        for(ContentVersion f:files)
        {
            appIds.add(f.ContentDocumentId);
        }

        Map<Id, Application__c> applicationMap = new Map<Id, Application__c>([SELECT ID FROM Application__c WHERE Id IN :appIds]);

        for(ContentVersion f:files)
        {
            if(f.Dragon_File_Type_fileupload__c != Null)
            {
                f.Title = f.Dragon_File_Type_fileupload__c;
            }
        }
    }

}
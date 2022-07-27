/**********************************************************************
* Name:     SG_ApplicationHelper
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     NOV 2020
* ======================================================
* ======================================================
* Purpose: 	Processes Submitted Applications
* ======================================================
* ======================================================
* History:                                                            
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       NOV 2020        GO          Initial Development           
*   
***********************************************************************/
public class SG_ApplicationHelper 
{
    public static Boolean processPaymentDueDate_Ran = false;
    public static Map<Id, Boolean> appIdToHasPaymentDueDateRan_Map = new Map<Id, Boolean>();
    public static Boolean syncContact_Ran = false;

    public static void syncContact(TriggerOperation operation, List<Application__c> applications, Map<Id, Application__c> applications_OldMap)
    {
        System.debug(LoggingLevel.WARN, '==> BEGIN SG_ApplicationHelper.syncContact()');

        // only do for AFTER UPDATE/AFTER INSERT
        if(operation != System.TriggerOperation.AFTER_INSERT && operation != System.TriggerOperation.AFTER_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '==>ABORTING: operation != System.TriggerOperation.BEFORE_INSERT && operation != System.TriggerOperation.BEFORE_UPDATE');
            return;
        }

        // prevents recursive triggers
        if(syncContact_Ran == true)
        {
            System.debug(LoggingLevel.WARN, '==> ABORTING: syncContact_Ran == true');
            return;
        }

        syncContact_Ran = true;

        // get list of contacts to update
        Map<Id, Application__c> contactIdToApplicationMap = new Map<Id, Application__c>();

        for(Application__c a:applications)
        {
            if(a.Student__c == null) continue;

            if(operation == System.TriggerOperation.AFTER_INSERT)
            {
                contactIdToApplicationMap.put(a.Student__c, a);
            }
            else
            {
                if(a.High_School_Graduation_Date__c != applications_OldMap.get(a.Id).High_School_Graduation_Date__c
                        || a.High_School_Name__c != applications_OldMap.get(a.Id).High_School_Name__c)
                {
                    contactIdToApplicationMap.put(a.Student__c, a);
                }
            }
        }

        // find contacts to update
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id IN :contactIdToApplicationMap.keySet()];
        if(contacts.isEmpty()) return;

        for(Contact c:contacts)
        {
            c.High_School_Name__c = contactIdToApplicationMap.get(c.Id).High_School_Name__c;
            c.High_School_Grad_Year__c = contactIdToApplicationMap.get(c.Id).High_School_Graduation_Date__c;
        }

        update contacts;

    }

    public static void processPaymentDueDate(TriggerOperation operation, List<Application__c> applications)
    {
        System.debug(LoggingLevel.WARN, '==> BEGIN SG_ApplicationHelper.processPaymentDueDate()');

        // only do for BEFORE UPDATE/BEFORE INSERT
        if(operation != System.TriggerOperation.BEFORE_INSERT && operation != System.TriggerOperation.BEFORE_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '==>ABORTING: operation != System.TriggerOperation.BEFORE_INSERT && operation != System.TriggerOperation.BEFORE_UPDATE');
            return;
        }

        // prevents recursive triggers
        if(processPaymentDueDate_Ran == true)
        {
            System.debug(LoggingLevel.WARN, '==> ABORTING: processPaymentDueDate_Ran == true');
            //return;
        }

        processPaymentDueDate_Ran = true;

        // List of Applications to Process
        List<Application__c> appsToProcess = new List<Application__c>();
        for(Application__c a:applications)
        {
            if(a.Application_Accepted_Date__c != Null && a.Final_Payment_Due_Date__c == null)
            {
                if(operation == System.TriggerOperation.BEFORE_UPDATE)
                {
                    if (appIdToHasPaymentDueDateRan_Map.containsKey(a.Id))
                    {
                        if (appIdToHasPaymentDueDateRan_Map.get(a.Id) == true)
                        {
                            // already ran Payment Due Date code this for this record, so skip to next
                            continue;
                        }
                    }
                    else
                    {
                        // not processes, so add to map
                        appIdToHasPaymentDueDateRan_Map.put(a.Id, true);
                    }
                }

                // 1. Accepted Date + 14 Days < 30 Days from start Date; Payment Due Date = DUE NOW (Accepted Date)
                // 2. If Accepted Date < 80 Days; Payment Due Date = Program.Payment Due Date
                // 3. Otherwise, Due Date = Accepted Date + 14

                Date acceptedDatePlusXDays = a.Application_Accepted_Date__c.addDays(14);
                Date dueNowDate = a.Program_Start_Date2__c.addDays(-30);
                Date XDaysBeforeStartDate = a.Program_Start_Date2__c.addDays(-80);
                if(acceptedDatePlusXDays > dueNowDate)
                {
                    // 1. Accepted Date + 14 Days < 30 Days from start Date; Payment Due Date = DUE NOW (Accepted Date)
                    a.Final_Payment_Due_Date__c = a.Application_Accepted_Date__c;
                }
                else if(a.Application_Accepted_Date__c < XDaysBeforeStartDate)
                {
                    // 2. If Accepted Date < 80 Days; Payment Due Date = Program.Payment Due Date
                    a.Final_Payment_Due_Date__c = a.Program_Final_Paymenet_Due_Date__c;
                }
                else
                {
                    // 3. Otherwise, Due Date = Accepted Date + 14
                    a.Final_Payment_Due_Date__c = acceptedDatePlusXDays;
                }
            }
        }


    }


}
trigger SG_Application on Application__c (before insert, before update, after insert, after update, after delete, after undelete )
{

    if(Trigger.isBefore)
    {
        SG_ApplicationHelper.processPaymentDueDate(Trigger.operationType, trigger.new);
        //SG_ApplicationHelper.associateApplicationToContact(trigger.operationType, trigger.new);
    }

    if(trigger.isAfter)
    {
        SG_ApplicationHelper.syncContact(trigger.operationType, trigger.new, Trigger.oldMap);
    }


    if(trigger.isAfter)
    {
        //Initialize the rollup helper
        SG_LookupRollupHelper lh = new SG_LookupRollupHelper();

        // take care of assigning the correct lists based on the trigger type (Insert vs Update vs Delete vs Undelete)
        lh.setTriggerLists(Trigger.operationType, Trigger.new, Trigger.old);

        // do the rollup(s) -- will execute all active rollups for current object
        lh.doRollupSummary();
    }

}
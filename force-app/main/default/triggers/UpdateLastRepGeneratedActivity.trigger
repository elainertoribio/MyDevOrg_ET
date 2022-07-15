Trigger UpdateLastRepGeneratedActivity on Task(after insert, after update){
   List<Contact> contactsToUpdate = new List<Contact>();
   List<Lead> leadsToUpdate = new List<Lead>();
   Map<Id, Task> taskMap = new Map<Id, Task>();
    
    for(Task t: Trigger.New){
        if(t.WhoId != null && t.Status == 'Completed'){
            taskMap.put(t.WhoId, t);
        }
    }
    
    if(taskMap.size() > 0){
        contactsToUpdate = [SELECT Id, Last_Rep_Generated_Activity__c 
                            FROM Contact WHERE Id IN: taskMap.keySet()];
        leadsToUpdate = [SELECT Id, Last_Rep_Generated_Activity__c 
                            FROM Lead WHERE Id IN: taskMap.keySet()];
        
        for(Contact cn: contactsToUpdate){
            cn.Last_Rep_Generated_Activity__c = Date.today();   
        }
        for(Lead ld: leadsToUpdate){
            ld.Last_Rep_Generated_Activity__c = Date.today();   
        }
        
        if(contactsToUpdate.size() > 0 && leadsToUpdate.size() > 0){
            update contactsToUpdate;
            update leadsToUpdate;
        }
    }
}
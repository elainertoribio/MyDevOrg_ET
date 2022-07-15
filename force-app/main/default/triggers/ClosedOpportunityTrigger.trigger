trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Task> taskToInsert = new List<Task>();
    
    for(Opportunity opp: Trigger.New){
        if(opp.StageName == 'Closed Won'){
            Task tk = new Task();
            tk.Subject = 'Follow Up Test Task';
            tk.WhatId = opp.Id;
            taskToInsert.add(tk);            
        }
    }
 		if (taskToInsert.size() > 0) {
        insert taskToInsert;
    }
}
trigger MatchingOpportunity on Opportunity (after insert, after update) {
    if(Trigger.isInsert){
        List<Opportunity> oppList = (List<Opportunity>) Trigger.new;
        List<Opportunity> existingOppList = [SELECT Id, StageName, Industry__c, CloseDate, Amount
                                            FROM Opportunity
                                            WHERE Id IN :oppList
                                            AND StageName = 'Close Won'
                                            AND CloseDate < TODAY];
        
        for(Opportunity opp: existingOppList){
            
            System.debug('list'+opp.StageName);
            Opportunity newOpp = [SELECT Id, StageName, Industry__c, CloseDate, Description, Amount
                                 FROM Opportunity
                                 WHERE Id =:opp.Id
                                 AND StageName ='Close Won'
                                 AND CloseDate < TODAY
                                 AND Industry__c =: opp.Industry__c];
        }
        
    }

}
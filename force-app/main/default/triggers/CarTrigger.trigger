trigger CarTrigger on Car__c (before insert) {
    for(Car__c car: Trigger.new){
        if(car.Currency__c >= 10000){
            car.Is_Expensive__c = true;
        }
        if(car.Acquisition_Date__c.month() == Date.today().month()){
            car.Is_new__c = true;
        }

    }
}
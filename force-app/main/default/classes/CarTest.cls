@isTest
private class CarTest{

     @testSetup static void dataSetup(){

       Engine__c TestEng = new Engine__c() ; //Crear eng

       Insert TestEng;  //Insertar un engine (objeto)


       Car__c TestCar = new Car__c (); //Crear un car con todos sus valores

       TestCar.Name = 'TestCar';

       TestCar.Acquisition_date__c = date.today();

       TestCar.Color__c = 'White';

      // TestCar.Is_expensive__c = True;

      // TestCar.Is_New__c = True;

       TestCar.Currency__c = 10001;

       TestCar.Type__c = 'Race';

       Insert TestCar;      

     }


     @isTest static void isnotExpensive (){
  		Engine__c testE = [SELECT Id FROM Engine__c];
        Car__c testCar = new Car__c();
         testCar.Name ='test car';
         testCar.Acquisition_Date__c = Date.today();
         testCar.Engine__c = testE.Id;
         testCar.Currency__c = 5000;
       	
         insert testCar;
         System.assertEquals(false, [SELECT Id, Currency__c, Is_Expensive__c FROM Car__c WHERE Id =:testCar.Id  LIMIT 1][0].Is_Expensive__c);
		
     }


     @isTest static void isExpensive() {
		 Car__c testCar = [SELECT Id, Name, Currency__c, Is_Expensive__c, Is_New__c FROM Car__c WHERE Name ='TestCar' LIMIT 1];
      	 System.assertEquals(true, testCar.Is_Expensive__c);

     }
    @isTest static void isNewTest (){
  		Engine__c testE = [SELECT Id FROM Engine__c];
        Car__c testCar = new Car__c();
         testCar.Name ='test car';
         testCar.Acquisition_Date__c = date.today();
         testCar.Engine__c = testE.Id;
         testCar.Currency__c = 5000;
       	
         insert testCar;
         System.assertEquals(true, [SELECT Id, Currency__c, Is_Expensive__c, Is_new__c FROM Car__c WHERE Id =:testCar.Id  LIMIT 1][0].Is_new__c);
		
     }  

     @isTest static void bulkTestingNegative() {
         Engine__c testEngine = [SELECT Id FROM Engine__c];
         List<Car__c> carList = new List<Car__c>();
         for(Integer i=0; i<200; i++){
             Car__c car = new Car__c();
             car.Name = 'TestCar'+i;
             car.Currency__c = 100*i;
             car.Engine__c = testEngine.Id;
             car.Acquisition_Date__c =date.newInstance(2020, 7, 21);
             carList.add(car);
         }
         insert carList;
         
         Car__c carTest = [SELECT Id, Currency__c, Is_Expensive__c, Is_new__c FROM Car__c][1];
         System.assertEquals(false, carTest.Is_Expensive__c);
         System.assertEquals(false, carTest.Is_new__c);
     }
    
    @isTest static void bulkTestingPositive() {
         Engine__c testEngine = [SELECT Id FROM Engine__c];
         List<Car__c> carList = new List<Car__c>();
         for(Integer i=0; i<200; i++){
             Car__c car = new Car__c();
             car.Name = 'TestCar'+i;
             car.Currency__c = 1000*i;
             car.Engine__c = testEngine.Id;
             car.Acquisition_Date__c = date.today();
             carList.add(car);
         }
         insert carList;
         
         Car__c carTest = [SELECT Id, Currency__c, Is_Expensive__c,Is_new__c FROM Car__c][11];
         System.assertEquals(true, carTest.Is_Expensive__c);
       	 System.assertEquals(true, carTest.Is_new__c);
     }
    	
	  

 }
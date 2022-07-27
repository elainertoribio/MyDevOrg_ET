/**
 * Created by MacBookPro on 12/9/20.
 */

 import {LightningElement, wire} from 'lwc';
 import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
 import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
 
 export default class ApplicationMenu extends NavigationMixin(LightningElement) {
 
     currPageName = null;
     isTab0On = 'none';
     isTab1On = 'none';
     isTab2On = 'none';
     isTab3On = 'none';
     isTab4On = 'none';
     isTab5On = 'none';
     isTab6On = 'none';
     isTab7On = 'none';
 
     isTab0Done = false;
     isTab1Done = false;
     isTab2Done = false;
     isTab3Done = false;
     isTab4Done = false;
     isTab5Done = false;
     isTab6Done = false;
     isTab7Done = false;
 
 
     connectedCallback() {
         console.log('--->MENU onload: connectedCallback()');
 
         var appId = null;
         if(document.cookie) {
             appId = document.cookie.replace('applicationId=', '');
         }
 
 
         getApplication({applicationId: appId})
             .then(function(result)
                 {
                     console.log(result);
 
                     if(result != null) {
                         console.log('Program Applied:' + result.Program_Applied__c);
 
                         if (result.Is_Personal_Section_Complete__c == true) this.isTab1Done = true;
                         if (result.Is_Guardian_Info_Complete__c == true) this.isTab2Done = true;
                         if (result.Is_Medical_Info_Complete__c == true) this.isTab3Done = true;
                         if (result.Is_Reference_Section_Complete__c == true) this.isTab4Done = true;
                         //if(result.Is_Short_Answer_Topic_Section_Complete__c == true) this.isTab5Done = true;
                         if (result.Is_Short_Answer_Topic_Section_Complete__c == true) this.isTab6Done = true;
                         if (result.Application_Submitted_date__c != null) this.isTab7Done = true;
                         if (result.Is_Program_Section_Complete__c == true) this.isTab0Done = true;
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
 
             });
 
 
     }
 
     @wire(CurrentPageReference)
     getPageRef(pageRef){
         if (pageRef) {
             console.log(pageRef);
             this.currPageName = pageRef.attributes.name;
             if(this.currPageName == 'Application_Programs__c')
             {
                 this.isTab0On = 'active';
             }
             if(this.currPageName == 'Application_PersonalInfo__c' || this.currPageName == 'Home')
             {
                 this.isTab1On = 'active';
             }
             if(this.currPageName == 'Application_GuardianInfo__c')
             {
                 this.isTab2On = 'active';
             }
             if(this.currPageName == 'Application_MedicalInfo__c')
             {
                 this.isTab3On = 'active';
             }
             if(this.currPageName == 'Application_References__c')
             {
                 this.isTab4On = 'active';
             }
             if(this.currPageName == 'Application_Questionnaire__c')
             {
                 this.isTab5On = 'active';
             }
             if(this.currPageName == 'Application_ShortAnswer__c')
             {
                 this.isTab6On = 'active';
             }
             if(this.currPageName == 'Application_Submit__c')
             {
                 this.isTab7On = 'active';
             }
         }
     }
 
     goToNext() {
         console.log('Click go to guardian info button');
         this[NavigationMixin.Navigate]({
             type:'comm__namedPage',
             attributes: {
                 pageName: 'Application_GuardianInfo__c',
             }
         });
     }
 
 
 }
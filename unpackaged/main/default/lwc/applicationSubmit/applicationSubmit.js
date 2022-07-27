/**
 * Created by MacBookPro on 12/10/20.
 */

 import {LightningElement, api, wire, track} from 'lwc';
 import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
 import getRelationships from '@salesforce/apex/SG_LWC_Application.getRelationShips';
 import submitApplication from '@salesforce/apex/SG_LWC_Application.submitApplication';
 import getStudent from '@salesforce/apex/SG_LWC_Application.getStudentInfo';
 import {ShowToastEvent} from "lightning/platformShowToastEvent";
 
 
 export default class ApplicationSubmit extends LightningElement {
 
     @track isLoading = false;
     @track contactId;
     @track applicationId;
     @track application;
     @track errorMessage;
     @track relationships;
     @track isPersonInfoComplete;
     @track isGuardianInfoComplete;
     @track isMedicalInfoComplete;
     @track isReferencedComplete;
     @track isQuestionnaireComplete;
     @track isShortAnswerComplete;
     @track canSubmit = false;
     @track hasBeenSubmitted = false;
     @track submittedDate;
     goToNext = false;
 
 
     connectedCallback() {
         console.log('--->onload: connectedCallback()');
         console.log('COOKIE: ' + document.cookie);
         var appId = null;
         if(document.cookie) {
             appId = document.cookie.replace('applicationId=', '');
         }
         console.log('APP ID: ' + appId);
 
         getApplication({applicationId:appId})
             .then(function(result)
                 {
                     console.log(result);
 
                     if(result == null)
                     {
                         this.errorMessage = 'Unable to find Application Information.';
                     }
                     else
                     {
                         this.applicationId = result.Id;
                         this.application = result;
                         this.contactId = result.Student__c;
                         console.log('-->contactId:' + this.contactId);
                         console.log('--> Is_Guardian_Info_Complete__c: ' + result.Is_Guardian_Info_Complete__c);
                         console.log('--> Is_Medical_Info_Complete__c: ' + result.Is_Medical_Info_Complete__c);
                         console.log('--> Is_Personal_Section_Complete__c:' + result.Is_Personal_Section_Complete__c	);
                         console.log('--> Is_Reference_Section_Complete__c: ' + result.Is_Reference_Section_Complete__c);
                         console.log('--> Is_Short_Answer_Topic_Section_Complete__c: ' + result.Is_Short_Answer_Topic_Section_Complete__c	);
                         console.log('--> canSubmit: ' + result.Is_Ready_To_Submit__c);
 
                         this.isGuardianInfoComplete = result.Is_Guardian_Info_Complete__c;
                         this.isMedicalInfoComplete = result.Is_Medical_Info_Complete__c;
                         this.isPersonInfoComplete = result.Is_Personal_Section_Complete__c;
                         this.isReferencedComplete = result.Is_Reference_Section_Complete__c;
                         this.isShortAnswerComplete = result.Is_Short_Answer_Topic_Section_Complete__c;
 
                         this.canSubmit = result.Is_Ready_To_Submit__c;
                         if(result.Application_Submitted_date__c != null) {
                             this.hasBeenSubmitted = true;
                             this.submittedDate = result.Application_Submitted_date__c;
                         }
 
 
                     }
                 }
                     .bind(this)
             )
 
         console.log('-->applicationId: ' + appId);
 
         getRelationships({applicationId:appId})
             .then(function (result)
                 {
                     console.log('-->relationships: ' + result);
                     this.relationships = result;
                 }
                     .bind(this)
             ).catch(function (err){
                 console.log('getRelationshpis function >> an error happened');
             })
 
 
 
         console.log('-->canSubmit : ' + this.canSubmit);
     }
 
     handleSubmit(event) {
         console.log('---> handleSubmit()');
         this.isLoading = true;
         var hasError = false;
         var errMsg;
 
         submitApplication({applicationId:this.applicationId})
             .then(function (result)
                 {
                     console.log('-->submit Status: ' + result);
                     if(result == 'Success')
                     {
                         window.open('application-completed', "_self");
                     }
                     else
                     {
                         hasError = true;
                         errMsg = result;
                     }
                 }
 
             )
             .finally(()=>{
                 if(hasError)
                 {
                     const event2 = new ShowToastEvent({
                         title: 'Error',
                         message: errMsg,
                         variant: 'error',
                         mode: 'dismissable'
                     });
                     this.dispatchEvent(event2);
                 }
                 this.isLoading = false;
             });
 
     }
 
 
 
 }
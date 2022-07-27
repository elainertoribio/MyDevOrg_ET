/**
 * Created by MacBookPro on 12/10/20.
 */


 import {LightningElement, api, wire, track} from 'lwc';
 import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
 import { getObjectInfo } from 'lightning/uiObjectInfoApi';
 import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
 import {ShowToastEvent} from "lightning/platformShowToastEvent";
 
 export default class ApplicationMedicalInfo extends LightningElement {
 
     @track isLoading = false;
     @track applicationId;
     @track errorMessage;
     @track submittedDate;
     @track hasBeenSubmitted = false;
     @track isEditable = true;
 
     goToNext = false;
 
     connectedCallback() {
         console.log('--->onload medical info: connectedCallback()');
 
         console.log('MED FORM COOKIE: ' + document.cookie);
 
         var appId = null;
         if(document.cookie) {
             appId = document.cookie.replace('applicationId=', '');
         }
 
         console.log('MED INFO APP ID: ' + appId);
 
         getApplication({applicationId:appId})
             .then(function(result)
                 {
                     console.log('MedicalInfo Application:');
                     console.log(result);
 
                     if(result == null)
                     {
                         this.errorMessage = 'Unable to find Application Information.';
                     }
                     else
                     {
                         console.log('ID: ' + result.Id);
                         console.log('SUBMITTED DATE: ' + result.Application_Submitted_date__c);
                         this.applicationId = result.Id;
 
                         this.submittedDate = result.Application_Submitted_date__c;
                         if(result.Application_Submitted_date__c != null)
                         {
                             console.log('SUBMITTED');
                             this.hasBeenSubmitted = true;
                             this.isEditable = false;
                         }
                     }
                 }
                     .bind(this)
             )
     }
 
     doGoBack()
     {
         window.open('application-guardianinfo', "_self");
     }
 
     doSaveAndNext()
     {
         this.goToNext = true;
         this.isLoading = true;
         this.template.querySelector('lightning-record-edit-form').submit();
 
     }
 
     handleSubmit(event) {
         console.log('---> handleSubmit()');
         this.isLoading = true;
 
         //event.preventDefault();
         //const fields = event.detail.fields;
         //console.log(fields);
 
         //this.template.querySelector('lightning-record-edit-form').submit(fields);
     }
 
     handleError(event) {
         console.log('error');
         this.isLoading = false;
         this.goToNext = false;
     }
 
     handleSuccess(event) {
         console.log('success');
 
         if(this.goToNext == true) {
             window.open('application-shortanswer', "_self");
         }
 
         this.isLoading = false;
 
         const event2 = new ShowToastEvent({
             title: 'Save Successful',
             message: 'Application Saved.',
             variant: 'success',
             mode: 'dismissable'
         });
         this.dispatchEvent(event2);
 
 
     }
 
 }
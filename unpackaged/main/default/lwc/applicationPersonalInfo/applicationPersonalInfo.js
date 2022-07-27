/**
 * Created by MacBookPro on 12/7/20.
 */

 import {LightningElement, api, wire, track} from 'lwc';
 import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
 import getStudent from '@salesforce/apex/SG_LWC_Application.getStudentInfo';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
 import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
 
 
 export default class ApplicationPersonalInfo extends NavigationMixin(LightningElement)
 {
     @track isLoading = false;
     @track applicationId;
     @track contactId;
     @track accountId;
     @track errorMessage;
     @track isNoUSAddress = 'Yes';
     @track showUSAddress = true;
     @track showNoUSAddress = false;
     @track hasError = false;
     @track submittedDate;
     @track hasBeenSubmitted = false;
     @track isEditable = true;
     goToNext = false;
 
     get options() {
         return [
             { label: 'Yes', value: 'Yes' },
             { label: 'No', value: 'No' },
         ];
     }
 
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
                     //console.log('application id:' + result.id);
 
                     if(result == null)
                     {
                         this.errorMessage = 'Unable to find Application Information.';
                     }
                     else
                     {
                         console.log('Date Application Submitted: ' + result.Application_Submitted_date__c)
 
                         this.submittedDate = result.Application_Submitted_date__c;
                         if(result.Application_Submitted_date__c != null)
                         {
                             this.hasBeenSubmitted = true;
                             this.isEditable = false;
                             //window.open('onboarding-application', "_self");
                         }
 
                         //if(result.Application_Submitted_date__c != null)
                         //{
                             //window.open('onboarding-application', "_self");
                         //}
                         this.applicationId = result.Id;
                     }
                 }
                     .bind(this)
             )
 
         getStudent()
             .then(function(result)
                 {
                     console.log(result);
 
                     if(result == null)
                     {
                         this.errorMessage = 'Unable to find Student Information.';
                     }
                     else
                     {
                         this.contactId = result.Id;
 
                     }
                 }
                     .bind(this)
         )
     }
 
     handleChange(event) {
         //console.log('handleFieldChange()');
         var value = event.target.value;
         console.log('Apply Values for ' + event.target.name + ': ' + value);
         if(value == 'Yes')
         {
             this.showUSAddress = true;
             this.showNoUSAddress = false;
         }
         else
         {
             this.showNoUSAddress = true;
             this.showUSAddress = false;
         }
 
         console.log('showNoUSAddress : ' + this.showNoUSAddress);
         console.log('showUSAddress : ' + this.showUSAddress);
     }
 
 
     saveAndNext(event) {
         console.log('--->saveAndNext()');
 
         this.goToNext = true;
 
         event.preventDefault();
         const fields = event.detail.fields;
         console.log('--->fields : ' + fields);
 
         this.isLoading = true;
 
         // save contact
         console.log('-->save student');
         this.template.querySelector( ".contactform" ).submit();
 
         // save application
         console.log('-->save application');
         this.template.querySelector( ".applicantform" ).submit();

         this.template.querySelector( ".contactform2" ).submit();
 
 
     }
 
     handleNext() {
         window.open('application-programs', "_self");
     }
 
     handleSubmit2(event){
         console.log('---> handleSubmit2()');
         this.isLoading = true;
         this.goToNext = false;
         this.hasError = false;
 
         // save contact
         console.log('-->save student');
         this.template.querySelector( ".contactform" ).submit();
 
         // save application
         console.log('-->save application');
         this.template.querySelector( ".applicantform" ).submit();

         this.template.querySelector(".contactform2").submit();
     }
 
     handleSubmit(event) {
         console.log('---> handleSubmit()');
         this.isLoading = true;
         this.goToNext = false;
         this.hasError = false;
 
         event.preventDefault();
         //const fields = event.detail.fields;
         //console.log(fields);
 
         // save data
         //this.template.querySelector('lightning-record-edit-form').submit(fields);
 
     }
 
     handleError(event) {
         console.log('error');
         this.isLoading = false;
         this.hasError = true;
 
         const event2 = new ShowToastEvent({
             title: 'Error',
             message: 'An error occurred.',
             variant: 'error',
             mode: 'dismissable'
         });
         this.dispatchEvent(event2);
 
     }
 
     handleSuccess(event) {
         console.log('success');
 
         if(this.goToNext == true) {
             window.open('application-programs', "_self");
         }
 
         this.isLoading = false;
 
         if(this.hasError == false) {
             const event2 = new ShowToastEvent({
                 title: 'Save Successful',
                 message: 'Application Saved.',
                 variant: 'success',
                 mode: 'dismissable'
             });
             this.dispatchEvent(event2);
         }
     }
 
 }
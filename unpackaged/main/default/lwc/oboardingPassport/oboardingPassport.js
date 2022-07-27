/**
 * Created by MacBookPro on 1/6/21.
 */

 import {LightningElement, api, wire, track} from 'lwc';
 import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
 
 export default class OboardingPassport extends LightningElement {
 
     @track applicationId;
     @track isPassportScanApproved = false;
     @track isPassportScanReceived = false;
     @track isVisaScanReceived = false;
     @track isVisaScanApproved = false;
     @track isPassportScanPending = true;
     @track isVisaScanPending = true;
     minimumPassportValidity = '11/10/2022';
     hasPassportComments = false;
     hasVisaComments = false;
 
     get acceptedFormats() {
         return ['.pdf', '.png', '.jpg', '.gif', '.doc', 'docx'];
     }
 
     connectedCallback() {
         console.log('--->onload onboardingPassport: connectedCallback()');
 
         console.log('PASSPORT FORM COOKIE: ' + document.cookie);
         
         var appId = null;
         if(document.cookie) {
             appId = document.cookie.replace('applicationId=', '');
         }
 
         console.log('PASSPORT APP ID: ' + appId);
 
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
                         console.log('-->applicationId: ' + this.applicationId);
                         this.isPassportScanApproved = result.Passport_Scan_Approved__c;
                         this.isPassportScanReceived = result.Passport_Scan_Received__c;
                         this.isVisaScanApproved = result.Visa_Scan_Approved__c;
                         this.isVisaScanReceived = result.Visa_Scan_Received__c	;
                         this.minimumPassportValidity = result.Minimum_Passport_Validity__c;
                         if(this.isPassportScanReceived == true)
                         {
                             this.isPassportScanPending = false;
                         }
                         else
                         {
                             this.isPassportScanPending = true;
                         }
                         if(this.isPassportScanApproved == true)
                         {
                             this.isPassportScanPending = false;
                             this.isPassportScanReceived = false;
                         }
 
                         if(this.isVisaScanReceived == true)
                         {
                             this.isVisaScanPending = false;
                         }
                         else
                         {
                             this.isVisaScanPending = true;
                         }
                         if(this.isVisaScanApproved == true)
                         {
                             this.isVisaScanPending = false;
                             this.isVisaScanReceived = false;
                         }
 
 
                         console.log('this.isPassportScanPending: ' + this.isPassportScanPending);
                         console.log('this.isPassportScanReceived: ' + this.isPassportScanReceived);
                         console.log('this.isPassportScanPending: ' + this.isPassportScanApproved);
                         console.log('this.isPassportScanApproved: ' + this.isVisaScanApproved);
                         console.log('this.isVisaScanReceived: ' + this.isVisaScanReceived);
                         console.log('this.isVisaScanApproved: ' + this.isVisaScanApproved);
 
                         if(result.Passport_Comments_To_Applicant__c != null)
                         {
                             this.hasPassportComments = true;
                         }
                         if(result.Visa_Comments_To_Applicant__c != null)
                         {
                             this.hasVisaComments = true;
                         }
                     }
                 }
                     .bind(this)
             )
     }
 
     handleUploadFinished(event) {
         // Get the list of uploaded files
         const uploadedFiles = event.detail.files;
         console.log("No. of files uploaded : " + uploadedFiles.length);
 
 
     }
 
 }
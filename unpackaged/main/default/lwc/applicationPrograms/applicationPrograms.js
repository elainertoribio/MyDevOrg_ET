/**
 * Created by MacBookPro on 1/19/21.
 */

 import {LightningElement, track, api, wire} from 'lwc';
 import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
 import getSemesters from '@salesforce/apex/SG_LWC_Apply.getSemesters';
 import getProgramsBySession from '@salesforce/apex/SG_LWC_Apply.getProgramsBySession';
 import saveSessions from '@salesforce/apex/SG_LWC_Application.updatePrograms';
 import { updateRecord } from 'lightning/uiRecordApi';
 //import getProgramTypes from '@salesforce/apex/SG_LWC_Application.getProgramTypes';
 //import getPrograms from '@salesforce/apex/SG_LWC_Application.getPrograms';
 //import getSessions from '@salesforce/apex/SG_LWC_Application.getSessions';
 
 export default class ApplicationPrograms extends LightningElement {
     @track applicationId;
 
     @track canEditProgram = false;
     @track canEditBackup = true;
     @track canEditBackup2 = true;
     @track isViewOnlyProgram = true;
     @track isViewOnlyBackup = true;
     @track isViewOnlyBackup2 = true;
 
     @track canShowSaveButton = false;
 
     @track optionsProgram = [];
     @track optionsProgramBackup = [];
     @track optionsProgramBackup2 = [];
 
     @track optionsSession = [];
     @track optionsSessionBackup = [];
     @track optionsSessionBackup2 = [];
 
     @track semester;
     @track semesterBackup;
     @track semesterBackup2;
 
     @track session;
     @track sessionBackup;
     @track sessionBackup2;
 
     @track submittedDate;
     @track hasBeenSubmitted = false;
     @track isEditable = true;
 
 
     @track isLoading = false;
     @track show2ndChoices = true;
     @track goToNextPage = false;
 
     connectedCallback() {
         console.log('--->onload APPLICATION PROGRAM: connectedCallback()');
         console.log('COOKIE: ' + document.cookie);
         var appId = null;
         if(document.cookie) {
             appId = document.cookie.replace('applicationId=', '');
         }
         console.log('APP ID: ' + appId);
 
         getApplication({applicationId:appId})
             .then(function(result)
                 {
                     //console.log(result);
 
                     if(result == null)
                     {
                         console.log('-->error');
                         this.errorMessage = 'Unable to find Application Information.';
                     }
                     else
                     {
                         this.applicationId = result.Id;
                         this.sessionBackup = result.Backup_Session__c;
                         this.sessionBackup2 = result.X3rd_Choice_Program__c;
 
                         if(result.Only_Interested_in_1st_Choice_Program__c == true)
                         {
                             this.show2ndChoices = false;
                         }
 
                         if(result.Program_Session_Semester__c != null)
                         {
                             this.semester = result.Program_Session_Semester__c;
                             this.session = result.Program_Applied__c;
                             getProgramsBySession({session: this.semester})
                                 .then(function(result)
                                     {
                                         console.log(result);
                                         this.optionsProgram = [];
                                         for(const list of result)
                                         {
                                             const option = {label: list.Program_Session_Display__c, value: list.Id};
                                             this.optionsProgram.push(option);
                                         }
                                     }
                                         .bind(this)
                                 )
                         }
 
                         if(result.X2nd_Choice_Program_Session_Semester__c != null)
                         {
                             this.semesterBackup = result.X2nd_Choice_Program_Session_Semester__c;
                             getProgramsBySession({session: this.semesterBackup})
                                 .then(function(result)
                                     {
                                         console.log(result);
                                         this.optionsProgramBackup = [];
                                         for(const list of result)
                                         {
                                             const option = {label: list.Program_Session_Display__c, value: list.Id};
                                             this.optionsProgramBackup.push(option);
                                         }
                                     }
                                         .bind(this)
                                 )
                         }
 
                         if(result.X3rd_Choice_Program_Session_Semester__c != null)
                         {
                             this.semesterBackup2 = result.X3rd_Choice_Program_Session_Semester__c;
                             getProgramsBySession({session: this.semesterBackup2})
                                 .then(function(result)
                                     {
                                         console.log(result);
                                         this.optionsProgramBackup2 = [];
                                         for(const list of result)
                                         {
                                             const option = {label: list.Program_Session_Display__c, value: list.Id};
                                             this.optionsProgramBackup2.push(option);
                                         }
                                     }
                                         .bind(this)
                                 )
                         }
 
                         if(result.Application_Submitted_date__c != null)
                         {
                             this.hasBeenSubmitted = true;
                             this.isEditable = false;
                         }
                     }
                 }
                     .bind(this)
             )
 
         getSemesters()
             .then(function(result)
                 {
                     console.log('--get semesters');
                     console.log(result);
 
                     if(result == null)
                     {
                         this.errorMessage = 'Unable to find Sessions';
                     }
                     else
                     {
                         this.optionsSession = [];
                         this.optionsSessionBackup = [];
                         result.forEach(element => {
                             const option = {label: element, value: element};
                             this.optionsSession.push(option);
                             this.optionsSessionBackup.push(option);
                             this.optionsSessionBackup2.push(option);
                         });
 
 
                     }
                 }
                     .bind(this)
             )
     }
 
     handleEditProgram(){
         console.log('-->> handleEditProgram');
         this.isViewOnlyProgram = false;
         this.canEditProgram = true;
         this.canShowSaveButton = true;
     }
 
     handleEditBackup(){
         this.sessionBackup = null;
         this.isViewOnlyBackup = false;
         this.canEditBackup = true;
         this.canShowSaveButton = true;
     }
 
     handleEditBackup2(){
         this.sessionBackup2 = null;
         this.isViewOnlyBackup2 = false;
         this.canEditBackup2 = true;
         this.canShowSaveButton = true;
     }
 
     goBack() {
         window.open('application-personalinfo', "_self");
     }
 
 
     handleChange_Semester(event) {
         this.isLoading = true;
         console.log('-->do Semester Change handleChange()');
         console.log(event.target.value);
         getProgramsBySession({session: event.target.value})
             .then(function(result)
                 {
                     console.log(result);
                     this.optionsProgram = [];
                     for(const list of result)
                     {
                         const option = {label: list.Program_Session_Display__c, value: list.Id};
                         this.optionsProgram.push(option);
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
 
     }
 
     handleChange_SemesterBackup(event) {
         this.isLoading = true;
         console.log('-->do Semester Backup Change handleChange()');
         console.log(event.target.value);
         getProgramsBySession({session: event.target.value})
             .then(function(result)
                 {
                     console.log(result);
                     this.optionsProgramBackup = [];
                     for(const list of result)
                     {
                         const option = {label: list.Program_Session_Display__c, value: list.Id};
                         this.optionsProgramBackup.push(option);
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
 
     }
 
     handleChange_SemesterBackup2(event) {
         this.isLoading = true;
         console.log('-->do Semester Backup2 Change handleChange()');
         console.log(event.target.value);
         getProgramsBySession({session: event.target.value})
             .then(function(result)
                 {
                     console.log(result);
                     this.optionsProgramBackup2 = [];
                     for(const list of result)
                     {
                         const option = {label: list.Program_Session_Display__c, value: list.Id};
                         this.optionsProgramBackup2.push(option);
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
 
     }
 
     handleSaveAndNext() {
         this.goToNextPage = true;
         this.handleSaveChanges();
     }
 
 
     handleSaveChanges() {
         console.log('SAVE CHANGES');
         this.isLoading = true;
         this.template.querySelector( ".appform" ).submit();
 
         saveSessions({applicationId: this.applicationId, session:this.session, sessionBackup:this.sessionBackup, sessionBackup2:this.sessionBackup2} )
             .then(function(result)
                 {
                     console.log(result);
 
                     if(result == null)
                     {
                         console.log('-->error');
                         this.errorMessage = 'An Error has occurred.';
                     }
                     else
                     {
                         if(result == 'SUCCESS')
                         {
                             this.canEditProgram = false;
                             this.canEditBackup = false;
                             this.canEditBackup2 = false;
                             this.isViewOnlyProgram = true;
                             this.isViewOnlyBackup = true;
                             this.isViewOnlyBackup2 = true;
 
                             this.canShowSaveButton = false;
                             updateRecord({fields: { Id: this.applicationId }});
                             if(this.goToNextPage) {
                                 window.open('application-guardianinfo', "_self");
                             }
                         }
                         else
                         {
                             this.errorMessage = result;
                         }
                     }
                 }
                     .bind(this)
             )
             .catch(error => {
                 console.error('**** error **** \n ',error)
             })
             .finally(()=>{
                 this.isLoading = false;
             });
     }
 
     handle2ndChoiceChange(event) {
         var value = event.target.value;
         console.log('Do Not Show 2nd Choices: ' + value);
 
         this.show2ndChoices = value;
     }
 
     handleFieldChange(event) {
         //console.log('handleFieldChange()');
         var value = event.target.value;
         console.log('Apply Values for ' + event.target.name + ': ' + value);
 
         switch (event.target.name)
         {
             case "semester":
                 this.semester = value;
                 break;
             case "semesterBackup":
                 this.semester = value;
                 break;
             case "semesterBackup2":
                 this.semester2 = value;
                 break;
             case "session":
                 this.session = value;
                 break;
             case "sessionBackup":
                 this.sessionBackup = value;
                 break;
             case "sessionBackup2":
                 this.sessionBackup2 = value;
                 break;
             default:
             //
         }
     }
 
     /*
 
     handleProgramChangeBackup(event) {
         this.isLoading = true;
         console.log(event.target.value);
         getSessions({programId: event.target.value})
             .then(function (result)
                 {
                     console.log(result);
                     this.optionsDate = [];
                     var firstResult;
 
                     for(const list of result)
                     {
                         const option = {label: list.Program_Session_Display__c, value: list.Id};
                         this.optionsDate.push(option);
                         firstResult = list.Id;
                     }
 
                     if(result.size == 1)
                     {
                         this.sessionBackup = firstResult;
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
 
 
     }
 
     handleChangeBackup(event) {
         this.isLoading = true;
         console.log('-->do Program Type Change handleChange()');
         console.log(event.target.value);
         getPrograms({programType: event.target.value})
             .then(function(result)
                 {
                     console.log(result);
                     this.optionsProgram = [];
                     this.optionsDate = [];
                     for(const list of result)
                     {
                         const option = {label: list.Name, value: list.Id};
                         this.optionsProgram.push(option);
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
 
     }
 
     handleProgramChange(event) {
         this.isLoading = true;
         console.log(event.target.value);
         getSessions({programId: event.target.value})
             .then(function (result)
                 {
                     console.log(result);
                     this.optionsDate = [];
                     var firstResult;
 
                     for(const list of result)
                     {
                         const option = {label: list.Program_Session_Display__c, value: list.Id};
                         this.optionsDate.push(option);
                         firstResult = list.Id;
                     }
 
                     if(result.size == 1)
                     {
                         this.session = firstResult;
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
 
 
     }
 
     handleChange(event) {
         this.isLoading = true;
         console.log('-->do Program Type Change handleChange()');
         console.log(event.target.value);
         getPrograms({programType: event.target.value})
             .then(function(result)
                 {
                     console.log(result);
                     this.optionsProgram = [];
                     this.optionsDate = [];
                     for(const list of result)
                     {
                         const option = {label: list.Name, value: list.Id};
                         this.optionsProgram.push(option);
                     }
                 }
                     .bind(this)
             )
             .finally(()=>{
                 this.isLoading = false;
             });
     }
 
      */
 
 }
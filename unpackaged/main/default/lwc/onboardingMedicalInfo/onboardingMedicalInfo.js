/**
 * Created by MacBookPro on 1/6/21.
 */

import {LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import { updateRecord } from 'lightning/uiRecordApi';



export default class OnboardingMedicalInfo extends LightningElement {

    doctorMedicalFormApproved;
    applicationId;
    studentMedicalFormRec;
    studentMedicalFormApproved;
    doctorMedicalFormRec;
    studentMedicalFormPending;
    doctorMedicalFormPending;
    liabilityFormPending;
    liabilityFormRec;
    liabilityFormApproved;
    courseWellnessPlanPending;
    courseWellnessPlanRec;
    courseWellnessPlanApproved;
    immunizationRecordPending;
    immunizationRecordRec;
    immunizationRecordApproved;
    medicationWorksheetPending;
    medicationWorksheetRec;
    medicationWorksheetApproved;
    covidCertificatePending; 
    covidCertificateRec;
    covidCertificateApproved;
    studentName; 

    hasMedicalFormComments = false;
    hasReqFormComments = false;


    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.gif', '.doc', 'docx'];
    }


    connectedCallback() {
        console.log('--->onload onboardingPassport: connectedCallback()');

        console.log('MED FORM COOKIE: ' + document.cookie);

        var appId = null;
        if(document.cookie) {
            appId = document.cookie.replace('applicationId=', '');
        }

        console.log('MEDFORM APP ID: ' + appId);

        getApplication({applicationId:appId})
            .then(function (result) {
                    console.log(result);

                    if (result == null) {
                        this.errorMessage = 'Unable to find Application Information.';
                    } else {
                        this.applicationId = result.Id;
                        console.log('Student_Medical_Form_Received__c: ' + result.Student_Medical_Form_Received__c);
                        console.log('Doctor_Medical_Form_Received__c: ' + result.Doctor_Medical_Form_Received__c);
                        console.log('Mental_Health_Form_Received__c: ' + result.Mental_Health_Form_Received__c);

                        this.studentName = result.Student__r.Full_Name__c;

                        this.studentMedicalFormRec = result.Student_Medical_Form_Received__c;
                        this.studentMedicalFormApproved = result.Student_Medical_Form_Approved__c;
                        this.doctorMedicalFormRec = result.Doctor_Medical_Form_Received__c;
                        this.doctorMedicalFormApproved = result.Doctor_Medical_Form_Approved__c;
                        this.redRuleFormRec = result.Red_Rules_Contract_Received__c;
                        this.redRuleFormApproved = result.Red_Rules_Contract_Approved__c;
                        this.liabilityFormRec = result.Liability_Form_Received__c;
                        this.liabilityFormApproved = result.Liability_Form_Approved__c;
                        this.courseWellnessPlanRec = result.Course_Wellness_Plan_Received__c;
                        this.courseWellnessPlanApproved = result.Course_Wellness_Plan_Approved__c;
                        this.immunizationRecordRec = result.Immunization_Record_Received__c;
                        this.immunizationRecordApproved = result.Immunization_Record_Approved__c;
                        this.medicationWorksheetRec = result.Medication_Worksheet_Received__c;
                        this.medicationWorksheetApproved = result.Medication_Worksheet_Approved__c;
                        this.covidCertificateRec = result.COVID_19_Certificate_Received__c;
                        this.covidCertificateApproved = result.COVID_19_Certificate_Approved__c;
                        

                        this.studentMedicalFormRec ? this.studentMedicalFormPending = false : this.studentMedicalFormPending = true;
                        this.doctorMedicalFormRec ? this.doctorMedicalFormPending = false: this.doctorMedicalFormPending = true;
                        this.liabilityFormRec ? this.liabilityFormPending = false: this.liabilityFormPending = true;
                        this.courseWellnessPlanRec ? this.courseWellnessPlanPending = false : this.courseWellnessPlanPending = true;
                        this.immunizationRecordRec ? this.immunizationRecordPending = false : this.immunizationRecordPending = true;
                        this.medicationWorksheetRec ? this.medicationWorksheetPending = false : this.medicationWorksheetPending = true;
                        this.covidCertificateRec ? this.covidCertificatePending = false : this.courseWellnessPlanPending = true;


                        if(this.studentMedicalFormApproved) this.studentMedicalFormRec = false;
                        if(this.doctorMedicalFormApproved) this.doctorMedicalFormRec = false;
                        if(this.liabilityFormApproved) this.liabilityFormRec = false;
                        if(this.courseWellnessPlanApproved) this.courseWellnessPlanRec = false;
                        if(this.covidCertificateApproved) this.covidCertificateRec = false;
                        if(this.immunizationRecordApproved) this.immunizationRecordRec = false;
                        if(this.medicationWorksheetApproved) this.medicationWorksheetRec =false;

                        if(result.Medical_Forms_Comments_To_Applicant__c != null)
                        {
                            this.hasMedicalFormComments = true;
                        }
                        if(result.Required_Forms_Comments_To_Applicant__c != null)
                        {
                            this.hasReqFormComments = true;
                        }


                    }
                }
                    .bind(this)
            )


    }

    get fileNameLiabilityForm(){
        return `${this.studentName} - Liability Form`               
    }

    get fileNameCourseWellness(){
        return `${this.studentName} - Course Wellness Plan`                     
    }
    get fileNameImmunizatioRecord(){
        return `${this.studentName} - Immunization Record`                       
    }
    get fileNameMedicationWorksheet(){
        return `${this.studentName} - Medication Worksheet`                       
    }

    get fileNameCovidVaccination(){
        return `${this.studentName} - COVID-19 Vaccination Certificate`                      
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.showToast();
        console.log("No. of files uploaded : " + uploadedFiles.length);
        console.log("File Name : " + uploadedFiles.item(0).name);
        
        updateRecord({fields: this.applicationId});
       
    }
    
    showToast() {
        const event = new ShowToastEvent({
            title: 'Document received!',
            variant: 'Success',
            message:
                'We will contact you if we have any questions.',
        });
        this.dispatchEvent(event);
    }
    

}
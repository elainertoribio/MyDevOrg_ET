/**
 * Created by MacBookPro on 1/6/21.
 */

import {LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import { updateRecord } from 'lightning/uiRecordApi';



export default class OnboardingMedicalInfo extends LightningElement {

    @track applicationId;
    @track studentMedicalFormRec;
    @track studentMedicalFormApproved;
    @track doctorMedicalFormRec;
    @track doctorMedicalFormApproved;
    @track studentMedicalFormPending;
    @track doctorMedicalFormPending;
    @track redRuleFormPending = true;
    @track redRuleFormRec;
    @track redRuleFormApproved;
    @track liabilityFormPending;
    @track liabilityFormRec;
    @track liabilityFormApproved;

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

                        this.studentMedicalFormRec = result.Student_Medical_Form_Received__c;
                        this.studentMedicalFormApproved = result.Student_Medical_Form_Approved__c;
                        this.doctorMedicalFormRec = result.Doctor_Medical_Form_Received__c;
                        this.doctorMedicalFormApproved = result.Doctor_Medical_Form_Approved__c;
                        this.redRuleFormRec = result.Red_Rules_Contract_Received__c;
                        this.redRuleFormApproved = result.Red_Rules_Contract_Approved__c;
                        this.liabilityFormRec = result.Liability_Form_Received__c;
                        this.liabilityFormApproved = result.Liability_Form_Approved__c;
                        if(this.studentMedicalFormRec == true)
                        {
                            this.studentMedicalFormPending = false;
                        }
                        else
                        {
                            this.studentMedicalFormPending = true;
                        }

                        if(this.doctorMedicalFormRec == true)
                        {
                            this.doctorMedicalFormPending = false;
                        }
                        else
                        {
                            this.doctorMedicalFormPending = true;
                        }

                        if(this.redRuleFormRec == true)
                        {
                            this.redRuleFormPending = false;
                        }
                        else
                        {
                            this.redRuleFormPending = true;
                        }

                        if(this.liabilityFormRec == true)
                        {
                            this.liabilityFormPending = false;
                        }
                        else
                        {
                            this.liabilityFormPending = true;
                        }


                        if(this.studentMedicalFormApproved) this.studentMedicalFormRec = false;
                        if(this.doctorMedicalFormApproved) this.doctorMedicalFormRec = false;
                        if(this.redRuleFormApproved) this.redRuleFormRec = false;
                        if(this.liabilityFormApproved) this.liabilityFormRec = false;

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
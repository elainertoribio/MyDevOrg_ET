/**
 * Created by MacBookPro on 12/10/20.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import processShortAnswer from '@salesforce/apex/SG_LWC_Application.shortAnswerComplete';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class ApplicationShortAnswer extends LightningElement
{

    @track isLoading = false;
    @track applicationId;
    @track errorMessage;
    goToNext = false;
    @track submittedDate;
    @track hasBeenSubmitted = false;
    @track isEditable = true;

    connectedCallback() {
        console.log('--->onload: connectedCallback()');
        console.log('SHORT ANSWER COOKIE: ' + document.cookie);

        var appId = null;
        if(document.cookie) {
            appId = document.cookie.replace('applicationId=', '');
        }

        console.log('SHORT ANSWER APP ID: ' + appId);

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
        window.open('application-medicalinfo', "_self");
    }

    doSaveAndNext()
    {
        this.isLoading = true;
        this.goToNext = true;
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSubmit(event) {
        console.log('---> handleSubmit()');
        this.isLoading = true;

    }

    handleError(event) {
        console.log('error');
        this.isLoading = false;
        this.goToNext = false;
    }

    handleSuccess(event) {
        console.log('success');
        if(this.goToNext == true) {
            //window.open('application-references', "_self");
            // 10/21/2021: do not go to Teacher Reference, but Submit Application
            window.open('application-submit', "_self");
        }

        this.isLoading = false;
        this.goToNext = false;

        const event2 = new ShowToastEvent({
            title: 'Save Successful',
            message: 'Application Saved.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event2);

    }


}
/**
 * Created by MacBookPro on 12/10/20.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class ApplicationQuestionairre extends LightningElement
{
    @track isLoading = false;
    @track applicationId;
    @track errorMessage;
    goToNext = false;

    connectedCallback() {
        console.log('--->onload: connectedCallback()');

        getApplication()
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
                    }
                }
                    .bind(this)
            )
    }

    doGoBack()
    {
        window.open('application-references', "_self");
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
            window.open('application-shortanswer', "_self");
        }

        this.isLoading = false;
        this.goToNext = false;
    }

}
/**
 * Created by MacBookPro on 2/1/21.
 */

import {LightningElement, api, wire, track} from 'lwc';

import getApplications from '@salesforce/apex/SG_LWC_Application.getApplications';
import createApplication from '@salesforce/apex/SG_LWC_Application.createNewApplication';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class ApplicationList extends LightningElement {

    @track applications;
    @track isLoading = false;
    @track submittedDate;

    connectedCallback() {
        this.isLoading = true;
        console.log('--->onload: connectedCallback()');

        getApplications()
            .then(function(result)
                {
                    console.log(result);

                    this.applications = result;
                }
                    .bind(this)
            )
            .finally(()=>{
                this.isLoading = false;
            });
    }

    viewApplication(event) {

        console.log(event.target.name);
        console.log(event.target.value);
        var appId = event.target.name;
        var stage = event.target.value;

        document.cookie = 'applicationId=;Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
        console.log('cookies blank: ' + document.cookie);

        document.cookie = 'applicationId=' + appId + ";path=/";
        console.log('cookies applicationId: '  + document.cookie);

        if(stage == 'Application'){
            window.open('application-personalinfo', "_self");
        } else if(stage == 'Pre-Course Prep') {
            window.open('onboarding-application', "_self");
        } else {
            window.open('admissions-myapplication', "_self");
        }


    }

    createApp()
    {
        window.open('application-apply', "_self");
    }






}
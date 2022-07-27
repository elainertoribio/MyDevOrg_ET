/**
 * Created by MacBookPro on 2/11/21.
 */

import {LightningElement, api, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class AdmissionsInterview extends LightningElement {

    @track isLoading = false;
    @track applicationId;
    @track interviewDate;
    @track phone;
    @track isInterviewScheduled = false;
    hasInterviewComments = false;


    connectedCallback() {
        console.log('--->Onboarding-Payments onload: connectedCallback()');
        console.log('COOKIE: ' + document.cookie);
        var appId = null;
        if(document.cookie) {
            appId = document.cookie.replace('applicationId=', '');
        }
        console.log('APP ID: ' + appId);

        getApplication({applicationId:appId})
            .then(function(result)
                {
                    console.log('getApplication()');
                    console.log(result);

                    if(result == null)
                    {
                        console.log('result is null');
                        this.errorMessage = 'Unable to find Application Information.';
                    }
                    else
                    {
                        this.applicationId = result.Id;
                        this.interviewDate = result.Interview_DateTime__c;
                        this.phone = result.Student_Phone__c;
                        if(result.Interview_Comments_To_Applicant__c != null)
                        {
                            this.hasInterviewComments = true;
                        }
                        if(result.Interview_Status__c == 'Interview Scheduled' || result.Interview_Status__c == 'Interview scheduled')
                        {
                            this.isInterviewScheduled = true;
                        }
                    }
                }
                    .bind(this)
            )


    }

}
/**
 * Created by MacBookPro on 1/6/21.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class OnboardingInterview extends LightningElement {

    @track applicationId;
    hasInterviewComments;

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
                        if(result.Interview_Comments_To_Applicant__c != null)
                        {
                            this.hasInterviewComments = true;
                        }
                        else
                        {
                            this.hasInterviewComments = false;
                        }
                        console.log('-->applicationId: ' + this.applicationId);
                        console.log('-->hasInterviewComments: ' + this.hasInterviewComments);

                    }
                }
                    .bind(this)
            )
    }

}
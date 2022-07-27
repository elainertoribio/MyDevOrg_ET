/**
 * Created by MacBookPro on 12/22/20.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import getRelationships from '@salesforce/apex/SG_LWC_Application.getRelationShips';
import getStudent from '@salesforce/apex/SG_LWC_Application.getStudentInfo';

export default class OnboardingApplications extends LightningElement {

    @track isLoading = false;
    @track applicationId;
    @track errorMessage;
    @track relationships;
    contactId;


    connectedCallback() {
        console.log('--->onload: connectedCallback()');

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
                        console.log('-->applicationId: ' + this.applicationId);
                    }
                }
                    .bind(this)
            )


        getRelationships({applicationId:this.applicationId})
            .then(function (result)
                {
                    console.log(result);
                    this.relationships = result;
                }
                    .bind(this)
            )
    }


}
/**
 * Created by MacBookPro on 1/6/21.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class OnboardingReference extends LightningElement {
    @track applicationId;
    hasReferenceNote;

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
                        console.log('-->applicationId: ' + this.applicationId);

                    }
                }
                    .bind(this)
            )
    }
}
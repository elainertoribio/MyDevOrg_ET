import {LightningElement, track, api} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class OnboardingTravel extends LightningElement {

    @track isLoading = false;
    @track applicationId;
    programId;
    departureHub = 'N/A';
    connectingTravelInfoReceived = false;

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
                        this.programId = result.Program_Applied__c;
                        this.departureHub = result.Departure_Hub__c;
                        this.connectingTravelInfoReceived = result.Connecting_Travel_Info_Received__c;
                    }
                }
                    .bind(this)
            )
    }

}
import {LightningElement, api, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class AdmissionsMentalHealth extends LightningElement {
    showMentalHealtTab = false;
    isAwaitingMHF;
    isMHFRecd;
    mhName;
    mhEmail;


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
                        this.mhEmail = result.Mental_Health_Professional_Email__c;
                        this.mhName = result.Mental_Health_Professional_Name__c;
                        if(result.Mental_Health_Form_Status__c == 'Awaiting MHF') {
                            this.isAwaitingMHF = true;
                            this.isMHFRecd = false;
                        }
                        else if(result.Mental_Health_Form_Status__c == 'MHF received')
                        {
                            this.isMHFRecd = true;
                            this.isAwaitingMHF = false;
                        }
                    }
                }
                    .bind(this)
            )


    }

}
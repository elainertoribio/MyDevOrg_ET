import {LightningElement, api, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class AdmissionsProgram extends LightningElement {

    @track isLoading = false;
    @track applicationId;
    @track programApplied;
    @track backupSession;
    @track backup2Session;

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
                        this.programApplied = String(result.Program_Name_formula__c).toLowerCase() ;
                        this.backupSession = String(result.X2nd_Choice_Program_Name__c).toLowerCase();
                        this.backup2Session = String(result.X3rd_Choice_Program_Name__c).toLowerCase();
                    }
                }
                    .bind(this)
            )


    }

}
/**
 * Created by MacBookPro on 2/11/21.
 */

import {LightningElement, api, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class AdmissionsDeposit extends LightningElement {

    @track isLoading = false;
    @track applicationId;
    @track programApplied;
    @track isDepositPending;
    @track isDepositRecd;
    @track depositURL;

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
                        this.programApplied = String(result.Program_Name_formula__c).toLowerCase();
                        this.depositURL = result.Deposit_URL__c;
                        if(result.Deposit_Date__c != null)
                        {
                            this.isDepositPending = false;
                            this.isDepositRecd = true;
                        }
                        else
                        {
                            this.isDepositPending = true;
                            this.isDepositRecd = false;
                        }

                    }
                }
                    .bind(this)
            )
    }

    handlePayDeposit() {
        window.open(this.depositURL, "_self");
    }


}
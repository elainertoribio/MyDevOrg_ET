/**
* Name:     applicationPersonalInformation.hmtl
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     DEC 2020
* ======================================================
* ======================================================
* Purpose: 	Community Menu
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       DEC 2020        GO          Initial Development
*/

import {LightningElement, api, track, wire} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import {CurrentPageReference} from "lightning/navigation";

export default class AdmissionsMenu extends LightningElement {
    @track applicationId;
    isTab0On = 'none';
    isTab1On = 'none';
    isTab2On = 'none';
    isTab3On = 'none';
    isTab4On = 'none';

    showMentalHealthTab = false;
    isAwaitingMHF = true;
    isMHFRecd = false;


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
                        if(result.Mental_Health_Form_Status__c == 'Awaiting MHF' || result.Mental_Health_Form_Status__c == 'MHF received')
                        {
                            this.showMentalHealthTab = true;
                            if(result.Mental_Health_Form_Status__c == 'Awaiting MHF') {
                                this.isAwaitingMHF = true;
                            }
                            else if(result.Mental_Health_Form_Status__c == 'MHF received')
                            {
                                this.isMHFRecd = true;
                            }
                        }
                    }
                }
                    .bind(this)
            )
    }

    @wire(CurrentPageReference)
    getPageRef(pageRef){
        if (pageRef) {
            console.log(pageRef);
            this.currPageName = pageRef.attributes.name;
            if(this.currPageName == 'Admissions_MyApplication__c')
            {
                this.isTab0On = 'active';
            }
            if(this.currPageName == 'Admissions_Program__c')
            {
                this.isTab1On = 'active';
            }
            if(this.currPageName == 'Admissions_Deposit__c')
            {
                this.isTab2On = 'active';
            }
            if(this.currPageName == 'Admissions_Interview__c')
            {
                this.isTab3On = 'active';
            }
            if(this.currPageName == 'Admissions_MentalHealth__c')
            {
                this.isTab4On = 'active';
            }
        }
    }

}
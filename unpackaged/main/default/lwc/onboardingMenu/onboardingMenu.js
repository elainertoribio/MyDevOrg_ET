/**
 * Created by MacBookPro on 12/10/20.
 */

import {LightningElement, wire, api} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';


export default class OnboardingMenu extends LightningElement {

    canViewInterviewTab;
    currPageName = null;
    isTab1On = 'none';
    isTab2On = 'none';
    isTab3On = 'none';
    isTab4On = 'none';
    isTab5On = 'none';
    isTab6On = 'none';
    isTab7On = 'none';
    isTab8On = 'none';

    @wire(CurrentPageReference)
    getPageRef(pageRef){
        if (pageRef) {
            console.log(pageRef);
            this.currPageName = pageRef.attributes.name;
            if(this.currPageName == 'Onboarding_Application__c' || this.currPageName == 'Home')
            {
                this.isTab1On = 'active';
            }
            if(this.currPageName == 'Onboarding_Payments__c')
            {
                this.isTab2On = 'active';
            }
            if(this.currPageName == 'OnboardingInterview__c')
            {
                this.isTab3On = 'active';
            }
            if(this.currPageName == 'Onboarding_References__c')
            {
                this.isTab4On = 'active';
            }
            if(this.currPageName == 'Onboarding_PassportInfo__c')
            {
                this.isTab5On = 'active';
            }
            if(this.currPageName == 'Onboarding_Travel__c')
            {
                this.isTab6On = 'active';
            }
            if(this.currPageName == 'Onboarding_RequiredDocuments__c')
            {
                this.isTab7On = 'active';
            }
            if(this.currPageName == 'Onboarding_Resources__c')
            {
                this.isTab8On = 'active';
            }
        }
    }

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
                        this.canViewInterviewTab = result.Can_View_Interview_Tab__c;
                        console.log('-->applicationId: ' + this.applicationId);
                    }
                }
                    .bind(this)
            )
    }

    goToNext() {
        console.log('Click go to guardian info button');
        this[NavigationMixin.Navigate]({
            type:'comm__namedPage',
            attributes: {
                pageName: 'Application_GuardianInfo__c',
            }
        });
    }

}
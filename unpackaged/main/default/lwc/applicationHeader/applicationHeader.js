/*
* Name:     applicationMenu.js
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

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';

export default class ApplicationHeader extends LightningElement {
    @track isLoading = false;
    @track contactId;
    @track application;
    @track applicationId;
    @track errorMessage;
    @track isApplicationPhase = true;
    @track isPrecoursePhase = false;
    @track title;

    connectedCallback() {
        console.log('--->onload HEADER: connectedCallback()');

        console.log('HEADER COOKIE: ' + document.cookie);

        var appId = null;
        if(document.cookie) {
            appId = document.cookie.replace('applicationId=', '');
        }

        console.log('APP ID: ' + appId);

        getApplication({applicationId: appId})
            .then(function(result)
                {
                    console.log('HEADER RESULT:' + result);

                    if(result == null)
                    {
                        this.errorMessage = 'Unable to find Application Information.';
                    }
                    else
                    {
                        this.applicationId = result.Id;
                        this.contactId = result.Student__c;
                        this.title = result.Community_View__c;
                        if(result.Application_Submitted_date__c != null)
                        {
                            this.isApplicationPhase = false;
                            this.isPrecoursePhase = true;
                        }
                    }
                }
                    .bind(this)
            )
    }
}
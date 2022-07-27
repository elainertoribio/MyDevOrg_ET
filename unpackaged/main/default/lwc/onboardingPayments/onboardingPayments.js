/**
 * Created by MacBookPro on 1/5/21.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import getPayments from '@salesforce/apex/SG_LWC_OnboardingHelper.getPayments';
import getCosts from '@salesforce/apex/SG_LWC_OnboardingHelper.getAdditionalCosts';


export default class OnboardingPayments extends LightningElement {

    @track isLoading = false;
    @track applicationId;
    @track errorMessage;
    @track payments;
    showPaymentComment;
    @track paymentComment;
    @track finalPaymentDueDate;
    @track serviceFee;
    @track costs;


    @track columns = [{
        label: 'Payment Date',
        fieldName: 'Payment_Date__c',
        type: 'Date',
        sortable: true,
        typeAttributes:{
            month: "2-digit",
            day: "2-digit",
            year: "numeric"
        }
    },
        {
            label: 'Description',
            fieldName: 'Name',
            type: 'text',
            sortable: false
        },
        {
            label: 'Payment Amount',
            fieldName: 'Amount__c',
            type: 'Currency',
            sortable: true
        }

    ];


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
                        console.log('result:' + result);
                        this.applicationId = result.Id;
                        if(result.Payment_Comment_To_Applicant__c != null)
                        {
                            this.showPaymentComment = true;
                            this.paymentComment = result.Payment_Comment_To_Applicant__c;
                        }
                        this.finalPaymentDueDate = result.Final_Payment_Due_Date__c;
                        this.serviceFee = result.Program_Payment_Service_Fee__c;

                        console.log('-->applicationId: ' + this.applicationId);
                        console.log('comment:' + this.paymentComment);

                        getPayments({applicationId:this.applicationId})
                            .then(function (result)
                                {
                                    console.log('getPayments()');
                                    this.payments = result;

                                    console.log('-->payments: ' + this.payments);
                                }
                                    .bind(this)
                            )

                        getCosts({applicationId:this.applicationId})
                            .then(function (result)
                                {
                                    console.log('getCosts()');
                                    this.costs = result;

                                    console.log('-->costs: ' + this.costs);
                                }
                                    .bind(this)
                            )

                    }
                }
                    .bind(this)
            )


    }

}
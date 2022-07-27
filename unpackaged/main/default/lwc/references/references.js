/**
 * Created by MacBookPro on 2/9/21.
 */

import {LightningElement, api, wire, track} from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_References.getApplication';
import {ShowToastEvent} from "lightning/platformShowToastEvent";


export default class References extends LightningElement {

    @track appId;
    @track studentName;
    @track teacherName;
    @track programName;
    @track isValidApplicationId = false;
    @track isInvalidApplicationId = true;

    connectedCallback() {
        console.log('REFERENCE connectedCallback()');
        var queryString = window.location.search;
        console.log(queryString);

        const urlParams = new URLSearchParams(queryString);
        this.appId = urlParams.get('appId');

        console.log('this.appId: ' + this.appId);

        if(this.appId != null) {
            getApplication({applicationId: this.appId})
                .then(function(result)
                    {
                        console.log('getApplication()');
                        console.log(result);

                        if(result == null)
                        {
                            console.log('result is null');
                            //this.isInvalidApplicationId = false;
                            //this.isValidApplicationId = true;
                        }
                        else
                        {
                            console.log('result:' + result);
                            this.studentName = result.Student_Name_Formula__c;
                            this.teacherName = result.Teacher_Reference_Name__c;
                            this.programName = result.Program_Name_formula__c;

                            this.isInvalidApplicationId = false;
                            this.isValidApplicationId = true;
                        }
                    }
                        .bind(this)
                )

        }
    }

    handleSubmit() {
        window.open('reference-submitted', "_self");
    }


    handleSuccess(event){
        console.log('SUCCESS');
        /*
        const event2 = new ShowToastEvent({
            title: 'Save Successful',
            message: 'Reference Submitted.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event2);
        */
        window.open('reference-submitted', "_self");
    }

    handleError(event){
        console.log('ERROR');
        /*
        const event2 = new ShowToastEvent({
            title: 'Error',
            message: 'An Error occurred submitting Reference.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event2);
        */
    }

}
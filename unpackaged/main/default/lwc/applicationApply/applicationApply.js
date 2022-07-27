import {LightningElement, track, api, wire} from 'lwc';
import getSemesters from '@salesforce/apex/SG_LWC_Apply.getSemesters';
import getProgramsBySession from '@salesforce/apex/SG_LWC_Apply.getProgramsBySession';
import saveSession from '@salesforce/apex/SG_LWC_Application.applyToNewProgram';
import {updateRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";


export default class ApplicationApply extends LightningElement {
    @track optionsSession;
    @track optionsProgram;
    @track semester;
    @track session;

    @track isLoading = false;

    connectedCallback() {
        console.log('--->onload New Application: connectedCallback()');

        getSemesters()
            .then(function(result)
                {
                    console.log('--get semesters');
                    console.log(result);


                    if(result == null)
                    {
                        this.errorMessage = 'Unable to find Sessions';
                    }
                    else
                    {
                        this.optionsSession = [];

                        result.forEach(element => {
                            const option = {label: element, value: element};
                            this.optionsSession.push(option);
                        });


                    }
                }
                    .bind(this)
            )

    }

    handleChange_Semester(event) {
        this.isLoading = true;
        console.log('-->do Semester Change handleChange()');
        console.log(event.target.value);
        getProgramsBySession({session: event.target.value})
            .then(function(result)
                {
                    console.log(result);
                    this.optionsProgram = [];
                    for(const list of result)
                    {
                        const option = {label: list.Program_Session_Display__c, value: list.Id};
                        this.optionsProgram.push(option);
                        this.isLoading = false;
                    }
                }
                    .bind(this)
            )
            .finally(()=>{
                this.isLoading = false;
            });

    }

    handleFieldChange(event) {
        //console.log('handleFieldChange()');
        var value = event.target.value;
        console.log('Apply Values for ' + event.target.name + ': ' + value);

        switch (event.target.name)
        {
            case "semester":
                this.semester = value;
                break;
            case "session":
                this.session = value;
                break;
            default:
            //
        }
    }

    handleSaveChanges() {
        console.log('SAVE CHANGES');
        this.isLoading = true;


        console.log('SESSION APPLIED: ' + this.session);

        const isSessionSelected = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                //this.isLoading = false;
                return validSoFar && inputField.checkValidity();
            }, true);

        if (!isSessionSelected) {
            this.isLoading = false;
            return;
        }

        saveSession({sessionId:this.session})
            .then(function(result)
                {
                    console.log('APPLICATION ID: ' + result);

                    if(result == null)
                    {
                        console.log('-->error');
                        this.errorMessage = 'An Error has occurred.';
                        this.isLoading = false;
                    }
                    else
                    {
                        if(result.includes('ERROR'))
                        {
                            this.errorMessage = result;
                            const event2 = new ShowToastEvent({
                                title: 'Error',
                                message: result,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event2);
                            this.isLoading = false;
                            //updateRecord({fields: { Id: this.applicationId }});
                        }
                        else
                        {
                            // save successful

                            document.cookie = 'applicationId=;Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
                            document.cookie = 'applciationId=;Expires=Thu, 01 Jan 1970 00:00:01 GMT;';

                            document.cookie = 'applicationId=' + result + ";path=/";

                            window.open('application-personalinfo', "_self");
                        }
                    }
                }
                    .bind(this)
            )

    }

}
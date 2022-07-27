/**
 * Created by MacBookPro on 12/10/20.
 */

import {LightningElement, api, wire, track} from 'lwc';

import registerUser from '@salesforce/apex/SG_LWC_Apply.registerUser';
import getSemesters from '@salesforce/apex/SG_LWC_Apply.getSemesters';
import getProgramsBySession from '@salesforce/apex/SG_LWC_Apply.getProgramsBySession';

//import getPrograms from '@salesforce/apex/SG_LWC_Apply.getPrograms';
//import getSessions from '@salesforce/apex/SG_LWC_Apply.getSessions';
//import getProgramTypes from '@salesforce/apex/SG_LWC_Apply.getProgramTypes';

import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class Apply extends NavigationMixin(LightningElement) {
    @track optionsProgram = [];
    @track optionsDate = [];
    @track firstname;
    @track lastname;
    @track email;
    @track confirmEmail;
    @track password;
    @track confirmPassword;
    @track optionsSession = [];
    @track semester;
    @track session;
    @track errorMessage;
    @track isLoading = false;

    connectedCallback() {
        console.log('-->get Sessions (semesters)');
        getSemesters()
            .then(function(result)
                {
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

    handleFieldChange(event) {
        //console.log('handleFieldChange()');
        var value = event.target.value;
        console.log('Apply Values for ' + event.target.name + ': ' + value);

        switch (event.target.name)
        {
            case "firstname":
                this.firstname = value;
                break;
            case "lastname":
                this.lastname = value;
                break;
            case "email":
                this.email = value;
                break;
            case "confirmEmail":
                this.confirmEmail = value;
                break;
            case "password":
                this.password = value;
                break;
            case "confirmPassword":
                this.confirmPassword = value;
                break;
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


    handleChange_Semester(event) {
        this.isLoading = true;
        console.log('-->do Semester Change handleChange()');
        console.log(event.target.value);
        getProgramsBySession({session: event.target.value})
            .then(function(result)
                {
                    console.log(result);
                    this.optionsProgram = [];
                    //this.optionsDate = [];
                    for(const list of result)
                    {
                        const option = {label: list.Program_Session_Display__c, value: list.Id};
                        this.optionsProgram.push(option);
                    }
                }
                    .bind(this)
            )
            .finally(()=>{
                this.isLoading = false;
            });

    }


    handleSubmit(event) {
        this.isLoading = true;

        console.log('Attempt Submit');

        console.log('firstname: ' + this.firstname);
        console.log('lastname: ' + this.lastname);
        console.log('email: ' + this.email);
        console.log('confirmemail: ' + this.confirmEmail);
        console.log('password: ' + this.password);
        console.log('confirmpassword: ' + this.confirmPassword);
        console.log('session: ' + this.session);

        this.errorMessage = '';

        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        const isSessionSelected = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);


        if (!isInputsCorrect || !isSessionSelected) {
            this.isLoading = false;
            return;
        }



        var hasErrors = false;
        // VALIDATIONS
        if(this.email != this.confirmEmail)
        {
            console.log('Email does not match');
            this.errorMessage += "Email and Confirmation does not match.<br />"
            hasErrors = true;
        }


        if(this.password != this.confirmPassword)
        {
            console.log('Password does not match');
            this.errorMessage += "Password does not match<br />";
            hasErrors = true;
        }

        if(this.password.length < 8)
        {
            console.log('Password Not 8 characters long.');
            this.errorMessage += 'Password must be at least 8 characters and must include alpha and numeric characters.';
            hasErrors = true;
        }


        console.log('Has Errors: ' + hasErrors);

        if(hasErrors)
        {
            // move to top
            scroll(0,0);

            const event2 = new ShowToastEvent({
                title: 'Error',
                message: this.errorMessage,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event2);

            this.isLoading = false;
        }

        if(!hasErrors)
        {
            // no errors... so continue
            console.log("NO ERRORS, so continue");
            console.log('-->session: ' + this.session);
            console.log('-->email: ' + this.email);
            console.log('-->password: ' + this.password);

            // register the user
            registerUser({email:this.email, firstname:this.firstname, lastname:this.lastname, password:this.password, sessionId:this.session})
                .then(function(result)
                    {
                        console.log(result);

                        if(result.includes('Error'))
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
                        }
                        else
                        {
                            console.log('Go to Home Page');
                            window.open(result, "_self");
                        }

                    }
                    .bind(this)
                )
                .finally(()=>{

                });

        }

        //this.isLoading = false;

    }

    /*
    get optionsType() {
        console.log('get program types');
        //console.log(this.programTypes);
        var optionsType = [];

        const option1 = {label: 'Gap', value: 'Gap'};
        const option2 = {label: 'Summer', value: 'Summer'};

        optionsType.push(option1);
        optionsType.push(option2);

        return optionsType;
    }

    handleProgramChange(event) {
        this.isLoading = true;
        console.log(event.target.value);
        getSessions({programId: event.target.value})
            .then(function (result)
                {
                    console.log(result);
                    this.optionsDate = [];
                    var firstResult;

                    for(const list of result)
                    {
                        const option = {label: list.Program_Session_Display__c, value: list.Id};
                        this.optionsDate.push(option);
                        firstResult = list.Id;
                    }

                    if(result.size == 1)
                    {
                        this.session = firstResult;
                    }
                }
                .bind(this)
            )
            .finally(()=>{
                this.isLoading = false;
            });


    }

    handleChange(event) {
        this.isLoading = true;
        console.log('-->do Program Type Change handleChange()');
        console.log(event.target.value);
        getPrograms({programType: event.target.value})
            .then(function(result)
                {
                    console.log(result);
                    this.optionsProgram = [];
                    this.optionsDate = [];
                    for(const list of result)
                    {
                        const option = {label: list.Name, value: list.Id};
                        this.optionsProgram.push(option);
                    }
                }
                .bind(this)
            )
            .finally(()=>{
                this.isLoading = false;
            });

    }
     */
}
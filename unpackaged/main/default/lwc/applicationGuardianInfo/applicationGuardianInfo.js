/**
 * Created by MacBookPro on 12/7/20.
 */

import {LightningElement, api, wire, track} from 'lwc';

import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import getRelationships from '@salesforce/apex/SG_LWC_Application.getRelationShips';
import addNewRelations from '@salesforce/apex/SG_LWC_Application.addNewRelationship';
import saveRelations from '@salesforce/apex/SG_LWC_Application.saveRelationships';
import getRoles from '@salesforce/apex/SG_LWC_Application.getRoles';
import deleteRelationship from '@salesforce/apex/SG_LWC_Application.deleteRelationship';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ApplicationGuardianInfo extends LightningElement
{
    @track isLoading = false;
    @track applicationId;
    @track errorMessage;
    relationships;
    @track optionsGuardianRoles;
    goToNext = false;


    connectedCallback() {
        console.log('--->onload: connectedCallback()');
        console.log('COOKIE: ' + document.cookie);

        var appId = null;
        if(document.cookie) {
            appId = document.cookie.replace('applicationId=', '');
        }

        console.log('APP ID: ' + appId);

        getApplication({applcationId: appId})
            .then(function(result)
                {
                    console.log('getApplication() result: ' + result);

                    if(result == null)
                    {
                        this.errorMessage = 'Unable to find Application Information.';
                    }
                    else
                    {
                        this.applicationId = result.Id;
                    }
                }
                    .bind(this)
            )

        console.log(appId);
        getRelationships({applicationId:appId})
            .then(function (result)
                {
                    console.log(result);
                    this.relationships = result;
                }
                .bind(this)
            ).catch(function (err){
                console.log('getRelationships function >> an error happened');
            })

        getRoles()
            .then(function (result)
                {
                    console.log('GUARDIAN ROLES: ' + result);
                    this.optionsGuardianRoles = [];
                    result.forEach(element => {
                        console.log(element);
                        const option1 = {label: element, value: element};
                        this.optionsGuardianRoles.push(option1);
                    });
                }
                .bind(this)
            ).catch(function (err){
                console.log('getRoles function >> an error happened');
            })
    }

    addNewGuardian() {
        addNewRelations({applicationId:this.applicationId, relationships: this.relationships})
            .then(function (result)
                {
                    this.relationships = result;
                }
                .bind(this)
            )
    }

    goBack() {
        window.open('application-programs', "_self");
    }

    doSaveAndNext(event) {
        console.log('---doSaveAndNext()');
        this.goToNext = true;
        this.doSave(event);
    }

    doDelete(event) {
        console.log('Delete Relationship');
        this.isLoading = true;

        var index = event.target.name;
        console.log('index: ' + index);

        var relIdToDelete = this.relationships[index].Id;
        console.log('relationship Id: ' + relIdToDelete);
        var hasError = false;

        if(relIdToDelete){
            deleteRelationship({relId:relIdToDelete})
                .then(function (result)
                    {
                        console.log('---> deleteRelationship()');
                        console.log(result);


                        if(result != 'Success') {
                            hasError = true;
                            const event2 = new ShowToastEvent({
                                title: 'Error',
                                message: result,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event2);
                        }
                        else {
                            console.log('remove relationship');
                            this.relationships.splice(index, 1);
                        }

                        this.isLoading = false;


                    }
                    .bind(this)
                )

            if(hasError == false){
                console.log('NoErrors: so delete');
                this.relationships.splice(index, 1);
            }

        }
        else {
            this.relationships.splice(index, 1);
        }




        this.isLoading = false;
    }


    doSave(event) {

        console.log('---donSave()');

        this.isLoading = true;

        event.preventDefault();
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            element.reportValidity();
        });

        // First Name
        var i = 0;
        this.template.querySelectorAll('.firstname').forEach(element => {
           console.log('firstname ' + i + ' ' + element.value);
           this.relationships[i].First_Name__c = element.value;
           i++;
        });
        // Last Name
        i = 0;
        this.template.querySelectorAll('.lastname').forEach(element => {
            console.log('lastname ' + i + ' ' + element.value);
            this.relationships[i].Last_Name__c = element.value;
            i++;
        });
        // Email
        i = 0;
        this.template.querySelectorAll('.email').forEach(element => {
            console.log('email ' + i + ' ' + element.value);
            this.relationships[i].Email__c = element.value;
            i++;
        });
        // Mobile PHone
        i = 0;
        this.template.querySelectorAll('.mobile').forEach(element => {
            console.log('mobile ' + i + ' ' + element.value);
            this.relationships[i].Mobile_Phone__c = element.value;
            i++;
        });
        // Home Phone
        i = 0;
        this.template.querySelectorAll('.home').forEach(element => {
            console.log('homephone ' + i + ' ' + element.value);
            this.relationships[i].Home_Phone__c = element.value;
            i++;
        });
        // Role
        i = 0;
        this.template.querySelectorAll('.role').forEach(element => {
            console.log('role ' + i + ' ' + element.value);
            this.relationships[i].Contact2_Role__c = element.value;
            i++;
        });
        // Other relationship role
        i=0;
        this.template.querySelectorAll('.otherRel').forEach(element => {
            console.log('other role ' + i + ' ' + element.value);
            this.relationships[i].Other_Relationship__c = element.value;
            i++;
        });

        // Opt Out
        i = 0;
        this.template.querySelectorAll('.emails').forEach(element => {
            console.log('opt out ' + i + ' ' + element.checked);
            this.relationships[i+1].Opt_Out__c = element.checked;
            i++;
        });

        console.log('-->relationships');
        console.log(this.relationships);

        //return;

        saveRelations({relationships:this.relationships, applicationId:this.applicationId})
            .then(function (result)
                {
                    console.log('---> saveRelations()');
                    console.log(result);
                    this.relationships = result;

                    if(this.goToNext == true) {
                        window.open('application-medicalinfo', "_self");
                    }

                    this.goToNext = false;

                    this.isLoading = false;

                    const event2 = new ShowToastEvent({
                        title: 'Save Successful',
                        message: 'Application Saved.',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event2);
                }
                .bind(this)
            )


    }

}
/**
 * Created by MacBookPro on 3/30/21.
 */

import {api, LightningElement, track} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getAccountInfo from '@salesforce/apex/SG_LWC_Relationships.getRecordInfo';
import cloneAccount from '@salesforce/apex/SG_LWC_Clone.cloneAccount';
//import {  getRecordNotifyChange } from 'lightning/uiRecordApi';
import getRoles from '@salesforce/apex/SG_LWC_Clone.getRoles';


import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CloneAccount extends NavigationMixin(LightningElement)
{
    @api recordId;
    @track firstname;
    @track lastname;
    @track role;
    @track other;
    accountInfo;
    optionsGuardianRoles;
    isLoading = false;

    connectedCallback() {
        console.log('--->onload: cloneAccount.connectedCallback()');

        console.log(this.recordId);

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
            )


        /*getAccountInfo({accountId: this.recordId})
            .then(function (result) {
                    console.log('getAccountInfo() result:');
                    console.log(result);
                    this.accountInfo = result;
                }
                .bind(this)
            )*/
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
            case "role":
                this.role = value;
                break;
            case "other":
                this.other = value;
                break;
            default:
            //
        }
    }

    close()
    {
        this.dispatchEvent(new CustomEvent('close'));
    }

    doSave()
    {
        console.log('doSave');

        this.isLoading = true;

        cloneAccount({firstname: this.firstname, lastname: this.lastname, acctId: this.recordId, role: this.role, other: this.other})
            .then(function (result) {
                    console.log('getAccountInfo() result:');
                    console.log(result);
                    if(!result.includes('Error'))
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'New Account clone.',
                            variant: 'success',
                            }
                        ));

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'ObjectApiName',
                                actionName: 'view'
                            }
                        });

                        this.dispatchEvent(new CustomEvent('close'));
                    }
                    else
                    {
                        this.dispatchEvent(new ShowToastEvent({
                                title: 'Error',
                                message: result,
                                variant: 'error',
                            }
                        ));
                        this.isLoading = false;
                    }
                }
                .bind(this)
            )
    }

    doClone()
    {
        console.log(this.accountInfo.PersonMailingStreet);
        const defaultValues = encodeDefaultFieldValues({
            High_School_Grad_Year__pc: this.accountInfo.High_School_Grad_Year__pc,
            High_School_Name__pc: this.accountInfo.High_School_Name__pc,
            RecordTypeId: this.accountInfo.RecordTypeId,
            PersonMailingStreet: this.accountInfo.PersonMailingStreet,
            PersonMailingCity: this.accountInfo.PersonMailingCity,
            PersonMailingState: this.accountInfo.PersonMailingState,
            PersonMailingPostalCode: this.accountInfo.PersonMailingPostalCode,
            PersonMailingCountry: this.accountInfo.PersonMailingCountry
        });

        console.log(defaultValues);



        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account', // objectApiName is optional
                recordTypeId: this.accountInfo.RecordTypeId,
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }


}
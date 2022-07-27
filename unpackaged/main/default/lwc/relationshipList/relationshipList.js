/**
 * Created by MacBookPro on 3/30/21.
 */

import {LightningElement, api} from 'lwc';
import getRelationships from '@salesforce/apex/SG_LWC_Relationships.getRelationships';
import getContactId from '@salesforce/apex/SG_LWC_Relationships.getContactId';
import getAccountInfo from '@salesforce/apex/SG_LWC_Relationships.getAccountInfo';


import {NavigationMixin} from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const columns = [
    {label:'Relationship Name', fieldName: 'Name'},
    { label: 'Contact', fieldName: 'Mobile_Phone__c', type: 'url',typeAttributes: { label: {fieldName:'First_Name__c'}  } },
    {label:'Role', fieldName: 'Contact2_Role__c'},
    {label:'Email', fieldName: 'Email__c'},
    {label:'Email Opt Out', type: 'checkbox', fieldName: 'Opt_Out__c'},
    { type:  'button', typeAttributes: {
            label: 'View', name: 'View', variant: 'brand', iconPosition: 'right'
        }
    }
];

export default class RelationshipList extends NavigationMixin(LightningElement)
{
    @api recordId;
    currentContact;
    contactId;
    relationships;
    selectedRecord;
    columnList = columns;

    connectedCallback() {
        console.log('--->onload: relationshipList connectedCallback()');

        console.log(this.recordId);
        getRelationships({accountId: this.recordId})
            .then(function(result)
                {
                    console.log('getRelationships() result:');
                    console.log(result);
                    this.relationships = result;
                }
                .bind(this)
            )

        getAccountInfo({accountId: this.recordId})
            .then(function(result)
                {
                    console.log('getContactId() result:');
                    console.log(result);
                    this.currentContact = result;
                    this.contactId = result.PersonContactId;
                }
                    .bind(this)
            )

        /*
        getContactId({accountId: this.recordId})
            .then(function(result)
                {
                    console.log('getContactId() result:');
                    console.log(result);
                    this.contactId = result;
                }
                    .bind(this)
            )

         */
    }

    createNewRelationship()
    {
        var defaultValues;

        console.log('Dragons Type: ' + this.currentContact.Dragons_Type__pc);

        if(this.currentContact.Dragons_Type__pc == null || this.currentContact.Dragons_Type__pc.includes('Student')) {
            defaultValues = encodeDefaultFieldValues({
                Name: 'Test',
                Contact1__c: this.contactId,
                Contact1_Role__c: 'Student'
            });
        }
        else
        {
            defaultValues = encodeDefaultFieldValues({
                Name: 'Test',
                Contact2__c: this.contactId,
            });
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Relationship__c', // objectApiName is optional
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }



    handleRowAction(event){
        console.log('rowaction');
        console.log(event.detail.row.Id);
        this.selectedRecord = event.detail.row.Id;
        // View a custom object record.

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedRecord,
                objectApiName: 'Relationship__c', // objectApiName is optional
                actionName: 'view'
            }
        });

    }

}
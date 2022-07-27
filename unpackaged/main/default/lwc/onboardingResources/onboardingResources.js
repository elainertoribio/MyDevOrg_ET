/**
 * Created by MacBookPro on 1/12/21.
 */

import { api, LightningElement, track, wire } from 'lwc';
import getApplication from '@salesforce/apex/SG_LWC_Application.getApplication';
import getContentDetails from '@salesforce/apex/SG_ContentManagerService.getContentDetails';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    {  fieldName: 'Title', wrapText : true,
        cellAttributes: {
            iconName: { fieldName: 'icon' }, iconPosition: 'left'
        }
    },
    { fieldName: 'Description', wrapText : true, },
    //{ label: 'ID', fieldName: 'CId', wrapText : true, },
    //{ label: 'File Size',   fieldName: 'Size' },
    { type:  'button', typeAttributes: {
            label: 'Download', name: 'Download', variant: 'brand', iconName: 'action:download',
            iconPosition: 'right'
        }
    }
];

export default class OnboardingResources extends NavigationMixin(LightningElement) {

    @api showDetails;
    @api showFileUpload;
    @api showsync;
    @api recordId;
    @api usedInCommunity;
    @api showFilters;
    @api accept = '.csv,.doc,.xsl,.pdf,.png,.jpg,.jpeg,.docx,.doc';
    programId;

    @track dataList;
    @track columnsList = columns;
    isLoading = false;

    wiredFilesResult;

    connectedCallback() {
        console.log('--->onboardingResources onload: connectedCallback()');
        console.log('COOKIE: ' + document.cookie);
        var appId = null;
        if(document.cookie) {
            appId = document.cookie.replace('applicationId=', '');
        }
        console.log('APP ID: ' + appId);

        getApplication({applicationId:appId})
            .then(function(result)
                {
                    console.log(result);

                    if(result == null)
                    {
                        this.errorMessage = 'Unable to find Application Information.';
                    }
                    else
                    {
                        this.recordId = result.Id;
                        this.programId = result.Program_Applied__c;
                        this.handleSync();
                    }
                }
                    .bind(this)
            )

    }

    getBaseUrl(){
        let baseUrl = 'https://'+location.host+'/';
        return baseUrl;
    }

    handleRowAction(event){

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Download':
                this.downloadFile(row);
                break;
            default:
        }

    }

    downloadFile(file){
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.downloadUrl
                }
            }, false
        );
    }

    handleSync(){

        let imageExtensions = ['png','jpg','gif'];
        let supportedIconExtensions = ['ai','attachment','audio','box_notes','csv','eps','excel','exe',
            'flash','folder','gdoc','gdocs','gform','gpres','gsheet','html','image','keynote','library_folder',
            'link','mp4','overlay','pack','pages','pdf','ppt','psd','quip_doc','quip_sheet','quip_slide',
            'rtf','slide','stypi','txt','unknown','video','visio','webex','word','xml','zip'];

        this.isLoading = true;
        getContentDetails({
            recordId : this.recordId
        })
            .then(result => {
                let parsedData = JSON.parse(result);
                let stringifiedData = JSON.stringify(parsedData);
                let finalData = JSON.parse(stringifiedData);
                let baseUrl = this.getBaseUrl();
                finalData.forEach(file => {
                    //file.downloadUrl = baseUrl+'sfc/servlet.shepherd/document/download/'+file.ContentDocumentId;
                    //file.fileUrl     = baseUrl+'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+file.Id;
                    //file.CREATED_BY  = file.ContentDocument.CreatedBy.Name;
                    //file.Size        = this.formatBytes(file.ContentDocument.ContentSize, 2);

                    file.downloadUrl = file.ContentDownloadUrl;
                    file.fileUrl     = baseUrl+'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+file.Id;
                    file.Size        = this.formatBytes(file.ContentVersion.ContentDocument.ContentSize, 2);
                    file.Title       = file.ContentVersion.Title;
                    file.Description = file.ContentVersion.Description;
                    file.CId         = file.ContentVersion.ContentDocumentId;
                    console.log('Cid: ' + file.CId);

                    //let fileType = file.ContentDocument.FileType.toLowerCase();
                    let fileType = file.ContentVersion.ContentDocument.FileType.toLowerCase();
                    if(imageExtensions.includes(fileType)){
                        file.icon = 'doctype:image';
                    }else{
                        if(supportedIconExtensions.includes(fileType)){
                            file.icon = 'doctype:' + fileType;
                        }
                    }
                });
                this.dataList = finalData;
            })
            .catch(error => {
                console.error('**** error **** \n ',error)
            })
            .finally(()=>{
                this.isLoading = false;
            });
    }

    handleUploadFinished(){
        this.handleSync();
        //eval("$A.get('e.force:refreshView').fire();");
    }
    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    handleSearch(event){
        let value = event.target.value;
        let name  = event.target.name;
        if( name === 'Title' ){
            this.dataList = this.dataList.filter( file => {
                return file.Title.toLowerCase().includes(value.toLowerCase());
            });
        } else if( name === 'Created By' ){
            this.dataList = this.dataList.filter( file => {
                return file.CREATED_BY.toLowerCase().includes(value.toLowerCase());
            });
        }
    }

}
import {
    LightningElement
    , api, wire
    //, track
} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import callRusInt from '@salesforce/apex/CDCCACRussianInterceptorCallouts.auraExecute';
import { refreshApex } from '@salesforce/apex';

import NAME_FIELD from '@salesforce/schema/Contact.Name';
import TITLE_FIELD from '@salesforce/schema/Contact.CDC_CAC_Title__c';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';

export default class CreateCustomer extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    //@track fields = ['Name', 'Title', 'Phone', 'Email'];

    @wire(callRusInt) rusIntResponse;   //call rus interceptor

    fields = [NAME_FIELD, TITLE_FIELD, PHONE_FIELD, EMAIL_FIELD];

    handleSubmit(event) {
        event.preventDefault();         // stop the form from submitting

        console.log("1", this.rusIntResponse);
        console.log("2", refreshApex(this.rusIntResponse));
        console.log("3", this.rusIntResponse.data);

        if (this.rusIntResponse.data !== 200) {
            //throw new Error('a');

            const evt = new ShowToastEvent({
                title: "Request was not accepted by Russian Interceptor",
                message: this.rusIntResponse.error,
                variant: "error"
            });
            this.dispatchEvent(evt);
            return;
        }

        const fields = event.detail.fields;
        fields.LastName = 'My Custom Last Name'; // modify a field
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    handleSuccess(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        const evt = new ShowToastEvent({
            title: "Customer created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);

        //$A.get("e.force:closeQuickAction").fire();
        //updateRecord({ fields: { Id: event.detail.id } });

        //console.log("start navigate", event.detail.id);
        // Generate a URL to a User record page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                actionName: 'view',
            },
        }).then(url => {
            this.recordPageUrl = url;
            //console.log("url", url);
            //console.log("this.recordPageUrl", this.recordPageUrl);

            // Navigate to the Contact record; couldn't get it working without being called by GenerateUrl promise
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.detail.id,
                    actionName: 'view',
                },
            });

            //console.log("navigate");
        });
        //console.log("end navigate");
    }

    handleCancel(event) {
        /*const modal = this.template.querySelector('lightning-card');
        //console.log("1", modal);
        modal.hide();*/

        //send event to parent aura component
        const closeEvent = new CustomEvent('closeEvent');
        // Fire the custom event
        this.dispatchEvent(closeEvent);
    }
}
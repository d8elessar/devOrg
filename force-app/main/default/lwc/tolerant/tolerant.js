import {
    LightningElement, track
    //, wire 
} from 'lwc';
import getAccountList from '@salesforce/apex/customerController.searchCustomers';
//import { refreshApex } from '@salesforce/apex';

// The base URL (in this case https://www.googleapis.com/ must be added to the CSP Trusted Sites in Setup)
const QUERY_URL =
    //'http://t1220001007i.nl122.corpintra.net:20085/test/CompassFacade/v1/Tolerant/MatchService?housename=&lastname=val%C3%A9rio&firstname=&streetname=&housenumber=&zipcode=&city=&country=Netherlands&email_address=&province=&fleetowner_flg=&email_address2=&disabledFields=housename,firstname,streetname,housenumber,zipcode,city,email_address,province,fleetowner_flg,email_address2&reqId=1&resultMode=1&maxResultCount=50&project=matchProject-1&profile=matchProfile-2';
    //'https://www.googleapis.com/books/v1/volumes?langRestrict=en&q=';
    'https://compass-test.nl122.corpintra.net/test/CompassFacade/v1/Tolerant/MatchService?housename=&lastname=val%C3%A9rio&firstname=&streetname=&housenumber=&zipcode=&city=&country=Netherlands&email_address=&province=&fleetowner_flg=&email_address2=&disabledFields=housename,firstname,streetname,housenumber,zipcode,city,email_address,province,fleetowner_flg,email_address2&reqId=1&resultMode=1&maxResultCount=50&project=matchProject-1&profile=matchProfile-2';
//var httpRequest;

export default class Tolerant extends LightningElement {
    @track searchKey = 'Harry';
    @track customers;
    @track searchArray = new Array();
    @track error;
    @track customerList;

    /*@wire(getAccountList, { searchTerm: this.searchArray })
    wiredValues({ error, data }) {
        if (data) {
            this.customerList = data;
            this.error = undefined;
        } else {
            this.error = error;
            this.customerList = undefined;
        }
    }*/

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearchClick() {
        // The Fetch API is currently not polyfilled for usage in IE11.
        // Use XMLHttpRequest instead in that case.
        //fetch(QUERY_URL + this.searchKey)
        fetch(QUERY_URL, {
            method: 'GET', // *GET, POST, PUT, DELETE, etc.
            //mode: 'cors', // no-cors, cors, *same-origin
            cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
            credentials: 'same-origin', // include, *same-origin, omit
            headers: {
                'Content-Type': 'application/json',
            },
            redirect: 'follow', // manual, *follow, error
            referrer: 'no-referrer' // no-referrer, *client
            //, 
            //body: JSON.stringify(data), // body data type must match "Content-Type" header
        }
        )
            .then(response => {
                // fetch isn't throwing an error if the request fails.
                // Therefore we have to check the ok property.
                if (!response.ok) {
                    this.error = response;
                }
                return response.json();
            })
            .then(jsonResponse => {
                this.customers = jsonResponse;
                //console.log("this.customers", this.customers);
                //this.customers = this.customers.Message;
                //console.log("this.customers", this.customers);

                this.customers = jsonResponse.Message.map(function (message) {
                    var data = {
                        "matchKey": message["match.Key"],
                        "matchScore": message["match.Score"],
                        "matchSingleScores": message["match.SingleScores"],
                        "matchRuleId": message["match.RuleId"],
                        "matchRuleName": message["match.RuleName"],
                        "matchInternalData": message["match.InternalData"]
                    };
                    return data;
                }
                );
                console.log("this.customers", this.customers);

                this.searchArray = jsonResponse.Message.map(function (message) {
                    var data = new Array();

                    try {
                        data.push(message["match.Key"]);
                    }
                    catch (error) {
                        console.log("error", error);
                    }
                    return data;
                }
                );
                console.log("this.searchArray", this.searchArray);

                //query org data
                this[getAccountList](
                    { searchTerm: this.searchArray })
                    .then(data => {
                        console.log("data", data);
                        this.customerList = data;
                    }
                    );

                console.log("this.customerList", this.customerList);

            })
            .catch(error => {
                this.error = error;
                this.customers = undefined;
            });

        /*httpRequest = new XMLHttpRequest();

        httpRequest.open('GET', QUERY_URL);
        httpRequest.send();*/
    }
}
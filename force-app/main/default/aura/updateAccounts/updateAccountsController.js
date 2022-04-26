({
    handleSubmit : function(component, event, helper) {
        console.log('handleSubmit');
        event.preventDefault();       // stop the form from submitting
        component.set('v.displayedSection', 'no');
        
        const fields = event.getParam('fields');
        //console.log('Fields that are changed: ' + JSON.stringify(fields));
        component.set('v.accountId', fields.AccountId);
        
        component.set('v.showConfirmDialog', true);
        
        //component.find('myRecordForm').submit(fields);
    },
    
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
        component.set('v.showConfirmDialog', false);
        
        var flow = component.find("flow");
        
        var inputVariables = [
            {
                name : 'recordId',
                type : 'String',
                value : component.get("v.recordId")
            },{
                name : 'newAccountId',
                type : 'String',
                value : component.get("v.accountId")
            }
        ];
        
        flow.startFlow("Update_Order_Price_Book", inputVariables);
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
        
        $A.get('e.force:refreshView').fire();
    },
    
    flowStatusChange : function( component, event, helper ) {
        console.log('flowStatusChange');
        console.log('status: ' + event.getParam( "status" ));
        
        if ( event.getParam( "status" ) === "FINISHED_SCREEN" ) {
            component.find('notifLib').showToast({
                "variant": "success",
                "title": "Order updated"
            });
            
            $A.get('e.force:refreshView').fire();
            
        } else if ( event.getParam( "status" ) ===  "ERROR" ) { 
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Order not updated",
                "message": "Record ID: " + event.getParam( "status" )
            });
            
            component.set('v.displayedSection', 'yes');
        }
    }
})
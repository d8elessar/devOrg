({
    goToRecord : function(component) {
        //navigate to same record, it was the only way I found to put the component back in view mode
        //otherwise it would keep showing the Cancel/Save button
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    }
})
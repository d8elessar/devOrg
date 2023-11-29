trigger leadBeforeSave on Lead(before insert) {
    /*if(Trigger.isInsert && Trigger.isBefore){
        Set<String> setOfEmailIds = new Set<String>();
		list<Task> listTask = new list<Task>();
		
        for(lead leadObj : Trigger.new){
            if(leadObj.email!= null && leadObj.leadSource =='Web'){ // look for leads whose source is web
                setOfEmailIds.add(leadObj.email);
            }
        }

		if(setOfEmailIds.size() > 0){
			Map<String,Contact> mapContact = new Map<String,Contact>(); // create map of email and contact
			for(Contact contact : [Select id,email from contact where email in:setOfEmailIds]){
				mapContact.put(contact.email , contact);
			}
			
			for(lead leadObj : Trigger.new){
				if(mapContact.containsKey(leadObj.email)){ // show error if email Id found
                    System.debug('contact found, not going to create the lead');
					leadObj.addError('You are already registered with email Id with us');
				}
				else{ // create follow up task
                    System.debug('contact not found, create the lead and task');
					Task t = new Task();
					t.OwnerId = 'Add QueueId or User Id';
					t.Subject='Follow up for ' + leadObj.Name;
					t.Status='Not Started';
					t.Priority='Normal';
					listTask.add(t);
				}
			}

			if(listTask.size() > 0){
				insert listTask;
			}
		}
    }*/
}
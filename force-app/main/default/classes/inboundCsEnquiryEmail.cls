global class inboundCsEnquiryEmail implements Messaging.InboundEmailHandler {
global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                       Messaging.InboundEnvelope envelope) {
	Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

	String myPlainText= '';

	// Store the email plain text into the local variable
	myPlainText = email.plainTextBody;

	// Create a new Task object
	Task[] newTask = new Task[0];

	//create a new Case object
	Case[] newCase = new Case[0];

	// Try to look up any contacts based on the from email address.
	// If there are more than one contacts with the same email address,
	// an exception will be thrown and the catch statement block will be executed.
	try
	{
		Contact vCon = [SELECT Id, Name, Email FROM Contact WHERE Email = :email.fromAddress LIMIT 1];

		// Add a new Task to the contact record we just found above.
		newTask.add(new Task(Description =  myPlainText,
		                     Priority = 'Normal',
		                     Status = 'Inbound Email',
		                     Subject = email.subject,
		                     IsReminderSet = true,
		                     ReminderDateTime = System.now()+1,
		                     WhoId =  vCon.Id));

		// Insert the new Task
		insert newTask;
		System.debug('New Task Object: ' + vCon.name+vCon.id);

		//add new Case to Customer
		CDC_CAC_Asset_Contact__c vVehicle = [SELECT Asset__c FROM CDC_CAC_Asset_Contact__c WHERE Contact__c = :vCon.Id LIMIT 1];
		System.debug('vVehicle: ' + vVehicle);

		/*newCase.add(new Case(Description = myPlainText,
		                     Priority = 'Medium',
		                     Status = 'New',
		                     Subject = email.subject,
		                     CDC_CAC_Service_Type__c = 'CS',
		                     CDC_CAC_Case_Type__c = 'Enquiry',
		                     CDC_CAC_Classification_Type__c = 'Dealer Enquiry',
		                     CDC_CAC_Classification_Topic__c = 'DHD',
		                     CDC_CAC_Classification_Topic_Detail__c = 'DhD',
		                     Origin = 'Email',
		                     ContactId = vCon.Id,
		                     AssetId = vVehicle.Asset__c));

		   //insert new Case
		   insert newCase;
		   System.debug('New Case Object: ' + newCase[0].Id);*/

		//Fetching the assignment rules on case
		AssignmentRule AR = new AssignmentRule();
		AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
		Case newCaseDml = new Case(Description = myPlainText,
		                           Priority = 'Medium',
		                           Status = 'New',
		                           Subject = email.subject,
		                           CDC_CAC_Service_Type__c = 'CS',
		                           CDC_CAC_Case_Type__c = 'Enquiry',
		                           CDC_CAC_Classification_Type__c = 'Dealer Enquiry',
		                           CDC_CAC_Classification_Topic__c = 'DHD',
		                           CDC_CAC_Classification_Topic_Detail__c = 'DhD',
		                           Origin = 'Email',
		                           ContactId = vCon.Id,
		                           AssetId = vVehicle.Asset__c);

		//Setting the DMLOption on Case instance
		newCaseDml.setOptions(dmlOpts);
		insert newCaseDml;
		System.debug('New Case Object: ' + newCaseDml.Id);

		//add attachments
		if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
			for (integer i = 0; i < email.binaryAttachments.size(); i++) {
				Attachment attachment = new Attachment();
				// attach to the newly created contact record
				attachment.ParentId = newTask[0].Id;
				attachment.Name = email.binaryAttachments[i].filename;
				attachment.Body = email.binaryAttachments[i].body;
				insert attachment;
				System.debug('new attachment: ' + attachment.Id);
			}
		}

	}
	// If an exception occurs when the query accesses
	// the contact record, a QueryException is thrown.
	// The exception is written to the Apex debug log.
	catch (QueryException e) {
		System.debug('Query Issue: ' + e);
	}

	// Set the result to true. No need to send an email back to the user
	// with an error message
	result.success = true;

	// Return the result for the Apex Email Service
	return result;
}
}
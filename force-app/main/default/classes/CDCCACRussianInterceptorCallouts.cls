global class CDCCACRussianInterceptorCallouts implements Queueable, Database.AllowsCallouts {
public static ID jobID = null;
public static String rusInt = '';

//@future (callout=true)
//public static HttpResponse makeGetCallout() {

public static void execute(QueueableContext context) {
	Http http = new Http();
	HttpRequest request = new HttpRequest();
	request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
	request.setMethod('GET');
	HttpResponse response = http.send(request);
	// If the request is successful, parse the JSON response.
	if (response.getStatusCode() == 200) {
		// Deserializes the JSON string into collections of primitive data types.
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		// Cast the values in the 'animals' key as a list
		List<Object> animals = (List<Object>) results.get('animals');
		System.debug('Received the following animals:');
		for (Object animal: animals) {
			System.debug(animal);
		}
	}
	//return response;
}

@AuraEnabled(cacheable=true)
public static Integer auraExecute() {
	Http http = new Http();
	HttpRequest request = new HttpRequest();
	request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
	request.setMethod('GET');
	HttpResponse response = http.send(request);
	// If the request is successful, parse the JSON response.
	if (response.getStatusCode() == 200) {
		// Deserializes the JSON string into collections of primitive data types.
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		// Cast the values in the 'animals' key as a list
		List<Object> animals = (List<Object>) results.get('animals');
		System.debug('Received the following animals:');
		for (Object animal: animals) {
			System.debug(animal);
		}
	}
	return response.getStatusCode();
}

@InvocableMethod
global static void RusInt() {
	makeGetCallout();

	/*Http http = new Http();
	   HttpRequest request = new HttpRequest();
	   request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
	   request.setMethod('GET');

	   System.debug(request);

	   HttpResponse response = http.send(request);

	   System.debug(response);

	   // If the request is successful, parse the JSON response.
	   if (response.getStatusCode() == 200) {
	    // Deserializes the JSON string into collections of primitive data types.
	    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
	    // Cast the values in the 'animals' key as a list
	    List<Object> animals = (List<Object>) results.get('animals');
	    System.debug('Received the following animals:');
	    for (Object animal: animals) {
	        System.debug(animal);
	    }
	   }*/

	/*if(jobID == null) {
	    jobID = System.enqueueJob(new CDCCACRussianInterceptorCallouts());
	   }
	   System.debug(jobID);

	   AsyncApexJob jobInfo;
	   jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
	   System.debug(jobInfo);

	   if(jobInfo.Status == 'Failed') {
	    throw new customException('RusInt Error!');
	   }*/
}

@future (callout=true)
public static void makeGetCallout() {
	Http http = new Http();
	HttpRequest request = new HttpRequest();
	request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
	request.setMethod('GET');
	HttpResponse response = http.send(request);
	// If the request is successful, parse the JSON response.
	if (response.getStatusCode() == 200) {
		// Deserializes the JSON string into collections of primitive data types.
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		// Cast the values in the 'animals' key as a list
		List<Object> animals = (List<Object>) results.get('animals');
		System.debug('Received the following animals:');
		for (Object animal: animals) {
			System.debug(animal);
		}
	}
	//return response;
}

@future (callout=true)
public static void makeGetCalloutLog(String timestamp) {
	Http http = new Http();
	HttpRequest request = new HttpRequest();
	request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
	request.setMethod('GET');

	HttpResponse response = http.send(request);

	EAI_Log__c oLog = new EAI_Log__c(Request_Id__c = timestamp);
	insert oLog;

	oLog.Error_Code__c = String.valueOf(response.getStatusCode());

	// If the request is successful, parse the JSON response.
	if (response.getStatusCode() == 200) {
		oLog.Status__c = 'Completed';
		// Deserializes the JSON string into collections of primitive data types.
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		// Cast the values in the 'animals' key as a list
		List<Object> animals = (List<Object>) results.get('animals');
		System.debug('Received the following animals:');
		for (Object animal: animals) {
			System.debug(animal);
		}
	}
	else {
		oLog.Status__c = 'Failed';
	}
	update oLog;
	//return response;
}

@future (callout=true)
public static void makeGetCalloutGlobal(String timestamp) {
	Http http = new Http();
	HttpRequest request = new HttpRequest();
	request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
	request.setMethod('GET');

	HttpResponse response = http.send(request);

	// If the request is successful, parse the JSON response.
	if (response.getStatusCode() == 200) {
		rusInt = 'OK';
	}
	else {
		rusInt = 'NOK';
	}

	System.debug('rusInt global: ' + rusInt);

	//return response;
}

public static void RussianInterceptor(Map<Id, Contact> oldMap, Map<Id, Contact> newMap, Boolean isBefore) {
	String sCustCountry = '';
	Contact oContact;
	AsyncApexJob jobInfo;
	//List<Task> count;
	List<EAI_Log__c> reqInfo;

	try{
		for (Id iId: newMap.keySet()) {
			oContact = newMap.get(iId);
			sCustCountry = oContact.MailingCountry;

			System.debug('sCustCountry: ' + sCustCountry);

			if(sCustCountry == 'Russia') {
				//if(sCustCountry == 'xpto') {
				//HttpResponse result =

				//String timestamp = String.valueOf(DateTime.now().getTime());
				//CDCCACRussianInterceptorCallouts.makeGetCalloutLog(timestamp);

				System.debug('calling it');
				List<People__x> people = [select Id from People__x limit 1];

				if(people[0].Id != null) {
					oContact.addError('Interceptor response: NOK');
				}
				//CDCCACRussianInterceptorCallouts.makeGetCalloutGlobal(oContact.Id);
				System.debug('called it');

				//System.debug('result: ' + result);

				while(rusInt == '') {
					//ApexUtil.wait(300);
				}

				System.debug('rusInt: ' + rusInt);

				if(rusInt == 'NOK') {
					oContact.addError('Interceptor response: NOK');
				}


				/*reqInfo = [SELECT Status__c FROM EAI_Log__c WHERE Request_Id__c=:timestamp];

				   while(reqInfo.size() == 0 || reqInfo[0].Status__c == 'Queued') {
				        ApexUtil.wait(300);
				        reqInfo = [SELECT Status__c FROM EAI_Log__c WHERE Request_Id__c=:timestamp];
				   }

				   if(reqInfo[0].Status__c == 'Failed') {
				        oContact.addError('Interceptor response: NOK');
				   }*/

				/*if(isBefore && jobID == null) {
				    //jobID = System.enqueueJob(new CDCCACRussianInterceptorCallouts());
				    System.debug('jobID: ' + jobID);
				   }
				   else {
				    System.debug('jobID : ' + jobID);

				    if(jobID != null) {
				        jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];

				        //if(result.getStatusCode() != 200) {
				        //while(jobInfo.Status == 'Queued'){
				        //   ApexUtil.wait(500); //sleep 100ms
				        //  //count = [SELECT id FROM TASK LIMIT 50000 ALL ROWS ];

				        //  jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
				        //}

				        //if(jobInfo.Status == 'Failed') {
				        if(jobInfo.Status == 'Failed') {
				            oContact.addError('Interceptor response: NOK');
				        }
				    }
				   }*/
			}
		}
	}
	catch (Exception e) {
		System.debug('Error Cause: ' + e.getCause());
		System.debug('Error Message: ' + e.getMessage());
	}
	finally {
		sCustCountry = null;
		oContact = null;
	}
}
}
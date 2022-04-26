public with sharing class customerController {
@AuraEnabled(Cacheable=true)
public static Contact[] getAllCustomers() {
	return [SELECT Id, LastName, FirstName, Salutation, MailingStreet, MailingCity,
	        MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude,
	        MailingGeocodeAccuracy, Phone, Fax, MobilePhone, HomePhone, OtherPhone,
	        AssistantPhone, Email, Title, AssistantName, Birthdate, CDC_CAC_Title__c,
	        CDC_CAC_Last_Name_Native__c, CDC_CAC_Business_Trading_Name__c, CDC_CAC_First_Name_Native__c,
	        CDC_CAC_VAT_Number__c, CDC_CAC_Business_Email__c, CDC_CAC_Interceptor_Id__c,
	        CDC_CAC_Interceptor_Flag__c, CDC_CAC_Interceptor_Timestamp__c, CDC_CAC_Consent_Given__c,
	        CDC_CAC_Expiration_Date__c, CDC_CAC_Integration_Id__c
	        FROM Contact ORDER BY Name LIMIT 50];
}

@AuraEnabled(Cacheable=true)
public static Contact[] searchCustomers(String[] searchTerm) {
	// Execute search query
	return [SELECT Id, LastName, FirstName, Salutation, MailingStreet, MailingCity,
	        MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude,
	        MailingGeocodeAccuracy, Phone, Fax, MobilePhone, HomePhone, OtherPhone,
	        AssistantPhone, Email, Title, AssistantName, Birthdate, CDC_CAC_Title__c,
	        CDC_CAC_Last_Name_Native__c, CDC_CAC_Business_Trading_Name__c, CDC_CAC_First_Name_Native__c,
	        CDC_CAC_VAT_Number__c, CDC_CAC_Business_Email__c, CDC_CAC_Interceptor_Id__c,
	        CDC_CAC_Interceptor_Flag__c, CDC_CAC_Interceptor_Timestamp__c, CDC_CAC_Consent_Given__c,
	        CDC_CAC_Expiration_Date__c, CDC_CAC_Integration_Id__c
	        FROM Contact WHERE CDC_CAC_Integration_Id__c in : searchTerm LIMIT 50];
}
}
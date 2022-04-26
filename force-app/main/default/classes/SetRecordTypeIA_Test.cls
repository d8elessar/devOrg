@isTest
public class SetRecordTypeIA_Test {
	@isTest
    public static void testSetRecordTypeIA() {
        Quote a = new Quote();
        a.Name = 'TestQuote';
        insert a;
        
 	    SetRecordTypeIA.Request req = new SetRecordTypeIA.Request();
        
		// assumes Quote has at least one recordType
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
        Schema.RecordTypeInfo rtInfo = rtMap.get(new List<String>(rtMap.keySet())[0]);
        
        Id recordTypeId = rtInfo.getRecordTypeId();
        String recordTypeDevName = rtInfo.getDeveloperName();
        
        req.newRecordTypeDeveloperName = recordTypeDevName;
        req.recordIdToUpdate = a.Id;
        req.objectName = 'Quote';
        
        List<SetRecordTypeIA.Request> reqList = new List<SetRecordTypeIA.Request>();
        reqList.add(req);
        
        SetRecordTypeIA.execute(reqList);
        
        Quote newAcct = [SELECT Id, RecordTypeId FROM Quote WHERE Id = :a.Id][0];
        System.assert(newAcct.RecordTypeId == recordTypeId, 'Looking for test Quote to have recordTypeId: ' + recordTypeId + ' (DevName: '
                     + recordTypeDevName + '), but found: ' + newAcct.RecordTypeId);
        
        
        
    }
}
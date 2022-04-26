trigger DefaultEntitlement on Case (Before Insert, Before Update) {
	List<Id> contactIds = new List<Id>();
	List<Id> acctIds = new List<Id>();
	for (Case c : Trigger.new) {
		if (c.EntitlementId == null ) {
			if(c.ContactId != null) {
				contactIds.add(c.ContactId);
			}
			if(c.AccountId != null) {
				acctIds.add(c.AccountId);
			}
		}
	}
	if(contactIds.isEmpty()==false || acctIds.isEmpty()==false) {
		List <EntitlementContact> entlContacts =
		[Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId
		 From EntitlementContact e
		 Where e.ContactId in :contactIds
		 And ( e.Entitlement.EndDate >= Today OR e.Entitlement.EndDate = null )
		 And (e.Entitlement.StartDate <= Today OR e.Entitlement.StartDate = null)];
		if(entlContacts.isEmpty()==false) {
			for(Case c : Trigger.new) {
				if(c.EntitlementId == null && c.ContactId != null) {
					for(EntitlementContact ec:entlContacts) {
						if(ec.ContactId==c.ContactId) {
							c.EntitlementId = ec.EntitlementId;
							if(c.AssetId==null && ec.Entitlement.AssetId!=null)
								c.AssetId=ec.Entitlement.AssetId;
							break;
						}
					}
				}
			}
		} else{
			List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate,
			                            e.AccountId, e.AssetId
			                            From Entitlement e
			                            Where e.AccountId in :acctIds And (e.EndDate >= Today or e.EndDate = null)
			                            And (e.StartDate <= Today or e.StartDate = null)];
			if(entls.isEmpty()==false) {
				for(Case c : Trigger.new) {
					if(c.EntitlementId == null && c.AccountId != null) {
						for(Entitlement e:entls) {
							if(e.AccountId==c.AccountId) {
								c.EntitlementId = e.Id;
								if(c.AssetId==null && e.AssetId!=null)
									c.AssetId=e.AssetId;
								break;
							}
						}
					}
				}
			}
		}
	}
}
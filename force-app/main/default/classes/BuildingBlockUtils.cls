public class BuildingBlockUtils {
    @InvocableMethod(label='checkOpportunities' 
                     description='method that checks building blocks totals for a list of Opportunities')
    //method that checks building blocks totals for a list of Opportunities (Opportunity trigger)
    public static void checkOpportunities(List<List<Opportunity>> oppList) {
        system.debug( 'Inputs: ' + oppList[0] );
        
    }
    
    public static void checkOpportunityServices(List<OpportunityLineItem> oppList) {
        system.debug( 'Inputs: ' + oppList[0] );
        
    }
}
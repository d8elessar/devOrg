@IsTest
private class PriceBookManagerTest {
    @isTest static void testUpsertCase() {
        // 1. Insert new record
        Pricebook2 PriceBook = new Pricebook2(
            Name= 'Christeyns Portugal',
            Description='Price Book base para a Christeyns Portugal',
            IsActive= true
        );
        
        List<PricebookEntry> Products = new List<PricebookEntry>();
        
        Product2 Product = new Product2(
        	Name='GenWatt Diesel 5000kW',
            Id='01t3Y00000GU0YlQAL'
        );
        
        PricebookEntry Entry = new PricebookEntry(
            UnitPrice = 49.0,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id = '01t3Y00000GU0YlQAL'
        );
        
        Products.add(Entry);
        
        List<String> output = PriceBookManager.upsertPriceBook(PriceBook, Products);
        
        // Verify new record was created
        System.assert(!output.isEmpty());
        PricebookEntry entry1 = [SELECT Id,UnitPrice FROM PricebookEntry WHERE Id=:output.get(0)];
        System.assert(entry1 != null);
        System.assertEquals(entry1.UnitPrice, 49.0);
        
        // 2. Update price
        Products.remove(0);
        Entry.UnitPrice = 499.99;
        Products.add(Entry);
        
        output.clear();
        output = PriceBookManager.upsertPriceBook(PriceBook, Products);
        
        // Verify record was updated
        System.assertEquals(entry1.Id, output.get(0));
        PricebookEntry entry2 = [SELECT Id,UnitPrice FROM PricebookEntry WHERE Id=:output.get(0)];
        System.assert(entry2 != null);
        System.assertEquals(entry2.UnitPrice, 499.99);
    }    
}
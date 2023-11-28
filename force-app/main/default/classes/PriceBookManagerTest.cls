@IsTest
private class PriceBookManagerTest {
    @isTest
    static void testUpsertCase() {
        // 1. Insert new record
        Pricebook2 PriceBook = new Pricebook2(
            Name = 'Christeyns Portugal',
            Description = 'Price Book base para a Christeyns Portugal',
            IsActive = true
        );

        List<PricebookEntry> Products = new List<PricebookEntry>();

        Product2 Product = new Product2(Name = 'GenWatt Diesel 5000kW', Integration_Id__c = '123');
        insert Product;

        PricebookEntry Entry = new PricebookEntry(
            UnitPrice = 49.0,
            IsActive = true,
            UseStandardPrice = false,
            Product2Id = Product.Id,
            Product2 = Product
        );

        Products.add(Entry);

        List<String> output = PriceBookManager.upsertPriceBook(PriceBook, Products);

        // Verify new record was created
        System.assert(!output.isEmpty());
        PricebookEntry entry1 = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :output.get(0)];
        System.assert(entry1 != null);
        System.assertEquals(entry1.UnitPrice, 49.0);
    }
}
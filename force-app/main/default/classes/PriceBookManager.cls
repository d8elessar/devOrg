@RestResource(urlMapping='/PriceBooks/*')
global with sharing class PriceBookManager {
    @HttpPatch
    global static List<String> upsertPriceBook(Pricebook2 PriceBook, List<PricebookEntry> Products) {
        String priceBookId = '';

        try {
            //upsert PriceBook
            PriceBook.Integration_Id__c = PriceBook.Name;
            upsert PriceBook Pricebook2.Fields.Integration_Id__c;

            //get PriceBook Id
            priceBookId = PriceBook.Id;
            System.debug('priceBookId: ' + priceBookId);

            //add PriceBook to each PriceBookEntry
            List<String> prods = new List<String>();

            for (PricebookEntry Entry : Products) {
                Entry.Pricebook2Id = priceBookId;

                Product2 prod = Entry.Product2;
                Entry.Integration_Id__c = PriceBook.Name + '_' + prod.Integration_Id__c;

                System.debug('prod integration id: ' + prod.Integration_Id__c);
                prods.add(prod.Integration_Id__c);
            }

            //check if product is part of the standard price book
            //Set<Id> records = new Set<Id>{ 'a4fa0000000KzbV','a4fa0000000KzbW' }; //or an existing collection from elsewhere
            List<Product2> prodIds = [
                SELECT Id
                FROM Product2
                WHERE Integration_Id__c IN :prods
            ];

            Pricebook2 standardPriceBook;
            if (!Test.isRunningTest()) {
                standardPriceBook = [
                    SELECT Id
                    FROM Pricebook2
                    WHERE isStandard = TRUE
                    LIMIT 1
                ];
            }

            List<PricebookEntry> entryIds = [
                SELECT Product2Id
                FROM PricebookEntry
                WHERE
                    Pricebook2Id IN (
                        SELECT Id
                        FROM Pricebook2
                        WHERE isStandard = TRUE
                    )
                    AND Product2Id IN :prodIds
            ];

            //Set<Id> entrySet = new Set<PricebookEntry>(entryIds);
            //Set<Id> entrySet = (new Map<Id,PricebookEntry>(entryIds)).keySet();
            Set<Id> entrySet = new Set<Id>();

            for (PricebookEntry entry : entryIds) {
                entrySet.add(entry.Product2Id);
            }

            for (Product2 prod : prodIds) {
                Id prodId = prod.Id;

                if (!entrySet.contains(prodId)) {
                    System.debug('add product to standard price book');
                    PricebookEntry standardPriceBookEntry;
                    // Insert the Product in the Standard Price Book (if necessary)
                    if (Test.isRunningTest()) {
                        standardPriceBookEntry = new PricebookEntry(
                            Pricebook2Id = Test.getStandardPricebookId(),
                            Product2Id = prodId,
                            UnitPrice = 0.0,
                            UseStandardPrice = false,
                            IsActive = true
                        );
                    } else {
                        standardPriceBookEntry = new PricebookEntry(
                            Pricebook2Id = standardPriceBook.Id,
                            Product2Id = prodId,
                            UnitPrice = 0.0,
                            UseStandardPrice = false,
                            IsActive = true
                        );
                    }

                    insert standardPriceBookEntry;
                }
            }

            //upsert products in PriceBookEntry, using existing External Fields (no Id present)
            if (!Products.isEmpty()) {
                upsert Products PricebookEntry.Fields.Integration_Id__c;
            }

            // Return the PriceBookEntry Ids
            List<String> output = new List<String>();

            for (PricebookEntry Entry : Products) {
                output.add(Entry.Id);
                System.debug('Entry.Id: ' + Entry.Id);
            }

            return output;
        } finally {
            priceBookId = null;
        }
    }
}

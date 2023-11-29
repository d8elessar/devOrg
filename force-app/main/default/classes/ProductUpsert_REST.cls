/**
 *@author       Alexandre Valério
 *@date         07/10/2023
 *@group        CustomWebservice
 *@description  MJ Gerust - Custom APEX REST Method to upsert Products in Salesforce
 */
@RestResource(urlMapping='/ProductUpsert')
global with sharing class ProductUpsert_REST {
    /**
     *@description       Main method
     *@return resultList List of strings with the results
     */
    @HttpPost
    global static List<String> upsertProduct() {
        List<String> resultList = new List<String>();
        List<String> articleNoList = new List<String>();
        Map<String, Product2> existingProductsMap = new Map<String, Product2>();
        Map<String, ProductUpsertRequest> inputsMap = new Map<String, ProductUpsertRequest>();
        Map<String, Product2> productUpsertMap = new Map<String, Product2>();

        //handle inputs
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String jsonRequest = req.requestBody.toString();
        List<ProductUpsertRequest> requests = (List<ProductUpsertRequest>) JSON.deserialize(jsonRequest, List<ProductUpsertRequest>.class);

        //check is there are any inputs
        if (requests.isEmpty()) {
            res.statusCode = 500;
            resultList.add('No inputs were found, nothing was changed.');
            return resultList;
        }

        //build a map of products
        for (ProductUpsertRequest request : requests) {
            articleNoList.add(request.ArticleNo);
            inputsMap.put(request.ArticleNo + '---' + request.Language, request);

            //return error in case required fields are empty
            if (String.isBlank(request.Language)) {
                res.statusCode = 500;
                resultList.add('Language is a required field');
                return resultList;
            } else if (String.isBlank(request.ArticleNo)) {
                res.statusCode = 500;
                resultList.add('ArticleNo is a required field');
                return resultList;
            }
        }

        //query all received products
        List<Product2> existingProductsList = [
            SELECT
                Id,
                Name,
                ProductCode,
                Description,
                IsActive,
                Weight__c,
                Article_group__c,
                Country_of_Origin__c,
                Dimension__c,
                Drawing_No__c,
                Language__c,
                Retail_Price__c,
                Sale__c,
                VBME__c,
                Article_No__c,
                Origin_Inland__c,
                Customs_tariff_no__c,
                QuantityUnitOfMeasure
            FROM Product2
            WHERE Article_No__c IN :articleNoList
            WITH SECURITY_ENFORCED
        ];

        //build a map of products
        for (Product2 prod : existingProductsList) {
            existingProductsMap.put(prod.Article_No__c + '---' + prod.Language__c, prod);
        }

        //process request list
        for (ProductUpsertRequest request : requests) {
            String productKey = request.ArticleNo + '---' + request.Language;
            String mainProductKey = request.ArticleNo + '---' + 'DE';
            Product2 product;

            if (existingProductsMap.containsKey(productKey)) {
                //update existing product
                product = existingProductsMap.get(productKey);
                product.IsActive = request.IsActive == 'true' ? true : false;
                product.Name = request.Name;
                product.Country_of_Origin__c = request.CountryOfOrigin;
                product.Weight__c = request.Weight;
                product.Article_No__c = request.ArticleNo;
                product.Drawing_No__c = request.DrawingNo;
                product.Sale__c = request.Sale == 'true' ? true : false;
                product.Article_group__c = request.ArticleGroup;
                product.VBME__c = request.VBME;
                product.Dimension__c = request.Dimension;
                product.Retail_Price__c = request.RetailPrice;
                product.Origin_Inland__c = request.OriginInland;
                product.Customs_tariff_no__c = request.CustomsTariffNo;
                product.Language__c = request.Language;
                product.Description = request.Description;
                product.QuantityUnitOfMeasure = request.QuantityUnitOfMeasure;
            } else {
                //create product
                product = new Product2();
                product.IsActive = request.IsActive == 'true' ? true : false;
                product.Name = request.Name;
                product.Country_of_Origin__c = request.CountryOfOrigin;
                product.Weight__c = request.Weight;
                product.Article_No__c = request.ArticleNo;
                product.Drawing_No__c = request.DrawingNo;
                product.Sale__c = request.Sale == 'true' ? true : false;
                product.Article_group__c = request.ArticleGroup;
                product.VBME__c = request.VBME;
                product.Dimension__c = request.Dimension;
                product.Retail_Price__c = request.RetailPrice;
                product.Origin_Inland__c = request.OriginInland;
                product.Customs_tariff_no__c = request.CustomsTariffNo;
                product.Language__c = request.Language;
                product.Description = request.Description;
                product.QuantityUnitOfMeasure = request.QuantityUnitOfMeasure;
            }

            //if it's not the main product, copy data from main product
            if (!request.Language.equals('DE')) {
                //if it was received at the same time, use the received information
                if (inputsMap.containsKey(mainProductKey)) {
                    product.IsActive = inputsMap.get(mainProductKey).IsActive == 'true' ? true : false;
                    product.Country_of_Origin__c = inputsMap.get(mainProductKey).CountryOfOrigin;
                    product.Weight__c = inputsMap.get(mainProductKey).Weight;
                    product.Drawing_No__c = inputsMap.get(mainProductKey).DrawingNo;
                    product.Sale__c = inputsMap.get(mainProductKey).Sale == 'true' ? true : false;
                    product.Article_group__c = inputsMap.get(mainProductKey).ArticleGroup;
                    product.VBME__c = inputsMap.get(mainProductKey).VBME;
                    product.Dimension__c = inputsMap.get(mainProductKey).Dimension;
                    product.Retail_Price__c = inputsMap.get(mainProductKey).RetailPrice;
                    product.Origin_Inland__c = inputsMap.get(mainProductKey).OriginInland;
                    product.Customs_tariff_no__c = inputsMap.get(mainProductKey).CustomsTariffNo;
                    product.QuantityUnitOfMeasure = inputsMap.get(mainProductKey).QuantityUnitOfMeasure;
                } else {
                    //if it was not received, use the existing main product details
                    if (existingProductsMap.containsKey(mainProductKey)) {
                        product.IsActive = existingProductsMap.get(mainProductKey).IsActive;
                        product.Country_of_Origin__c = existingProductsMap.get(mainProductKey).Country_of_Origin__c;
                        product.Weight__c = existingProductsMap.get(mainProductKey).Weight__c;
                        product.Drawing_No__c = existingProductsMap.get(mainProductKey).Drawing_No__c;
                        product.Sale__c = existingProductsMap.get(mainProductKey).Sale__c;
                        product.Article_group__c = existingProductsMap.get(mainProductKey).Article_group__c;
                        product.VBME__c = existingProductsMap.get(mainProductKey).VBME__c;
                        product.Dimension__c = existingProductsMap.get(mainProductKey).Dimension__c;
                        product.Retail_Price__c = existingProductsMap.get(mainProductKey).Retail_Price__c;
                        product.Origin_Inland__c = existingProductsMap.get(mainProductKey).Origin_Inland__c;
                        product.Customs_tariff_no__c = existingProductsMap.get(mainProductKey).Customs_tariff_no__c;
                        product.QuantityUnitOfMeasure = existingProductsMap.get(mainProductKey).QuantityUnitOfMeasure;
                    }
                }
            } else {
                //it's the main product, so make sure all related products are updated
                for (Product2 prod : existingProductsMap.values()) {
                    //if a related product exists but was not received, update it with main product details
                    if (!inputsMap.containsKey(prod.Article_No__c + '---' + prod.Language__c)) {
                        Product2 relatedProduct = existingProductsMap.get(prod.Article_No__c + '---' + prod.Language__c);

                        relatedProduct.IsActive = product.IsActive;
                        relatedProduct.Country_of_Origin__c = product.Country_of_Origin__c;
                        relatedProduct.Weight__c = product.Weight__c;
                        relatedProduct.Drawing_No__c = product.Drawing_No__c;
                        relatedProduct.Sale__c = product.Sale__c;
                        relatedProduct.Article_group__c = product.Article_group__c;
                        relatedProduct.VBME__c = product.VBME__c;
                        relatedProduct.Dimension__c = product.Dimension__c;
                        relatedProduct.Retail_Price__c = product.Retail_Price__c;
                        relatedProduct.Origin_Inland__c = product.Origin_Inland__c;
                        relatedProduct.Customs_tariff_no__c = product.Customs_tariff_no__c;
                        relatedProduct.QuantityUnitOfMeasure = product.QuantityUnitOfMeasure;

                        productUpsertMap.put(prod.Article_No__c + '---' + prod.Language__c, relatedProduct);
                    }
                }
            }

            productUpsertMap.put(productKey, product);
        }

        //upsert products
        if (!productUpsertMap.isEmpty()) {
            Schema.SObjectField f = Product2.Fields.Id;
            List<Database.upsertResult> uResults = Database.upsert(productUpsertMap.values(), f, false);
            Integer recordCount = 0;

            for (Database.upsertResult sr : uResults) {
                //system.debug(LoggingLevel.DEBUG, 'result: ' + sr.isSuccess());
                recordCount++;

                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors and add them to the
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(
                            LoggingLevel.DEBUG,
                            'The following error has occurred for product #"' +
                                recordCount +
                                ' with ID: ' +
                                sr.getId() +
                                '":: ' +
                                err.getStatusCode() +
                                ': ' +
                                err.getMessage()
                        );

                        System.debug(LoggingLevel.DEBUG, 'Fields that affected this error: ' + err.getFields());

                        resultList.add(
                            'The following error has occurred for product # "' +
                                recordCount +
                                ' with ID: ' +
                                sr.getId() +
                                '":: ' +
                                err.getStatusCode() +
                                ': ' +
                                err.getMessage()
                        );
                        res.statusCode = 500;
                    }
                } else {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug(LoggingLevel.DEBUG, 'Successfully upserted product #' + recordCount + '. Product ID: ' + sr.getId());

                    resultList.add('Successfully upserted product #' + recordCount + '. Product ID: ' + sr.getId());
                    res.statusCode = 200;
                }
            }
        }

        return resultList;
    }

    /**
     *@author       Alexandre Valério
     *@date         07/10/2023
     *@group        CustomWebservice
     *@description  Input fields for this custom APEX REST Method
     */
    global class ProductUpsertRequest {
        public String IsActive;
        public String Name;
        public String CountryOfOrigin;
        public Decimal Weight;
        public String ArticleNo;
        public String DrawingNo;
        public String Sale;
        public String ArticleGroup;
        public String VBME;
        public String Dimension;
        public Decimal RetailPrice;
        public String OriginInland;
        public String CustomsTariffNo;
        public String Language;
        public String Description;
        public String QuantityUnitOfMeasure;
    }
}

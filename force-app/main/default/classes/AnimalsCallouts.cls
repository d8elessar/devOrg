public class AnimalsCallouts {
    public static HttpResponse makeGetCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map < String,
            Object > results = (Map < String, Object > )JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'animals' key as a list
            List < Object > animals = (List < Object > )results.get('animals');
            System.debug('Received the following animals:');
            for (Object animal: animals) {
                System.debug(animal);
            }
        }
        return response;
    }

    public class Aux {
        ID Id;
        String Product2Id;
        Decimal Quantity;
        String Description;

        public Aux(ID Ident, String ProductId, Decimal Quant, String Descp) {
            Id = Ident;
            Product2Id = ProductId;
            Quantity = Quant;
            Description = Descp;
        }
    }

    public static HttpResponse makePostCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Order order = [select Id, AccountId, EffectiveDate from Order where Id = '8013Y00000B83OwQAJ' limit 1];

        OrderItem[]orderItems = [SELECT Id, Product2Id, Quantity, Description FROM OrderItem WHERE orderid = : order.Id limit 2];

        /*        String jsonString = JSON.serialize(new Map<String, Object> {
        'Fecha' => fecha,
        'Detalle' => listaCot
        });*/

        // Map<ID, Order> m = new Map<ID, Order>([select Id, Name from Order where Id = '8013Y00000B83OwQAJ' limit 1]);

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('Id', order.Id);
        gen.writeIdField('AccountId', order.AccountId);
        gen.writeDateField('StartDate', order.EffectiveDate);

        if (orderItems.size() > 0) {
            gen.writeFieldName('OrderItems');
            gen.writeStartObject();

            List < Aux > items = new List < Aux > ();
            for (OrderItem item: orderItems) {
                //gen.writeObjectField('Product', item);	//fica com coisas a mais, como links para o record tipo REST
                /*gen.writeFieldName('OrderItem');
                gen.writeStartObject();
                gen.writeStringField('Id', item.Id);
                gen.writeStringField('Product2Id', item.Product2Id);
                gen.writeNumberField('Quantity', item.Quantity);
                //gen.writeStringField('Description', item.Description);
                gen.writeEndObject();*/
                Aux A = new Aux(item.Id, item.Product2Id, item.Quantity, item.Description);
                items.add(A);
            }

            gen.writeObjectField('OrderItem', items);

            gen.writeEndObject();
        }

        String pretty = gen.getAsString();

        System.debug('pretty: ' + pretty);

        request.setBody('{"name":"mighty moose"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        return response;
    }
}
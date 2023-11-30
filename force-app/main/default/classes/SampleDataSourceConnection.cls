global class SampleDataSourceConnection extends DataSource.Connection {
    private String customerId = null;
    private String invoiceId = null;

    global SampleDataSourceConnection(DataSource.ConnectionParams connectionParams) {
    }

    override global List<DataSource.Table> sync() {
        List<DataSource.Table> tables = new List<DataSource.Table>();
        List<DataSource.Column> columns;
        columns = new List<DataSource.Column>();
        columns.add(DataSource.Column.text('invoice_navision_id', 255));
        columns.add(DataSource.Column.text('customer_navision_id', 255));
        columns.add(DataSource.Column.text('number', 255));
        columns.add(DataSource.Column.text('invoice_date', 255));
        columns.add(DataSource.Column.text('due_date', 255));
        columns.add(DataSource.Column.text('descriptive', 255));
        columns.add(DataSource.Column.text('total_price', 255));
        columns.add(DataSource.Column.text('state', 255));
        columns.add(DataSource.Column.text('iban', 255));
        columns.add(DataSource.Column.url('DisplayUrl'));
        columns.add(DataSource.Column.text('ExternalId', 255));
        tables.add(DataSource.Table.get('Sample', 'Title', columns));

        columns = new List<DataSource.Column>();
        columns.add(DataSource.Column.text('invoice_navision_id', 255));
        columns.add(DataSource.Column.text('product_navision_id', 255));
        columns.add(DataSource.Column.text('quantity', 255));
        columns.add(DataSource.Column.text('unit_price', 255));
        columns.add(DataSource.Column.text('total_com_iva', 255));
        columns.add(DataSource.Column.text('total_sem_iva', 255));
        columns.add(DataSource.Column.text('iva', 255));
        columns.add(DataSource.Column.text('unit_measure', 255));
        columns.add(DataSource.Column.url('DisplayUrl'));
        columns.add(DataSource.Column.text('ExternalId', 255));
        tables.add(DataSource.Table.get('Sample2', 'Title2', columns));

        return tables;
    }

    override global DataSource.TableResult query(DataSource.QueryContext c) {
        System.debug('query: ' + c);

        if (c.tableSelection.filter.subfilters != null) {
            customerId = String.valueOf(c.tableSelection.filter.subfilters.get(0).columnValue);
        } else if (c.tableSelection.filter != null) {
            customerId = String.valueOf(c.tableSelection.filter.columnValue).split(';')[0];
            invoiceId = String.valueOf(c.tableSelection.filter.columnValue).split(';')[1];
        }

        System.debug('query customerId: ' + customerId);
        System.debug('query invoiceId: ' + invoiceId);

        return DataSource.TableResult.get(c, getRows());
    }

    override global List<DataSource.TableResult> search(DataSource.SearchContext c) {
        System.debug('search: ' + c);

        List<DataSource.TableResult> results = new List<DataSource.TableResult>();
        customerId = String.valueOf(c.searchPhrase);
        System.debug('search customerId: ' + customerId);

        for (DataSource.TableSelection tableSelection : c.tableSelections) {
            results.add(DataSource.TableResult.get(tableSelection, getRows()));
        }

        return results;
    }

    // Helper method to get record values from the external system.
    private List<Map<String, Object>> getRows() {
        List<Map<String, Object>> rows = new List<Map<String, Object>>();

        if (customerId == null) {
            return rows;
        }

        // Get row field values from the external system via a callout.
        HttpResponse response = makeGetCallout(this.customerId);
        // Parse the JSON response and populate the rows.
        String estado = 'erro';
        Dom.XMLNode resposta;
        Dom.XMLNode erros;
        //String mensagem;

        /*Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> error = (Map<String, Object>) m.get('error');
        if (error != null) {
            throwException(string.valueOf(error.get('message')));
        }*/

        if (response.getStatusCode() == 200 && response.getBody() != null && response.getBody() != '') {
            Dom.Document doc = response.getBodyDocument();
            if (doc != null) {
                //Retrieve the root element for this document.
                Dom.XMLNode root = doc.getRootElement();
                if (root != null) {
                    Dom.XMLNode bodyXML = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                    if (bodyXML != null) {
                        Dom.XMLNode clResult = bodyXML.getChildElement(
                            'ListaFaturasPendentesCliente_Result',
                            'urn:microsoft-dynamics-schemas/codeunit/Salesforce'
                        );
                        if (clResult != null) {
                            resposta = clResult.getChildElement('response', 'urn:microsoft-dynamics-schemas/codeunit/Salesforce');
                            if (resposta != null) {
                                estado = resposta.getChildElement('estado', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                                erros = resposta.getChildElement('erros', 'urn:microsoft-dynamics-nav/xmlports/x50005');
                            }
                        }
                    }
                }
            }

            system.debug('estado: ' + estado);
            system.debug('erros: ' + erros);

            //Dom.XMLNode dados = resposta.getChildElement('Invoices', 'urn:microsoft-dynamics-nav/xmlports/x50005');
            //system.debug('Invoices: ' + dados);

            List<Dom.XMLNode> respostaList = resposta.getChildElements();
            system.debug('respostaList: ' + respostaList);
            Dom.XMLNode invoice;

            for (Dom.XMLNode node : respostaList) {
                system.debug('node: ' + node);
                //invoice = node.getChildElement('Invoices', 'urn:microsoft-dynamics-nav/xmlports/x50005');
                //system.debug('invoice: ' + invoice);

                system.debug('node name: ' + node.getName());
                system.debug('node namespace: ' + node.getNamespace());
                system.debug('node type: ' + node.getNodeType());
                system.debug('node text: ' + node.getText());

                if (node.getName() == 'Invoices') {
                    String invoice_navision_id = node.getChildElement('invoice_navision_id', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String customer_navision_id = node.getChildElement('customer_navision_id', 'urn:microsoft-dynamics-nav/xmlports/x50005')
                        .getText();
                    String number1 = node.getChildElement('number', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String invoice_date = node.getChildElement('invoice_date', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String due_date = node.getChildElement('due_date', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String descriptive = node.getChildElement('descriptive', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String total_price = node.getChildElement('total_price', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String state = node.getChildElement('state', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();
                    String iban = node.getChildElement('iban', 'urn:microsoft-dynamics-nav/xmlports/x50005').getText();

                    system.debug('invoice_navision_id: ' + invoice_navision_id);
                    system.debug('customer_navision_id: ' + customer_navision_id);
                    system.debug('number1: ' + number1);
                    system.debug('invoice_date: ' + invoice_date);
                    system.debug('due_date: ' + due_date);
                    system.debug('descriptive: ' + descriptive);
                    system.debug('total_price: ' + total_price);
                    system.debug('state: ' + state);
                    system.debug('iban: ' + iban);

                    Map<String, Object> row = new Map<String, Object>();
                    row.put('invoice_navision_id', invoice_navision_id);
                    row.put('ExternalId', customer_navision_id + ';' + invoice_navision_id);
                    row.put('customer_navision_id', customer_navision_id);
                    row.put('number', number1);
                    row.put('invoice_date', invoice_date);
                    row.put('due_date', due_date);
                    row.put('descriptive', descriptive);
                    row.put('total_price', total_price);
                    row.put('state', state);
                    row.put('iban', iban);

                    //if it's a detail page
                    if (invoiceId != null) {
                        //only return the correct record
                        if (invoiceId == invoice_navision_id) {
                            rows.add(row);
                        }
                    } else {
                        //return everything
                        rows.add(row);
                    }
                }
            }

            //might be needed if the FOR above doesn't work as expected
            //if (dados != null && estado == 'ok') {
            //}
        }

        /*List<Object> jsonRows = (List<Object>) m.get('value');
        if (jsonRows == null) {
            rows.add(foundRow(m));
        } else {
            for (Object jsonRow : jsonRows) {
                Map<String, Object> row = (Map<String, Object>) jsonRow;
                rows.add(foundRow(row));
            }
        }*/
        return rows;
    }

    // Helper methods

    // Make a GET callout
    private static HttpResponse makeGetCallout(String customerId) {
        // Make callout
        HttpRequest req = new HttpRequest();

        system.debug('build request');

        // prettier-ignore
        String body =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/Salesforce" xmlns:x50="urn:microsoft-dynamics-nav/xmlports/x50005">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
                '<sal:ListaFaturasPendentesCliente>' +
                    '<sal:customer_navision_id>' + customerId + '</sal:customer_navision_id>' +
                    '<sal:response></sal:response>' +
                '</sal:ListaFaturasPendentesCliente>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';
        //remove all 'null' values from the request
        body = body.replaceAll('null', '');

        system.debug('request built: ' + body);
        req.setBody(body);

        String username = 'logista\\ptx01057';
        String password = 'Nudu!3186';

        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/Salesforce:ListaFaturasPendentesCliente'); //Clientes
        headerMap.put('Content-Type', 'text/xml;charset=UTF-8');
        headerMap.put('Accept-Encoding', 'gzip,deflate');

        req.setEndpoint('callout:Navision_Logista');
        req.setMethod('POST');

        HttpClient httpObj = new HttpClient(username, password, false);

        Httpresponse response = new Httpresponse();
        response = httpObj.send(req, headerMap);
        // Parse the JSON response
        System.debug('The status code returned was: ' + response.getStatusCode() + ' ' + response.getStatus());
        System.debug(response.getBody());

        return response;
    }

    // Populate a row based on values from the external system.
    /*private Map<String, Object> foundRow(Map<String, Object> foundRow) {
        Map<String, Object> row = new Map<String, Object>();
        row.put('ExternalId', string.valueOf(foundRow.get('Id')));
        row.put('DisplayUrl', string.valueOf(foundRow.get('DisplayUrl')));
        row.put('Name', string.valueOf(foundRow.get('Name')));
        return row;
    }*/
}
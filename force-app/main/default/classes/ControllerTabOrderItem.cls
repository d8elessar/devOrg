public class ControllerTabOrderItem {
    
    public static List<PricebookEntry> getPriceBooks(){
        Id orderId = ApexPages.currentPage().getParameters().get('id');	//Id da order, vai buscar ao contexto da visualforce page
        
        List<Order> encomendas = [SELECT Id, Pricebook2Id FROM Order WHERE Id=:orderId];	//pesquisa o price book da order
        Order encomenda;
        
        //TODO: validar se a order foi encontrada e se tem price book, senão devolve erro em vez de pesquisar por produtos
        if(!encomendas.isEmpty()) {
             encomenda= encomendas[0];
        }
        
        List<PricebookEntry> pBooks = new List<PricebookEntry>();
        //for(Order ord :new Order()) {
        // ord.Pricebook2Id = pBooks.get(ord.Pricebook2Id);
        // if(pBooks.Pricebook2Id==ord.Pricebook2Id && IsActive=true){
        // PriceBookEntry[] pbeExist =[SELECT Id, Product2Id, Pricebook2Id, IsActive  FROM PriceBookEntry WHERE Pricebook2Id = :ord.Pricebook2Id  LIMIT 1]; 
        //}
        for(PriceBookEntry pbeExist:[SELECT Id, Product2Id, Product2.Name, Pricebook2Id, IsActive FROM PriceBookEntry WHERE Pricebook2Id = :encomenda.Pricebook2Id and IsActive=true]){
            //if(pBooks.get(pbeExist.Pricebook2Id)){//.get só funciona para Maps, não para Lists
            pBooks.add(pbeExist);     
        }
        //este else não vai funcionar sem o if lá em cima
        /*else{
            List<PricebookEntry> lstpBooks = new List<PricebookEntry>();  
            lstpBooks.add(pbeExist);
            pBooks.add(pbeExist.Pricebook2Id, lstpBooks);       
            }
        }*/
        
        return pBooks;
    }
}
global class SampleDataSourceProvider extends DataSource.Provider {
    public SampleDataSourceProvider() {
    }

    override global List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities = new List<DataSource.AuthenticationCapability>();
        capabilities.add(DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }

    override global List<DataSource.Capability> getCapabilities() {
        List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY); //SOQL
        capabilities.add(DataSource.Capability.SEARCH); //SOSL and Salesforce searches
        //capabilities.add(DataSource.Capability.ROW_CREATE); //upserting external data
        //capabilities.add(DataSource.Capability.ROW_UPDATE); //upserting external data
        //capabilities.add(DataSource.Capability.ROW_DELETE); //deleting external data
        capabilities.add(DataSource.Capability.REQUIRE_ENDPOINT);
        return capabilities;
    }

    override global DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams) {
        return new SampleDataSourceConnection(connectionParams);
    }
}
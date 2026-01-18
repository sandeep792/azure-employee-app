const { app } = require('@azure/functions');
const { CosmosClient } = require('@azure/cosmos');
const { DefaultAzureCredential } = require('@azure/identity');

app.http('getEmployees', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        context.log(`Http function processed request for url "${request.url}"`);

        const endpoint = process.env.COSMOS_ENDPOINT;
        const databaseId = process.env.COSMOS_DATABASE || 'EmployeeDB';
        const containerId = process.env.COSMOS_CONTAINER || 'Employees';

        if (!endpoint) {
            return { status: 500, body: "Missing COSMOS_ENDPOINT configuration" };
        }

        try {
            // Use Managed Identity
            const client = new CosmosClient({ 
                endpoint, 
                aadCredentials: new DefaultAzureCredential() 
            });

            const database = client.database(databaseId);
            const container = database.container(containerId);

            // Simple query to get all items
            const querySpec = {
                query: "SELECT c.id, c.name, c.department, c.role FROM c"
            };

            const { resources: items } = await container.items
                .query(querySpec)
                .fetchAll();

            return {
                jsonBody: items
            };
        } catch (error) {
            context.log.error("Error fetching employees:", error);
            return {
                status: 500,
                body: "Error fetching data"
            };
        }
    }
});

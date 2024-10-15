
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordCore.Models;

namespace ServerSVH.DocRecordDataAccess
{
    public class DocRecordContext : IDocRecordContext
    {
        private readonly IMongoDatabase _database = null;
        public DocRecordContext(IOptions<Settings> settings)
        {
            var client = new MongoClient(settings.Value.ConnectionString);
            if (client != null)
            {
                _database = client.GetDatabase(settings.Value.Database);
            }
        }
        public IMongoCollection<DocRecord> DocRecords
        {
            get
            {
                return _database.GetCollection<DocRecord>("DocRecord");
            }
        }
    }
}

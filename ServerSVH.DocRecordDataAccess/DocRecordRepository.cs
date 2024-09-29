using ServerSVH.DocRecordCore.Abstraction;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using ServerSVH.DocRecordCore.Models;


namespace ServerSVH.DocRecordDataAccess
{
    public class DocRecordRepository : IDocRecordRepository
    {
        private readonly IMongoCollection<DocRecord> _docRecordCollection;

        public DocRecordRepository(IOptions<DocRecordDBSettings> DocRecordDBSettings, IMongoClient client)
        {
            var database = client.GetDatabase(DocRecordDBSettings.Value.MongoDBName);

            _docRecordCollection = database.GetCollection<DocRecord>(DocRecordDBSettings.Value.MongoDBName);

            //var mongoClient = new MongoClient(
            //    DocBodyDBSettings.Value.MongoDBContext);

            //var mongoDatabase = mongoClient.GetDatabase(
            //   DocBodyDBSettings.Value.MongoDBName);

            //_docBodyCollection = mongoDatabase.GetCollection<DocRecord>(
            //    DocBodyDBSettings.Value.MongoDBCollectionName);
            //this.DocRecordDBSettings = DocRecordDBSettings;

        }

        public async Task<DocRecord?> GetByDocId(Guid docId) =>
        await _docRecordCollection.Find(x => x.DocId == docId).FirstOrDefaultAsync();

        public async Task<Guid> Add(DocRecord docRecord)
        {
            await _docRecordCollection.InsertOneAsync(docRecord);
            return docRecord.DocId;
        }

        public async Task Update(Guid Docid, DocRecord docRecord) =>
           await _docRecordCollection.ReplaceOneAsync(x => x.DocId == Docid, docRecord);

        public async Task DeleteId(Guid Docid) =>
            await _docRecordCollection.DeleteOneAsync(x => x.DocId == Docid);



    }
}

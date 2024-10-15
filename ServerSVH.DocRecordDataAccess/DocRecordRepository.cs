using ServerSVH.DocRecordCore.Abstraction;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using ServerSVH.DocRecordCore.Models;


namespace ServerSVH.DocRecordDataAccess
{
    public class DocRecordRepository : IDocRecordRepository
    {
        private readonly DocRecordContext _docRecordCollection;
        public DocRecordRepository(IOptions<Settings> settings) => _docRecordCollection = new DocRecordContext(settings);
        public async Task<DocRecord> GetByDocId(Guid docId)
        {
            var filter = Builders<DocRecord>.Filter.Eq("DocId", docId);

            try
            {
                return await _docRecordCollection.DocRecords
                                .Find(filter)
                                .FirstOrDefaultAsync();
            }
            catch (Exception)
            {
                throw;
            }
        }
        public async Task<Guid> AddRecord(DocRecord item)
        {
            try
            {
                await _docRecordCollection.DocRecords.InsertOneAsync(item);
                return item.DocId;
            }
            catch (Exception)
            {
                throw;
            }
        }
        public async Task<long> UpdateRecord(Guid DocId, DocRecord docRecord)
        {
            var filter = Builders<DocRecord>.Filter.Eq(s => s.DocId, DocId);
            var update = Builders<DocRecord>.Update
                            .Set(s => s.DocText, docRecord.DocText)
                            .Set(s => s.ModifyDate, DateTime.Now);
            try
            {
                var resUpdate = await _docRecordCollection.DocRecords.UpdateOneAsync(filter, update);
                if (resUpdate != null) return resUpdate.ModifiedCount;
                else return 0;
            }
            catch (Exception)
            {
                throw;
            }
        }

        public async Task<long> DeleteId(Guid Docid)
        {
            try
            {
                var resDel = await _docRecordCollection.DocRecords.DeleteOneAsync(x => x.DocId == Docid);
                if (resDel != null) return resDel.DeletedCount;
                else return 0;
            }
            catch (Exception)
            {
                throw;
            }
        }



    }
}

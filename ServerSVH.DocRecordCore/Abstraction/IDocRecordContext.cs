
using MongoDB.Driver;
using ServerSVH.DocRecordCore.Models;

namespace ServerSVH.DocRecordCore.Abstraction
{
    public interface IDocRecordContext
    {
        IMongoCollection<DocRecord> DocRecords { get; }
    }
}
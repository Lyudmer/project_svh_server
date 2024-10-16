using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
namespace ServerSVH.DocRecordDataAccess.Entities
{
    public class DocRecordEntity
    {
        [BsonId]
        public ObjectId Id { get; set; }

        [BsonElement("doc_id")]
        public Guid DocId { get; set; }
        [BsonElement("doc_body")]
        public string DocText { get; set; } = null!;

    }
}

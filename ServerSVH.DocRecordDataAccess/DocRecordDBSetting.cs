namespace ServerSVH.DocRecordDataAccess
{
    public class DocRecordDBSettings
    {
        public string MongoDBConnectionString { get; set; } = null!;
        public string MongoDBName { get; set; } = null!;
        public string MongoDBCollectionName { get; set; } = null!;

    }
}

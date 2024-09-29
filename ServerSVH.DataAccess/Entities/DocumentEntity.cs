
namespace ServerSVH.DataAccess.Entities
{
    public class DocumentEntity
    {
        public int Id { get; set; }
        public int SizeDoc { get; set; }
        public string DocType { get; set; } = string.Empty;
        public string Idmd5 { get; set; } = string.Empty;
        public string IdSha256 { get; set; } = string.Empty;
        public DateTime CreateDate { get; set; }
        public DateTime ModifyDate { get; set; }
        public int Pid { get; set; }
        public PackageEntity? Package { get; set; }
        public Guid DocId { get; set; }
        
    }
}

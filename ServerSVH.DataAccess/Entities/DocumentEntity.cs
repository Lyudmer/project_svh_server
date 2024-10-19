
namespace ServerSVH.DataAccess.Entities
{
    public class DocumentEntity
    {
        public int Id { get; set; }
        public Guid DocId { get; set; }
        public DateTime CreateDate { get; set; } = DateTime.Now.Date;
        public DateTime ModifyDate { get; set; } = DateTime.Now.Date;
        public int SizeDoc { get; set; }
        public string DocType { get; set; } = string.Empty;
        public string Idmd5 { get; set; } = string.Empty;
        public string IdSha256 { get; set; } = string.Empty;
        public int Pid { get; set; }
        public PackageEntity? Package { get; set; }
    }
}

namespace ServerSVH.DocRecordCore.Models
{
    public class DocRecord
    {
        private DocRecord(Guid id, Guid docId, string docText, DateTime createDate, DateTime modifyDate)
        {
            Id = id;
            DocId = docId;
            DocText = docText;
            CreateDate = createDate;
            ModifyDate = modifyDate;
        }

        public Guid Id { get; set; }
        public Guid DocId { get; set; }
        public DateTime CreateDate { get; set; } = DateTime.Now;
        public DateTime ModifyDate { get; set; } = DateTime.Now;
        public string DocText { get; set; } = null!;
        public static DocRecord Create(Guid id, Guid docId, string docText, DateTime createDate, DateTime modifyDate)
        {
            var docrecord = new DocRecord(id, docId, docText, createDate, modifyDate);
            return docrecord;
        }

    }



}

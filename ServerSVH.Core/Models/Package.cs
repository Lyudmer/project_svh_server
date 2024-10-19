namespace ServerSVH.Core.Models
{
    public class Package
    {
        private Package(int pid, Guid userId, int statusId, Guid uuId, DateTime createDate, DateTime modifyDate)
        {
            Id = pid;
            UserId = userId;
            StatusId = statusId;
            UUID = uuId;
            CreateDate = createDate;
            ModifyDate = modifyDate;
        }
        public int Id { get; set; }
        public Guid UserId { get; set; }= Guid.Empty;
        public int StatusId { get; set; }

        public Guid UUID { get; set; }=Guid.Empty;
        public DateTime CreateDate { get; set; } = DateTime.UtcNow;
        public DateTime ModifyDate { get; set; } = DateTime.UtcNow;
        public static Package Create(int pid, Guid userId, int statusId, Guid uuId,
                                     DateTime createDate, DateTime modifyDate)
        {
            var package = new Package(pid, userId, statusId, uuId, createDate, modifyDate);
            return package;
        }
        public ICollection<Document> Documents { get; set; } = [];
    }
}

namespace ServerSVH.DataAccess.Entities
{
    public class PackageEntity
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public int StatusId { get; set; }
        public Guid UUID { get; set; } 
        public DateTime CreateDate { get; set; }=DateTime.Now.Date;
        public DateTime ModifyDate { get; set; } = DateTime.Now.Date;


        public ICollection<DocumentEntity> Documents { get; set; } = [];
      

    }
}

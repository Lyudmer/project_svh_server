using ServerSVH.DocRecordCore.Models;

namespace ServerSVH.DocRecordCore.Abstraction
{
    public interface IDocRecordRepository
    {
        Task<Guid> Add(DocRecord docRecord);
        Task DeleteId(Guid Docid);
        Task<DocRecord?> GetByDocId(Guid docId);
        Task Update(Guid Docid, DocRecord docRecord);
    }
}
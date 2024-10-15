

using ServerSVH.Core.Models;


namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IDocumentsRepository
    {
        Task<Document> Add(Document Doc);
        Task Delete(int Id);
        Task Delete(Guid Id);
        Task<List<Document>> GetByFilter(int pid);
        Task<Document> GetById(int id);
        Task<Document> GetByDocType(int pid,string docType);
        Task<List<Document>> GetListByDocType(int pid, string docType);
        Task<Document> GetByGuidId(Guid did);
        Task<List<Document>> GetByPage(int page, int page_size);
        Task<int> GetLastDocId();
        Task Update(Guid DocId, Document Doc);
    }
}
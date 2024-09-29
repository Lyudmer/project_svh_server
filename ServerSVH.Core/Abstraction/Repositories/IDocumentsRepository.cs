

using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Models;

namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IDocumentsRepository
    {
        Task<Document> Add(Document Doc);
        Task Delete(int Id);
        Task<List<Document>> GetByFilter(int pid);
        Task<Document> GetById(int id);
        Task<Document> GetByGuidId(Guid did);
        Task<List<Document>> GetByPage(int page, int page_size);
        Task<int> GetLastDocId();
        Task Update(int Id);
    }
}
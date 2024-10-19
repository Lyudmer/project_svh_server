using ServerSVH.Core.Models;

namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IPackagesRepository
    {
        Task<Package> Add(Package Pkg);
        Task Delete(int Pid);
        Task<List<Package>> GetAll();
        Task<Package> GetById(int Pid);
        Task<Package> GetByUUId(Guid uuid);
        Task<List<Package>> GetByPage(int Page, int Page_Size);
        Task<int> GetLastPkgId();
   
        Task<int> GetPkgByGuid(Guid UserId, Guid UUID);
        Task<List<Package>> GetPkgUser(Guid UserId);
        Task<Package> GetPkgWithDoc(int Pid);
        Task <int>UpdateStatus(int Pid, int statusId);
    }
}
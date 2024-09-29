using ServerSVH.Core.Models;

namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IPackagesRepository
    {
        Task<Package> Add(Package Pkg);
        Task Delete(int Pid);
        
        Task<Package> GetById(int Pid);
        Task<List<Package>> GetByPage(int Page, int Page_Size);
        Task<Package> GetPkgWithDoc(int Pid);
        Task UpdateStatus(int Pid, int statusId);
        Task<int> GetLastPkgId();
        Task<int> GetByStatus(int Pid);


    }
}
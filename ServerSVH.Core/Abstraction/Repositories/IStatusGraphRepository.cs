using ServerSVH.Core.Models;


namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IStatusGraphRepository
    {
        Task Add(StatusGraph statusGraph);
        Task Delete(StatusGraph statusGraph);
        Task<StatusGraph> GetNewSt(int OldSt);
    }
}
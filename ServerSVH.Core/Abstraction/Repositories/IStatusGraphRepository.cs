using ServerSVH.Core.Models;


namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IStatusGraphRepository
    {
        Task<StatusGraph> Add(StatusGraph statusGraph);
        Task Delete(StatusGraph statusGraph);
        Task<StatusGraph> GetNewSt(int OldSt);
    }
}
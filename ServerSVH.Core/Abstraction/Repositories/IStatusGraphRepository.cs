namespace ServerSVH.Core.Abstraction.Repositories
{
    public interface IStatusGraphRepository
    {
        Task Add(int oldst, int newst, string maskbit);
        Task Delete(int oldst, int newst);
        Task<int> GetNewSt(int OldSt);
    }
}
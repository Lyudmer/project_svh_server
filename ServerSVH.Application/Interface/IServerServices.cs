
namespace ServerSVH.Application.Interface
{
    public interface IServerServices
    {
        Task<int> LoadMessage();
        Task<int> LoadMessageFile(string resMess, string typeMess);
    }
}
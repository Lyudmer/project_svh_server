namespace ServerSVH.Application.Interface
{
    public interface IServerServices
    {
         Task<int> LoadMessage();
    }
}
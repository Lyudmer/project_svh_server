

namespace ServerSVH.Core.Abstraction.Services
{
    public interface IPackagesServices
    {
        Task<int> ReceiptFromClient(string Message);
        Task<int> SendToClient(string Message);
        Task<string> TransformPkg(string Message);

        //Task<int> SendToEmul(int Pid);
        //Task<int> SendToClient(int Pid,int Status);
        //Task<int> LoadEmul(int Pid,string Message);
    }
}
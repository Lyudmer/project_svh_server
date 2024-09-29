using ServerSVH.Core.Abstraction.Repositories;

namespace ServerSVH.SendReceiv
{
    public class ServerServices(IPackagesRepository pkgRepository)
    {

        private readonly IPackagesRepository _pkgRepository = pkgRepository;

        public static Task<int> ReceiptFromClient(string Message)
        {
            int StPkg = 0;


            return Task.FromResult(StPkg);
        }

        //public async Task<int> SendToClient(string Message)
        //{

        //}
        //public async Task<string> TransformPkg(string Message)
        //{

        //}
    }
}

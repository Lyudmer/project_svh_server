
using ClientSVH.Contracts;
using ServerSVH.Application.Interface;
using ServerSVH.Core.Abstraction.Services;
using ServerSVH.SendReceiv;




namespace ServerSVH.Endpoints
{
    public static  class ServerEndpoints
    {
        public static IEndpointRouteBuilder MapPackagesEndpoints(this IEndpointRouteBuilder app)
        {
            var endpoints = app.MapGroup("Packages");
            app.MapGet("LoadPackage", LoadMessage);
            app.MapGet("LoadPackageFile", LoadMessageFile);
            app.MapGet("GetPackage", GetPkgAll);
            app.MapGet("GetPackage{Pid:int}", GetPkgId);

            return app;
        }
        private static async Task<IResult> GetPkgAll(ServerFunction srvService)
        {
            await ((IServerFunction)srvService).GetPackageList();
            return Results.Ok();
        }
        private static async Task<IResult> GetPkgId(int Pid, ServerFunction srvService)
        {
            await ((IServerFunction)srvService).GetPkgId(Pid);
            return Results.Ok();
        }
        private static async Task<IResult> LoadMessage(ServerServices srvService)
        {
            await ((IServerServices)srvService).LoadMessage();
            return Results.Ok();
        }
        private static async Task<IResult> LoadMessageFile(LoadFileRequest request, ServerServices srvService)
        {
            await ((IServerServices)srvService).LoadMessageFile(request.FileName,request.TypeMess);
            return Results.Ok();
        }
    }
}

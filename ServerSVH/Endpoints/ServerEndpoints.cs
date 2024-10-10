
using ServerSVH.Application.Interface;
using ServerSVH.SendReceiv;




namespace ServerSVH.Endpoints
{
    public static  class ServerEndpoints
    {
        public static IEndpointRouteBuilder MapPackagesEndpoints(this IEndpointRouteBuilder app)
        {
            var endpoints = app.MapGroup("Packages");
            app.MapGet("GetPackage", GetPkgAll);
            return app;
        }
        private static async Task<IResult> GetPkgAll(ServerServices srvService)
        {
            await ((IServerServices)srvService).GetPackageList();
            return Results.Ok();
        }  
        
    }
}

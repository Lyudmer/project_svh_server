using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using ServerSVH.Application.Interface;
using ServerSVH.Contracts;
using System.Text;


namespace ServerSVH.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServerController( IServerFunction serverFunction, IServerServices serverServices) : ControllerBase
    {
        private readonly IServerFunction _serverFunction = serverFunction;
        private readonly IServerServices _serverServices = serverServices;
        [HttpPost("LoadMessage")]
        public async Task<IActionResult> LoadMess()
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var result = await _serverServices.LoadMessage();

            return Ok(result);
        }

        [HttpPost("GetPackage")]
        public async Task<IActionResult> GetPkgAll(PackageResponse pkgSend)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _serverFunction.GetPackageList();

            return Ok(result);
        }
        [HttpPost("GetDocsPackage")]
        public async Task<IActionResult> GetDocsPkg(DocumentResponse docSend)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _serverFunction.GetDocumentList(docSend.Pid);

            return Ok(result);
        }
        [HttpPost("GetDocRecord")]
        public async Task<IActionResult> GetRecord(DocRequest docSend)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var Doc = await _serverFunction.GetDocument(docSend.Id);
            var result = await _serverFunction.GetRecord(Doc.DocId);

            return Ok(result);
        }
     
    }
}

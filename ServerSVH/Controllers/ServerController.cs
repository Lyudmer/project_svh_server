using Microsoft.AspNetCore.Mvc;
using ServerSVH.Application.Interface;
using ServerSVH.Contracts;


namespace ServerSVH.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServerController(IServerServices srvService) : ControllerBase
    {
        
        
        private readonly IServerServices _srvService = srvService;

    
        [HttpPost("GetPackage")]
        public async Task<IActionResult> GetPkgAll(PackageResponse pkgSend)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _srvService.GetPackageList();

            return Ok(result);
        }
        [HttpPost("GetDocsPackage")]
        public async Task<IActionResult> GetDocsPkg(DocumentResponse docSend)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _srvService.GetDocumentList(docSend.Pid);

            return Ok(result);
        }
        [HttpPost("GetDocRecord")]
        public async Task<IActionResult> GetRecord(DocRequest docSend)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var Doc = await _srvService.GetDocument(docSend.Id);
            var result = await _srvService.GetRecord(Doc.DocId);

            return Ok(result);
        }
    }
}

using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using ServerSVH.Application.Interface;
using ServerSVH.Contracts;
using ServerSVH.Core.Abstraction.Repositories;
using System.Text;


namespace ServerSVH.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServerController( IServerFunction serverFunction,
                                   IServerServices serverServices,
                                   IWebHostEnvironment webHostEnvironment) : ControllerBase
    {
        private readonly IWebHostEnvironment _webHostEnvironment = webHostEnvironment;
        
        private readonly IServerFunction _serverFunction = serverFunction;
        private readonly IServerServices _serverServices = serverServices;
        [HttpPost("LoadFile")]
        public async Task<IActionResult> LoadFile(IFormFile InName)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            int result =0;
            using (var fileStream = new FileStream(_webHostEnvironment.WebRootPath + InName.FileName, FileMode.Create))
            {
                await InName.CopyToAsync(fileStream);

                fileStream.Position = 0;
                using (StreamReader reader = new StreamReader(fileStream, Encoding.UTF8))
                {
                    var resFile = reader.ReadToEnd();
                    reader.Close();

                    if (resFile.Length > 0)
                    {
                         result = await _serverServices.LoadMessageFile(resFile, "sendpkg");
                    }
                }
            }
            return Ok(result);
        }
        [HttpPost("LoadMessage")]
        public async Task<IActionResult> LoadMess()
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var result = await _serverServices.LoadMessage();

            return Ok(result);
        }

        [HttpPost("GetPackageAll")]
        public async Task<IActionResult> GetPkgAll()
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _serverFunction.GetPackageList();

            return Ok(result);
        }
        [HttpPost("GetPackage")]
        public async Task<IActionResult> GetPkgById(PackageRequest pkgRes)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _serverFunction.GetPkgId(pkgRes.Pid);
            
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

using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordCore.Models;
using ServerSVH.SendReceiv.Consumer;
using System.Security.Cryptography;
using System.Xml.Linq;

namespace ServerSVH.SendReceiv
{
    public class Receiving(IRabbitMQConsumer rabbitMQConsumer,
        IDocumentsRepository docRepository, IDocRecordRepository docRecordRepository,
            IPackagesRepository pkgRepository)
    {
        private readonly IRabbitMQConsumer _rabbitMQConsumer = rabbitMQConsumer;
        private readonly IPackagesRepository _pkgRepository = pkgRepository;
        private readonly IDocumentsRepository _docRepository = docRepository;
        private readonly IDocRecordRepository _docRecordRepository = docRecordRepository;

        async Task<int> LoadMessage()
        {
            int stPkg = 0;
            try
            {
                // получить сообщение с пакетом
                string CodeCMN = "SendPkg";
                var resMess = _rabbitMQConsumer.LoadMessage(CodeCMN);
                // создать пакет и запустить workflow
                if (resMess != null)
                {


                    stPkg = int.Parse(resMess);
                    var Pid = int.Parse(resMess);
                    int olsstPkg = _pkgRepository.GetByStatus(Pid).Result;
                    await _pkgRepository.UpdateStatus(Pid, stPkg);


                }


                // поменять статус
            }
            catch (Exception)
            {
                //string mess = ex.Message;

            }
            return stPkg;
        }
        private static Guid GetValuePropsGuid(IEnumerable<XElement>? propsPkg, string nameAtt)
        {

            var valPkg = propsPkg?.Elements("name").Where(s => s.Attribute(nameAtt)?.Value is not null).ToString();
            if (valPkg is not null)
                if (nameAtt == "UserId" || nameAtt == "uuid")
                {
                    if (Guid.TryParse(valPkg, out var res))
                        return res;

                }
            return Guid.NewGuid();

        }
        private static int GetValuePropsInt(IEnumerable<XElement>? propsPkg, string nameAtt)
        {

            var valPkg = propsPkg?.Elements("name").Where(s => s.Attribute(nameAtt)?.Value is not null).ToString();
            if (valPkg is not null && int.TryParse(valPkg, out var res))
                return res;


            return 0;

        }
        private static DateTime GetValuePropsDT(IEnumerable<XElement>? propsPkg, string nameAtt)
        {

            var valPkg = propsPkg?.Elements("name").Where(s => s.Attribute(nameAtt)?.Value is not null).ToString();
            if (valPkg is not null && DateTime.TryParse(valPkg, out var res))
                return res;


            return DateTime.Now;

        }
        private async Task<int> CreatePaskageFromMessage(string Mess)
        {
            int stPkg = -1;
            try
            {
                XDocument xMess = XDocument.Load(Mess);
                if (xMess is null) return stPkg;
                var xPkg = xMess.Element("Package")?
                           .Elements("*").Where(p => p.Attribute("ctmtd")?.Value == "CfgName");
                if (xPkg is not null)
                {
                    //create package
                    var pid_1 = await _pkgRepository.GetLastPkgId() + 1;
                    var attPkg = xMess.Elements("Package")?.Attributes("pid").ToString();
                    if (attPkg is not null && int.TryParse(attPkg, out int Pid))
                    {
                        if (pid_1 <= Pid) pid_1 = Pid;
                    }

                    var propsPkg = xMess.Elements("Package")?.Elements("package-properties");
                    var userPkg = GetValuePropsGuid(propsPkg, "UserId");
                    stPkg = GetValuePropsInt(propsPkg, "Status");
                    var cdPkg = GetValuePropsDT(propsPkg, "CreateDate");
                    Guid uuidPkg = GetValuePropsGuid(propsPkg, "uuid");

                    var Pkg = Package.Create(pid_1, userPkg, stPkg, uuidPkg, cdPkg, DateTime.Now);
                    Pkg = await _pkgRepository.Add(Pkg);
                    Pid = Pkg.Pid;
                    var xDocs = from xDoc in xPkg?.AsParallel().Elements()
                                select new
                                {
                                    tdoc = xDoc.Name?.LocalName,
                                    num = xDoc.Elements().Elements().FirstOrDefault(n => n.Name == "RegNum")?.Value,
                                    dat = xDoc.Elements().Elements().FirstOrDefault(n => n.Name == "RegDate")?.Value,
                                    doctext = xDoc.ToString()

                                };
                    foreach (var doc in xDocs)
                    {
                        var doc_1 = await _docRepository.GetLastDocId() + 1;
                        var DocId = Guid.NewGuid();
                        var Doc = Document.Create(doc_1, DocId,
                                  doc.doctext.Length, GetHashMd5(doc.doctext), GetSha256(doc.doctext),
                                  Pid, DateTime.Now, DateTime.Now);


                        Doc = await _docRepository.Add(Doc);
                        if (Doc is not null)
                        {
                            DocRecord dRecord = DocRecord.Create(Guid.NewGuid(), Doc.DocId, doc.doctext, DateTime.Now, DateTime.Now);
                            var dRecordId = await _docRecordRepository.Add(dRecord);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                string mess = ex.Message;
                //

            }
            return stPkg;
        }
    }
}

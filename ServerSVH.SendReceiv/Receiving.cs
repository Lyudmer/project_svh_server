using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordCore.Models;
using ServerSVH.SendReceiv.Consumer;
using System.Collections.Generic;
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
                    ResLoadPackage resPkg = await PaskageFromMessage(resMess);

                    switch(resPkg.Status)
                    {
                        case -1:
                            //отправить ошибку слиенту

                            break;
                        case 0:
                            await _pkgRepository.UpdateStatus(resPkg.Pid, resPkg.Status);
                            break;
                        case 1:
                            break;
                            //запуск workflow
                        default:
                            // ждем смены статуса
                            break;
                    }

                    //int olsstPkg = _pkgRepository.GetByStatus(resPkg.Pid).Result;
                    //await _pkgRepository.UpdateStatus(Pid, stPkg);


                }


                // поменять статус
            }
            catch (Exception)
            {
                //string mess = ex.Message;

            }
            return stPkg;
        }
   
        private async Task<ResLoadPackage> PaskageFromMessage(string Mess)
        {
            ResLoadPackage resPkg = new(-1, -1);
            try
            {
                XDocument xMess = XDocument.Load(Mess);
               
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
                    

                    var userPkg = ConverterValue.ConvertTo<Guid>(propsPkg?.Elements("name").Where(s => s.Attribute("UserId")?.Value is not null).ToString());
                    var stPkg = ConverterValue.ConvertTo<int>(propsPkg?.Elements("name").Where(s => s.Attribute("Status")?.Value is not null).ToString());
                    var cdPkg = ConverterValue.ConvertTo<DateTime>(propsPkg?.Elements("name").Where(s => s.Attribute("CreateDate")?.Value is not null).ToString());
                    var uuidPkg = ConverterValue.ConvertTo<Guid>(propsPkg?.Elements("name").Where(s => s.Attribute("uuid")?.Value is not null).ToString());
                   
                    var xDocs = from xDoc in xPkg?.AsParallel().Elements()
                                select new
                                {
                                    doctype = xDoc.Attribute("doctype")?.Value,
                                    docid = ConverterValue.ConvertTo<Guid>(xDoc.Attribute("docid")?.Value),
                                    doccreate = ConverterValue.ConvertTo<DateTime>(xDoc.Attribute("createdate")?.Value),
                                    doctext = xDoc.ToString()

                                };
                    // проверить наличие пакета на сервере
                    var getPkg = await _pkgRepository.GetPkgByGuid(userPkg, uuidPkg);
                    if (getPkg != null)
                    {
                        //внести изменения в записи
                        await _pkgRepository.UpdateStatus(getPkg.Pid, stPkg);
                        var Docs =await _docRepository.GetByFilter(getPkg.Pid);
                        foreach (var doc in xDocs)
                        {
                            var Doc = await _docRepository.GetByGuidId(doc.docid);
                            if (Doc != null) { }

                        }
                        resPkg = new(getPkg.Pid, stPkg);
                    }
                    else
                    {
                        // создать новый
                        var Pkg = Package.Create(pid_1, userPkg, stPkg, uuidPkg, cdPkg, DateTime.Now);
                        Pkg = await _pkgRepository.Add(Pkg);
                        Pid = Pkg.Pid;
                        foreach (var doc in xDocs)
                        {
                            var doc_1 = await _docRepository.GetLastDocId() + 1;
                            var Doc = Document.Create(doc_1, doc.docid, doc.doctype, doc.doctext.Length,
                                                      DopFunction.GetHashMd5(doc.doctext), DopFunction.GetSha256(doc.doctext),
                                                        Pid, doc.doccreate, DateTime.Now);


                            Doc = await _docRepository.Add(Doc);
                            if (Doc is not null)
                            {
                                DocRecord dRecord = DocRecord.Create(Guid.NewGuid(), Doc.DocId, doc.doctext, doc.doccreate, DateTime.Now);
                                var dRecordId = await _docRecordRepository.Add(dRecord);
                            }
                        }
                        resPkg = new(Pid, stPkg);
                    }
                }
            }
            catch (Exception ex)
            {
                string mess = ex.Message;
                //

            }
            return resPkg;
        }

        
    }
}

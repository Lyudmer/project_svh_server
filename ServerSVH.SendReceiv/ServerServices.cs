using ServerSVH.Application.Interface;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordCore.Models;
using ServerSVH.SendReceiv.Consumer;
using ServerSVH.SendReceiv.Producer;
using System.Xml.Linq;
using ServerSVH.Application.Common;
using System.Security.Cryptography;
using MongoDB.Driver;
using System.Reflection.Metadata;
using Document = ServerSVH.Core.Models.Document;
using MongoDB.Driver.Core.Operations;

namespace ServerSVH.SendReceiv
{
    public class ServerServices(IRabbitMQConsumer rabbitMQConsumer,
            IDocumentsRepository docRepository, IDocRecordRepository docRecordRepository,
                IPackagesRepository pkgRepository, IMessagePublisher messagePublisher,
                IStatusGraphRepository statusGraphRepository,IRunWorkflow runWorkflow) : IServerServices
    {
        private readonly IRabbitMQConsumer _rabbitMQConsumer = rabbitMQConsumer;
        private readonly IPackagesRepository _pkgRepository = pkgRepository;
        private readonly IDocumentsRepository _docRepository = docRepository;
        private readonly IDocRecordRepository _docRecordRepository = docRecordRepository;
        private readonly IMessagePublisher _messagePublisher = messagePublisher;
        private readonly IStatusGraphRepository _statusGraphRepository = statusGraphRepository;
        private readonly IRunWorkflow _runWorkflow = runWorkflow;
        async Task<int> IServerServices.LoadMessage()
        {
            int stPkg = 0;
            try
            {
                // получить сообщение с пакетом
                var resMessEmul = _rabbitMQConsumer.LoadMessage("EmulSendDoc");
                var resMess = _rabbitMQConsumer.LoadMessage("SendPkg");
                // создать пакет и запустить workflow
                if (resMess != null || resMessEmul!=null)
                {
                    ResLoadPackage resPkg = await PaskageFromMessage(resMess);
                    XDocument xPkg = XDocument.Load(resMess);
                    
                    switch (resPkg.Status)
                    {
                        case -1:
                        case 4:
                            //отправить ошибку клиенту
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            break;
                        case 1:
                            await _pkgRepository.UpdateStatus(resPkg.Pid, resPkg.Status);
                            //отправить собщение клиенту
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            //запуск workflow
                            _runWorkflow.RunBuilderXml(xPkg,ref resPkg);
                            
                            if (stPkg == 3) goto case 3;
                            if (stPkg == 4) goto case 4;
                            break;
                        case 3:
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);

                            if (stPkg == 5) goto case 5;
                            if (stPkg == 4) goto case 4;

                            break;
                        case 5:
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            try
                            {
                                List<XDocument> resXml = await CreatePkgForEmul(resPkg);
                                var CountDoc = resXml.Count();
                                
                                foreach (XDocument xDoc in resXml)
                                {
                                    _messagePublisher.SendMessage(xDoc.ToString(), "SendEmulPkg");
                                    CountDoc--;
                                }
                                if (CountDoc == 0) 
                                {
                                    resPkg.Status = 208;
                                    await _pkgRepository.UpdateStatus(resPkg.Pid, resPkg.Status);
                                    _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                                    goto case 208;
                                }
                            }
                            catch (Exception ex)
                            {
                                resPkg.Status = 4;
                                resPkg.Message = ex.Message;
                                goto case 4;
                            }
                            break;
                        case 208:
                        default:
                            // ждем смены статуса
                            break;
                    }
                }

            }
            catch (Exception)
            {
                //string mess = ex.Message;

            }
            return stPkg;
        }
       
        private async Task <List<XDocument>> CreatePkgForEmul(ResLoadPackage resPkg)
        {
            List<XDocument> resXml = [];
            try
            {
                var docs = await _docRepository.GetByFilter(resPkg.Pid);
                foreach (var docId in docs.AsParallel().Where(d => d.DocType == "archive-doc.cfg.xml")
                                        .Select(d => d.DocId).ToList())
                    foreach (var doc in docs)
                    {
                        var dRecord = await _docRecordRepository.GetByDocId(doc.DocId);
                        if (dRecord != null)
                        {
                            XDocument xDoc = XDocument.Load(dRecord.ToString());
                            resXml.Add(xDoc);
                        }
                    }
            }
            catch (Exception) 
            { }

            return resXml;// status send to arch
        }
        public XDocument CreateResultXml(ResLoadPackage resPkg)
        {
            var xRes = new XDocument();

            var elem = new XElement("Result");
            elem.SetAttributeValue("pid", resPkg.Pid.ToString());
            elem.Add(new XElement("uuid", resPkg.UUID.ToString()));
            elem.Add(new XElement("Status", resPkg.Status.ToString()));
            elem.Add(new XElement("Message", resPkg.Message));
            xRes.Add(elem);
            return xRes;
        }
        private async Task<ResLoadPackage> PaskageFromMessage(string Mess)
        {
            ResLoadPackage resPkg = new();
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
                        Pid = getPkg.Pid;


                    }
                    else
                    {
                        // создать новый
                        var Pkg = Package.Create(pid_1, userPkg, stPkg, uuidPkg, cdPkg, DateTime.Now);
                        Pkg = await _pkgRepository.Add(Pkg);
                        Pid = Pkg.Pid;
                    }
                    resPkg.UUID = uuidPkg;
                    resPkg.Pid = Pid;
                    resPkg.Status = stPkg;
                    resPkg.Message="Pkg";
                    var Docs = await _docRepository.GetByFilter(Pid);
                    int countDoc= Docs.Count();
                    foreach (var doc in xDocs)
                    {
                        var gDoc = SaveDocToPkg(doc.docid, string.Empty, doc.doctext, Pid);
                        if (gDoc != null) countDoc--;

                    }
                    
                    resPkg.UUID = uuidPkg;
                    resPkg.Pid = Pid;
                    if (countDoc == 0)
                    {
                        resPkg.Status = GetLastStatus(stPkg).Result;
                        resPkg.Message = "Ok";
                    }
                    else
                    {
                        resPkg.Status = 4;
                        resPkg.Message = "Error add documents";
                    }
                }
                
            }
            catch (Exception ex)
            {
                resPkg.Status = 4;
                resPkg.Message = ex.Message;
            }
            return resPkg;
        }

        private async Task<int> GetLastStatus(int OldSt)
        {   
            var NewSt= await _statusGraphRepository.GetNewSt(OldSt);
           
            return NewSt;
        }
        public async Task<Guid> SaveDocToPkg(Guid gDocId,string docName, string docRecord, int Pid)
        {
           Guid dRecordId = Guid.Empty;
           Guid resDoc = Guid.Empty;
           var Doc =(gDocId.ToString().Length>0)? await _docRepository.GetByGuidId(gDocId): 
                                                  await _docRepository.GetByDocType(Pid,docName);

           var doc_1 = await _docRepository.GetLastDocId() + 1;
           if (Doc is not null)
           {
              await _docRepository.Update(Doc.DocId, Document.Create(Doc.Id, Doc.DocId, docName,
                                              docRecord.Length,DopFunction.GetHashMd5(docRecord), 
                                              DopFunction.GetSha256(docRecord),
                                              Pid, Doc.CreateDate, DateTime.Now));

              var oldDocRec = await _docRecordRepository.GetByDocId(Doc.DocId);
              if (oldDocRec != null)
              {
                  await _docRecordRepository.Update(Doc.DocId, DocRecord.Create(oldDocRec.Id, Doc.DocId,
                                                    docRecord, oldDocRec.CreateDate, DateTime.Now));
                  dRecordId= oldDocRec.DocId;
              }
              else
              {
                  dRecordId = await _docRecordRepository.Add(DocRecord.Create(Guid.NewGuid(),
                                      Doc.DocId,docRecord, DateTime.Now, DateTime.Now));
              }
           }
           else
           {
               Doc = await _docRepository.Add(Document.Create(doc_1, Guid.NewGuid(), docName,
                                         docRecord.Length, DopFunction.GetHashMd5(docRecord),
                                         DopFunction.GetSha256(docRecord),
                                         Pid, DateTime.Now, DateTime.Now));

               if (Doc is not null)
               {
                    dRecordId = await _docRecordRepository.Add(DocRecord.Create(Guid.NewGuid(), Doc.DocId,
                                                                  docRecord, DateTime.Now, DateTime.Now));
               }
           }

           if(dRecordId.ToString().Length>0 && Doc is not null)
                resDoc= Doc.DocId;
           
           return resDoc;
        }
        public async Task<Guid> ExtractEDContainerToPkg(string docName, string docRecord, int Pid)
        {
            Guid dRecordId = Guid.Empty;
            Guid resDoc = Guid.Empty;
            
            var doc_1 = await _docRepository.GetLastDocId() + 1;
            
            var Doc = await _docRepository.Add(Document.Create(doc_1, Guid.NewGuid(), docName,
                                          docRecord.Length, DopFunction.GetHashMd5(docRecord),
                                          DopFunction.GetSha256(docRecord),
                                          Pid, DateTime.Now, DateTime.Now));
            if (Doc is not null)
            {
              dRecordId = await _docRecordRepository.Add(DocRecord.Create(Guid.NewGuid(), Doc.DocId,
                                                         docRecord, DateTime.Now, DateTime.Now));
            }

            if (dRecordId.ToString().Length > 0 && Doc is not null)
                resDoc = Doc.DocId;

            return resDoc;
        }
        public async Task<bool> DeleteFromPkg(string docName, int Pid)
        {
            
            var Docs = await _docRepository.GetListByDocType(Pid, docName);
            int countDoc = Docs.Count;
            if (countDoc > 0) 
            {
                foreach (var Doc in Docs) 
                {
                    await _docRepository.Delete(Doc.DocId);
                    var rDoc = await _docRepository.GetByGuidId(Doc.DocId);
                    if (rDoc is null) countDoc--;
                }

            }
            return (countDoc == 0);
        }
        public async Task<bool> UpdateStatusPkg(int Pid, int stPkg)
        {
            await _pkgRepository.UpdateStatus(Pid, stPkg);

            var Pkg =await _pkgRepository.GetById(Pid);
            if (Pkg is null) return false;
            
            return (Pkg.StatusId==stPkg);
        }
    }
   }



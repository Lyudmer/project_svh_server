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
using System.Text;
using System.Xml.Xsl;
using System.Xml;
using System.Xml.XPath;
using System.Collections.Generic;

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
            int CountDoc = 0;  
            List<XDocument> resXml;
            try
            {
                // получить сообщение с пакетом
                var resMessEmul = _rabbitMQConsumer.LoadMessage("EmulSendDoc");
                var resMess = _rabbitMQConsumer.LoadMessage("SendPkg");
                // создать пакет и запустить workflow
                if (resMess != null || resMessEmul!=null)
                {
                    ResLoadPackage resPkg= new();
                    XDocument xPkg= new();
                    if (resMess != null)
                    {
                        resPkg = await PaskageFromMessage(resMess);
                        xPkg = XDocument.Load(resMess);
                    }
                    if (resMessEmul != null)
                    {
                        resPkg = await PaskageFromMessageEmul(resMessEmul);
                        xPkg = XDocument.Load(resMessEmul);
                    }
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
                                resXml = await CreatePkgForEmul(resPkg, "archive-doc.cfg.xml");
                                if (resXml != null)
                                {
                                    CountDoc = resXml.Count();
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
                                    else {
                                        resPkg.Status = 4;
                                        resPkg.Message = "error archive-doc";
                                        goto case 4;
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                resPkg.Status = 4;
                                resPkg.Message = ex.Message;
                                goto case 4;
                            };
                            break;
                        case 208:
                            if (resPkg.Message.Contains("arch"))
                            {
                                xPkg = await CreatePaskageAddAcrhXml(resPkg.Pid);
                                _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                                if (resPkg.Status==217) goto case 217;
                            };
                         break;
                        case 217:
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                            if (resPkg.Status == 210) goto case 210;
                           
                            break;
                        case 210:
                            resXml = await CreatePkgForEmul(resPkg, "armti.cfg.xml");
                            if (resXml != null)
                            {
                                _messagePublisher.SendMessage(resXml.ToString(), "SendEmulPkg");
                                await _pkgRepository.UpdateStatus(resPkg.Pid, resPkg.Status);
                                _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            }
                            else
                            {
                                resPkg.Status = 4;
                                resPkg.Message = "error armti";
                                goto case 4;
                            }
                            break;
                        case 214:
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                            _messagePublisher.SendMessage(CreateResultXml(resPkg, "ConfirmWHDocReg.cfg.xml"), "DocResultPkg");
                            break;
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
       
        private async Task <List<XDocument>> CreatePkgForEmul(ResLoadPackage resPkg,string docType)
        {
            List<XDocument> resXml = [];
            try
            {
                var docs = await _docRepository.GetByFilter(resPkg.Pid);
                foreach (var docId in docs.AsParallel().Where(d => d.DocType == docType)
                                        .Select(d => d.DocId).ToList())
                    foreach (var doc in docs)
                    {
                        var dRecord = await _docRecordRepository.GetByDocId(doc.DocId);
                        if (dRecord != null)
                        {
                            XDocument xDoc = XDocument.Load(dRecord.DocText);
                            resXml.Add(xDoc);
                        }
                    }
            }
            catch (Exception) 
            { 

            }

            return resXml;// status send to arch
        }
        private async Task<XDocument> CreatePaskageAddAcrhXml(int Pid)
        {
            var xPkg = new XDocument();
            var elem = new XElement("Package");
            elem.SetAttributeValue("pid", Pid);
            var elem_props = new XElement("package-properties"
                , new XElement("props", new XAttribute("name", "uuid"), _pkgRepository.GetById(Pid).Result.UUID.ToString())
                , new XElement("props", new XAttribute("name", "UserId"), _pkgRepository.GetById(Pid).Result.UserId.ToString()));
            elem.Add(elem_props);
            var docs = await _docRepository.GetByFilter(Pid);
            foreach (var docId in docs.AsParallel().Select(d => d.DocId).ToList())
                foreach (var doc in docs)
                {
                    elem.SetAttributeValue("docid", doc.DocId.ToString());
                    elem.SetAttributeValue("doctype", doc.DocType);
                    elem.SetAttributeValue("createdate", doc.CreateDate);
                    elem.Add(_docRecordRepository.GetByDocId(doc.DocId).ToString());
                }
            xPkg.Add(elem);
            return xPkg;
        }
        public XDocument CreateResultXml(ResLoadPackage resPkg)
        {
            var xRes = new XDocument();

            var elem = new XElement("Result");
            elem.SetAttributeValue("pid", resPkg.Pid.ToString());
            var elem_props = new XElement("package-properties"
              , new XElement("props", new XAttribute("name", "Status"), resPkg.Status.ToString())
              , new XElement("props", new XAttribute("name", "uuid"), resPkg.UUID.ToString())
              , new XElement("props", new XAttribute("name", "Message"), resPkg.Message));
            elem.Add(elem_props);
            xRes.Add(elem);
            return xRes;
        }
        public async Task<XDocument> CreateResultXml(ResLoadPackage resPkg,string docType)
        {
            var xRes = new XDocument();

            var elem = new XElement("Package");
            elem.SetAttributeValue("pid", resPkg.Pid.ToString());
            var elem_props = new XElement("package-properties"
             , new XElement("props", new XAttribute("name", "Status"), resPkg.Status.ToString())
             , new XElement("props", new XAttribute("name", "uuid"), resPkg.UUID.ToString())
             , new XElement("props", new XAttribute("name", "Message"), resPkg.Message));
            elem.Add(elem_props);
            var doc = await _docRepository.GetByDocType(resPkg.Pid, docType);
            if (doc != null) 
            {
                var docRecord = await _docRecordRepository.GetByDocId(doc.DocId);
                if (docRecord != null) { elem.Add(docRecord.DocText); }
            }
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
                           .Elements("*").Where(p => p.Attribute("docs")?.Value == "CfgName");
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

        private async Task<ResLoadPackage> PaskageFromMessageEmul(string Mess)
        {
            int CountResult=0;
            int CountSendDoc = 0;
            ResLoadPackage resPkg = new();

            try
            {
                XDocument xMess = XDocument.Load(Mess);
                var xResAch = new XDocument();
                string typeDoc = string.Empty;
                string nodeDoc = string.Empty;
                string xpath = string.Empty;
                if (xMess.Elements("ArchResult") is not null)
                {
                    typeDoc = "archive-rtu-doc-result.cfg.xml";
                    xResAch = ResultTransform(xMess);
                    nodeDoc = "DesNotif_PIResult";
                    xpath = "DesNotif_PIResult_ITEM/DocumentID";
                }
                if (xMess.Elements("ConfirmWHDocReg") is not null)
                {
                    typeDoc = "ConfirmWHDocReg.cfg.xml";
                    xResAch = xMess;
                    nodeDoc = "ConfirmWHDocReg";
                    xpath = "ConfirmWHDocReg/DocumentID";
                }
                if (xResAch is not null)
                {

                    //create result
                    var pid_1 = await _pkgRepository.GetLastPkgId();
                    var resPid = xResAch.Elements(nodeDoc)?.Attributes("pid").ToString();
                    var userPkg = ConverterValue.ConvertTo<Guid>(xResAch.Elements(nodeDoc)?.Attributes("userid").ToString());
                    var uuidPkg = ConverterValue.ConvertTo<Guid>(xResAch.Elements(nodeDoc)?.Attributes("uuid").ToString());
                   
                    if (resPid is not null && int.TryParse(resPid, out int Pid))
                    {
                        if (pid_1 <= Pid) pid_1 = Pid;
                    }

                    var xDocs = from xDoc in xResAch.Elements(nodeDoc)
                        select new
                        {
                            doctype = typeDoc,
                            docid = ConverterValue.ConvertTo<Guid>(xDoc.XPathSelectElement(xpath)?.Value),
                            doccreate = DateTime.Now,
                            doctext = xDoc.ToString()
                        };
                        
                    // проверить наличие пакета на сервере
                    var getPkg = await _pkgRepository.GetPkgByGuid(userPkg, uuidPkg);
                    if (getPkg != null) pid_1 = getPkg.Pid;
                    int countDoc = xDocs.Count();
                    foreach (var doc in xDocs)
                    {
                        var gDoc = SaveDocToPkg(doc.docid, doc.doctype, doc.doctext, pid_1);
                        if (gDoc != null) countDoc--;

                    }

                    if (xMess.Elements("ArchResult") is not null)
                    {
                        var ListDoc = await _docRepository.GetListByDocType(pid_1, "archive-doc.cfg.xml");
                        if (ListDoc != null) { CountSendDoc = ListDoc.Count(); };

                        var ListDocRes = await _docRepository.GetListByDocType(pid_1, "archive-rtu-doc-result.cfg.xml");
                        if (ListDocRes != null) { CountResult = ListDocRes.Count(); };
                        resPkg.UUID = uuidPkg;
                        resPkg.Pid = pid_1;
                        resPkg.Status = 208;
                        resPkg.Message = (CountResult == CountSendDoc) ? "arch" : "waitarch";
                    }
                    if (xMess.Elements("ConfirmWHDocReg") is not null) 
                    {
                        resPkg.UUID = uuidPkg;
                        resPkg.Pid = pid_1;
                        resPkg.Status = 214;
                        resPkg.Message = "add ConfirmWHDocReg";

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
        public static XDocument ResultTransform(XDocument inMess)
        {
            XDocument resXml = new();

            string filexslt ="Workflow\\COMMON\\package.result_arch.xsl";
           
            using (var stringReader = new StringReader(filexslt))
            {
                using XmlReader xsltReader = XmlReader.Create(stringReader);
                var transformer = new XslCompiledTransform();
                transformer.Load(xsltReader);
                XsltArgumentList args = new();
                using XmlReader oldDocumentReader = inMess.CreateReader();

                StringBuilder resultStr = new(1024 * 1024 * 10);
                XmlWriter resultWriter = XmlWriter.Create(resultStr);
                transformer.Transform(oldDocumentReader, args, resultWriter);
                resultWriter?.Close();
                resXml.Add(resultStr.ToString());
            }
            return resXml;
        }
    }
   }



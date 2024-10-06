using ServerSVH.Application.Interface;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordCore.Models;
using ServerSVH.SendReceiv.Consumer;
using ServerSVH.SendReceiv.Producer;
using System.Xml.Linq;
using ServerSVH.Application.Common;

namespace ServerSVH.SendReceiv
{
    public class ServerServices(IRabbitMQConsumer rabbitMQConsumer,
            IDocumentsRepository docRepository, IDocRecordRepository docRecordRepository,
                IPackagesRepository pkgRepository, IMessagePublisher messagePublisher,
                IStatusGraphRepository statusGraphRepository) : IServerServices
    {
        private readonly IRabbitMQConsumer _rabbitMQConsumer = rabbitMQConsumer;
        private readonly IPackagesRepository _pkgRepository = pkgRepository;
        private readonly IDocumentsRepository _docRepository = docRepository;
        private readonly IDocRecordRepository _docRecordRepository = docRecordRepository;
        private readonly IMessagePublisher _messagePublisher = messagePublisher;
        private readonly IStatusGraphRepository _statusGraphRepository = statusGraphRepository;

        async Task<int> IServerServices.LoadMessage()
        {
            int stPkg = 0;
            try
            {
                // получить сообщение с пакетом
                
                var resMess = _rabbitMQConsumer.LoadMessage("SendPkg");
                // создать пакет и запустить workflow
                if (resMess != null)
                {
                    ResLoadPackage resPkg = await PaskageFromMessage(resMess);

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

                            break;
                        case 3:
                            _messagePublisher.SendMessage(CreateResultXml(resPkg), "StatusPkg");
                            break;
                        //запуск workflow

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
                    foreach (var doc in xDocs)
                    {
                        var doc_1 = await _docRepository.GetLastDocId() + 1;
                        var oldDoc = await _docRepository.GetByGuidId(doc.docid);
                        if (oldDoc != null)
                        {
                            await _docRepository.Update(doc.docid, Document.Create(oldDoc.Id, doc.docid, doc.doctype, doc.doctext.Length,
                                                  DopFunction.GetHashMd5(doc.doctext), DopFunction.GetSha256(doc.doctext),
                                                  Pid, doc.doccreate, DateTime.Now));
                            var oldDocRec = await _docRecordRepository.GetByDocId(doc.docid);
                            if (oldDocRec != null)
                            {
                                await _docRecordRepository.Update(doc.docid, DocRecord.Create(oldDocRec.Id, doc.docid, doc.doctext, doc.doccreate, DateTime.Now));
                            }
                            else
                            {
                                var dRecordId = await _docRecordRepository.Add(DocRecord.Create(Guid.NewGuid(), doc.docid, doc.doctext, doc.doccreate, DateTime.Now));
                            }
                        }
                        else
                        {
                            var Doc = await _docRepository.Add(Document.Create(doc_1, doc.docid, doc.doctype, doc.doctext.Length,
                                              DopFunction.GetHashMd5(doc.doctext), DopFunction.GetSha256(doc.doctext),
                                              Pid, doc.doccreate, DateTime.Now));

                            if (Doc is not null)
                            {
                                var dRecordId = await _docRecordRepository.Add(DocRecord.Create(Guid.NewGuid(), Doc.DocId, doc.doctext, doc.doccreate, DateTime.Now));
                            }
                        }

                    }
                    resPkg.UUID = uuidPkg;
                    resPkg.Pid = Pid;
                    resPkg.Status = GetLastStatus(stPkg).Result;
                    resPkg.Message = "Ok";
                    
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
    }
   }



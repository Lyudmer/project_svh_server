using ServerSVH.Application.Common;
using ServerSVH.Application.Interface;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordCore.Models;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace ServerSVH.SendReceiv
{
    public class ServerFunction(IDocumentsRepository docRepository,
                                IDocRecordRepository docRecordRepository,
                                IPackagesRepository pkgRepository,
                                IStatusGraphRepository statusGraphRepository) : IServerFunction
    {
        private readonly IPackagesRepository _pkgRepository = pkgRepository;
        private readonly IDocumentsRepository _docRepository = docRepository;
        private readonly IDocRecordRepository _docRecordRepository = docRecordRepository;
        private readonly IStatusGraphRepository _statusGraphRepository = statusGraphRepository;
        public async Task<ResLoadPackage> PaskageFromMessageDel(string Mess)
        {
            ResLoadPackage resPkg = new();
            try
            {
                XDocument xMess = XDocument.Load(Mess);

                var xPkg = xMess.Element("Package");
                if (xPkg is not null)
                {

                    var attPkg = xPkg.Attributes("pid").ToString();

                    if (attPkg is null || !int.TryParse(attPkg, out int Pid))
                    {
                        resPkg.Pid = -1;
                        resPkg.Status = 107;
                        resPkg.Message = "Not found pkg on server";

                        return resPkg;
                    }
                    var propsPkg = xPkg.Elements("package-properties");
                    var uuidPkg = ConverterValue.ConvertTo<Guid>(propsPkg?.Elements("name").Where(s => s.Attribute("uuid")?.Value is not null).ToString());
                    var servPkg = _pkgRepository.GetByUUId(uuidPkg).Result;
                    if (servPkg is not null)
                    {
                        var Docs = await _docRepository.GetByFilter(servPkg.Id);
                        int cDocs = Docs.ToList().Count;
                        foreach (var Doc in Docs)
                        {
                            var dRecord = await _docRecordRepository.GetByDocId(Doc.DocId);
                            if (dRecord != null)
                                await _docRecordRepository.DeleteId(dRecord.DocId);
                            await _docRepository.Delete(Doc.Id);
                            cDocs--;
                        }
                        if (cDocs == 0)
                            await _pkgRepository.Delete(servPkg.Id);
                        resPkg.Pid = Pid;
                        resPkg.UUID = uuidPkg;
                        resPkg.Status = 107;
                        resPkg.Message = "Delete pkg on server";
                    }

                }
            }
            catch
            { }
            return resPkg;
        }
        public async Task<List<XDocument>> CreatePkgForEmul(ResLoadPackage resPkg, string docType)
        {
            List<XDocument> resXml = [];
            try
            {
                var docs = await _docRepository.GetListByDocType(resPkg.Pid,docType);
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
        public async Task<XDocument> CreatePaskageAddAcrhXml(int Pid)
        {
            var xPkg = new XDocument();
            var elem = new XElement("Package");
            elem.SetAttributeValue("pid", Pid);
            var elem_props = new XElement("package-properties"
                , new XElement("props", new XAttribute("name", "uuid"), _pkgRepository.GetById(Pid).Result.UUID.ToString()));

            elem.Add(elem_props);
            var docs = await _docRepository.GetByFilter(Pid);
            foreach (var doc in docs)
            {
                var docRecord = _docRecordRepository.GetByDocId(doc.DocId).Result.DocText.ToString();
                if (docRecord != null)
                {
                    XElement elem_doc = XElement.Parse(docRecord);
                    elem_doc.SetAttributeValue("docid", doc.DocId.ToString());
                    elem_doc.SetAttributeValue("doctype", doc.DocType);
                    elem.Add(elem_doc);
                }
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
        public async Task<XDocument> CreateResultXml(ResLoadPackage resPkg, string docType)
        {
            var xRes = new XDocument();

            var elem = new XElement("Package");
            elem.SetAttributeValue("pid", resPkg.Pid.ToString());
            var elem_props = new XElement("package-properties"
             , new XElement("props", new XAttribute("name", "Status"), resPkg.Status.ToString())
             , new XElement("props", new XAttribute("name", "uuid"), resPkg.UUID.ToString())
             , new XElement("props", new XAttribute("name", "Message"), resPkg.Message));
            elem.Add(elem_props);
            var doc = await _docRepository.GetByGuidDocType(resPkg.Pid, docType);
            if (doc!=Guid.Empty)
            {
                var docRecord = await _docRecordRepository.GetByDocId(doc);
                if (docRecord != null) { elem.Add(docRecord.DocText); }
            }
            xRes.Add(elem);
            return xRes;
        }
        public async Task<ResLoadPackage> PaskageFromMessage(string Mess)
        {
            ResLoadPackage resPkg = new();
            try
            {
                XDocument xMess = XDocument.Parse(Mess.Trim());

                var xPkg = xMess.Element("Package");
                     

                if (xPkg is not null)
                {
                    //create package
                    var LastPid = await _pkgRepository.GetLastPkgId() + 1;

                    var attPkg = xPkg.Attribute("pid")?.Value.ToString();

                    if (attPkg is not null && int.TryParse(attPkg, out int Pid))
                    {
                        if (LastPid <= Pid) LastPid = Pid;
                    }

                    var propsPkg = xPkg.Elements("package-properties");
                    
                    if (propsPkg is not null) 
                    {

                        var prop = propsPkg?.Elements().Where(x => x.Name.LocalName.Contains("props")
                                                               && x.Attribute(XName.Get("name"))?.Value == "UserId")
                                                             .FirstOrDefault()?.Value;
                        if (prop is not null) resPkg.UserId = ConverterValue.ConvertTo<Guid>(prop.ToString());
                        prop = propsPkg?.Elements().Where(x => x.Name.LocalName.Contains("props")
                                                               && x.Attribute(XName.Get("name"))?.Value == "Status")
                                                             .FirstOrDefault()?.Value;
                        if (prop is not null) resPkg.Status = ConverterValue.ConvertTo<int>(prop.ToString());
                        prop = propsPkg?.Elements().Where(x => x.Name.LocalName.Contains("props")
                                                               && x.Attribute(XName.Get("name"))?.Value == "CreateDate")
                                                             .FirstOrDefault()?.Value;
                        if (prop is not null) resPkg.CreateDate = ConverterValue.ConvertTo<DateTime>(prop.ToString());
                        prop = propsPkg?.Elements().Where(x => x.Name.LocalName.Contains("props")
                                                               && x.Attribute(XName.Get("name"))?.Value == "uuid")
                                                             .FirstOrDefault()?.Value;
                        if (prop is not null) resPkg.UUID = ConverterValue.ConvertTo<Guid>(prop.ToString());
                    }
                    
                    var xDocs= xPkg.Elements().Where(p => p.Attributes().Where(a => a.Name.LocalName.Contains("CfgName")).FirstOrDefault()?.Value is not null);
                    if (xDocs != null)
                    {
                            // проверить наличие пакета на сервере
                            var getPkg = await _pkgRepository.GetPkgByGuid( resPkg.UserId,resPkg.UUID);
                            if (getPkg != 0)
                            {
                                //внести изменения в записи
                                var cRes = await _pkgRepository.UpdateStatus(getPkg, resPkg.Status);
                                Pid = (cRes > 0) ? getPkg : cRes;
                            }
                            else
                            {
                                // создать новый
                                var Pkg = Package.Create(LastPid, resPkg.UserId, resPkg.Status, resPkg.UUID, resPkg.CreateDate, DateTime.UtcNow);
                                Pkg = await _pkgRepository.Add(Pkg);
                                Pid = Pkg.Id;
                            }
                        
                        resPkg.Pid = Pid;
                        resPkg.Message = "loadpkgsrv";
                        
                        int countDoc = xDocs.Count();

                        foreach (var xDoc in xDocs)
                        {
                            var rDoc = await SaveDocToPkg(xDoc, Pid);
                            if (rDoc!= Guid.Empty ) countDoc--;
                        }
                        if (countDoc == 0)
                        {
                            var resSt = await GetLastStatus(resPkg.Status);
                            if (resSt > 0) resPkg.Status = resSt;
                            resPkg.Message = "Ok";
                        }
                        else
                        {
                            resPkg.Status = 4;
                            resPkg.Message = "Error add documents";
                        }
                    }
                    else
                    {
                        resPkg.Status = 4;
                        resPkg.Message = "error add package";
                    }
                }
                else
                {
                    resPkg.Status = 4;
                    resPkg.Message = "error add package";
                }
            }
            catch (Exception ex)
            {
                resPkg.Status = 4;
                resPkg.Message = ex.Message;
            }
            return resPkg;
        }

        public async Task<ResLoadPackage> PaskageFromMessageEmul(string Mess)
        {
            int CountResult = 0;
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

                    var xDocs = xResAch.Elements(nodeDoc);

                    // проверить наличие пакета на сервере
                    var getPkg = await _pkgRepository.GetPkgByGuid(userPkg, uuidPkg);
                    if (getPkg != 0) pid_1 = getPkg;
                    int countDoc = xDocs.Count();
                    foreach (var doc in xDocs)
                    {
                        var gDoc = SaveDocToPkg(doc, pid_1);
                        if (gDoc != null) countDoc--;

                    }

                    if (xMess.Elements("ArchResult") is not null)
                    {
                        var ListDoc = await _docRepository.GetListByDocType(pid_1, "archive-doc.cfg.xml");
                        if (ListDoc != null) { CountSendDoc = ListDoc.Count; };

                        var ListDocRes = await _docRepository.GetListByDocType(pid_1, "archive-rtu-doc-result.cfg.xml");
                        if (ListDocRes != null) { CountResult = ListDocRes.Count; };
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
        public async Task<int> GetLastStatus(int OldSt)
        {
            var newSt = await _statusGraphRepository.GetNewSt(OldSt);

            return newSt.NewSt;
        }
        public async Task<Guid> SaveDocToPkg(XElement xDoc, int Pid)
        {
            Guid dRecordId = Guid.Empty;
            Guid resDoc = Guid.Empty;
            var LastDocId = await _docRepository.GetLastDocId() + 1;
            var prop = xDoc.Attribute(XName.Get("doctype"))?.Value;

            DocFromXml DocXml = new()
            {
                TypeDoc = (prop != null) ? prop.ToString() : string.Empty,
                DocId = ConverterValue.ConvertTo<Guid>(xDoc.Attribute("docid")?.Value),
                CreateDate = ConverterValue.ConvertTo<DateTime>(xDoc.Attribute("createdate")?.Value).Date,
                DocText = xDoc.Value.ToString(),
                Did = LastDocId,
                HashMd5 = DopFunction.GetHashMd5(xDoc.Value.ToString()),
                Sha256= DopFunction.GetSha256(xDoc.Value.ToString())

            };

            if (DocXml.Did > 1)
            {
                var srvDoc = (DocXml.DocId != Guid.Empty) ?
                    await _docRepository.GetByGuidId(DocXml.DocId) :
                    await _docRepository.GetByDocType(Pid, DocXml.TypeDoc);


                if (srvDoc > 0)
                {
                    await _docRepository.Update(DocXml.DocId, Document.Create(srvDoc, DocXml.DocId, DocXml.CreateDate, DateTime.Now.Date,
                                                    DocXml.DocText.Length, DocXml.TypeDoc, DocXml.HashMd5,
                                                    DocXml.Sha256, Pid));
                    resDoc = DocXml.DocId;
                    var oldDocRec = await _docRecordRepository.GetByDocId(DocXml.DocId);
                    if (oldDocRec != null)
                    {
                        await _docRecordRepository.UpdateRecord(DocXml.DocId, DocRecord.Create(DocXml.DocId, DocXml.DocText));
                        dRecordId = DocXml.DocId;
                    }
                    else
                    {
                        dRecordId = await _docRecordRepository.AddRecord(DocRecord.Create(DocXml.DocId, DocXml.DocText));
                    }

                }
                else
                    resDoc = await AddDocementToDb(Pid, dRecordId, resDoc, DocXml);

            }
            else
                resDoc = await AddDocementToDb(Pid,  dRecordId,  resDoc,  DocXml);
            

            return resDoc;
        }

        private async Task<Guid> AddDocementToDb(int Pid,  Guid dRecordId,  Guid resDoc,  DocFromXml DocXml)
        {

            var LoadDoc = await _docRepository.Add(Document.Create(DocXml.Did, DocXml.DocId, DateTime.Now.Date, DateTime.Now.Date, 
                                                        DocXml.DocText.Length,DocXml.TypeDoc, DocXml.HashMd5,DocXml.Sha256, Pid));


            if (LoadDoc is not null)
            {
                dRecordId = await _docRecordRepository.AddRecord(DocRecord.Create(LoadDoc.DocId, DocXml.DocText));
            }
            if (dRecordId.ToString().Length > 0 && LoadDoc is not null)
                resDoc = LoadDoc.DocId;
            return resDoc;
        }

        public async Task<Guid> SaveDocToPkg(Guid DocId, string DocName, string Doctext, int Pid)
        {

            Guid dRecordId = Guid.Empty;
            Guid resDoc = Guid.Empty;
            var LastDocId = await _docRepository.GetLastDocId() + 1;
            var LoadDoc = await _docRepository.Add(Document.Create(LastDocId, DocId, DateTime.Now.Date, DateTime.Now.Date,
                                                            Doctext.Length,  DocName,DopFunction.GetHashMd5(Doctext),
                                                            DopFunction.GetSha256(Doctext),Pid));


            if (LoadDoc is not null)
            {
                dRecordId = await _docRecordRepository.AddRecord(DocRecord.Create(LoadDoc.DocId,Doctext));
            }
            if (dRecordId.ToString().Length > 0 && LoadDoc is not null)
                resDoc = LoadDoc.DocId;
            return resDoc;
        }
        public async Task<Guid> ExtractEDContainerToPkg(string docName, string docRecord, int Pid)
        {
            Guid dRecordId = Guid.Empty;
            Guid resDoc = Guid.Empty;

            var doc_1 = await _docRepository.GetLastDocId() + 1;

            var Doc = await _docRepository.Add(Document.Create(doc_1, Guid.NewGuid(), DateTime.Now, DateTime.Now, 
                                          docRecord.Length, docName, DopFunction.GetHashMd5(docRecord),
                                          DopFunction.GetSha256(docRecord),Pid));
            if (Doc is not null)
            {
                dRecordId = await _docRecordRepository.AddRecord(DocRecord.Create(Doc.DocId,docRecord));
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
                    if (rDoc >0) countDoc--;
                }

            }
            return (countDoc == 0);
        }
        public async Task<bool> UpdateStatusPkg(int Pid, int stPkg)
        {
            await _pkgRepository.UpdateStatus(Pid, stPkg);

            var Pkg = await _pkgRepository.GetById(Pid);
            if (Pkg is null) return false;

            return (Pkg.StatusId == stPkg);
        }
        public static XDocument ResultTransform(XDocument inMess)
        {
            XDocument resXml = new();

            string filexslt = "Workflow\\COMMON\\package.result_arch.xsl";

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
        public async Task<List<Package>> GetPackageList()
        {
            return await _pkgRepository.GetAll();
        }
        public async Task<Package> GetPkgId(int Pid)
        {
            return await _pkgRepository.GetById(Pid);
        }
        public async Task<List<Document>> GetDocumentList(int Pid)
        {
            return await _docRepository.GetByFilter(Pid);
        }
        public async Task<Document> GetDocument(int Id)
        {
            return await _docRepository.GetById(Id);
        }
        public async Task<DocRecord> GetRecord(Guid DocId)
        {
            return await _docRecordRepository.GetByDocId(DocId);
        }
    }
}

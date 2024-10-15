using ServerSVH.Application.Common;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Models;
using System.Xml.Linq;

namespace ServerSVH.Application.Interface
{
    public interface IServerFunction
    {
        Task<ResLoadPackage> PaskageFromMessageDel(string Mess);
        Task<ResLoadPackage> PaskageFromMessage(string Mess);
        Task<ResLoadPackage> PaskageFromMessageEmul(string Mess);
        XDocument CreateResultXml(ResLoadPackage resPkg);
        Task<XDocument> CreateResultXml(ResLoadPackage resPkg, string docType);
        Task<bool> DeleteFromPkg(string docName, int Pid);
        Task<Guid> ExtractEDContainerToPkg(string docName, string docRecord, int Pid);
        Task<Document> GetDocument(int Id);
        Task<List<Document>> GetDocumentList(int Pid);
        Task<List<Package>> GetPackageList();
        Task<DocRecord> GetRecord(Guid DocId);
        Task<Guid> SaveDocToPkg(Guid gDocId, string docName, string docRecord, int Pid);
        Task<bool> UpdateStatusPkg(int Pid, int stPkg);
        Task<List<XDocument>> CreatePkgForEmul(ResLoadPackage resPkg, string docType);
        Task<XDocument> CreatePaskageAddAcrhXml(int Pid);
    }
}
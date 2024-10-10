using ServerSVH.Application.Common;
using ServerSVH.Core.Models;
using ServerSVH.DocRecordCore.Models;
using System.Xml.Linq;

namespace ServerSVH.Application.Interface
{
    public interface IServerServices
    {
     
        Task<int> LoadMessage();
        XDocument CreateResultXml(ResLoadPackage resPkg);
        Task<Guid> SaveDocToPkg(Guid gDocId, string docName, string docRecord, int Pid);
        Task<Guid> ExtractEDContainerToPkg(string docName, string docRecord, int Pid); 
        Task<bool> DeleteFromPkg(string docName,  int Pid);
        Task<bool> UpdateStatusPkg(int Pid,int stPkg);
        Task<List<Package>> GetPackageList();
        Task<List<Document>> GetDocumentList(int Pid);
        Task<Document> GetDocument(int Id);
        Task<DocRecord> GetRecord(Guid DocId);
    }
}
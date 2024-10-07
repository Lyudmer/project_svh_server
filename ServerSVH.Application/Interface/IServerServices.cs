using ServerSVH.Application.Common;
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
    }
}
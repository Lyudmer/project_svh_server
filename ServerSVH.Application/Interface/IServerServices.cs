using ServerSVH.Application.Common;
using System.Xml.Linq;

namespace ServerSVH.Application.Interface
{
    public interface IServerServices
    {
     
        Task<int> LoadMessage();
        XDocument CreateResultXml(ResLoadPackage resPkg);
    }
}
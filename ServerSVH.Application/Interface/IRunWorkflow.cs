using ServerSVH.Application.Common;
using System.Xml.Linq;

namespace ServerSVH.Application.Interface
{
    public interface IRunWorkflow
    {
        XDocument RunBuilderXml(XDocument inXmlPkg,ref ResLoadPackage resPkg);
    }
}
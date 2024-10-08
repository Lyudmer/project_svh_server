using System.Xml.Xsl;
using System.Xml;
using System.Xml.Linq;
using System.Text;

using ServerSVH.Application.Interface;
using ServerSVH.Application.Common;

using ServerSVH.Workflow.Actions;

namespace ServerSVH.Workflow
{
    public class RunWorkflow() : IRunWorkflow
    {

        public XDocument RunBuilderXml(XDocument inXmlPkg, ref ResLoadPackage resPkg)
        {
            var resXml = new XDocument();
            if (!ValidateDesXml(inXmlPkg))
            {
                resPkg.Status = 4;
                resPkg.Message = "Пакет содержит не корректный документ";
                return resXml;
            }
            try
            {
                var strXml = WorkfowBuilder(inXmlPkg, ref resPkg);
                // запуск actions
                string xml = ActionHelper.Normalize(strXml);
                resXml = ValidateActions(xml, inXmlPkg,ref resPkg);
            }
            catch (XsltException xEx)
            {
                resPkg.Status = 4;
                resPkg.Message = xEx.Message;
            }
            return resXml;
        }

        private static XDocument ValidateActions(string xml, XDocument inXmlPkg,ref ResLoadPackage resPkg)
        {
            XDocument resXml = new();
           XDocument actions = XDocument.Load(xml);
            if (actions != null)
            {
                ActionContext.Init();

                var actionContainer = new ActionContainer();
                var actItem = actions.Element("Actions");
                var currXml = inXmlPkg.Root;

                if (actItem != null && currXml!=null)
                {
                    actionContainer.Init(null, actItem, currXml,ref resPkg);
                    actionContainer.Execute(ref resPkg);
                }
                resXml.Add(currXml);
            }
           
            return resXml;
        }
        private static string WorkfowBuilder(XDocument inXmlPkg, ref ResLoadPackage resPkg)
        {
            string filexslt = "Workflow\\workflow.xsl";
            string resAction = string.Empty;

            using (var stringReader = new StringReader(filexslt))
            {
                using XmlReader xsltReader = XmlReader.Create(stringReader);
                var transformer = new XslCompiledTransform();
                transformer.Load(xsltReader);
                XsltArgumentList args = new();
                args.AddParam("PkgStatus", "", resPkg.Status);
                args.AddParam("Now", "", DateTime.Now.ToString());
                using XmlReader oldDocumentReader = inXmlPkg.CreateReader();

                StringBuilder resultStr = new(1024 * 1024 * 10);
                XmlWriter resultWriter = XmlWriter.Create(resultStr);
                transformer.Transform(oldDocumentReader, args, resultWriter);
                resultWriter?.Close();
                resAction = resultStr.ToString();
            }
            return resAction;
        }

        public static string LoadTxtAsString(string file)
        {
            using StreamReader Result = new(file, Encoding.GetEncoding(1251));
            return Result.ReadToEnd();
        }
        private static bool ValidateDesXml(XDocument inXml)
        {

            string DesXmlList = "Workflow\\desxml.lst";

            string s = LoadTxtAsString(DesXmlList).ToLower().Replace(" ", "");
            string[] mass = s.Split('\n');
            var ListDoc = inXml.Element("Package")?.Elements("*").Where(p => p.Attribute("ctmtd")?.Value == "CfgName");
            var xDocs = from xDoc in ListDoc?.AsParallel().Elements()
                        select new { typedoc = xDoc.Name?.LocalName };
            foreach (var doc in xDocs)
            {
                if (!doc.typedoc.Contains("armti"))
                    if (!mass.Contains(doc.typedoc))
                    {
                        return false;
                    }
            }
            return true;
        }
    }


}

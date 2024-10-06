using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using System.Xml.Xsl;

namespace ServerSVH.Workflow.Actions
{
    public class FLKHandler : ActionHandlerBase
    {
        protected override void ExecuteCore()
        {
            IsSuccess = CheckFLK(ActionNode);
        }

        private bool CheckFLK(XElement node)
        {
            var schemeName = node.Attribute("name")?.Value;
            if (!File.Exists(ActionHelper.GetBaseDir() + schemeName))
                return false;
            var args = new XsltArgumentList();
            var nodes = node.Elements("with-param");
            if(nodes is null) return false;

            foreach (var arg in nodes)
            {  
                args.AddParam(arg.Attribute("name").Value, "", arg.Value);
            }
           

            var transform = ActionContext.Instance.TransformCache.Load(ActionHelper.GetBaseDir() + schemeName);

            var resultXml = new StringBuilder(1024 * 1024 * 10);
            var resultWriter = XmlWriter.Create(resultXml);
            transform.Transform(CurrentDocument.ToString(), args, resultWriter);
            resultWriter.Close();
            XDocument flkResult = XDocument.Load(resultXml.ToString());
            
            if(flkResult?.XPathSelectElements("*[not(contains(ResultCategory,'WARNING'))]").Count()==0) return true;
            return false;
        }
    }
}

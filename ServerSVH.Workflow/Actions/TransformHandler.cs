using ServerSVH.Application.Common;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using System.Xml.Xsl;


namespace ServerSVH.Workflow.Actions
{
    public class TransformHandler : ActionHandlerBase
    {
        protected override void ExecuteCore(ref ResLoadPackage resPkg)
        {
            ValidateTransform(ActionNode);
        }

        private void ValidateTransform(XElement node)
        {
           
            var schemeName = node.Attribute("name")?.Value;
            if (File.Exists(ActionHelper.GetBaseDir() + schemeName))
            {
                var args = new XsltArgumentList();
                var nodes = node.XPathSelectElements("with-param");

                foreach (var arg in nodes)
                {
                    args.AddParam(arg.Attribute("name").Value, "", arg.Value);
                }

                var transform = ActionContext.Instance.TransformCache.Load(ActionHelper.GetBaseDir() + schemeName);
                var resultXml = new StringBuilder(1024 * 1024 * 10);
                var resultWriter = XmlWriter.Create(resultXml);

                try
                {
                    transform.Transform(CurrentDocument.ToString(), args, resultWriter);
                }
                catch (XsltException xEx)
                {
                    resultXml.Append(string.Format("<Result>{0}</Result>", xEx.Message));
                }
                resultWriter.Close();

                CurrentDocument.Add(resultXml.ToString());
            }
            
        }
        
    }
}

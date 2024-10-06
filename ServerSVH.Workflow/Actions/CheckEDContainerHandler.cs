
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;


namespace ServerSVH.Workflow.Actions
{
    public class CheckEDContainerHandler : ActionHandlerBase
    {
        protected override void ExecuteCore()
        {
            CheckEDContainer(ActionNode);
        }

        private void CheckEDContainer(XElement node)
        {
            var schemaPath = node.Attribute("dir")?.Value.ToString();
            schemaPath = ActionHelper.GetBaseDir() + schemaPath;

            if (Directory.Exists(schemaPath))
            {
                ActionContext.Instance.Schemas.LoadSchemas(schemaPath);

                var documents = CurrentDocument.XPathSelectElements("//*[local-name()='DocBody']/*");
                foreach (var item in documents)
                {
                    var targetNs = item.Attribute("xmlns")?.Value.ToString();
                    if (targetNs != null)
                    {
                        var schemaSet = ActionContext.Instance.Schemas.GetByTargetNS(schemaPath, targetNs);
                        ActionHelper.ValidateSchema(schemaSet, item);
                    }
                }
            }
        }
    }
}

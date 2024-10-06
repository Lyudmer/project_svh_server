using System.Xml;
using System.Xml.Linq;

namespace ServerSVH.Workflow.Actions
{
    public class CheckSchemaHandler : ActionHandlerBase
    {
        protected override void ExecuteCore()
        {
            ValidateSchema(ActionNode);
        }

        private void ValidateSchema(XElement node)
        {
            var schemeName = node.Attribute("name")?.Value;
            if(File.Exists(ActionHelper.GetBaseDir() + schemeName))
                ValidateSchema(ActionHelper.GetBaseDir() + schemeName);
        }

        private void ValidateSchema(string schemaName)
        {
            ActionHelper.ValidateSchema(ActionContext.Instance.Schemas.Get(schemaName), CurrentDocument);
        }
    }
}

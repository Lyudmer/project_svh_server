using System.Xml;
using System.Xml.Linq;
using ServerSVH.Application.Common;
namespace ServerSVH.Workflow.Actions
{
    public class CheckSchemaHandler : ActionHandlerBase
    {
        protected override void ExecuteCore(ref ResLoadPackage resPkg)
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

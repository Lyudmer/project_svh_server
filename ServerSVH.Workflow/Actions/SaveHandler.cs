
using ServerSVH.Application.Common;
using ServerSVH.Application.Interface;
using System.Security.Cryptography;
using System.Xml.Linq;

namespace ServerSVH.Workflow.Actions
{
    public class SaveHandler(IServerServices serverServices) : ActionHandlerBase
    {
        private readonly IServerServices _serverServices=serverServices;
        protected override void ExecuteCore(ref ResLoadPackage resPkg)
        {
            IsSuccess = ValidateSaveDocToPkg(ActionNode,CurrentDocument,ref resPkg);
        }
        private bool ValidateSaveDocToPkg(XElement node, XElement currentDocument,ref ResLoadPackage resPkg)
        {
            var docName = node.Attribute("name")?.Value;
            if (string.IsNullOrEmpty(docName)) return false;
            if(resPkg is null) return false;
            Guid resDoc =  _serverServices.SaveDocToPkg(Guid.Empty,docName, currentDocument.ToString(), resPkg.Pid).Result;
            if (resDoc == Guid.Empty)
            {
                resPkg.Status = 4;
                resPkg.Message = "Error save doc " + docName;
            }

            return (resDoc != Guid.Empty);
        }
        public override void Init(ActionHandlerBase parentAction, XElement actionNode, XElement currentDocument,ref ResLoadPackage resPkg)
        {
            base.Init(parentAction, actionNode, currentDocument,ref resPkg);
            if (ActionNode.Attribute("name") is not null)
                ActionNode.Attribute("name")?.Value.ToString();
        }
    }
}

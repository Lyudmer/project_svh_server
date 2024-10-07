using Microsoft.AspNetCore.Mvc.ApplicationModels;
using ServerSVH.Application.Common;
using ServerSVH.Application.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace ServerSVH.Workflow.Actions
{
    public class ExtractEDContainerHandler(IServerServices serverServices) : ActionHandlerBase
    {
        private readonly IServerServices _serverServices = serverServices;
        protected override void ExecuteCore(ref ResLoadPackage resPkg)
        {
            IsSuccess = ValidateExtractEDContainerToPkg(ActionNode, CurrentDocument, ref resPkg);
        }
        private bool ValidateExtractEDContainerToPkg(XElement node, XElement currentDocument,ref ResLoadPackage resPkg)
        {
            var docName = node.Attribute("name")?.Value;
            if (string.IsNullOrEmpty(docName)) return false;
            if (resPkg is null) return false;
            Guid resDoc = _serverServices.ExtractEDContainerToPkg(docName, currentDocument.ToString(), resPkg.Pid).Result;
            return (resDoc.ToString().Length > 0);
        }
        public override void Init(ActionHandlerBase parentAction, XElement actionNode, XElement currentDocument,ref ResLoadPackage resPkg)
        {
            base.Init(parentAction, actionNode, currentDocument,ref resPkg);
            if (ActionNode.Attribute("name") is not null)
                ActionNode.Attribute("name")?.Value.ToString();
        }
    }
}

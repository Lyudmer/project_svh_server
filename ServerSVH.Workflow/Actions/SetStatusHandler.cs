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
    public class SetStatusHandler(IServerServices serverServices) : ActionHandlerBase
    {
        private readonly IServerServices _serverServices = serverServices;
        protected override void ExecuteCore(ref ResLoadPackage resPkg)
        {
            IsSuccess = ValidateSetStatusPkg(ActionNode, ref resPkg);
        }
        private bool ValidateSetStatusPkg(XElement node, ref ResLoadPackage resPkg)
        {
            var stPkg = ConverterValue.ConvertTo<int>(node.Attribute("name")?.Value);
            if (_serverServices.UpdateStatusPkg(resPkg.Pid, resPkg.Status).Result)
            {
                resPkg.Status = stPkg;
                resPkg.Message = "Set status package " + stPkg;
            }
            else
            {
                resPkg.Status = 4;
                resPkg.Message = "Error set status package " + stPkg;
            }

            return (resPkg.Status == stPkg);
        }
        public override void Init(ActionHandlerBase parentAction, XElement actionNode, XElement currentDocument, ref ResLoadPackage resPkg)
        {
            base.Init(parentAction, actionNode, currentDocument, ref resPkg);
            if (ActionNode.Attribute("name") is not null)
                ActionNode.Attribute("name")?.Value.ToString();
        }
    }
}

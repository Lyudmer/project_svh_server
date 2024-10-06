﻿using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;

namespace ServerSVH.Workflow.Actions
{
    public class CreateGUIDHandler : ActionHandlerBase
    {
        private string _nodeFilter;

        protected override void ExecuteCore()
        {
            CreateAndCheckGUID(ActionNode);
        }

        private void CreateAndCheckGUID(XElement node)
        {
            var guid = Guid.NewGuid();

            if (!string.IsNullOrEmpty(_nodeFilter))
            {
                var list = CurrentDocument.XPathSelectElements(_nodeFilter);
                if (list != null)
                {
                    foreach (var item in list)
                    {
                        item.SetValue(guid);
                    }
                }
            }
        }

        public override void Init(ActionHandlerBase parentAction, XElement actionNode, XElement currentDocument)
        {
            base.Init(parentAction, actionNode, currentDocument);
            if (_nodeFilter is not null  
                && ActionNode.Attribute("xpath") is not null
                && _nodeFilter == ActionNode.Value)
                ActionNode.Attribute("xpath")?.Value.ToString();
        }
    }
}

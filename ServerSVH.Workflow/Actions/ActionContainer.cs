using System.Xml;
using System.Xml.Linq;


namespace ServerSVH.Workflow.Actions
{
    public class ActionContainer : ActionHandlerBase
    {
        protected override void ExecuteCore()
        {
            if (ActionNode == null) throw new ArgumentException("ActionNode is null.");
            if (CurrentDocument == null) throw new ArgumentException("CurrentDocument is null.");

            var nodes = ActionNode.Elements("*");
            if (nodes == null) return;

            foreach (var node in nodes)
            {
                if (!DoAction(node, CurrentDocument)) break;
            }
        }

        public ActionHandlerBase? InitActionHandler(XElement actionNode, XElement currentDocument)
        {

            var handlerType = ActionHelper.FindActionHandlerType(actionNode.Name.ToString());
            if (handlerType == null) return null;

            var actionHandler = Activator.CreateInstance(handlerType) as ActionHandlerBase;
            if (actionHandler == null) return null;

            actionHandler.Init(this, actionNode, currentDocument);

            return actionHandler;
        }

        public bool DoAction(XElement actionNode, XElement currentDocument)
        {
            var actionHandler = InitActionHandler(actionNode, currentDocument);
            if (actionHandler == null) return true;

            actionHandler.Execute();
            if (actionHandler.IsSuccess) CurrentDocument = actionHandler.CurrentDocument;

            return actionHandler.IsSuccess;
        }
    }
}

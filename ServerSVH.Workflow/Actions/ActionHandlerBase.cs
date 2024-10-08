
using ServerSVH.Application.Common;
using System.Xml.Linq;

namespace ServerSVH.Workflow.Actions
{
    public abstract class ActionHandlerBase
    {
        public ActionHandlerBase()
        {
            _context = ActionContext.Instance;
        }

        private readonly ActionContext _context;

        public XElement ActionNode { get; set; }
        public XElement CurrentDocument { get; set; }  
        public ActionHandlerBase ParentAction { get; set; }
        public string Key { get; set; }
        public bool IsSuccess { get; set; }
       
         public void Execute(ref ResLoadPackage resPkg)
        {
            IsSuccess = true;
            ExecuteCore(ref resPkg);
        }

        protected abstract void ExecuteCore(ref ResLoadPackage resPkg);
        public virtual void Init(ActionHandlerBase parentAction, XElement actionNode, XElement currentDocument,ref ResLoadPackage resPkg)
        {
            ParentAction = parentAction;
            ActionNode = actionNode;

            CurrentDocument = currentDocument;
           
            var parentKey = ParentAction != null ? ParentAction.Key : String.Empty;
            Key = parentKey + ActionNode.Name;
        }

       

      
    }
}

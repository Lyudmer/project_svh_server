

namespace ServerSVH.Workflow.Actions
{
    public class ActionContext
    {
        private static ActionContext _instance;

        private Dictionary<string, int> actionSequence = new();
        public SchemasCache Schemas = new();
        private CachedXslTransformLoader transformCache = new();

        public static ActionContext Instance
        {
            get { return _instance ??= new ActionContext(); }
        }

        public CachedXslTransformLoader TransformCache { get => transformCache; set => transformCache = value; }
        public Dictionary<string, int> ActionSequence { get => actionSequence; set => actionSequence = value; }

        public static void Init()
        {
            Instance.ActionSequence.Clear();
        }
    }
}

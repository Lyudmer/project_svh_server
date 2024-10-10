using System.Xml.Schema;
using System.Xml;

namespace ServerSVH.Workflow.Actions
{
    public class SchemasCache
    {
        private Dictionary<string, XmlSchemaSet> _loadedSchemasSet = [];
        private Dictionary<string, Dictionary<string, string>> _targetNSMapDirToFile = [];

        public void Clear()
        {
            _loadedSchemasSet = [];
            _targetNSMapDirToFile = [];
        }

        public XmlSchemaSet Get(string SchemaName)
        {
            
            string key = SchemaName.ToUpper();
            if (!_loadedSchemasSet.TryGetValue(key, out XmlSchemaSet value))
            {
                XmlSchemaSet newSchemasSet = new();
                var pathScheme = Path.GetDirectoryName(SchemaName);
                if (pathScheme != null)
                {
                    XmlResolver resolver = new WorkflowXmlUrlResolver(pathScheme);
                    newSchemasSet.XmlResolver = resolver;
                    var readSchema = new FileStream(SchemaName, FileMode.Open, FileAccess.Read, FileShare.Read);
                    if (readSchema != null)
                    {
                        XmlSchema schema = XmlSchema.Read(readSchema, null);
                        if (schema != null)
                        {
                            newSchemasSet.Add(schema);
                            newSchemasSet.Compile();
                            value = newSchemasSet;
                            _loadedSchemasSet.Add(key, value);
                        }
                    }
                }
            }
            return value;
        }

        public XmlSchemaSet GetByTargetNS(string Dir, string targetNamespace)
        {
            return Get(_targetNSMapDirToFile[Dir][targetNamespace]);
        }


        public void LoadSchemas(string SchemasDirectory)
        {
            if (!_targetNSMapDirToFile.ContainsKey(SchemasDirectory))
                _targetNSMapDirToFile.Add(SchemasDirectory, []);

            Dictionary<string, string> _targetNSFile = _targetNSMapDirToFile[SchemasDirectory];


            string[] files = Directory.GetFiles(SchemasDirectory, "*.xsd");
            foreach (string file in files)
            {
                using FileStream stream = new(file, FileMode.Open, FileAccess.Read, FileShare.Read);
                if (stream != null)
                {
                    XmlSchema schema = XmlSchema.Read(stream, null);
                    if (schema != null && schema.TargetNamespace !=null)
                        _targetNSFile.TryAdd(schema.TargetNamespace, file);
                    stream.Close();
                }
            }
        }
    }
}


using System.Xml.Schema;
using System.Xml;
using System.Xml.Linq;



namespace ServerSVH.Workflow.Actions
{
    public static class ActionHelper
    {
        private const string HandlerNamespace = "Workflow.Actions";
        public static string GetBaseDir()
        {
            return "..\\Workflow\\";
        }
        public static Type FindActionHandlerType(string actionName)
        {
            var handlerType = Type.GetType(HandlerNamespace + "." + actionName + "Handler", false, true);
            return handlerType != null && typeof(ActionHandlerBase).IsAssignableFrom(handlerType) ? handlerType : null;
        }
        public static string Normalize(string xml)
        {
            xml = xml.Replace("\r\n", "");
            while (xml.Contains(' ')) xml = xml.Replace(" ", "");
            return xml;
        }

        public static string LoadXmlAsString(string file)
        {
            var desXml = new XmlDocument();
            desXml.Load(file);
            return LoadDomAsString(desXml);
        }

        public static string LoadDomAsString(XmlDocument desXml)
        {
            var result = new StringWriter();
            desXml.Save(result);
            return result.ToString();
        }

      
        private static bool _validationResult;
        private static string _validationResultInfo;

        public static string ValidateSchema(XmlSchemaSet schemaSet, XElement node)
        {
            var settings = new XmlReaderSettings
            {
                Schemas = schemaSet,
                ValidationType = ValidationType.Schema,
                ValidationFlags = XmlSchemaValidationFlags.ProcessSchemaLocation | XmlSchemaValidationFlags.ReportValidationWarnings
            };
            
            settings.ValidationEventHandler += ValidationHandler;
           
            var xmlRead = new XmlNodeReader(GetXmlNode(node));
            var reader = XmlReader.Create(xmlRead, settings);

            _validationResult = true;
            while (reader.Read()) ;

            if (!_validationResult)
            {
                _validationResultInfo ??= "error";
               return _validationResultInfo;
            }
            return "Ok";
        }

        public static void ValidationHandler(object sender, ValidationEventArgs args)
        {
            _validationResult = false;
            _validationResultInfo += String.Format("***Validation error\n");
            _validationResultInfo += String.Format("\tSeverity:{0}\n", args.Severity);
            _validationResultInfo += String.Format("\tMessage:{0}\n", args.Message);
        }

        public static XmlNode GetXmlNode(this XElement element)
        {
            using (XmlReader xmlReader = element.CreateReader())
            {
                XmlDocument xmlDoc = new();
                xmlDoc.Load(xmlReader);
                return xmlDoc;
            }
        }


    }
}

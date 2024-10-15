using System.Xml.Xsl;
using System.Xml;

namespace ServerSVH.Workflow.Actions
{
    public class ExXmlUrlResolver : XmlUrlResolver
    {
        public override Uri ResolveUri(Uri baseUri, string relativeUri)
        {
            if (relativeUri == "NSI//TranspNSIXml.xml")
                return new Uri(baseUri, "..//..//Workflow//NSI//TranspNSIXml.xml");
            Uri Result = base.ResolveUri(baseUri, relativeUri);
            return Result;
        }
        public override object GetEntity(Uri absoluteUri, string role, Type ofObjectToReturn)
        {
            var entry = base.GetEntity(absoluteUri, role, ofObjectToReturn);
            return entry;
        }
    }

    public class CachedXslTransformLoader
    {
        private readonly Dictionary<string, XslCompiledTransform> transforms = [];

        public XslCompiledTransform Load(string name)
        {
            if (!transforms.TryGetValue(name, out XslCompiledTransform transform))
            {
                XsltSettings settings = new(true, true);
                transform = new XslCompiledTransform();
                transform.Load(name, settings, new ExXmlUrlResolver());
                transforms[name] = transform;
            }

            return transform;
        }

        public void Clear()
        {
            transforms.Clear();
        }
    }
}

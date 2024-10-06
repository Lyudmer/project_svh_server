using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace ServerSVH.Workflow.Actions
{
    class WorkflowXmlUrlResolver : XmlUrlResolver
    {
        string _basePath;
        public WorkflowXmlUrlResolver(string basePath)
        {
            _basePath = basePath;
        }
        public override object GetEntity(Uri absoluteUri, string role, Type ofObjectToReturn)
        {
            return base.GetEntity(absoluteUri, role, ofObjectToReturn);
        }

        public override Uri ResolveUri(Uri baseUri, string relativeUri)
        {
            string Path = System.IO.Path.GetFullPath(System.IO.Path.Combine(_basePath, relativeUri));
            return new Uri(Path);
        }
    }
}

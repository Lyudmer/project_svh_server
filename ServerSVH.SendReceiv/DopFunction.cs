using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace ServerSVH.SendReceiv
{
    record class DocFromXml
    (
        string TypeDoc,
        Guid DocId,
        DateTime DocCreate,
        string DocText
    );
    record class PkgFromXml
    (
        int Pid,
        int Status,
        Guid UserId,
        Guid UUID
    );
    record class ResLoadPackage
    (
        int Pid,
        int Status
    );
    public class DopFunction
    {
     
       
        public static string GetHashMd5(string text)
        {
            string result = string.Empty;
            if (string.IsNullOrEmpty(text))
            {
                var md5 = MD5.Create();
                var hash = md5?.ComputeHash(Encoding.UTF8.GetBytes(text));
                if (hash != null) result = Convert.ToBase64String(hash);
            }
            return result;
        }
        public static string GetSha256(string text)
        {
            var sb = new StringBuilder();
            using (var hash = SHA256.Create())
            {
                var result = hash?.ComputeHash(Encoding.UTF8.GetBytes(text));
                if (result != null)
                {
                    for (int i = 0; i < result.Length; i++)
                        sb.Append(result[i].ToString("x2"));
                }
            }
            return sb.ToString();
        }
    }
}

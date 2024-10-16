using System.Security.Cryptography;
using System.Text;


namespace ServerSVH.Application.Common
{
    public record class DocFromXml
    (
        string TypeDoc,
        Guid DocId,
        DateTime DocCreate,
        string DocText
    );
    public class ResLoadPackage
    {
        public Guid UUID { get; set; }= Guid.Empty;
        public int Pid { get; set; } = -1;    
        public int Status { get; set; }= -1;
        public string Message { get; set; }=string.Empty;
    };

    public class DopFunction
    {
       
        public static string GetHashMd5(string text)
        {
            string result = string.Empty;
            if (!string.IsNullOrEmpty(text))
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

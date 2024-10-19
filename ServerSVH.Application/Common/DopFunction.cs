using System.Security.Cryptography;
using System.Text;


namespace ServerSVH.Application.Common
{
    public class DocFromXml
    {
        public string TypeDoc { get; set; } = string.Empty;
        public Guid DocId { get; set; } = Guid.Empty;
        public DateTime CreateDate { get; set; } = DateTime.Now.Date;
        public string DocText { get; set; } = string.Empty;
        public int Did { get; set; } = -1;
        public string HashMd5 { get; set; } = string.Empty;
        public string Sha256 { get; set; } = string.Empty;
        
    };
    public class ResLoadPackage
    {
        public Guid UserId { get; set; } = Guid.Empty;
        public Guid UUID { get; set; }= Guid.Empty;
        public DateTime CreateDate { get; set; } = DateTime.UtcNow;
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

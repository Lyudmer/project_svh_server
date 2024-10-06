using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace ServerSVH.Application.Common
{
    public class ConverterValue
    {
        public static T? ConvertTo<T>(string? valStr)
        {
            if (typeof(T) == typeof(int))
            {
                if (int.TryParse(valStr, out int result))
                {
                    return (T)Convert.ChangeType(result, typeof(T));
                }
            }
            else if (typeof(T) == typeof(Guid))
            {
                if (Guid.TryParse(valStr, out Guid result))
                {
                    return (T)Convert.ChangeType(result, typeof(T));
                }
            }
            else if (typeof(T) == typeof(DateTime))
            {
                if (DateTime.TryParse(valStr, out DateTime result))
                {
                    return (T)Convert.ChangeType(result, typeof(T));
                }
            }

            return default; // Возвращаем значение по умолчанию, если преобразование не удалось
        }
    }
}

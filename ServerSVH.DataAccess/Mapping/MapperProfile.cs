using AutoMapper;
using ServerSVH.Core.Models;
using ServerSVH.DataAccess.Entities;

namespace ServerSVH.DataAccess.Mapping
{
    public class MapperProfile : Profile
    {
        public MapperProfile()
        {
            CreateMap<DocumentEntity, Document>()
                .ForAllMembers(x => x.Condition((src, dest, prop) =>
                    {
                        if (prop == null) return false;
                        if (prop.GetType() == typeof(string) && string.IsNullOrEmpty((string)prop)) return false;
                        return true;
                     }
                ));
            CreateMap<PackageEntity, Package>()
                .ForAllMembers(x => x.Condition((src, dest, prop) =>
            {
                if (prop == null) return false;
                if (prop.GetType() == typeof(string) && string.IsNullOrEmpty((string)prop)) return false;
                return true;
            }
                ));
            CreateMap<StatusGraphEntity, StatusGraph>()
                .ForAllMembers(x => x.Condition((src, dest, prop) =>
                {
                    if (prop == null) return false;
                    if (prop.GetType() == typeof(string) && string.IsNullOrEmpty((string)prop)) return false;
                    return true;
                }
                ));
        }
    }
}

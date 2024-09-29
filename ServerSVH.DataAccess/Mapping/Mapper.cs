using AutoMapper;
using ServerSVH.Core.Models;
using ServerSVH.DataAccess.Entities;

namespace ServerSVH.DataAccess.Mapping
{
    public class Mapper : Profile
    {
        public Mapper()
        {
            CreateMap<DocumentEntity, Document>(MemberList.Destination);
            CreateMap<PackageEntity, Package>(MemberList.Destination);
            CreateMap<StatusGraphEntity, StatusGraph>(MemberList.Destination);
        }
    }
}

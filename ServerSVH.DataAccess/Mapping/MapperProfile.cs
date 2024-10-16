using AutoMapper;
using ServerSVH.Core.Models;
using ServerSVH.DataAccess.Entities;

namespace ServerSVH.DataAccess.Mapping
{
    public class MapperProfile : Profile
    {
        public MapperProfile()
        {
            CreateMap<DocumentEntity, Document>().ReverseMap();
            CreateMap<Document, DocumentEntity>().ReverseMap();
            CreateMap<PackageEntity, Package>().ReverseMap();
            CreateMap<Package, PackageEntity>().ReverseMap();
            CreateMap<StatusGraphEntity, StatusGraph>().ReverseMap();
        }
    }
}

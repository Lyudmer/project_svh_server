
using ServerSVH.DataAccess.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ServerSVH.DataAccess.Configurations
{
    public class StatusGraphConfiguration : IEntityTypeConfiguration<StatusGraphEntity>
    {
        
        public void Configure(EntityTypeBuilder<StatusGraphEntity> builder)
        {
            builder.ToTable("pkg_status_graph");
    //ключи
            builder.HasKey(st => new { st.OldSt, st.NewSt });
            
    //свойства полей
            builder.Property(st => st.OldSt)
                   .HasColumnName("oldst")
                   .IsRequired();
            builder.Property(st => st.NewSt)
                    .HasColumnName("newst")
                   .IsRequired();
           
        }
    }
}

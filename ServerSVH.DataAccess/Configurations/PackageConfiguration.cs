
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;

using ServerSVH.DataAccess.Entities;



namespace ServerSVH.DataAccess.Configurations
{
    public class PackageConfiguration : IEntityTypeConfiguration<PackageEntity>
    {
        public void Configure(EntityTypeBuilder<PackageEntity> builder)
        {
            builder.ToTable("packages");
            //ключи
            builder.HasKey(p => p.Id);

            builder
                .HasMany(p => p.Documents)
                .WithOne(d => d.Package)
                .HasForeignKey(d => d.Pid)
                .OnDelete(DeleteBehavior.Cascade); 
            //свойства полей
            builder.Property(p => p.Id)
                   .IsRequired()
                   .ValueGeneratedOnAdd()
                   .HasColumnName("pid")
                   .HasColumnType("bigint");
            builder.Property(p => p.UUID)
                        .IsRequired()
                        .HasColumnName("uuid")
                        .HasColumnType("uuid");

            builder.Property(p => p.CreateDate)
                        .HasColumnName("create_date");

            builder.Property(p => p.ModifyDate)
                    .HasColumnName("modify_date");

            builder.Property(p => p.StatusId)
                   .HasColumnName("status");

            builder.Property(p => p.UserId)
                   .HasColumnName("user_id")
                   .HasColumnType("uuid")
                   .IsRequired();


        }
    }
}

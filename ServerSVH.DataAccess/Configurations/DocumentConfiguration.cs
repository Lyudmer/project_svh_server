using ServerSVH.DataAccess.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ServerSVH.DataAccess.Configurations
{
    public class DocumentConfiguration : IEntityTypeConfiguration<DocumentEntity>
    {
        public void Configure(EntityTypeBuilder<DocumentEntity> builder)
        {
            builder.ToTable("documents");
            //ключи
            builder.HasKey(d => d.Id);
            builder
                .HasOne(p => p.Package)
                .WithMany(d => d.Documents)
                .HasForeignKey(d => d.Id);
            //свойства полей
            builder.Property(d => d.Id)
                   .IsRequired()
                   .ValueGeneratedOnAdd()
                   .HasColumnName("did")
                   .HasColumnType("bigint");

            builder.Property(d => d.DocId)
                   .IsRequired()
                   .ValueGeneratedOnAdd()
                   .HasColumnName("docid")
                   .HasColumnType("uuid");
            builder.Property(d => d.Pid)
                   .IsRequired()
                   .HasColumnName("pid");

            builder.Property(d => d.CreateDate)
                    .HasColumnName("create_date")
                    .HasDefaultValueSql("now()");

            builder.Property(d => d.ModifyDate)
                    .HasColumnName("modify_date");
            builder.Property(d => d.SizeDoc)
                    .IsRequired()
                    .ValueGeneratedOnAdd()
                    .HasColumnName("size_doc");
            builder.Property(d => d.Idmd5)
                   .IsRequired()
                   .ValueGeneratedOnAdd()
                   .HasColumnName("idmd5")
                   .HasMaxLength(32);
            builder.Property(d => d.IdSha256)
                   .IsRequired()
                   .ValueGeneratedOnAdd()
                   .HasColumnName("idsha256")
                   .HasMaxLength(64);
        }
    }
}

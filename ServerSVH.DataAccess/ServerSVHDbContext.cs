
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using ServerSVH.DataAccess.Configurations;
using ServerSVH.DataAccess.Entities;

namespace ServerSVH.DataAccess
{
    public class ServerSVHDbContext(DbContextOptions<ServerSVHDbContext> options)
        : DbContext(options)
    {
        public DbSet<PackageEntity> Packages { get; set; }
        public DbSet<DocumentEntity> Document { get; set; }
     
        public DbSet<StatusGraphEntity> StatusGraph { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfiguration(new PackageConfiguration());
            modelBuilder.ApplyConfiguration(new DocumentConfiguration());
            modelBuilder.ApplyConfiguration(new StatusGraphConfiguration());
          

            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ServerSVHDbContext).Assembly);

            base.OnModelCreating(modelBuilder);

        }
      
       
    }
    public class MyAppDbContextFactory : IDesignTimeDbContextFactory<ServerSVHDbContext>
    {
        public ServerSVHDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<ServerSVHDbContext>();
            optionsBuilder.UseNpgsql("Host=localhost;User ID=postgres;Password=studadmin;Port=5132;Database=srsvhdb;");
            var b = optionsBuilder.Options;

            return new ServerSVHDbContext(b);
        }
    }
}

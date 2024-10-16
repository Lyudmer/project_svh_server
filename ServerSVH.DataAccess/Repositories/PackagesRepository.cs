using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DataAccess.Entities;

namespace ServerSVH.DataAccess.Repositories
{
    public class PackagesRepository(ServerSVHDbContext dbContext, IMapper mapper) : IPackagesRepository
    {
        private readonly ServerSVHDbContext _dbContext = dbContext;
        private readonly IMapper _mapper = mapper;

        public async Task<Package> Add(Package Pkg)
        {
            var PkgEntity = _mapper.Map<PackageEntity>(Pkg);
            var resPkg = await _dbContext.AddAsync(PkgEntity);
            await _dbContext.SaveChangesAsync();
            return _mapper.Map<Package>(resPkg.Entity);
        }
        public async Task<Package> GetByUUId(Guid uuid)
        {
            var pkgEntity = await _dbContext.Packages
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.UUID == uuid) ?? throw new Exception();
            return _mapper.Map<Package>(pkgEntity);

        }
        public async Task<Package> GetById(int Pid)
        {
            var pkgEntity = await _dbContext.Packages
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == Pid) ?? throw new Exception();

            return _mapper.Map<Package>(pkgEntity);

        }
        public async Task<List<Package>> GetAll()
        {
            var query = _dbContext.Packages
                .AsNoTracking()
                .OrderBy(p => p.UserId)
                .ThenBy(p => p.Id);
            var pkgList = await query.ToListAsync();
            return _mapper.Map<List<Package>>(pkgList);
        }
        public async Task<List<Package>> GetPkgUser(Guid UserId)
        {
            var query = _dbContext.Packages
                .AsNoTracking()
                .OrderBy(p => p.Id);
            var pkgList = await query.ToListAsync();
            return _mapper.Map<List<Package>>(pkgList);
        }
        public async Task<Package> GetPkgByGuid(Guid UserId, Guid UUID)
        {
            var pkgEntity = await _dbContext.Packages
                .AsNoTracking()
                .Include(p => p.Documents)
                .FirstOrDefaultAsync(p => p.UUID == UUID && p.UserId == UserId)
                ?? throw new Exception();

            return _mapper.Map<Package>(pkgEntity);

        }
        public async Task<Package> GetPkgWithDoc(int Pid)
        {
            var pkgEntity = await _dbContext.Packages
                .AsNoTracking()
                .Include(p => p.Documents)
                .FirstOrDefaultAsync(p => p.Id == Pid)
                ?? throw new Exception();

            return _mapper.Map<Package>(pkgEntity);

        }

        public async Task<List<Package>> GetByPage(int Page, int Page_Size)
        {
            var query = _dbContext.Packages
                .AsNoTracking()
                .Skip((Page - 1) * Page_Size)
                .Take(Page_Size);
            var pkgList = await query.ToListAsync();
            return _mapper.Map<List<Package>>(pkgList);

        }
        public async Task<int> UpdateStatus(int Pid, int statusId)
        {
           var resId= await _dbContext.Packages
                            .Where(p => p.Id == Pid)
                            .ExecuteUpdateAsync(s => s.SetProperty(p => p.StatusId, statusId)
                                                      .SetProperty(p => p.ModifyDate, DateTime.Now));
            if (resId == 0) return 0;
            else return Pid;
        }
        public async Task Delete(int Pid)
        {
            await _dbContext.Packages
                .Where(u => u.Id == Pid)
                .ExecuteDeleteAsync();
        }
        public async Task<int> GetLastPkgId()
        {
            var cPkg = await _dbContext.Packages.CountAsync();

            return cPkg;
        }

    }
}

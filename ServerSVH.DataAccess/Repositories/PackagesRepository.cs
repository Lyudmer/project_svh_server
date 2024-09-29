using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;

namespace ServerSVH.DataAccess.Repositories
{
    public class PackagesRepository(ServerSVHDbContext dbContext, IMapper mapper) : IPackagesRepository
    {
        private readonly ServerSVHDbContext _dbContext = dbContext;
        private readonly IMapper _mapper = mapper;

        public async Task<Package> Add(Package Pkg)
        {
            await _dbContext.AddAsync(Pkg);
            await _dbContext.SaveChangesAsync();
            return Pkg;
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
        public async Task<Package> GetPkgWithDoc(int Pid)
        {
            var pkgEntity = await _dbContext.Packages
                .AsNoTracking()
                .Include(p => p.Documents)
                .FirstOrDefaultAsync(p => p.Id == Pid)
                ?? throw new Exception();

            return _mapper.Map<Package>(pkgEntity);

        }
        public async Task<int> GetByStatus(int Pid)
        {
            var pkgEntity = await _dbContext.Packages
                        .AsNoTracking()
                        .FirstOrDefaultAsync(p => p.Id == Pid);
            return _mapper.Map<Package>(pkgEntity).StatusId;
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
        public async Task UpdateStatus(int Pid, int statusId)
        {
            await _dbContext.Packages
                .Where(p => p.Id == Pid)
                .ExecuteUpdateAsync(s => s.SetProperty(p => p.StatusId, statusId)
                                          .SetProperty(p => p.ModifyDate, DateTime.Now));
        }
        public async Task Delete(int Pid)
        {
            await _dbContext.Packages
                .Where(u => u.Id == Pid)
                .ExecuteDeleteAsync();
        }
        public async Task<int> GetLastPkgId()
        {
            return await _dbContext.Packages.MaxAsync(p => p.Id);
        }
     
        
    }
}

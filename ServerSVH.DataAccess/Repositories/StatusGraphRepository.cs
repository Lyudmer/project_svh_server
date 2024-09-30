using ServerSVH.DataAccess.Entities;
using Microsoft.EntityFrameworkCore;
using ServerSVH.Core.Abstraction.Repositories;
using AutoMapper;


namespace ServerSVH.DataAccess.Repositories
{
    public class StatusGraphRepository(ServerSVHDbContext dbContext, IMapper mapper) : IStatusGraphRepository
    {
        private readonly ServerSVHDbContext _dbContext = dbContext;
        private readonly IMapper _mapper = mapper;
        public async Task Add(int oldst, int newst, string maskbit)
        {
            var statusGraphEntity = new StatusGraphEntity
            {
                OldSt = oldst,
                NewSt = newst,

            };
            await _dbContext.AddAsync(statusGraphEntity);
            await _dbContext.SaveChangesAsync();
        }
        public async Task Delete(int oldst, int newst)
        {

            await _dbContext.StatusGraph
                .Where(u => u.OldSt == oldst)
                .Where(u => u.NewSt == newst)
                .ExecuteDeleteAsync();
        }
        public async Task<int> GetNewSt(int OldSt)
        {
            var newStatus = await _dbContext.StatusGraph
                                .AsNoTracking()
                                .FirstOrDefaultAsync(u => u.OldSt == OldSt) ?? throw new Exception();
           
            return _mapper.Map<int>(newStatus);
        }
    }
}

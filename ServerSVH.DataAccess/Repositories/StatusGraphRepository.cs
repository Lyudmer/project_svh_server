using ServerSVH.DataAccess.Entities;
using Microsoft.EntityFrameworkCore;
using ServerSVH.Core.Abstraction.Repositories;
using AutoMapper;
using ServerSVH.Core.Models;


namespace ServerSVH.DataAccess.Repositories
{
    public class StatusGraphRepository(ServerSVHDbContext dbContext, IMapper mapper) : IStatusGraphRepository
    {
        private readonly ServerSVHDbContext _dbContext = dbContext;
        private readonly IMapper _mapper = mapper;
        public async Task Add(StatusGraph statusGraph)
        {
            var stGrEntity = _mapper.Map<StatusGraphEntity>(statusGraph);
            await _dbContext.AddAsync(stGrEntity);
            await _dbContext.SaveChangesAsync();
        }
        public async Task Delete(StatusGraph statusGraph)
        {
            await _dbContext.StatusGraph
                .Where(u => u.OldSt == statusGraph.OldSt)
                .Where(u => u.NewSt == statusGraph.NewSt)
                .ExecuteDeleteAsync();
        }
        public async Task<StatusGraph> GetNewSt(int OldSt)
        {
            var newStatus = await _dbContext.StatusGraph
                                .AsNoTracking()
                                .FirstOrDefaultAsync(u => u.OldSt == OldSt) ?? throw new Exception();

            return _mapper.Map<StatusGraph>(newStatus);
        }
    }
}

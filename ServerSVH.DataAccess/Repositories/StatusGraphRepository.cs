using ServerSVH.DataAccess.Entities;
using Microsoft.EntityFrameworkCore;
using ServerSVH.Core.Abstraction.Repositories;


namespace ServerSVH.DataAccess.Repositories
{
    public class StatusGraphRepository(ServerSVHDbContext dbContext) : IStatusGraphRepository
    {
        private readonly ServerSVHDbContext _dbContext = dbContext;

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
    }
}

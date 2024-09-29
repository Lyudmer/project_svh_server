using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.Core.Models;
using ServerSVH.DataAccess.Entities;



namespace ServerSVH.DataAccess.Repositories
{
    public class DocumentsRepository(ServerSVHDbContext dbContext, IMapper mapper) : IDocumentsRepository
    {
        private readonly ServerSVHDbContext _dbContext = dbContext;

        private readonly IMapper _mapper = mapper;

        public async Task<Document> Add(Document Doc)
        {
            var docEntity = new DocumentEntity
            {
                Pid = Doc.Pid,
                Id = Doc.Id,
                DocId = Doc.DocId,
                SizeDoc = Doc.SizeDoc,
                Idmd5 = Doc.Idmd5,
                IdSha256 = Doc.IdSha256,
                CreateDate = Doc.CreateDate,
                ModifyDate = Doc.ModifyDate
            };

            await _dbContext.AddAsync(docEntity);
            await _dbContext.SaveChangesAsync();

            return Doc;
        }
        public async Task<Document> GetById(int id)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Id == id) ?? throw new Exception();

            return _mapper.Map<Document>(docEntity);

        }
        public async Task<List<Document>> GetByFilter(int pid)
        {
            var query = _dbContext.Document.AsNoTracking();

            if (pid > 0) { query = query.Where(p => p.Pid == pid); }

            var docs = await query.ToListAsync();
            return _mapper.Map<List<Document>>(docs);

        }
        public async Task<List<Document>> GetByPage(int page, int page_size)
        {
            var query = _dbContext.Document
                .AsNoTracking()
                .Skip((page - 1) * page_size)
                .Take(page_size);

            var docs = await query.ToListAsync();
            return _mapper.Map<List<Document>>(docs);
        }

        public async Task Update(int Id)
        {
            await _dbContext.Document
                .Where(p => p.Id == Id)
                .ExecuteUpdateAsync(s => s.SetProperty(p => p.ModifyDate, DateTime.Now));
        }
        public async Task Delete(int Id)
        {
            await _dbContext.Document
                .Where(u => u.Id == Id)
                .ExecuteDeleteAsync();
        }
       
        public async Task<int> GetLastDocId()
        {
            return await _dbContext.Document.MaxAsync(p => p.Id);
        }
    }
}

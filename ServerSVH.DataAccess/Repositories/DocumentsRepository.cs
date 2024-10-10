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
            await _dbContext.AddAsync(Doc);
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
        public async Task<Document> GetByDocType(int pid,string docType)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Pid == pid && d.DocType == docType) ?? throw new Exception();

            return _mapper.Map<Document>(docEntity);

        }
        public async Task<List<Document>> GetListByDocType(int pid, string docType)
        {

            var query = _dbContext.Document.AsNoTracking();

            if (pid > 0) { query = query.Where(d => d.Pid == pid && d.DocType == docType); }

            var docs = await query.ToListAsync();
            return _mapper.Map<List<Document>>(docs);
        }
        public async Task<Document> GetByGuidId(Guid did)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.DocId == did) ?? throw new Exception();

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

        public async Task Update(Guid DocId, Document Doc)
        {
            await _dbContext.Document
                .Where(p => p.DocId == DocId)
                .ExecuteUpdateAsync(s => s.SetProperty(p => p.ModifyDate, DateTime.Now)
                                          .SetProperty(p => p.SizeDoc, Doc.SizeDoc)
                                          .SetProperty(p => p.DocType, Doc.DocType)
                                          .SetProperty(p => p.Idmd5, Doc.Idmd5)
                                          .SetProperty(p => p.IdSha256, Doc.IdSha256)
                                    );
        }
        public async Task Delete(int Id)
        {
            await _dbContext.Document
                .Where(u => u.Id == Id)
                .ExecuteDeleteAsync();
        }
        public async Task Delete(Guid Id)
        {
            await _dbContext.Document
                .Where(u => u.DocId == Id)
                .ExecuteDeleteAsync();
        }
        public async Task<int> GetLastDocId()
        {
            return await _dbContext.Document.MaxAsync(p => p.Id);
        }
    }
}

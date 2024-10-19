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

        public async Task<Document> Add(Document inDoc)
        {
            var docEntity = _mapper.Map<DocumentEntity>(inDoc);
            
            var resEntity = await _dbContext.AddAsync(docEntity);
            await _dbContext.SaveChangesAsync();
            return _mapper.Map<Document>(resEntity.Entity);

        }
        public async Task<Document> GetById(int id)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Id == id);

            return _mapper.Map<Document>(docEntity);

        }
        public async Task<int> GetByDocType(int pid,string docType)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Pid == pid && d.DocType == docType);

            if (docEntity == null) return 0;
            else return docEntity.Id;

        }
        public async Task<Guid> GetByGuidDocType(int pid, string docType)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.Pid == pid && d.DocType == docType);

            if (docEntity == null) return Guid.Empty;
            else return docEntity.DocId;

        }
        public async Task<List<Document>> GetListByDocType(int pid, string docType)
        {

            var query = _dbContext.Document.AsNoTracking();

            if (pid > 0) { query = query.Where(d => d.Pid == pid && d.DocType == docType); }

            var docs = await query.ToListAsync();
            return _mapper.Map<List<Document>>(docs);
        }
        public async Task<int> GetByGuidId(Guid did)
        {
            var docEntity = await _dbContext.Document
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.DocId == did);
            if (docEntity == null) return 0;
            else  return docEntity.Id;

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
                .ExecuteUpdateAsync(s => s.SetProperty(p => p.ModifyDate, DateTime.UtcNow)
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
            int cDoc = 0;
            try
            {
                var resId= await _dbContext.Document.CountAsync();

                if (resId != 0) cDoc = resId;
                else cDoc = 0;

            }
            catch (Exception )
            {
                return cDoc;
            }
            return cDoc;
        }
    }
}

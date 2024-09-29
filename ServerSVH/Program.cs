using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using ServerSVH.DataAccess;
using ServerSVH.DocRecordDataAccess;

var builder = WebApplication.CreateBuilder(args);
var services = builder.Services;
var configuration = builder.Configuration;
// Add services to the container.

services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
services.AddEndpointsApiExplorer();
services.AddSwaggerGen();


//postgresql db
var connectionString = builder.Configuration.GetConnectionString("PostgresConnection");
services.AddDbContext<ServerSVHDbContext>(options => { options.UseNpgsql(connectionString); });

services.Configure<DocRecordDBSettings>(configuration.GetSection("MongoDBSettings"));

services.AddTransient<IMongoClient>(_ =>
{
    var connectionString = configuration.GetSection("MongoDBSettings:MongoDBConnectionString")?.Value;

    return new MongoClient(connectionString);
});
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

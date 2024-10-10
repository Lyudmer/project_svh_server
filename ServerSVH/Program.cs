using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver;
using ServerSVH.Application.Interface;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.DataAccess;
using ServerSVH.DataAccess.Repositories;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordDataAccess;
using ServerSVH.SendReceiv;
using ServerSVH.SendReceiv.Consumer;
using ServerSVH.SendReceiv.Producer;
using ServerSVH.SendReceiv.Settings;

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

services.AddTransient<IServerServices, ServerServices>();

services.Configure<DocRecordDBSettings>(configuration.GetSection("MongoDBSettings"));

services.AddTransient<IMongoClient>(_ =>
{
    var connectionString = configuration.GetSection("MongoDBSettings:MongoDBConnectionString")?.Value;

    return new MongoClient(connectionString);
});

services.AddTransient<IPackagesRepository, PackagesRepository>();
services.AddTransient<IDocumentsRepository, DocumentsRepository>();
services.AddTransient<IDocRecordRepository, DocRecordRepository>();
services.AddTransient<IStatusGraphRepository, StatusGraphRepository>();

services.AddScoped<IMessagePublisher, RabbitMQProducer>();
services.AddScoped<IRabbitMQConsumer, RabbitMQConsumer>();

services.AddAutoMapper(typeof(ServerServices).Assembly);

services.AddHttpContextAccessor();
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

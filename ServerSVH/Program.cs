
using Microsoft.EntityFrameworkCore;

using MongoDB.Driver;
using ServerSVH.Application.Interface;
using ServerSVH.Core.Abstraction.Repositories;
using ServerSVH.DataAccess;
using ServerSVH.DataAccess.Mapping;
using ServerSVH.DataAccess.Repositories;
using ServerSVH.DocRecordCore.Abstraction;
using ServerSVH.DocRecordDataAccess;
using ServerSVH.SendReceiv;
using ServerSVH.SendReceiv.Consumer;
using ServerSVH.SendReceiv.Producer;
using ServerSVH.SendReceiv.Settings;
using ServerSVH.Workflow;

var builder = WebApplication.CreateBuilder(args);
var services = builder.Services;
var configuration = builder.Configuration;
// Add services to the container.

services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
services.AddEndpointsApiExplorer();
services.AddSwaggerGen();


//postgresql db

services.AddDbContext<ServerSVHDbContext>(options => 
{ 
    options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")); 

});

services.AddControllers()
    .AddJsonOptions(options => options.JsonSerializerOptions.PropertyNamingPolicy = null);

//mongodb
services.Configure<Settings>(configuration.GetSection("MongoConnection"));


services.AddTransient<IMongoClient>(_ =>
{
    var connectionString = configuration.GetSection("MongoConnection:ConnectionString")?.Value;

    return new MongoClient(connectionString);
});

services.AddTransient<IPackagesRepository, PackagesRepository>();
services.AddTransient<IDocumentsRepository, DocumentsRepository>();
services.AddTransient<IDocRecordRepository, DocRecordRepository>();
services.AddTransient<IStatusGraphRepository, StatusGraphRepository>();
services.AddTransient<IRunWorkflow, RunWorkflow>();
services.AddTransient<IRabbitMQBase, RabbitMQBase>();
services.AddTransient<IMessagePublisher, RabbitMQProducer>();
services.AddTransient<IRabbitMQConsumer, RabbitMQConsumer>();

services.AddTransient<IServerFunction, ServerFunction>();
services.AddTransient<IServerServices, ServerServices>();
builder.Services.AddAutoMapper(typeof(MapperProfile));
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

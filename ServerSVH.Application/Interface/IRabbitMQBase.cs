using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;

namespace ServerSVH.Application.Interface
{
    public interface IRabbitMQBase
    {
        IModel GetConfigureRabbitMQ();
        IConnection GetRabbitConnection(IConfiguration configuration);
    }
}
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using ServerSVH.Application.Interface;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace ServerSVH.SendReceiv.Consumer
{
    public class RabbitMQConsumer(IRabbitMQBase rabbitMQBase) : IRabbitMQConsumer
    {
        private readonly IRabbitMQBase _rabbitMQBase = rabbitMQBase;

        public string LoadMessage(string CodeCMN)
        {
            string resLoadMessage = "";
            using IModel channel = _rabbitMQBase.GetConfigureRabbitMQ();

            channel.QueueDeclare(CodeCMN, false, true, false, null);

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (sender, e) =>
            {
                var body = e.Body;
                resLoadMessage = Encoding.UTF8.GetString(body.ToArray());
                channel.BasicAck(e.DeliveryTag, false);

            };

            channel.BasicConsume(CodeCMN, false, consumer);

            return resLoadMessage;
        }

    }
}
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using ServerSVH.Application.Interface;

namespace ServerSVH.SendReceiv.Consumer
{
    public class RabbitMQConsumer(IRabbitMQBase rabbitMQBase) : IRabbitMQConsumer
    {
        private readonly IRabbitMQBase _rabbitMQBase = rabbitMQBase;

        public string LoadMessage(string exchangeName, string queueName, string CodeCMN)
        {
            string resLoadMessage = "";
            using IModel channel = _rabbitMQBase.GetConfigureRabbitMQ();
            channel.BasicQos(0, 10, false);
            channel.QueueDeclare(queueName, false, false, false, null);
            channel.QueueBind(queueName, exchangeName, CodeCMN, null);

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (sender, e) =>
            {
                var body = e.Body;
                resLoadMessage = Encoding.UTF8.GetString(body.ToArray());
                channel.BasicAck(e.DeliveryTag, false);

            };

            channel.BasicConsume(queueName, false, consumer);

            return resLoadMessage;
        }
    }
}
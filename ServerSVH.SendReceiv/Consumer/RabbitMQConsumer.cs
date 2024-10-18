using System.Text;
using System.Text.Json;

using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using ServerSVH.Application.Interface;


namespace ServerSVH.SendReceiv.Consumer
{
    public class RabbitMQConsumer(IRabbitMQBase rabbitMQBase) : IRabbitMQConsumer
    {
        private readonly IRabbitMQBase _rabbitMQBase = rabbitMQBase;

        public string LoadMessage(string CodeCMN)
        {
            using IModel channel = _rabbitMQBase.GetConfigureRabbitMQ();
            string resMess = Register(channel, $"exchange.direct", $"queue.direct", CodeCMN);
            _rabbitMQBase.CloseModelRabbitMQ(channel);
            return resMess;
        }
        public static string Register(IModel channel, string exchangeName, string queueName, string routingKey)
        {
            channel.BasicQos(0, 10, false);
            channel.QueueDeclare(queueName, false, false, false, null);
            channel.QueueBind(queueName, exchangeName, routingKey, null);
            var message = string.Empty;
            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (sender, e) =>
            {

                var body = e.Body;
                message = JsonSerializer.Deserialize<string>(Encoding.UTF8.GetString(body.ToArray()));

                channel.BasicAck(e.DeliveryTag, false);

            };

            channel.BasicConsume(queueName, false, consumer);
           
            return message;
        }
    }
}
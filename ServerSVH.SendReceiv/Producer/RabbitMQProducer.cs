using RabbitMQ.Client;
using ServerSVH.Application.Interface;
using System.Text;


namespace ServerSVH.SendReceiv.Producer
{
    public class RabbitMQProducer(IRabbitMQBase rabbitMQBase) : IMessagePublisher
    {
        private readonly IRabbitMQBase _rabbitMQBase = rabbitMQBase;
        public void SendMessage<T>(T xPkg, string CodeCMN)
        {
            using IModel channel = _rabbitMQBase.GetConfigureRabbitMQ();

            channel.QueueDeclare(CodeCMN, exclusive: false);
            var strPkg = xPkg?.ToString();
            if (strPkg != null)
            {
                var body = Encoding.UTF8.GetBytes(strPkg);

                channel.BasicPublish(exchange: "package", routingKey: CodeCMN, body: body);
            }
        }
    }
}

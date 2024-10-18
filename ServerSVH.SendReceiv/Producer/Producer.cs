using System;
using System.Text;
using System.Text.Json;
using RabbitMQ.Client;

namespace ServerSVH.SendReceiv.Producer
{
    public class Producer
    {
        private string _exchangeType;
        private string _exchangeName;
        private string _routingKey;
        private IModel _model;
        public Producer(string exchangeType, string exchangeName, string routingKey, IModel model)
        {
            _exchangeName = exchangeName;
            _exchangeType = exchangeType;
            _routingKey = routingKey;
            _model = model;
            _model.ExchangeDeclare(_exchangeName, _exchangeType);
        }

        public bool Produce(string messageContent)
        {
            try
            {
                var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(messageContent));

                _model.BasicPublish(exchange: _exchangeName,
                    routingKey: _routingKey,
                    basicProperties: null,
                    body: body);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
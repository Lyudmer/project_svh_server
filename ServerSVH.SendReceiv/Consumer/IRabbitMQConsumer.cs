namespace ServerSVH.SendReceiv.Consumer
{
    public interface IRabbitMQConsumer
    {
        string LoadMessage(string CodeCMN);
    }
}
using ServerSVH.Application.Interface;
using ServerSVH.SendReceiv.Consumer;
using ServerSVH.SendReceiv.Producer;
using System.Xml.Linq;
using ServerSVH.Application.Common;




namespace ServerSVH.SendReceiv
{
    public class ServerServices(IRabbitMQConsumer rabbitMQConsumer,
                IServerFunction srvFunction,
                IMessagePublisher messagePublisher,
                IRunWorkflow runWorkflow) : IServerServices
    {
        private readonly IRabbitMQConsumer _rabbitMQConsumer = rabbitMQConsumer;
        private readonly IServerFunction _srvFunction = srvFunction;
        private readonly IMessagePublisher _messagePublisher = messagePublisher;
        private readonly IRunWorkflow _runWorkflow = runWorkflow;
        async Task<int> IServerServices.LoadMessage()
        {
            int stPkg = 0;
            int CountDoc = 0;  
            List<XDocument> resXml;
            try
            {
                // получить сообщение с пакетом
                var resMessEmul = _rabbitMQConsumer.LoadMessage("EmulSendDoc");
                var resMess = _rabbitMQConsumer.LoadMessage("SendPkg"); 
                ResLoadPackage resPkg = new();
                XDocument xPkg = new();
                // создать пакет и запустить workflow
                if (resMess != null || resMessEmul != null)
                {
                   
                    if (resMess != null)
                    {
                        resPkg = await _srvFunction.PaskageFromMessage(resMess);
                        xPkg = XDocument.Load(resMess);
                    }
                    if (resMessEmul != null)
                    {
                        resPkg = await _srvFunction.PaskageFromMessageEmul(resMessEmul);
                        xPkg = XDocument.Load(resMessEmul);
                    }
                    switch (resPkg.Status)
                    {
                        case -1:
                        case 4:
                            //отправить ошибку клиенту
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            break;
                        case 1:
                            await _srvFunction.UpdateStatusPkg(resPkg.Pid, resPkg.Status);
                            //отправить собщение клиенту
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            //запуск workflow
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);

                            if (stPkg == 3) goto case 3;
                            if (stPkg == 4) goto case 4;
                            break;
                        case 3:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);

                            if (stPkg == 5) goto case 5;
                            if (stPkg == 4) goto case 4;

                            break;
                        case 5:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            try
                            {
                                resXml = await _srvFunction.CreatePkgForEmul(resPkg, "archive-doc.cfg.xml");
                                if (resXml != null)
                                {
                                    CountDoc = resXml.Count;
                                    foreach (XDocument xDoc in resXml)
                                    {
                                        _messagePublisher.SendMessage(xDoc.ToString(), "SendEmulArch");
                                        CountDoc--;
                                    }
                                    if (CountDoc == 0)
                                    {
                                        resPkg.Status = 208;
                                        await _srvFunction.UpdateStatusPkg(resPkg.Pid, resPkg.Status);
                                        _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                                        goto case 208;
                                    }
                                    else
                                    {
                                        resPkg.Status = 4;
                                        resPkg.Message = "error archive-doc";
                                        goto case 4;
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                resPkg.Status = 4;
                                resPkg.Message = ex.Message;
                                goto case 4;
                            };
                            break;
                        case 208:
                            if (resPkg.Message.Contains("arch"))
                            {
                                xPkg = await _srvFunction.CreatePaskageAddAcrhXml(resPkg.Pid);
                                _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                                if (resPkg.Status == 217) goto case 217;
                            };
                            break;
                        case 217:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                            if (resPkg.Status == 210) goto case 210;

                            break;
                        case 210:
                            resXml = await _srvFunction.CreatePkgForEmul(resPkg, "armti.cfg.xml");
                            if (resXml != null)
                            {
                                CountDoc = resXml.Count;
                                foreach (XDocument xDoc in resXml)
                                {
                                    _messagePublisher.SendMessage(xDoc.ToString(), "SendEmulArmti");
                                }
                                await _srvFunction.UpdateStatusPkg(resPkg.Pid, resPkg.Status);
                                _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            }
                            else
                            {
                                resPkg.Status = 4;
                                resPkg.Message = "error armti";
                                goto case 4;
                            }
                            break;
                        case 214:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "StatusPkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg, "ConfirmWHDocReg.cfg.xml").ToString(), "DocResultPkg");
                            break;
                        default:
                            // ждем смены статуса
                            break;
                    }
                }
                var resMessDel = _rabbitMQConsumer.LoadMessage("DelPkg");
                if (resMessDel != null)
                {
                    resPkg = await _srvFunction.PaskageFromMessageDel(resMessDel);
                    _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "DeletedPkg");
                }
            }
            catch (Exception)
            {
                //string mess = ex.Message;

            }
            return stPkg;
        }
       
    }
   }



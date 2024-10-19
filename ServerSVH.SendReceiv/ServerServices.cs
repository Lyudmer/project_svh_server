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

        public async Task<int> LoadMessage()
        {

            // получить сообщение с пакетом
            //    var resMessEmul = _rabbitMQConsumer.LoadMessage("EmulSendDoc");

            var resMess = _rabbitMQConsumer.LoadMessage("sendpkg");
            if (resMess != null)
            {
                return await LoadMessageFile(resMess, "sendpkg");
            }
            return 0;
        }
        public async Task<int> LoadMessageFile(string resMess, string typeMess)
        {
            int stPkg = 0;
            if (resMess != null && resMess.Length > 0)
            {

                int CountDoc = 0;
                List<XDocument> resXml;
                ResLoadPackage resPkg = new();
                XDocument xPkg = new();
                try
                {
                    switch (typeMess)
                    {
                        case "sendpkg":
                            {
                                // создать пакет и запустить workflow
                                resPkg = await _srvFunction.PaskageFromMessage(resMess);
                            }
                            break;
                        case "loaddelpkg":
                            resPkg = await _srvFunction.PaskageFromMessageDel(resMess);
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "deletedpkg");
                            break;
                        case "loademulmess":
                            resPkg = await _srvFunction.PaskageFromMessageEmul(resMess);
                            xPkg = XDocument.Parse(resMess);
                            break;
                        default:
                            break;
                    }

                    switch (resPkg.Status)
                    {
                        case -1:
                        case 4:
                            //отправить ошибку клиенту
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
                            break;
                        case 1:
                            await _srvFunction.UpdateStatusPkg(resPkg.Pid, resPkg.Status);
                            //отправить собщение клиенту
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
                            //запуск workflow
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);

                            if (stPkg == 3) goto case 3;
                            if (stPkg == 4) goto case 4;
                            break;
                        case 3:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);

                            if (stPkg == 5) goto case 5;
                            if (stPkg == 4) goto case 4;

                            break;
                        case 5:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
                            try
                            {
                                resXml = await _srvFunction.CreatePkgForEmul(resPkg, "archive-doc.cfg.xml");
                                if (resXml != null)
                                {
                                    CountDoc = resXml.Count;
                                    foreach (XDocument xDoc in resXml)
                                    {
                                        _messagePublisher.SendMessage(xDoc.ToString(), "sendemularch");
                                        CountDoc--;
                                    }
                                    if (CountDoc == 0)
                                    {
                                        resPkg.Status = 208;
                                        await _srvFunction.UpdateStatusPkg(resPkg.Pid, resPkg.Status);
                                        _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
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
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
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
                                    _messagePublisher.SendMessage(xDoc.ToString(), "sendemularmti");
                                }
                                await _srvFunction.UpdateStatusPkg(resPkg.Pid, resPkg.Status);
                                _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
                            }
                            else
                            {
                                resPkg.Status = 4;
                                resPkg.Message = "error armti";
                                goto case 4;
                            }
                            break;
                        case 214:
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg).ToString(), "statuspkg");
                            _runWorkflow.RunBuilderXml(xPkg, ref resPkg);
                            _messagePublisher.SendMessage(_srvFunction.CreateResultXml(resPkg, "ConfirmWHDocReg.cfg.xml").ToString(), "docresult");
                            break;
                        default:
                            // ждем смены статуса
                            break;
                    }
                }
                catch (Exception)
                {
                    //string mess = ex.Message;

                }

            }
            return stPkg;
        }
    }
}



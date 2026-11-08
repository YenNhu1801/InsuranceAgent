using System;
using System.Collections.Generic;
using System.Threading;
using System.Reflection;
using EasyNetQ;
using EasyNetQ.Topology;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace PaymentService.Messaging.RabbitMq;

public class RabbitEventListener
{
    private readonly IBus busClient;
    private readonly IServiceProvider serviceProvider;
    private readonly ILogger<RabbitEventListener> logger;
    private readonly Exchange exchange;

    public RabbitEventListener(
        IBus busClient,
        IServiceProvider serviceProvider,
        ILogger<RabbitEventListener> logger)
    {
        this.busClient = busClient;
        this.serviceProvider = serviceProvider;
        this.logger = logger;
        this.exchange = this.busClient.Advanced.ExchangeDeclare("lab-dotnet-micro", ExchangeType.Topic);
    }

    public void ListenTo(List<Type> eventsToSubscribe)
    {
        foreach (var evtType in eventsToSubscribe)
            //add check if is INotification
            GetType()
                .GetMethod("Subscribe", BindingFlags.NonPublic | BindingFlags.Instance)
                .MakeGenericMethod(evtType)
                .Invoke(this, new object[] { });
    }

    private void Subscribe<T>() where T : INotification
    {
        //create queue & binding
        var queue = busClient.Advanced.QueueDeclare("lab-payments-service-" + typeof(T).Name);
        busClient.Advanced.Bind(exchange, queue, typeof(T).Name.ToLower());
        //subscribe
        busClient.Advanced.Consume(queue, async (IMessage<T> msg, MessageReceivedInfo messageReceivedInfo) =>
        {
            try
            {
                using var scope = serviceProvider.CreateScope();
                var internalBus = scope.ServiceProvider.GetRequiredService<IMediator>();
                await internalBus.Publish(msg.Body, CancellationToken.None);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Rabbit handler failed for {EventType}", typeof(T).Name);
                throw;
            }
        });
    }
}
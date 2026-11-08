using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Polly;
using Polly.Retry;
using PricingService.Api.Commands;
using RestEase;
using Steeltoe.Common.Discovery;
using Steeltoe.Discovery;

namespace PolicyService.RestClients;

public interface IPricingClient
{
    [Post]
    Task<CalculatePriceResult> CalculatePrice([Body] CalculatePriceCommand cmd);
}

public class PricingClient : IPricingClient
{
    private static readonly AsyncRetryPolicy retryPolicy = Policy
        .Handle<HttpRequestException>()
        .WaitAndRetryAsync(3, retryAttempt => TimeSpan.FromSeconds(3));

    private readonly IPricingClient client;

    public PricingClient(IConfiguration configuration, IDiscoveryClient discoveryClient)
    {
        var pricingUri = new Uri(configuration.GetValue<string>("PricingServiceUri"));
        // Instructor sample resolves the logical host "PricingService" through Eureka.
        // Concrete hosts (localhost or a container DNS name) are called directly so the
        // same REST contract works when discovery is not part of the running profile.
        HttpMessageHandler handler = string.Equals(pricingUri.Host, "PricingService", StringComparison.OrdinalIgnoreCase)
            ? new DiscoveryHttpClientHandler(discoveryClient)
            : new HttpClientHandler();

        var httpClient = new HttpClient(handler, false)
        {
            BaseAddress = pricingUri
        };
        client = RestClient.For<IPricingClient>(httpClient);
    }

    public Task<CalculatePriceResult> CalculatePrice([Body] CalculatePriceCommand cmd)
    {
        return retryPolicy.ExecuteAsync(async () => await client.CalculatePrice(cmd));
    }
}
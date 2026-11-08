using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using PolicySearchService.Api.Queries;
using PolicySearchService.Domain;
using PolicySearchService.Listeners;
using PolicySearchService.Queries;
using PolicyService.Api.Commands.Dtos;
using PolicyService.Api.Events;

namespace PolicySearchService.Test;

public class PolicyCreatedIndexingTest
{
    [Fact]
    public async Task PolicyCreatedIsStoredForLaterSearch()
    {
        var repository = new RecordingPolicyRepository();
        var handler = new PolicyCreatedHandler(repository);

        await handler.Handle(new PolicyCreated
        {
            PolicyNumber = "P-100",
            ProductCode = "TRI",
            PolicyFrom = new DateTime(2026, 12, 1),
            PolicyTo = new DateTime(2026, 12, 15),
            TotalPremium = 130m,
            PolicyHolder = new PersonDto { FirstName = "Ha", LastName = "Le" }
        }, CancellationToken.None);

        Assert.NotNull(repository.Added);
        Assert.Equal("P-100", repository.Added.PolicyNumber);
        Assert.Equal("TRI", repository.Added.ProductCode);
        Assert.Equal("Ha Le", repository.Added.PolicyHolder);
        Assert.Equal(130m, repository.Added.PremiumAmount);
    }

    [Fact]
    public async Task SearchReturnsTheIndexedPolicy()
    {
        var stored = new Policy
        {
            PolicyNumber = "P-100",
            ProductCode = "TRI",
            PolicyHolder = "Ha Le",
            PremiumAmount = 130m,
            PolicyStartDate = new DateTime(2026, 12, 1),
            PolicyEndDate = new DateTime(2026, 12, 15)
        };
        var repository = new RecordingPolicyRepository { Matches = new List<Policy> { stored } };
        var handler = new FindPolicyHandler(repository);

        var result = await handler.Handle(new FindPolicyQuery { QueryText = "Ha Le" }, CancellationToken.None);

        Assert.Equal("Ha Le", repository.LastQuery);
        var found = Assert.Single(result.Policies);
        Assert.Equal("P-100", found.PolicyNumber);
        Assert.Equal("TRI", found.ProductCode);
        Assert.Equal("Ha Le", found.PolicyHolder);
        Assert.Equal(130m, found.PremiumAmount);
    }

    [Fact]
    public async Task SearchWithNoMatchReturnsEmptyList()
    {
        var repository = new RecordingPolicyRepository();
        var handler = new FindPolicyHandler(repository);

        var result = await handler.Handle(new FindPolicyQuery { QueryText = "khong-co" }, CancellationToken.None);

        Assert.Empty(result.Policies);
    }

    private sealed class RecordingPolicyRepository : IPolicyRepository
    {
        public Policy Added { get; private set; }
        public string LastQuery { get; private set; } = "";
        public List<Policy> Matches { get; set; } = new();

        public Task Add(Policy policy)
        {
            Added = policy;
            return Task.CompletedTask;
        }

        public Task<List<Policy>> Find(string queryText)
        {
            LastQuery = queryText;
            return Task.FromResult(Matches);
        }
    }
}

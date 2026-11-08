using Xunit;

// Offer/policy tests share the static SysTime clock. Parallel collections
// make expiration checks intermittent, so this assembly runs collections serially.
[assembly: CollectionBehavior(DisableTestParallelization = true)]

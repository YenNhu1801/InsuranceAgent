using Xunit;

// SysTime.CurrentTimeProvider là trạng thái tĩnh. TimeMachine trong OfferFactory
// sẽ đua nếu xUnit chạy song song và làm CannotBuyExpiredOffer lúc đúng lúc sai.
[assembly: CollectionBehavior(DisableTestParallelization = true)]

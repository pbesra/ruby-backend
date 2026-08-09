using ruby.application.Ports.In.IServices;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Models.Responses;

namespace ruby.application.Services
{
    public class HomeFeedService : IHomeFeedService
    {
        private readonly IHomeFeedRepository _homeFeedRepository;

        public HomeFeedService(IHomeFeedRepository homeFeedRepository)
        {
            _homeFeedRepository = homeFeedRepository;
        }

        public async Task<IEnumerable<UserPreviewResponse>> GetDiscoverUsersAsync(Guid userId)
        {
            return await _homeFeedRepository.GetDiscoverUsersAsync(userId);
        }

        public async Task<IEnumerable<UserPreviewResponse>> GetFollowingUsersAsync(Guid userId)
        {
            return await _homeFeedRepository.GetFollowingUsersAsync(userId);
        }
    }
}
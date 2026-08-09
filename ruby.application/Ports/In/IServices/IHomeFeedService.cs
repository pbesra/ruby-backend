using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Models.Responses;

namespace ruby.application.Ports.In.IServices
{
    public interface IHomeFeedService
    {
        Task<IEnumerable<UserPreviewResponse>> GetDiscoverUsersAsync(Guid userId);

        Task<IEnumerable<UserPreviewResponse>> GetFollowingUsersAsync(Guid userId);
    }
}
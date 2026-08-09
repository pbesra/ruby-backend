using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Models.Responses;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IHomeFeedRepository
    {
        Task<IEnumerable<UserPreviewResponse>> GetDiscoverUsersAsync(Guid currentUserId);

        Task<IEnumerable<UserPreviewResponse>> GetFollowingUsersAsync(Guid currentUserId);
    }
}
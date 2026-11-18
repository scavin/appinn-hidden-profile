# frozen_string_literal: true
# name: appinn-hidden-profile-state
# about: Exposes only the viewer's own relationship state and permissions on hidden profiles.
# version: 0.1.1
# authors: Appinn

after_initialize do
  add_to_serializer(:hidden_profile, :can_mute_user) do
    scope.can_mute_user?(object)
  end
  add_to_serializer(:hidden_profile, :muted) do
    scope.authenticated? && scope.is_muting_user?(object)
  end
  add_to_serializer(:hidden_profile, :can_ignore_user) do
    scope.can_ignore_user?(object)
  end
  add_to_serializer(:hidden_profile, :ignored) do
    scope.authenticated? && scope.is_ignoring_user?(object)
  end
  add_to_serializer(:hidden_profile, :can_follow) do
    SiteSetting.respond_to?(:discourse_follow_enabled) &&
      SiteSetting.discourse_follow_enabled && scope.respond_to?(:can_follow?) &&
      scope.can_follow?(object)
  end
  add_to_serializer(:hidden_profile, :is_followed) do
    !!(
      scope.user.present? && defined?(::UserFollower) &&
        ::UserFollower.exists?(follower_id: scope.user.id, user_id: object.id)
    )
  end
end

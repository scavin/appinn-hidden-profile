# frozen_string_literal: true
# name: appinn-hidden-profile
# about: Links hidden user cards and restores native relationship controls.
# version: 0.2.0
# authors: Appinn
# url: https://github.com/scavin/appinn-hidden-profile

after_initialize do
  add_to_serializer(:hidden_profile, :can_mute_user) { scope.can_mute_user?(object) }
  add_to_serializer(:hidden_profile, :muted) do
    scope.authenticated? && scope.is_muting_user?(object)
  end
  add_to_serializer(:hidden_profile, :can_ignore_user) { scope.can_ignore_user?(object) }
  add_to_serializer(:hidden_profile, :ignored) do
    scope.authenticated? && scope.is_ignoring_user?(object)
  end
  add_to_serializer(:hidden_profile, :can_follow) do
    SiteSetting.respond_to?(:discourse_follow_enabled) && SiteSetting.discourse_follow_enabled &&
      scope.respond_to?(:can_follow?) && scope.can_follow?(object)
  end
  add_to_serializer(:hidden_profile, :is_followed) do
    !!(
      scope.user.present? && defined?(::UserFollower) &&
        ::UserFollower.exists?(follower_id: scope.user.id, user_id: object.id)
    )
  end
end

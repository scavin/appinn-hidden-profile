# frozen_string_literal: true

RSpec.describe UsersController do
  fab!(:viewer) { Fabricate(:user, trust_level: 2, refresh_auto_groups: true) }
  fab!(:target, :user)

  before do
    SiteSetting.allow_users_to_hide_profile = true
    SiteSetting.hide_new_user_profiles = false
    SiteSetting.ignore_allowed_groups = Group::AUTO_GROUPS[:trust_level_2].to_s
    SiteSetting.discourse_follow_enabled = true
    target.user_option.update!(hide_profile: true)
  end

  describe "#show" do
    it "exposes native controls without exposing hidden profile details" do
      target.user_profile.update!(bio_raw: "Private biography")
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["user"]).to include(
        "profile_hidden" => true,
        "can_ignore_user" => true,
        "ignored" => false,
        "can_mute_user" => true,
        "muted" => false,
        "can_follow" => false,
        "is_followed" => false,
      )
      expect(response.parsed_body["user"].keys).not_to include("bio_raw", "bio_cooked", "email")
    end

    it "returns the visitor's own ignore state" do
      IgnoredUser.create!(user: viewer, ignored_user: target, expiring_at: 2.days.from_now)
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]).to include("ignored" => true, "muted" => false)
    end

    it "returns the visitor's own mute state" do
      MutedUser.create!(user: viewer, muted_user: target)
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]).to include("ignored" => false, "muted" => true)
    end

    it "keeps another visitor's relationships private" do
      IgnoredUser.create!(user: viewer, ignored_user: target, expiring_at: 2.days.from_now)
      UserFollower.create!(
        follower_id: viewer.id,
        user_id: target.id,
        level: Follow::Notification.levels[:watching],
      )
      sign_in(Fabricate(:user))

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]).to include(
        "ignored" => false,
        "muted" => false,
        "is_followed" => false,
      )
    end

    it "returns no personal relationship state or permissions to an anonymous visitor" do
      IgnoredUser.create!(user: viewer, ignored_user: target, expiring_at: 2.days.from_now)
      UserFollower.create!(
        follower_id: viewer.id,
        user_id: target.id,
        level: Follow::Notification.levels[:watching],
      )

      get "/u/#{target.username}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["user"]).to include(
        "can_ignore_user" => false,
        "ignored" => false,
        "can_mute_user" => false,
        "muted" => false,
        "can_follow" => false,
        "is_followed" => false,
      )
    end

    it "respects the configured ignore groups" do
      SiteSetting.ignore_allowed_groups = Group::AUTO_GROUPS[:trust_level_4].to_s
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]["can_ignore_user"]).to eq(false)
    end

    it "prevents ignoring a hidden staff member" do
      target.update!(moderator: true)
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]["can_ignore_user"]).to eq(false)
    end

    it "detects an existing follow after the target hides their profile and opts out" do
      target.user_option.update!(hide_profile: false)
      Follow::Updater.new(viewer, target).watch_follow
      target.user_option.update!(hide_profile: true)
      target.custom_fields["allow_people_to_follow_me"] = false
      target.save_custom_fields
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]).to include("can_follow" => false, "is_followed" => true)
      expect(UserFollower.exists?(follower_id: viewer.id, user_id: target.id)).to eq(true)
    end

    it "supports native controls when Follow is disabled" do
      SiteSetting.discourse_follow_enabled = false
      sign_in(viewer)

      get "/u/#{target.username}.json"

      expect(response.parsed_body["user"]).to include(
        "can_ignore_user" => true,
        "can_mute_user" => true,
        "can_follow" => false,
        "is_followed" => false,
      )
    end
  end
end

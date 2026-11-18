# frozen_string_literal: true

RSpec.describe Follow::FollowController do
  fab!(:viewer, :user)
  fab!(:target, :user)

  before do
    SiteSetting.allow_users_to_hide_profile = true
    SiteSetting.discourse_follow_enabled = true
  end

  describe "#unfollow" do
    it "lets a visitor remove an old relationship after the target hides their profile" do
      Follow::Updater.new(viewer, target).watch_follow
      target.user_option.update!(hide_profile: true)
      sign_in(viewer)

      delete "/follow/#{target.username}.json"

      expect(response.status).to eq(200)
      expect(UserFollower.exists?(follower_id: viewer.id, user_id: target.id)).to eq(false)
      get "/u/#{target.username}.json"
      expect(response.parsed_body["user"]["is_followed"]).to eq(false)
    end
  end
end

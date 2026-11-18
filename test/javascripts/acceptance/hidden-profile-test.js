import { click, triggerEvent, visit, waitFor } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { i18n } from "discourse-i18n";

acceptance("Appinn Hidden Profile - user cards", function (needs) {
  needs.user();

  needs.pretender((server, helper) => {
    server.get("/u/eviltrout/card.json", () =>
      helper.response({
        user: {
          id: 6,
          username: "eviltrout",
          name: "A Different Display Name",
          avatar_template: "/letter_avatar_proxy/v4/letter/e/8edcca/{size}.png",
          profile_hidden: true,
          title: null,
          primary_group_name: null,
        },
      })
    );
  });

  test("links the actual hidden user and preserves the localized message", async (assert) => {
    await visit("/t/this-is-a-test-topic/9");
    await click('a[data-user-card="eviltrout"]');
    await waitFor(".user-card .hidden-profile-link");

    assert.dom(".user-card .hidden-profile-link").exists({ count: 1 });
    assert
      .dom(".user-card .hidden-profile-link")
      .hasAttribute("href", "/u/eviltrout/profile-hidden");
    assert
      .dom(".user-card .profile-hidden")
      .hasText(i18n("user.profile_hidden"));
  });

  test("reopening a user card does not duplicate the link", async (assert) => {
    await visit("/t/this-is-a-test-topic/9");
    await click('a[data-user-card="eviltrout"]');
    await waitFor(".user-card .hidden-profile-link");
    await triggerEvent("#main-outlet", "pointerdown");
    await click('a[data-user-card="eviltrout"]');
    await waitFor(".user-card .hidden-profile-link");

    assert.dom(".user-card .hidden-profile-link").exists({ count: 1 });
  });
});

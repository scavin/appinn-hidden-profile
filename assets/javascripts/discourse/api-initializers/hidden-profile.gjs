import { apiInitializer } from "discourse/lib/api";
import { userPath } from "discourse/lib/url";

export default apiInitializer((api) => {
  api.renderInOutlet(
    "user-card-after-username",
    <template>
      <span
        data-hidden-profile-username={{@outletArgs.user.username}}
        hidden
      ></span>
    </template>
  );

  const updateCards = () => {
    document
      .querySelectorAll(".user-card .profile-hidden > span")
      .forEach((span) => {
        const username = span
          .closest(".card-content")
          ?.querySelector("[data-hidden-profile-username]")
          ?.dataset.hiddenProfileUsername;
        if (!username) {
          return;
        }
        const href = userPath(`${encodeURIComponent(username)}/profile-hidden`);
        const existing = span.querySelector("a.hidden-profile-link");
        if (existing) {
          if (existing.getAttribute("href") !== href) {
            existing.setAttribute("href", href);
          }
          return;
        }
        const text = span.textContent;
        const keyword = "已被隐藏";
        const index = text.indexOf(keyword);
        const link = document.createElement("a");
        link.className = "hidden-profile-link";
        link.href = href;
        link.textContent = index < 0 ? text : keyword;
        span.replaceChildren(
          ...(index < 0
            ? [link]
            : [
                document.createTextNode(text.slice(0, index)),
                link,
                document.createTextNode(text.slice(index + keyword.length)),
              ])
        );
      });
  };
  const observer = new MutationObserver(updateCards);
  observer.observe(document.body, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ["data-hidden-profile-username"],
  });
  updateCards();
});

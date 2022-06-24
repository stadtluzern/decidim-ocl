// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack

// Load images
require.context("../../images", true)

window.addEventListener("load", (event) => {
  if (!window.localStorage) {
    return;
  }

  let getDismissedHelpers = () => {
    let serialized = localStorage.getItem("dismissedHelpers");
    if (!serialized) {
      return [];
    }

    return serialized.split(",");
  };

  /**
   * Collapse the floating help dialogs by default
   */
  document.querySelectorAll('.floating-helper-container').forEach((elem) => {
    let id = elem.dataset.helpId;
    let dismissedHelpers = getDismissedHelpers();
    if (!dismissedHelpers.includes(id)) {
      localStorage.setItem(
        "dismissedHelpers",
        [...dismissedHelpers, id].join(",")
      );
    }
  });

})
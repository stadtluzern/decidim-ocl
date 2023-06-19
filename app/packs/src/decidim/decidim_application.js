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

/**
 * For tenants which have this activated, auto-scroll down to the tab navigation in processes.
 */
window.addEventListener("load", (event) => {
  console.log('tenant type', window.tenantType)
  if (!['koeniz', 'deinklima', 'dialogluzern', 'winterthur'].includes(window.tenantType)) return

  const process_nav = document.querySelector('#process-nav-content > ul');
  if (process_nav == null) {
    return;
  }

  const active_child = process_nav.querySelector('li + li.is-active');

  if (active_child != null) {
    process_nav.scrollIntoView({ behavior: "smooth", block: "start", inline: "start" });
  }
});

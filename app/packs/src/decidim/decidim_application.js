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

/**
 * For tenants which have this activated, collapse the process navigation on mobile by default.
 */
window.addEventListener("load", (event) => {
  if (!['koeniz'].includes(window.tenantType)) return

  // Bug that appears on mobile devices but not on desktop browsers with narrow window width:
  // The process navigation (list of components) is open on mobile devices for some reason.
  // To work around this, we toggle the navigation collapse state on narrow screens.
  if (window.innerWidth < 640) {
    document.querySelectorAll('#process-nav-content').forEach((elem) => {
      setTimeout(() => {
        $(elem).trigger('toggle')
      });
    });
  }
});

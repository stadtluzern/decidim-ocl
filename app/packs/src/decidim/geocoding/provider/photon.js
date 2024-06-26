import "src/decidim/geocoding"
import formatAddress from "src/decidim/geocoding/format_address"

/**
 * For the available address format keys, refer to:
 * https://github.com/komoot/photon
 */
$(() => {
  const generateAddressLabel = formatAddress;

  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);
    const config = $input.data("decidim-geocoding");
    const queryMinLength = config.queryMinLength || 2;
    // Default Photon installation only supports these languages but for
    // custom instances, you can configure the supported languages.
    const supportedLanguages = config.supportedLanguages || ["de", "en", "it", "fr"];
    const defaultLanguage  = config.defaultLanguage || "en";
    const addressFormat = config.addressFormat || [
      "name",
      ["street", "housenumber"],
      "postcode",
      "city",
      "state",
      "country"
    ];
    let language = $("html").attr("lang");
    if (!supportedLanguages.includes(language)) {
      language = defaultLanguage;
    }
    let currentSuggestionQuery = null;

    if (!config.url || config.url.length < 1) {
      return;
    }

    $input.on("geocoder-suggest.decidim", (_ev, query, callback) => {
      clearTimeout(currentSuggestionQuery);

      // Do not trigger API calls on short queries
      if (`${query}`.trim().length < queryMinLength) {
        return;
      }

      currentSuggestionQuery = setTimeout(() => {
        $.ajax({
          method: "GET",
          url: config.url,
          data: {
            q: query, // eslint-disable-line
            lang: language
          },
          dataType: "json"
        }).done((resp) => {
          if (resp.features) {
            return callback(resp.features.map((item) => {
              const label = generateAddressLabel(item.properties, addressFormat);

              return {
                key: label,
                value: label,
                // ONLY CHANGE IN THIS FILE:
                // For some reason, photon returns longitude first, then latitude
                // but decidim expects it in reverse.
                coordinates: item.geometry.coordinates.reverse()
              }
            }));
          }
          return null;
        });
      }, 200);
    });
  })
});

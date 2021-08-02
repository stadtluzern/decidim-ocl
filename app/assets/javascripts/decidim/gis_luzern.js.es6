// = require leaflet
// = require leaflet.markercluster
// = require proj4
// = require proj4leaflet
// = require esri-leaflet/dist/esri-leaflet
// = require leaflet-tilelayer-swiss
// = require leaflet-svg-icon
// = require jquery-tmpl
// = require_self
// = require decidim/map

/**
 * NOTE:
 * This has to load before decidim/map in order for it to apply correctly when
 * the map is initialized. The document.ready handler set by this script has to
 * be registered before decidim/map registers its own.
 *
 * Also it has to load after JQuery.
 */
((exports) => {
  const $ = exports.$; // eslint-disable-line
  const L = exports.L; // eslint-disable-line

  $(() => {
    exports.Decidim = exports.Decidim || {};
    const MapMarkersController = exports.Decidim.MapMarkersController;
    const MapStaticController = exports.Decidim.MapStaticController;

    class GisLuzernMapController extends MapMarkersController {
      start() {
        this.setCoordinateReferenceSystem()
        this.addTileLayers()

        // Don't render any markers that are out of bounds due to wrong geocoding
        // or because they're simply located someplace the GIS maps don't cover
        this.config.markers = this.config.markers.filter(marker => {
          return marker.latitude > this.config.mapLimits.latMin &&
            marker.latitude < this.config.mapLimits.latMax &&
            marker.longitude > this.config.mapLimits.lngMin &&
            marker.longitude < this.config.mapLimits.lngMax
        })

        // decidim adds the markers for us, but if navigation maps are active,
        // a different L without the markercluster plugin is used for some reason.
        // Workaround is to overwrite the global L again from here.
        exports.L = L
        super.start()

        this.setViewport()
      }

      setCoordinateReferenceSystem() {
        // Swiss coordinate system LV95 is used in these maps, see https://epsg.io/2056
        this.map.options.crs = L.CRS.EPSG2056;
      }

      addTileLayers() {
        const tileLayers = Object.fromEntries(Object.entries(this.config.layers).map(([_, layer]) => {

          if (layer.type === 'swisstopo') {
            return [ layer.name, L.tileLayer.swiss({
              layer: layer.layer || 'ch.swisstopo.pixelkarte-farbe'
            }).addTo(this.map) ]
          }

          return [
            layer.name,
            L.esri.tiledMapLayer({
              url: layer.url,
              attribution: layer.attribution || this.config.attribution,
              minZoom: 0,
              maxZoom: 9,
            }).addTo(this.map)
          ];

        }));

        L.control.layers(tileLayers).addTo(this.map);
      }

      setViewport() {
        if (this.config.markers.length === 0) {
          const center = this.config.defaultCenter ? [this.config.defaultCenter.lat, this.config.defaultCenter.lng] : [0,0];
          const bounds = new L.LatLngBounds([center, center]);
          this.map.fitBounds(bounds, {padding: [100, 100], maxZoom: 19});
        } else {
          const bounds = new L.LatLngBounds(this.config.markers.map((markerData) => [markerData.latitude, markerData.longitude]));
          this.map.fitBounds(bounds, {padding: [100, 100], maxZoom: 23});
        }
      }
    }

    // We need to replace the dynamic map controller of decidim and use our own
    exports.Decidim.createMapController = (mapId, config) => {
      if (config.type === "static") {
        return new MapStaticController(mapId, config);
      }

      return new GisLuzernMapController(mapId, config);
    }

    $("[data-decidim-map]").on("configure.decidim", (_ev, map, _mapConfig) => {
      $(map._container).css("display", "block");
    })
  });

})(window);

// = require leaflet
// = require proj4
// = require proj4leaflet
// = require esri-leaflet/dist/esri-leaflet
// = require leaflet-svg-icon
// = require leaflet.markercluster
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

        // decidim adds the markers for us
        super.start()

        this.setViewport()
      }

      setCoordinateReferenceSystem() {
        // Swiss coordinate system LV95 is used in these maps, see https://epsg.io/2056
        this.map.options.crs = new L.Proj.CRS('EPSG:2056', '+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs', {
          // Origin and resolutions of the maps are taken from the ArcGIS service description, see https://svc.geo.lu.ch/main/rest/services/basis/basis_citymap_baspla/MapServer/WMTS/basis_basis_citymap_baspla
          origin: [-2.9380010775807664E7, 3.500843066123094E7],
          resolutions: [10, 5, 2.5, 2, 1.5, 1, 0.5, 0.25, 0.1, 0.05]
        });
      }

      addTileLayers() {
        const tileLayers = Object.fromEntries(Object.entries(this.config.layers).map(([_, layer]) => {

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
          this.map.fitBounds(bounds, {padding: [100, 100], maxZoom: 1});
        } else {
          const bounds = new L.LatLngBounds(this.config.markers.map((markerData) => [markerData.latitude, markerData.longitude]));
          this.map.fitBounds(bounds, {padding: [100, 100], maxZoom: 5});
        }
      }

      // TODO remove this method after upgrading to decidim 0.24
      addMarkers(markersData) {
        if (this.markerClusters === null) {
          this.markerClusters = L.markerClusterGroup();
          this.map.addLayer(this.markerClusters);
        }

        // Pre-compiles the template
        $.template(
          this.config.popupTemplateId,
          $(`#${this.config.popupTemplateId}`).html()
        );

        const updateCoordinates = (data) => {
          $('input[data-type="latitude"]').val(data.lat);
          $('input[data-type="longitude"]').val(data.lng);
        };

        const bounds = new L.LatLngBounds(
          markersData.map(
            (markerData) => [markerData.latitude, markerData.longitude]
          )
        );

        markersData.forEach((markerData) => {
          let marker = L.marker([markerData.latitude, markerData.longitude], {
            icon: this.createIcon(),
            keyboard: true,
            title: markerData.title,
            draggable: markerData.draggable
          });

          if (markerData.draggable) {
            updateCoordinates({
              lat: markerData.latitude,
              lng: markerData.longitude
            });
            marker.on("drag", (ev) => {
              updateCoordinates(ev.target.getLatLng());
            });
          } else {
            let node = document.createElement("div");

            $.tmpl(this.config.popupTemplateId, markerData).appendTo(node);

            marker.bindPopup(node, {
              maxwidth: 640,
              minWidth: 500,
              keepInView: true,
              className: "map-info"
            }).openPopup();
          }

          this.markerClusters.addLayer(marker);
        });

        this.map.fitBounds(bounds, { padding: [100, 100] });
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

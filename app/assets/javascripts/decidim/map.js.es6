// = require leaflet
// = require proj4
// = require proj4leaflet
// = require esri-leaflet/dist/esri-leaflet
// = require leaflet-svg-icon
// = require leaflet.markercluster
// = require jquery-tmpl
// = require_self

L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
  options: {
    fillColor: "#ef604d",
    opacity: 0
  },
  _createPathDescription: function() {
    return "M14 1.17a11.685 11.685 0 0 0-11.685 11.685c0 11.25 10.23 20.61 10.665 21a1.5 1.5 0 0 0 2.025 0c0.435-.435 10.665-9.81 10.665-21A11.685 11.685 0 0 0 14 1.17Zm0 17.415A5.085 5.085 0 1 1 19.085 13.5 5.085 5.085 0 0 1 14 18.585Z";
  },
  _createCircle: function() {
    return ""
  }
});

const popupTemplateId = "marker-popup";
$.template(popupTemplateId, $(`#${popupTemplateId}`).html());

const addMarkers = (markersData, markerClusters, map) => {
  const bounds = new L.LatLngBounds(markersData.map((markerData) => [markerData.latitude, markerData.longitude]));

  markersData.forEach((markerData) => {
    let marker = L.marker(L.latLng([markerData.latitude, markerData.longitude]), {
      icon: new L.DivIcon.SVGIcon.DecidimIcon()
    });
    let node = document.createElement("div");

    $.tmpl(popupTemplateId, markerData).appendTo(node);

    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    markerClusters.addLayer(marker);
  });

  map.addLayer(markerClusters);
  map.fitBounds(bounds, { padding: [100, 100], maxZoom: 5 });
};

const loadMap = (mapId, markersData) => {
  let markerClusters = L.markerClusterGroup();

  // Swiss coordinate system LV95 is used in these maps, see https://epsg.io/2056
  const crs = new L.Proj.CRS('EPSG:2056', '+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs', {
    // Origin and resolutions of the maps are taken from the ArcGIS service description, see https://svc.geo.lu.ch/main/rest/services/basis/basis_citymap_baspla/MapServer/WMTS/basis_basis_citymap_baspla
    origin: [-2.9380010775807664E7, 3.500843066123094E7],
    resolutions: [10, 5, 2.5, 2, 1.5, 1, 0.5, 0.25, 0.1, 0.05]
  })

  if (window.Decidim.currentMap) {
    window.Decidim.currentMap.remove();
    window.Decidim.currentMap = null;
  }
  const map = L.map(mapId, {
    crs: crs,
  });

  L.esri.tiledMapLayer({
    url: 'https://svc.geo.lu.ch/main/rest/services/basis/basis_citymap_baspla/MapServer',
    attribution: '<a href="https://geoportal.lu.ch/">Geoportal Kt. LU</a>',
    minZoom: 0,
    maxZoom: 9,
  }).addTo(map);

  if (markersData.length > 0) {
    addMarkers(markersData, markerClusters, map);
  }

  map.scrollWheelZoom.disable();

  return map;
};

window.Decidim = window.Decidim || {};

window.Decidim.loadMap = loadMap;
window.Decidim.currentMap =  null;
window.Decidim.mapConfiguration = {};

$(() => {
  const mapId = "map";
  const $map = $(`#${mapId}`);
  const markersData = $map.data("markers-data");

  if ($map.length > 0) {
    if (markersData.length > 0) {
      $map.css("display", "block");
      window.Decidim.currentMap = loadMap(mapId, markersData);
    }
  }
});

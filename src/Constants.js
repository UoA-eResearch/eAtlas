function define(name, value) {
  Object.defineProperty(exports, name, {
    value: value,
    enumerable: true
  });
}

// TODO: change to domain name 
define("PRD_URL", 'https://uoa-eresearch.github.io/eAtlas');
define("DEV_URL", '');
define("UI_LIST", [
  "checkbox",
  "radio",
  "buttongroups",
  "dropdown",
  "slider"]) 
define("LAYERSTYLES", [
  "arc",
  "geojson",
  "grid",
  "heatmap",
  "hex",
  "icon",
  "line",
  "path",
  "scatterplot",
  "sgrid"
])     

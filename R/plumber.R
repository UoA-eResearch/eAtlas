if(is.null(curl::nslookup("r-project.org", error = FALSE))) {
  stop(message(
    "No connection",
    "To save space on the repo files need to be downloaded.",
    "Please re-run when you are connected."
  ))
}
packages <- c("sf", "geojsonsf", "osmdata", "curl")
main.file <- "ac_joined_wy_2009-2017.Rds"
# https://github.com/layik/eAtlas/releases/
# download/0.0.1/spenser.geojson
spenser.file <- "spenser.geojson"
github <- "https://github.com/layik/eAtlas/releases/download/0.0.1/"

if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())),repos='http://cran.us.r-project.org')
}

lapply(packages, library, character.only = TRUE)

if(!file.exists(main.file)) {
  download.file(
    paste0(github,
           main.file),
    destfile = main.file)
}

if(!file.exists(spenser.file)) {
  download.file(
    paste0(github,
           spenser.file),
    destfile = spenser.file)
}

# Enable CORS -------------------------------------------------------------
#' CORS enabled for now. See docs of plumber
#' for disabling it for any endpoint we want in future
#' https://www.rplumber.io/docs/security.html#cross-origin-resource-sharing-cors
#' @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}
# TODO: option to remove above CORS

#' @section TODO:
#' The plumber endpoint should not be there. Currently mapping React build to /
#' at assets causes the swagger endpoint to be 404. Support is limited.
#'
#' @get /__swagger__/
swagger <- function(req, res){
  fname <- system.file("swagger-ui/index.html", package = "plumber") # serve the swagger page.
  plumber::include_html(fname, res)
}

accidents <- readRDS(main.file)
accidents <- sf::st_transform(accidents, 4326)
# keep using below and avoid dynamic api for dev
v <- c(53.698968, -1.800421, 53.945872, -1.290352)
# # Leeds bbox in case of future offline mode
# bb <- osmdata::getbb("leeds")
# bb_str <- osmdata::bbox_to_string(bb)
# v <- as.double(unlist(strsplit(bb_str, ",")))
bbx <- c(
  xmin = v[2],
  ymin = v[1],
  xmax = v[4],
  ymax = v[3]
)
accidents <- sf::st_crop(accidents, bbx) # Leeds only
# for dev lets just load 5000
accidents <- accidents[sample(nrow(accidents), 5e3),]
accidents <- accidents[c(
  "sex_of_casualty",
  "speed_limit",
  "date",
  "road_type",
  "number_of_casualties",
  "accident_severity",
  "casualty_type",
  "age_of_casualty",
  "age_band_of_casualty",
  "vehicle_types"
)]

# saving memory
encode <- function(column_name) {
  cts <- 1:length(levels(factor(accidents[[column_name]])))
  names(cts) <- levels(factor(accidents[[column_name]]))
  accidents[[column_name]] <- vapply(accidents[[column_name]], 2, FUN = function(x) cts[[x]])
  cts
}
# TODO: find a way to detect encode'able columns
rt <- encode("road_type")
ct <- encode("casualty_type")
accidents_vector <- unname(unlist(accidents))

# message("Converting to geojson")
accidents_geojson <- geojsonsf::sf_geojson(accidents)

#' @get /api/vector
#' @serializer unboxedJSON
all_vector <- function(){
  list(data=accidents_vector, 
       road_type = names(rt), # hardcode
       casualty_type = names(ct) # hardcode
       )
}

# print(accidents)
#' @get /api/stats19
all_geojson <- function(res){
  res$headers$`Content-type` <- "application/json"
  res$body <- accidents_geojson
  res
}

#' get a subset of results depending on a bbox provided
#' @get /api/stats19/<xmin:double>/<ymin:double>/<xmax:double>/<xmax:double>/
#' @get /api/stats19/<xmin:double>/<ymin:double>/<xmax:double>/<ymax:double>
#'
subs_geojson <- function(res, xmin, ymin, xmax, ymax){
  res$headers$`Content-type` <- "application/json"
  if(exists(c('xmin', 'ymin', 'xmax', 'ymax')) &&
     !is.na(as.numeric(c(xmin, ymin, xmax, ymax)))) {
    cat(c(xmin, ymin, xmax, ymax))
    
    bbx <- c(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax)
    cat(bbx)
    cat(length(accidents))
    subset <-  sf::st_crop(accidents, bbx) # bbox only
    subset_geojson <-  geojsonsf::sf_geojson(subset)
    print(subset)
    print(subset_geojson)
    res$body <- subset_geojson
  } else {
    res$body <- accidents_geojson
  }
  res
}

#' Get geojson from URL and pass it to client
#' @get /api/url
parse_url <- function(res, q = "") {
  res$headers$`Content-type` <- "application/json"
  er <- try(res$body <- readLines(q), silent = TRUE)
  if(class(res) == "try-error") {
    msg <- paste0("Failed to read the URL: ", q)
    res$status <- 400 # Bad request
    list(error=jsonlite::unbox(msg))
  } else {
    return(res)
  }
}

#' start wip/play.R
#' 
csv = read.csv("wip/ne-other.csv", stringsAsFactors=FALSE)
names(csv) = gsub("X", "", names(csv)) # remove X's make.names
names(csv) = gsub("..b.", "", names(csv)) # remove X's make.names
csv = Filter(function(x)!all(is.na(x)), csv) # efficient
max.trips = max(as.numeric(sapply(csv[,names(csv)[2:24]], max, na.rm = TRUE)))
min.trips = min(as.numeric(sapply(csv[,names(csv)[2:24]], min, na.rm = TRUE)))
# regions including scotland
# https://opendata.arcgis.com/datasets/bafeb380d7e34f04a3cdf1628752d5c3_0.geojson
# download.file("https://raw.githubusercontent.com/martinjc/UK-GeoJSON/master/json/eurostat/ew/nuts1.json",
              # destfile = file.path("R/nuts1.json"))
json = geojsonsf::geojson_sf("https://raw.githubusercontent.com/martinjc/UK-GeoJSON/master/json/eurostat/ew/nuts1.json")
json = json[order(json$NUTS112NM),]
csv$Between.North.East.and[match("Wales - Cymru", csv$Between.North.East.and)] = "Wales"
json$NUTS112NM
csv$Between.North.East.and
# no geometry for scotland
csv = csv[-(match("Scotland", csv$Between.North.East.and)),]
indices = unlist(sapply(csv$Between.North.East.and, 
                        function(x)grep(pattern = x, json$NUTS112NM, 
                                        ignore.case = TRUE)))
# json = json[order(json$NUTS112NM[indices]),] 
# json$NUTS112NM rows should match csv$Between.North.East.and
# then
st_geometry(csv) = json$geometry[indices]
#' 
#' end wip/play.R
geojson <- geojsonsf::sf_geojson(csv)
#' @get /api/trips
trips_geojson <- function(res){
  res$body <- geojson
  res
}

target <- json[grep("North East", json$NUTS112NM), "geometry"]
target_geojson <- geojsonsf::sf_geojson(target)
#' @get /api/target
trips_target <- function(res, name) {
  res$body <- target_geojson
  res
}

cent_others <- st_centroid(csv)
cent_northe <- st_centroid(target) 
linestrings <- lapply(cent_others$geometry, 
                     function(x)rbind(st_coordinates(cent_northe$geometry),st_coordinates(x)))
linestrings <- lapply(linestrings, 
                    function(x)st_linestring(x))
lines_sf = st_sf(csv, geometry = st_sfc(linestrings, crs = 4326))
lines_geojson = geojsonsf::sf_geojson(lines_sf)
#' @get /api/lines
trips_target <- function(res, name) {
  res$body <- lines_geojson
  res
}


# csvs = list.files("data", pattern = ".csv", 
#                   full.names = TRUE)
scenarios = read.csv("data/scenario0e.csv")
# for (file in csvs) {
#   scenarios = rbind(scenarios, read.csv(file))
# }
scenarios$JOBS = round(scenarios$JOBS, 3)
lad = "lad.json"
if(!file.exists(lad)) {
  download.file("https://github.com/martinjc/UK-GeoJSON/blob/master/json/administrative/gb/lad.json?raw=true",
                destfile = lad)
}
names(scenarios) = gsub("GEOGRAPHY_", "", names(scenarios))
lad_geojson = geojsonsf::geojson_sf(lad)
geom = lad_geojson[match(levels(factor(scenarios$CODE)), 
                         lad_geojson$LAD13CD), 
               c("LAD13CD", "geometry")]
rm(lad_geojson)
scenarios_json = jsonlite::toJSON(scenarios)
geom = st_centroid(geom)
scenarios_geojson = geojsonsf::sf_geojson(geom)
#' @get /api/scenarios
scenarios <- function(res) {
  res$body <- scenarios_json
  res
}
#' @get /api/geom
geom <- function(res) {
  res$body <- scenarios_geojson
  res
}

# read spenser.file
spenser <- readChar(spenser.file, file.info(spenser.file)$size)

#' serve spenser
#' @get /api/spenser
get_spenser <- function(res) {
  res$body <- spenser
  res
}

source("R/get_spenser.R")
#' combine both msoa.geojson and Rds in
#' {q: csv, m: msoa.json}
#' see get_quant.R for details.
#' serve quant
#' @serializer unboxedJSON
#' @get /api/spenser2
get_spenser2 <- function() {
  spenser2
}

source("R/get_quant.R")
#' combine both msoa.geojson and csv in
#' {q: csv, m: msoa.json}
#' see get_quant.R for details.
#' serve quant
#' @serializer unboxedJSON
#' @get /api/quant
get_quant <- function() {
  # res$headers$`Content-type` <- "application/json"
  # res$body <- quant
  # res
  quant
}

#' Tell plumber where our public facing directory is to SERVE.
#' No need to map / to the build or public index.html. This will do.
#'
#' @assets ./build /
list()

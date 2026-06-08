if (!require("CDSE")) {
  install.packages(c("geojsonsf", "lubdridate", "lutz", "lwgeom"))
  install.packages("./CDSE_0.3.2.tar.gz", repos = NULL, type = "source")
}

# Load librarys
library(sf)
library(dplyr)
library(CDSE) # API de la Agencia Espacial Europea (ESA)
library(ggplot2)
library(tidyterra)
library(terra)

# Carga del área de interés (aoi)
valle_mezquital <- read_sf("./resultados/zona_estudio.geojson")

sf_use_s2(FALSE)

# Fix invalid geometries
valle_mezquital <- st_make_valid(valle_mezquital)

sf_use_s2(TRUE)

v_mez_bb <- valle_mezquital |> st_bbox() |> st_as_sfc()

# Authenticate (credenciales sacadas de la plataforma de Copernicus)
OAuthClient <- GetOAuthClient(id = "sh-48c4b4ec-b369-4d74-ab05-a9a923158bce",
                              secret = "sVWVU8vNkbIeWmCFeb8XaAez3QRGgHvv")

# Define parameters (example: Sentinel-2 L2A for a small area)
# (Requires defining AOI, dates, etc., using CDSE functions)
cloudless_images <- SearchCatalog(aoi = v_mez_bb, from = "2026-01-01", to = "2026-06-30",
                                  collection = "sentinel-2-l2a", with_geometry = TRUE,
                                  filter = "eo:cloud_cover < 0.1", client = OAuthClient)

# Download (example: using a function to process and get data)
script_file <- system.file("scripts", "RawBands.js", package = "CDSE")

days <- rev(cloudless_images[1:5, ]$acquisitionDate)
lstRast <- lapply(days, GetImageByTimerange, aoi = v_mez_bb, collection = "sentinel-2-l2a",
                  script = script_file, file = NULL, format = "image/tiff", mosaicking_order = "mostRecent",
                  pixels = 2500, buffer = 0, mask = FALSE, client = OAuthClient,
                  url = getOption("CDSE.process_url"))

# par(mfrow = c(3, 3))
# ## Para NDVI
# sapply(seq_along(days), FUN = function(i) {
#   ras <- lstRast[[i]]
#   day <- days[i]
#   ras[ras < 0] <- 0
#   terra::plot(
#     ras, main = paste("NDVI en el Valle del mezquital", day), range = c(0, 255),
#     cex.main = 0.7, pax = list(cex.axis = 0.5), plg = list(cex = 0.5),
#     col = colorRampPalette(c("darkred", "yellow", "darkgreen"))(99))
# })

# Create a custom palette that fades from blue to white to red
my_palette <- colorRampPalette(c("#A80000", "#F3C911", "#026645"))(100)

ggplot(mtcars, aes(x = wt, y = mpg, color = disp)) +
  geom_point(size = 4) +
  scale_color_gradientn(colors = my_palette)
ggplot() + geom_spatraster(data = lstRast[[1]]) +
  geom_sf(data = zona_estudio, fill = "transparent", color = "black") +
  scale_fill_terrain_c()
  

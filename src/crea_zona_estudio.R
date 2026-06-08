library(sf)
library(dplyr)
library(ggplot2)
library(stringr)
library(basemaps)

municipios <- st_read("./datos/muni_zona_est.geojson")

# ggplot() +
#   geom_sf(data = municipios)

muni_hidalgo <- municipios |>
  filter(NOMGEO == "Hidalgo")

zona_estudio_muni <- municipios |> filter(
  NOMMUN %in% c("Actopan", "Ajacuba", "Alfajayucan", "Atitalaquia", "Atotonilco el Grande", "Cardonal",
                "Francisco I. Madero", "Huichapan",
                "Mixquiahuala de Juárez", "Progreso de Obregón", "San Salvador",
                "Tepeji del Río de Ocampo", "Tlaxcoapan",
                "Ixmiquilpan", "Tasquillo", "Tecozautla",
                "Nopala de Villagrán", "Chapantongo", "Chilcuautla", "Santiago de Anaya",
                "El Arenal", "San Agustín Tlaxiaca", "Tetepango",
                "Progreso de Obregón", "Mixquiahuala de Juárez", "Tezontepec de Aldama",
                "Tlaxcoapan", "Tlahuelilpan", "Atitalaquia", "Atotonilco de Tula",
                "Tepetitlán", "Tula de Allende", "Tepeji del Río de Ocampo"))

# zona_estudio_muni <- zona_estudio_muni |>
#   st_make_valid()

zona_estudio_agregado <- zona_estudio_muni |>
  st_union()

ggplot() +
  geom_sf(data = zona_estudio_agregado)

zona_estudio_agregado |>
  st_write(dsn = "./resultados/zona_estudio.geojson",
           driver = "GeoJSON", delete_layer = TRUE)

map_type <- "streets"
set_defaults(map_service = "osm",
             map_type = map_type, 
             map_res = 0.5)

bbox <- muni_hidalgo |>
  st_transform(crs = 3857) |>
  st_bbox()

ggplot() +
  basemap_gglayer(
    st_transform(muni_hidalgo |>
                   st_buffer(20000),
                 crs = 3857))+ 
  geom_sf(data = muni_hidalgo |> st_transform(crs = 3857),
          fill = "grey", alpha = 0.5, colour = "black") +
  geom_sf(data = zona_estudio |> st_transform(crs = 3857),
          fill = "#478f48", alpha = 0.5, colour = "black") +
  coord_sf(xlim = c(bbox$xmin, bbox$xmax),
           ylim = c(bbox$ymin, bbox$ymax)) +
  scale_fill_identity(
    guide = "legend",       # Forces the legend to appear
    name = "Birth Rate",    # Legend Title
    breaks = c("#E41A1C", "#377EB8"), # The exact values in your dataframe
    labels = c("High (>20k)", "Low (<=20k)") # Custom Legend Labels
  ) +
  labs(title = "Valle del mezquital",
       subtitle = "Hidalgo",
       caption = "Proyecto Hñäki, elaboración propia",
       x = "Longitud",
       y = "Latitud") +
  theme(
    plot.title = element_text(size = 20,
                              hjust = 0.0),
    plot.subtitle = element_text(size = 18,
                                 hjust = 0.0),
    axis.title = element_text(size = 16),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    legend.position = c(0.8, 0.2),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(6, 6, 6, 6))

p_zona_estudio |>
  ggsave(device = "png", file = "./resultados/img/zona_de_estudio.png",
         width=17, height=9, dpi = 300)

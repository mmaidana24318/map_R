library(dash)
library(dashHtmlComponents)
library(geojsonio)
library(leaflet)
library(plotly)

app = Dash$new()

vancity <- geojsonio::geojson_read("data/map.geojson", what = "sp")

m <- leaflet(vancity) %>%
    # setView(-96, 37.8, 4) %>%
    addProviderTiles("MapBox", options = providerTileOptions(
        id = "mapbox.light",
        accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = vancity$X2021, bins = bins)

labels <- sprintf(
    "<strong>%s</strong><br/>%g Crimes",
    vancity$name, vancity$X2021
) %>% lapply(htmltools::HTML)

m <- m %>% addPolygons(
    fillColor = ~pal(X2021),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "1",
    fillOpacity = 0.7,
    highlightOptions = highlightOptions(
        weight = 5,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto")) %>%
    addLegend(pal = pal, values = ~X2021, opacity = 0.7, title = NULL,
              position = "bottomright")

app$layout(dccGraph(figure=ggplotly(m)))

app$run_server(debug = T)
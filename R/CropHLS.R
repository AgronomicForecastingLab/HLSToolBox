#' CropHLS
#'
#' @param dir
#' @param xmin
#' @param xmax
#' @param ymin
#' @param ymax
#'
#' @return
#' @export
#'
#' @examples
CropHLS <- function(dir, xmin, xmax, ymin, ymax){

  # find directories with images
  dirs.wfiles <- list.files(dir, ".tif", recursive = TRUE, full.names = TRUE) %>%
    dirname() %>%
    unique()
  # for each dir
  dirs.wfiles %>%
    map(function(dirn){
      #create the dir
      if(!dir.exists(file.path(dirn, "Cropped"))) dir.create(file.path(dirn, "Cropped"))

      # copy the meta data
      list.files(dirn, full.names = TRUE) %>%
        discard(~ tools::file_ext(.x) =="tif") %>%
        map(~ file.copy(.x, file.path(dirn, "Cropped", basename(.x))))

      # crop the rasters
      list.files(dirn, full.names = TRUE) %>%
        discard(~ tools::file_ext(.x) !="tif") %>%
        map(function(rast){
          #read the raster
          r <- raster(rast)
          # make the boundry
          e <- as(extent(-88.7, -88.3, 40, 40.3), 'SpatialPolygons')
          crs(e) <- "+proj=longlat +datum=WGS84 +no_defs" # set the CRS for the boundry
          # crop
          r2 <- raster::crop(r, sp::spTransform(e, crs(r)))
          # Write back
          writeRaster(r2, filename=file.path(dirn, "Cropped", basename(rast)), format="GTiff", overwrite=TRUE)
        })


      # create the stack
      stack.rast <- raster::stack(list.files(file.path(dirn, "Cropped"),"tif", full.names = TRUE))

      writeRaster(stack.rast,
                  filename=file.path(dirn, "Cropped", paste0(basename(dirn), "_Stacked.tif")),
                  format="GTiff", overwrite=TRUE)

      print(dirn)
    })

}


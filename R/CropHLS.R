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
CropHLS <- function(dir, xmin=-88.7, xmax=-88.3, ymin=40, ymax=40.3, overwrite=TRUE){

  # find directories with images
  dirs.wfiles <- list.files(dir, ".tif", recursive = TRUE, full.names = TRUE) %>%
    dirname() %>%
    unique() %>%
    discard(~ grepl("Cropped", .x))
  # for each dir
 stack.paths <- dirs.wfiles %>%
    map(function(dirn){

      #create the dir
      if(!dir.exists(file.path(dirn, "Cropped"))) {

        dir.create(file.path(dirn, "Cropped"))
      }else{

        if(overwrite) {
          print("Overwrite is TRUE, therefore the previous cropped dir will be deleted. ")
          unlink(file.path(dirn, "Cropped"), recursive = TRUE)
          dir.create(file.path(dirn, "Cropped"))
        }else{
          stop("This dir already has a dir named Cropped.")
        }

      }

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
          e <- as(extent(xmin, xmax, ymin, ymax), 'SpatialPolygons')
          crs(e) <- "+proj=longlat +datum=WGS84 +no_defs" # set the CRS for the boundry
          # crop
          r2 <- raster::crop(r, sp::spTransform(e, crs(r)))
          # Write back
          writeRaster(r2, filename=file.path(dirn, "Cropped", basename(rast)), format="GTiff", overwrite=TRUE)
        })


      # create the stack
      stack.rast <- raster::stack(list.files(file.path(dirn, "Cropped"),"tif", full.names = TRUE))
      #Fix the names
      names(stack.rast) <- strsplit(names((stack.rast)), "\\.") %>% map_chr(~ .x[length(.x)])

      # Write the raster file
      f_stacked_name <- file.path(dirn, "Cropped", paste0(basename(dirn), "_Stacked.tif"))
      writeRaster(stack.rast,
                  filename=f_stacked_name,
                  format="GTiff", overwrite=TRUE)
      #-------------- Remove clouds
      tmpr <- stack.rast$Fmask
       vpixel <- Valid_pixels()
       values(tmpr)[!(values(tmpr) %in% vpixel)] <- NA
       tmpr.clean <- raster::mask(stack.rast, tmpr)


      # Write the raster file
      f_stacked_masked_name <- file.path(dirn, "Cropped", paste0(basename(dirn), "_Stacked_Masked.tif"))
      writeRaster(tmpr.clean,
                  filename=f_stacked_masked_name,
                  format="GTiff", overwrite=TRUE)

      print(dirn)

      return(list(f_stacked_name,
                  f_stacked_masked_name,
                  names(stack.rast)
                  ))
    })
return(stack.paths)
}


Valid_pixels <- function(){

  Validpixels <- c(0,   4,  16,  20,  32,  36,  48,  52,  64,  68,  80,  84,  96,
                   100, 112, 116, 128, 132, 144, 148, 160, 164, 176, 180, 192, 196,
                   208, 212, 224, 228, 240, 244)
  return(Validpixels)
}

library(HLSToolBox)
library(RStoolbox)

Validpixels <- c(0,   4,  16,  20,  32,  36,  48,  52,  64,  68,  80,  84,  96,
  100, 112, 116, 128, 132, 144, 148, 160, 164, 176, 180, 192, 196,
  208, 212, 224, 228, 240, 244)



QueryHLS(c('16TDK','16TDK'),
            "2020-05-01",
            "2021-11-05"
)



dwnd <- DownloadHLS(c('16TDK','16TDK'),
            "2021-08-01",
            "2021-08-05",
            "/mnt/iccp_storage/hamzed/tmp/HLS"
            )


stks <- CropHLS("/mnt/iccp_storage/hamzed/tmp/HLS",
        xmin=-87.25, xmax=-87,
        ymin=40, ymax=40.25)
i<- 3
rr <- stack(stks[[i]][1])
names(rr) <- stks[[i]][2] %>% unlist()

par(mfrow=c(1,2))
plotRGB(stack(stks[[i]][1]), r=4, g=3, b=2, stretch="hist")
plotRGB(stack(stks[[i]][2]), r=4, g=3, b=2, stretch="hist")

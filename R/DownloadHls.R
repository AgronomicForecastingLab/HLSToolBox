

DownloadHLS <- function(Tileids, sdate, edate, outdir, mincloud=0, maxcloud=100){

  if(!HLSToolBox::check_cred()){
    stop(" You need to set the credentials as .netrc file in the home dir. Please check the HLS documentation. https://git.earthdata.nasa.gov/projects/LPDUR/repos/hls-bulk-download/browse")
  }

  #------------------------------------------- Preparing the bash file
  #bash path
  bash_path <- system.file("templates", 'getHLS.sh', package = "HLSToolBox")
  tmp_bash <- readLines(bash_path)
  all_bash_tags <- list()

  all_bash_tags$max_cloud <- maxcloud
  all_bash_tags$min_cloud <- mincloud


  for (ntags in names(all_bash_tags)) {
    tmp_bash  <- gsub(pattern = paste0("@",ntags), replace =all_bash_tags[[ntags]], x = tmp_bash)
  }

  writeLines(tmp_bash, con=file.path(outdir, "getHLS.sh"))
  #-------------------------------------------- Preparing the id list
  writeLines(paste(Tileids, collapse = " "), con=file.path(outdir, "idlist.txt"))
  #------------------------------------------- Preparing the running bash file

  cmd <- paste0("bash ", file.path(outdir, "getHLS.sh"), " ",
                      file.path(outdir, "idlist.txt"), " ",
                      sdate, " ",
                      edate, " ",
                      outdir
                )
  system(cmd)
  #----------------------------------------- Excute the DOwnload.sh
  list.files(outdir, ".json", recursive = TRUE, full.names = TRUE) %>%
    purrr::map(purrr::possibly(function(ff){
      jsonlite::fromJSON(ff)
      }, otherwise = NULL)
      ) %>%
    setNames( list.files(outdir, ".json", recursive = TRUE, full.names = TRUE) )
}

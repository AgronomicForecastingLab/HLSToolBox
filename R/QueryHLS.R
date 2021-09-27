

QueryHLS <- function(Tileids, sdate, edate, mincloud=0, maxcloud=100){

  if(!HLSToolBox::check_cred()){
    stop(" You need to set the credentials as .netrc file in the home dir. Please check the HLS documentation. https://git.earthdata.nasa.gov/projects/LPDUR/repos/hls-bulk-download/browse")
  }

  outdir <- tempdir()
  unlink(file.path(outdir, "idlist.txt"))
  #------------------------------------------- Preparing the bash file
  #bash path
  bash_path <- system.file("templates", 'QueryHLS.sh', package = "HLSToolBox")
  tmp_bash <- readLines(bash_path)
  all_bash_tags <- list()

  all_bash_tags$max_cloud <- maxcloud
  all_bash_tags$min_cloud <- mincloud


  for (ntags in names(all_bash_tags)) {
    tmp_bash  <- gsub(pattern = paste0("@",ntags), replace =all_bash_tags[[ntags]], x = tmp_bash)
  }

  fname <- paste0(paste(sample(letters, 8), collapse = ""), "_QHLS.sh")

  writeLines(tmp_bash, con=file.path(outdir, fname))
  #-------------------------------------------- Preparing the id list
  writeLines(paste(Tileids, collapse = " "), con=file.path(outdir, "idlist.txt"))
  #------------------------------------------- Preparing the running bash file

  cmd <- paste0("bash ", file.path(outdir, fname), " ",
                      file.path(outdir, "idlist.txt"), " ",
                      sdate, " ",
                      edate, " ",
                      outdir
                )
  print(cmd)
  system(cmd)

}

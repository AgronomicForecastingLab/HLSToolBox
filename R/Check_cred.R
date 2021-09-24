
#' check_cred
#'
#' @return
#' @export
#'
#' @examples
check_cred <- function() {
  file.exists(file.path(fs::path_home(), ".netrc"))
}

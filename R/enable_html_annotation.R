#' Enable html annotations using the Hypothes.is web annontation client
#' (https://web.hypothes.is/)
#'
#' @return Hypothes.is web client javascript text snippet 
#'
#' @export
enable_html_annotation <- function() {
  rstudioapi::insertText(
    '<script src="https://hypothes.is/embed.js" async></script>'
  )
}
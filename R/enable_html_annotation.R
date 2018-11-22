#' Enable html annotations using the Hypothes.is web annontation client
#' (https://web.hypothes.is/)
#'
#' @return Hypothes.is web client javascript text snippet 
#'
#' @export
enable_html_annotation <- function() {
  content <- getActiveDocumentContext()
  if (!any(grepl('<script src="https://hypothes.is/embed.js" async></script>', content$contents))){
    rstudioapi::insertText(Inf,
      '<script src="https://hypothes.is/embed.js" async></script>'
  )
  } else {
    message("Time for a coffee, you hit the button twice. ")
  }
}
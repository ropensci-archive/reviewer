#' Enable html annotations using the Hypothes.is web annontation client
#' (https://web.hypothes.is/)
#'
#' @return Hypothes.is web client javascript text snippet 
#'
#' @export
enable_html_annotation <- function() {
  content <- rstudioapi::getActiveDocumentContext()
  jssnippet <- '<script src="https://hypothes.is/embed.js" async></script>'

  if (!any(grepl(jssnippet, content$contents))) {
    rstudioapi::insertText(Inf, jssnippet)
    message("Hypothes.is is inserted at the bottom of your markdown document")
  } else {
    message("Time for a coffee, you hit the button twice. ")
  }
}
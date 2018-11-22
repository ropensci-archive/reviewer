#' Enable html annotations using the Hypothes.is web annontation client
#' (https://web.hypothes.is/)
#'
#' @return Hypothes.is web client javascript text snippet 
#'
#' @export
enable_html_annotation <- function() {
<<<<<<< HEAD
  content <- rstudioapi::getActiveDocumentContext()
  if (!any(grepl('<script src="https://hypothes.is/embed.js" async></script>', content$contents))){
    rstudioapi::insertText(Inf,
      '<script src="https://hypothes.is/embed.js" async></script>'
  )
    message("Hypothes.is is inserted at the bottom of your markdown document")
||||||| merged common ancestors
  content <- getActiveDocumentContext()
  if (!any(grepl('<script src="https://hypothes.is/embed.js" async></script>', content$contents))){
    rstudioapi::insertText(Inf,
      '<script src="https://hypothes.is/embed.js" async></script>'
  )
    message("Hypothes.is is inserted at the bottom of your markdown document")
=======
  content <- getActiveDocumentContext()
  jssnippet <- '<script src="https://hypothes.is/embed.js" async></script>'

  if (!any(grepl(jssnippet, content$contents))) {
    rstudioapi::insertText(Inf, jssnippet)
>>>>>>> 8e20ff173aeaf3026cca94693fca595e69629437
  } else {
    message("Time for a coffee, you hit the button twice. ")
  }
}
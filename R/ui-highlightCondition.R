highlightCondition <- function(x) {
    x <- gsub("[{}]", "", x)
    x <- htmlEscape(x)
    x <- gsub("=", "</span>=<span class=\"pred_v\">", x)
    x <- gsub("^", "<span class=\"pred_n\">", x)
    x <- gsub("$", "</span>", x)
    x <- gsub(",", "</span><br/><span class=\"pred_n\">", x)

    x
}

#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


.parse_tree_def_from_condition <- function(pred, root_name) {
    if (is.null(pred) || length(pred) == 0) {
        return(.create_empty_tree_def())
    }

    empties <- vapply(pred, length, integer(1)) == 0
    pred <- pred[!empties]
    if (length(pred) == 0) {
        return(.create_empty_tree_def())
    }

    pred <- unlist(pred)
    pred <- unique(pred)
    pred <- sort(pred)
    n <- sub("=.*", "", pred)
    v <- sub(".*=", "", pred)
    hasEq <- grepl("=", pred)

    nid_dict <- unique(n)
    nid_dict <- setNames(seq_along(nid_dict), nid_dict)
    nid <- paste0("n", nid_dict[n])
    vid <- paste0("v", seq_along(pred))

    v <- paste0("= ", v)
    v[!hasEq] <- NA
    vid[!hasEq] <- NA

    res <- data.frame(nid = nid,         # predicate name ID
                      vid = vid,         # value ID
                      rid = root_name,   # root node name shown
                      predicate = pred,
                      name = n,          # node name shown
                      value = v,         # sub-node name shown
                      stringsAsFactors = FALSE)

    if (length(pred) > 50) {
        prefix <- substr(pred, 1, 1)
        prefix <- toupper(prefix)
        res$pid <- paste0(prefix, "...")
    }

    res
}

.create_empty_tree_def <- function() {
    data.frame(nid = character(0),
               vid = character(0),
               rid = character(0),
               predicate = character(0),
               name = character(0),
               value = character(0),
               stringsAsFactors = FALSE)
}

.create_tree_from_def <- function(def) {
    if (is.null(def$pid)) {
        lev <- c("rid", "name", "value")
        id <- c("rid", "nid", "vid")
    } else {
        lev <- c("rid", "pid", "name", "value")
        id <- c("rid", "pid", "nid", "vid")
    }

    shinyWidgets::create_tree(def, levels = lev, levels_id = id)
}

.create_filtering_table <- function(x, pred, def) {
    m <- matrix(FALSE, nrow = length(x), ncol = nrow(def))
    for (row in seq_along(x)) {
        m[row, ] <- def$predicate %in% pred[[row]]
    }

    m
}

conditionFilterModule <- function(id, x, meta) {
    root_name <- "predicate"
    pred <- parse_condition(x)
    def <- .parse_tree_def_from_condition(pred, root_name = root_name)
    tab <- .create_filtering_table(x, pred, def)
    tree <- .create_tree_from_def(def)
    empty_cond <- vapply(pred, length, integer(1)) == 0

    showTree <- NULL
    showRadio <- NULL
    showEmptyCheckbox <- NULL
    if (any(empty_cond)) {
        showEmptyCheckbox <- shiny::checkboxInput(shiny::NS(id, "emptyCondition"),
                                           paste0("show empty ", tolower(meta$long_name)),
                                           value = TRUE)
    }
    if (!all(empty_cond)) {
        showTree <- shinyWidgets::treeInput(shiny::NS(id, "tree"),
                                            label = tolower(meta$long_name),
                                            choices = tree,
                                            selected = root_name,
                                            returnValue = "id",
                                            closeDepth = 1)
        showRadio <- shiny::radioButtons(shiny::NS(id, "radio"),
                                         label = "show rules containing",
                                         choiceNames = c("all selected predicates", "at least one selected predicate"),
                                         choiceValues = c("all", "any"),
                                         selected = "all")
    }

    list(ui = function() {
            filterTabPanel(title = meta$long_name,
                           value = meta$data_name,
                           info = paste0("Filter the rules by choosing predicates that should appear in the ",
                                         tolower(meta$long_name), "."),
                showTree,
                showRadio,
                showEmptyCheckbox,
                htmltools::hr(),
                shiny::actionButton(shiny::NS(id, "resetButton"), "Reset"),
                shiny::actionButton(shiny::NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            shiny::moduleServer(id, function(input, output, session) {
                shiny::observeEvent(input$resetButton, {
                    if (!is.null(showTree)) {
                        shinyWidgets::updateTreeInput("tree", selected = def$vid, session = session)
                    }
                    if (!is.null(showRadio)) {
                        shiny::updateRadioButtons("radio", selected = "all", session = session)
                    }
                    if (!is.null(showEmptyCheckbox)) {
                        shiny::updateCheckboxInput("emptyCondition", value = TRUE, session = session)
                    }
                })

                shiny::observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })
            })
        },

        filter = function(input) {
            treeInput <- input[[shiny::NS(id, "tree")]]
            radioInput <- input[[shiny::NS(id, "radio")]]
            emptyInput <- input[[shiny::NS(id, "emptyCondition")]]

            if (is.null(treeInput) || is.null(radioInput)) {
                res <- rep(FALSE, length(x))
            } else {
                ids <- def$rid %in% treeInput |
                       def$nid %in% treeInput |
                       !is.na(def$vid) & def$vid %in% treeInput
                res <- tab[, ids, drop = FALSE]
                if (radioInput == "all") {
                    res <- rowSums(res) == rowSums(tab)
                } else {
                    res <- rowSums(res) > 0
                }
            }

            if (!is.null(emptyInput)) {
                if (emptyInput) {
                    res <- res | empty_cond
                } else {
                    res <- res & !empty_cond
                }
            }

            res
        },

        reset = function(session) {
            if (!is.null(showTree)) {
                shinyWidgets::updateTreeInput(shiny::NS(id, "tree"), selected = def$vid, session = session)
            }
            if (!is.null(showRadio)) {
                shiny::updateRadioButtons(shiny::NS(id, "radio"), selected = "all", session = session)
            }
            if (!is.null(showEmptyCheckbox)) {
                shiny::updateCheckboxInput(shiny::NS(id, "emptyCondition"), value = TRUE, session = session)
            }
        }
    )
}

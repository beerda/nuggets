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
        return(data.frame())
    }

    empties <- vapply(pred, length, integer(1)) == 0
    pred <- pred[!empties]
    if (length(pred) == 0) {
        return(data.frame())
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

.create_tree_from_def <- function(def) {
    if (is.null(def$pid)) {
        lev <- c("rid", "name", "value")
        id <- c("rid", "nid", "vid")
    } else {
        lev <- c("rid", "pid", "name", "value")
        id <- c("rid", "pid", "nid", "vid")
    }

    create_tree(def, levels = lev, levels_id = id)
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
    showEmptyCheckbox <- NULL
    if (any(empty_cond)) {
        showEmptyCheckbox <- checkboxInput(NS(id, "emptyCondition"),
                                           paste0("show empty ", tolower(meta$long_name)),
                                           value = TRUE)
    }

    list(ui = function() {
            tabPanel(title = meta$long_name,
                     value = paste0(meta$data_name, "-filter-tab"),
                infoBox(paste0("Filter the rules by choosing predicates that should appear in the ",
                              tolower(meta$long_name), ".")),
                treeInput(NS(id, "tree"),
                          label = tolower(meta$long_name),
                          choices = tree,
                          selected = root_name,
                          returnValue = "id",
                          closeDepth = 1),
                radioButtons(NS(id, "radio"),
                             label = "show rules containing",
                             choiceNames = c("all selected predicates", "at least one selected predicate"),
                             choiceValues = c("all", "any"),
                             selected = "all"),
                showEmptyCheckbox,
                hr(),
                actionButton(NS(id, "resetButton"), "Reset"),
                actionButton(NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            moduleServer(id, function(input, output, session) {
                observeEvent(input$resetButton, {
                    updateTreeInput("tree", selected = def$vid, session = session)
                    updateRadioButtons("radio", selected = "all", session = session)

                observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })
            })
        },

        filter = function(input) {
            treeInput <- input[[NS(id, "tree")]]
            radioInput <- input[[NS(id, "radio")]]
            emptyInput <- input[[NS(id, "emptyCondition")]]

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
            updateTreeInput(NS(id, "tree"), selected = def$vid, session = session)
            updateRadioButtons(NS(id, "radio"), selected = "all", session = session)
        }
    )
}

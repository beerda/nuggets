.parse_tree_def_from_condition <- function(x, root_name) {
    pred <- parse_condition(x)
    pred <- unlist(pred)
    pred <- unique(pred)
    pred <- sort(pred)
    n <- sub("=.*", "", pred)
    v <- sub(".*=", "", pred)
    nid_dict <- unique(n)
    nid_dict <- setNames(seq_along(nid_dict), nid_dict)

    res <- data.frame(nid = paste0("n", nid_dict[n]),     # predicate name ID
                      vid = paste0("v", seq_along(pred)), # value ID
                      rid = root_name,                    # root node name
                      predicate = pred,
                      name = n,
                      value = v,
                      stringsAsFactors = FALSE)

    if (length(pred) > 50) {
        prefix <- substr(pred, 1, 1)
        prefix <- toupper(prefix)
        res$pid <- paste0(prefix, "...")
    }

    res
}

.create_tree_from_def <- function(def) {
    lev = c("rid", "name", "value")
    id = c("rid", "nid", "vid")

    if (is.null(def$pid)) {
        lev = c("rid", "name", "value")
        id = c("rid", "nid", "vid")
    } else {
        lev = c("rid", "pid", "name", "value")
        id = c("rid", "pid", "nid", "vid")
    }

    create_tree(def, levels = lev, levels_id = id)
}

.create_filtering_table <- function(x, def) {
    pred <- parse_condition(x)
    m <- matrix(FALSE, nrow = length(x), ncol = nrow(def))
    colnames(m) <- def$vid
    for (row in seq_along(x)) {
        m[row, ] <- def$predicate %in% pred[[row]]
    }

    m
}

conditionFilterModule <- function(id,
                                  x,
                                  meta,
                                  resetAllEvent) {
    def <- .parse_tree_def_from_condition(x, root_name = "predicate")
    tab <- .create_filtering_table(x, def)
    tree <- .create_tree_from_def(def)

    list(ui = function() {
            tabPanel(meta$long_name,
                infoBox("Filter the rules by choosing predicates that should appear in the ",
                        tolower(meta$long_name), "."),
                treeInput(NS(id, "tree"),
                          label = tolower(meta$long_name),
                          choices = tree,
                          selected = def$vid,
                          returnValue = "id",
                          closeDepth = 1),
                radioButtons(NS(id, "radio"),
                             label = "show rules containing",
                             choiceNames = c("all selected predicates", "at least one selected predicate"),
                             choiceValues = c("all", "any"),
                             selected = "all"),
                actionButton(NS(id, "resetButton"), "Reset"),
                actionButton(resetAllEvent, "Reset all")
            )
        },

        server = function() {
            moduleServer(id, function(input, output, session) {
                observeEvent(input$resetButton, {
                    updateTreeInput("tree", selected = def$vid, session = session)
                    updateRadioButtons("radio", selected = "all", session = session)
                })
            })
        },

        filter = function(input) {
            treeInput <- input[[NS(id, "tree")]]
            radioInput <- input[[NS(id, "radio")]]

            if (is.null(treeInput) || is.null(radioInput)) {
                return(rep(FALSE, length(x)))
            }

            res <- as.character(treeInput)
            res <- res[startsWith(res, "v")]
            res <- tab[, res, drop = FALSE]

            if (radioInput == "all") {
                res <- rowSums(res) == rowSums(tab)
            } else {
                res <- rowSums(res) > 0
            }

            res
        },

        reset = function(session) {
            updateTreeInput(NS(id, "tree"), selected = def$vid, session = session)
            updateRadioButtons(NS(id, "radio"), selected = "all", session = session)
        }
    )
}

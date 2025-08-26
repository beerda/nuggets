tableButton <- function(action,
                        id,
                        title,
                        icon,
                        session) {
    ns <- session$ns
    paste0('<button ',
           'class="btn btn-sm" ',
           'type="button" ',
           'data-toggle="tooltip" ',
           'data-placement="top" ',
           'style="margin: 0" ',
           'title="', title, '" ',
           'onClick="Shiny.setInputValue(\'', ns(action), '\', ', id, ', { priority: \'event\' });"',
           '>',
           '<i class="fa fa-', icon, '"></i>',
           '</button>')
}


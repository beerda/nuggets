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


# datatable with tooltips shown over column names
datatable2 <- function(data,
                       tooltips = colnames(data),
                       escape = FALSE,
                       rownames = FALSE,
                       selection = "none",
                       filter = "none",
                       options = list(),
                       ...) {
    js_tips <- toJSON(unname(tooltips), auto_unbox = TRUE)

    if (is.null(options$pageLength)) {
        options$pageLength <- 10
    }
    if (is.null(options$autoWidth)) {
        options$autoWidth <- FALSE
    }
    if (is.null(options$searching)) {
        options$searching <- FALSE
    }
    if (is.null(options$scrollX)) {
        options$scrollX <- TRUE
    }
    if (is.null(options$initComplete)) {
        options$initComplete <- JS(sprintf(
                "function(settings, json){
             var api = this.api();
             var tips = %s;
             api.columns().every(function(i){
               var th = $(api.column(i).header());
               th.attr('title', tips[i] || th.text().trim());
             });
           }", js_tips))
    }
    if (is.null(options$drawCallback)) {
        options$drawCallback = JS(
                "function(settings){
             var api = this.api();
             api.columns().every(function(i){
               var th = $(api.column(i).header());
               if (!th.attr('title')) th.attr('title', th.text().trim());
             });
           }")
    }

    datatable(data = data,
              options = options,
              escape = escape,
              rownames = rownames,
              selection = selection,
              filter = filter,
              ...)
}

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


test_that("infoBox", {
    .skip_if_shiny_not_installed()

    # Test "info" status
    ui <- infoBox("Some text", "blah", status = "info")
    html <- as.character(ui)
    expect_match(html, "class=\"info-box\"")
    expect_match(html, "fa-circle-info")
    expect_match(html, "Some text\\n +blah")

    # Test "success" status
    ui <- infoBox("Done!", status = "success")
    html <- as.character(ui)
    expect_match(html, "fa-circle-check")

    # Test "danger" status
    ui <- infoBox("Error", status = "danger")
    html <- as.character(ui)
    expect_match(html, "fa-circle-xmark")

    # Test "warning" status
    ui <- infoBox("Careful", status = "warning")
    html <- as.character(ui)
    expect_match(html, "fa-triangle-exclamation")
})

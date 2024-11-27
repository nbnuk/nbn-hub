<asset:stylesheet src="saveSearchModals.css"/>

<div class="modal fade" id="createSavedSearchModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h4 class="modal-title" id="customiseFacetsLabel">
                    Save Search
                </h4>
            </div>
            <div class="modal-body">
                <g:if test="${!userId}">
                    <div id="saveSearchListPleaseLoginMessage" style="margin: 20px 20px;">Please login:
                        <a href="${grailsApplication.config.security.cas.casServerLoginUrl}?service=${grailsApplication.config.serverName}${request.contextPath}${request.forwardURI}${request.queryString ? '?' + request.queryString : ''}"><g:message code="show.loginorflag.div01.navigator" default="Click here"/></a>
                    </div>
                </g:if>
                <g:else>

                    <div id="saveSearchErrorMessage" class="alert alert-danger" style="opacity: 0">
                    </div>

                    <form id="createSavedSearchForm">
                        <div class="form-group">
                            <label for="searchName">Search Name</label>
                            <input type="text" class="form-control" id="searchName" required>
                        </div>
                        <div class="form-group">
                            <label for="searchDescription">Description (optional)</label>
                            <textarea class="form-control" id="searchDescription" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="searchUrl">Search URL</label>
                            <textarea class="form-control" id="searchUrl" rows="5"></textarea>
                        </div>
                    </form>
                </g:else>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="saveSearch">Save</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="savedSearchesModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h4 class="modal-title">
                    Saved Searches
                    <span>(scroll to see full list)</span>
                </h4>
            </div>
            <div class="modal-body">
                <g:if test="${!userId}">
                    <div id="saveSearchListPleaseLoginMessage" style="margin: 20px 20px;">Please login:
                        <a href="${grailsApplication.config.security.cas.casServerLoginUrl}?service=${grailsApplication.config.serverName}${request.contextPath}${request.forwardURI}${request.queryString ? '?' + request.queryString : ''}"><g:message code="show.loginorflag.div01.navigator" default="Click here"/></a>
                    </div>
                </g:if>
                <g:else>
%{--                    <div style="text-align:right; margin:15px"><a class="btn btn-primary" href="${grailsApplication.config.alerts.baseUrl}/savedSearch/mySavedSearches" >--}%
%{--                        <i class="fa fa-cog"></i> Manage Saved Searches</a></div>--}%
                      <div class="table-container">
                        <table class="table table-hover" id="savedSearchesTable">
                            <thead class="table-header">
                                <tr>
                                    <th>Name</th>
                                    <th>Description</th>
                                    <th>Query</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="savedSearchesList">
                            </tbody>
                        </table>
                    </div>
                </g:else>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
var customiseFilterButton = $('a[data-target="#facetConfigDialog"]');
if (customiseFilterButton) {
    var viewSearchesButton = $('<a>', {
        href: '#savedSearchesModal',
        'data-toggle': "modal",
        class: 'btn btn-primary nbn-saved-searches-btn',
        html: '<i class="fa fa-tags"></i> <span>View Searches</span>',
        title: 'View your Saved Searches'
    });
    customiseFilterButton.after(viewSearchesButton);
}

var saveSearchButton = $('<a>', {
    href: '#createSavedSearchModal',
    'data-toggle': "modal",
    'class': 'btn btn-primary nbn-saved-searches-btn',
    html: '<i class="fa fa-save"></i> <span>Save Search</span>',
    title: 'Save your current Search'
});

$('#download-button-area .btn:first').before(saveSearchButton);

// Function to set the current URL in the searchUrl field
function setCurrentUrl() {
    $('#searchUrl').val(cleanUpURL(window.location.href));
}

function cleanUpURL(url) {
    let resultUrl = url;

    // Replace specific patterns
    resultUrl = resultUrl.replace('?nbn_loading=true&', '?');
    resultUrl = resultUrl.replace('?nbn_loading=true', '');
    resultUrl = resultUrl.replace('&nbn_loading=true', '');

    // Add 'fq' if missing
    if (resultUrl && !resultUrl.includes('?fq=') && !resultUrl.includes('&fq=')) {
        if (resultUrl.includes('?')) {
            resultUrl += '&fq=';
        } else {
            resultUrl += '?fq=';
        }
    }

    return resultUrl;
}


// Call this function when the modal is shown
$('#createSavedSearchModal').on('show.bs.modal', function () {
    setCurrentUrl();
});

// Event handler for Save Search button
$('#createSavedSearchModal').on('click', '#saveSearch', function () {
    var searchName = $('#searchName').val();
    var searchDescription = $('#searchDescription').val();
    var searchUrl = $('#searchUrl').val();

    if (searchName && searchUrl) {
        // Call the save method of SavedSearchController
        $.ajax({
            url: "${createLink(controller: 'savedSearch', action: 'save')}",
            method: 'POST',
            data: {
                name: searchName,
                description: searchDescription,
                searchRequestQueryUI: searchUrl
            },
            success: function(response) {
                // Close the create modal
                $('#createSavedSearchModal').modal('hide');

                // Show success message in a more visible location (append to body)
                var successMessage = $('<div class="alert alert-success" style="position: fixed; top: 20px; left: 50%; transform: translateX(-50%); z-index: 9999;">' +
                    'Search saved successfully!' +
                    '</div>');
                $('body').append(successMessage);

                // Fade out and remove the success message after 2 seconds
                successMessage.delay(2000).fadeOut(500, function() {
                    $(this).remove();
                });

                // Reset the form
                $('#createSavedSearchForm')[0].reset();

                // Set the current URL again for next time
                setCurrentUrl();
            },
            error: function(xhr, status, error) {
                const response = JSON.parse(xhr.responseText);
                if (response.status === 401) {
                    $('#saveSearchErrorMessage').text("Sorry, you need to login again"); //this will rarely happen, so just show a simple message (easiest)
                    fadeinout('#saveSearchErrorMessage');
                }
                else {
                    const errorMessage = response.message || "An error occurred";
                    console.error('Error saving search:', errorMessage);
                    $('#saveSearchErrorMessage').text(errorMessage);
                    fadeinout('#saveSearchErrorMessage');
                }
            }
        });
    } else {
        // Show error message
        $('#saveSearchErrorMessage').text("You must provide both a name and a URL to save a search.");
        fadeinout('#saveSearchErrorMessage');
    }
});

function fadeinout(divId) {
    $(divId).animate({ opacity: 1 }, 500)
    .delay(3000)
    .animate({ opacity: 0 }, 1000)
}

function fetchAndDisplaySavedSearches() {
    $.ajax({
        url: "${createLink(controller: 'savedSearch', action: 'list')}",
        method: 'GET',
        success: function(response) {
            var savedSearchesList = $('#savedSearchesList');
            savedSearchesList.empty(); // Clear existing content

            if (response && response.length > 0) {
                response.forEach(function(search) {
                    var row = $('<tr></tr>');

                    // Create read-only textareas for each cell
                    row.append($('<td></td>').append(
                        $('<textarea class="cell-textarea" readonly></textarea>').val(search.name)
                    ));
                    row.append($('<td></td>').append(
                        $('<textarea class="cell-textarea" readonly></textarea>').val(search.description || '')
                    ));
                    row.append($('<td></td>').append(
                        $('<textarea class="cell-textarea query-textarea" readonly></textarea>').val(search.searchRequestQueryUI)
                    ));

                    var actionsCell = $('<td></td>');
                    var loadButton = $('<button>', {
                        'class': 'btn btn-sm btn-primary',
                        'data-toggle': 'tooltip',
                        'data-placement': 'top',
                        'data-original-title': 'Loading this search will overwrite any current search!',
                        text: 'Load'
                    }).click(function() {
                        window.location.href = search.searchRequestQueryUI;
                    });

                    // Initialize the tooltip
                    loadButton.tooltip();

                    actionsCell.append(loadButton);
                    row.append(actionsCell);
                    savedSearchesList.append(row);
                });
            } else {
                var emptyRow = $('<tr><td colspan="4" class="text-center">No saved searches found.</td></tr>');
                savedSearchesList.append(emptyRow);
            }

        },
        error: function(xhr, status, error) {
            let response = null;
            try {
                response = JSON.parse(xhr.responseText); //server can return html error page
            } catch (e) {
                 response = null;
            }
            let errorMessage = response && response.status === 401
                ? "Sorry, you need to login again"
                : (response && response.message) || "An error occurred";

            var errorRow = $('<tr><td colspan="4" class="text-center text-danger">' + errorMessage + '</td></tr>');
            $('#savedSearchesList').html(errorRow);
        }
    });
}

// Call fetchAndDisplaySavedSearches when the modal is shown
$('#savedSearchesModal').on('show.bs.modal', function () {
    fetchAndDisplaySavedSearches();
});


</asset:script>

<style>
.saved-searches-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 15px;
    padding: 15px;
}

.saved-search-cell {
    border: 1px solid #ccc;
    padding: 15px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
}

.search-name {
    font-weight: bold;
    margin-bottom: 10px;
}

.search-query {
    margin-bottom: 10px;
    word-break: break-all;
}

.run-search {
    align-self: flex-start;
}

#savedSearchesTable {
    margin-bottom: 0;
}

#savedSearchesTable th {
    background-color: #f5f5f5;
}

#savedSearchesModal .modal-body {
    padding: 0;
}

#savedSearchesModal .table {
    margin-bottom: 0;
}

#savedSearchesModal .btn-sm {
    padding: 2px 8px;
}

.cell-textarea {
    width: 100%;
    min-height: 60px;
    resize: vertical;
    border: none;
    background: transparent;
    padding: 5px;
    margin: 0;
    vertical-align: top;
}

.query-textarea {
    min-height: 80px;
    border: none;
    background: transparent;
}

#savedSearchesTableBody td {
    vertical-align: top;
    padding: 8px;
    border: none;
}

/* Remove focus outline but keep it accessible */
.cell-textarea:focus {
    outline: none;
}

/* Make the table header stick to the top */
.table-header {
    position: sticky;
    top: 0;
    z-index: 1;
    background-color: #f5f5f5;
}

/* Ensure consistent cell widths */
#savedSearchesTable th:nth-child(1),
#savedSearchesTableBody td:nth-child(1) {
    width: 20%;
}

#savedSearchesTable th:nth-child(2),
#savedSearchesTableBody td:nth-child(2) {
    width: 25%;
}

#savedSearchesTable th:nth-child(3),
#savedSearchesTableBody td:nth-child(3) {
    width: 45%;
}

#savedSearchesTable th:nth-child(4),
#savedSearchesTableBody td:nth-child(4) {
    width: 10%;
}
</style>

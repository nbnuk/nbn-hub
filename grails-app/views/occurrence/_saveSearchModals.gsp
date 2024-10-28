<asset:stylesheet src="saveSearchModals.css"/>

<div class="modal fade" id="createSavedSearchModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h4 class="modal-title" id="customiseFacetsLabel">
                    Create Saved Search
                </h4>
            </div>
            <div class="modal-body">
                <div id="saveSuccessMessage" class="alert alert-success" style="display: none;">
                    Search saved successfully!
                </div>
                <div id="saveErrorMessage" class="alert alert-danger" style="display: none;">
                    Please enter a Search name and URL
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
                    </table>
                    <div class="table-body-container">
                        <table class="table table-hover" id="savedSearchesTableBody">
                            <tbody id="savedSearchesList">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <a href="${createLink(controller: 'savedSearch', action: 'mySavedSearches')}" class="btn btn-primary">
                    <i class="fa fa-tags"></i> Manage Saved Searches
                </a>
            </div>
        </div>
    </div>
</div>

<asset:script type="text/javascript">
var customiseFilterButton = $('a[data-target="#facetConfigDialog"]');
if (customiseFilterButton) {
    var savedSearchesButton = $('<a>', {
        href: '#',
        class: 'btn btn-primary nbn-saved-searches-btn',
        html: '<i class="fa fa-tags"></i> <span>Saved Searches</span>',
        click: function (e) {
            e.preventDefault();
            $('#savedSearchesModal').modal('show');
        }
    });
    customiseFilterButton.after(savedSearchesButton);
}

var saveSearchButton = $('<a>', {
    href: '#',
    'data-toggle': "modal",
    'class': 'btn btn-primary nbn-saved-searches-btn',
    html: '<i class="fa fa-tag"></i> <span>Save Search</span>',
    click: function (e) {
        e.preventDefault();
        $('#createSavedSearchModal').modal('show');
    }
});

$('#download-button-area .btn:first').before(saveSearchButton);

// Function to set the current URL in the searchUrl field
function setCurrentUrl() {
    $('#searchUrl').val(window.location.href);
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
        console.log('Saving new search:', { name: searchName, description: searchDescription, searchUrl: searchUrl });

        // Call the save method of SavedSearchController
        $.ajax({
            url: "${createLink(controller: 'savedSearch', action: 'save')}",
            method: 'POST',
            data: {
                userId: '${session.userId}', // Assuming you have the userId in the session
                name: searchName,
                description: searchDescription,
                searchRequestQueryUI: searchUrl
            },
            success: function(response) {
                debugger
                console.log(`Search saved successfully: ${response}`);
                $('#saveSuccessMessage').fadeIn().delay(2000).fadeOut();
            },
            error: function(xhr, status, error) {
                console.error('Error saving search:', error);
                $('#saveErrorMessage').fadeIn().delay(2000).fadeOut();
            }
        });

        // Reset the form
        $('#createSavedSearchForm')[0].reset();

        // Set the current URL again
        setCurrentUrl();

        // Focus on the search name field for the next entry
        $('#searchName').focus();
    } else {
        // Show error message
        $('#saveErrorMessage').fadeIn().delay(2000).fadeOut();
    }
});

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

                    row.append($('<td></td>').text(search.name));
                    row.append($('<td></td>').text(search.description || ''));
                    row.append($('<td></td>').text(search.searchRequestQueryUI));

                    var actionsCell = $('<td></td>');
                    var runButton = $('<button class="btn btn-sm btn-primary">Run</button>').click(function() {
                        window.location.href = search.searchRequestQueryUI;
                    });
                    actionsCell.append(runButton);

                    row.append(actionsCell);
                    savedSearchesList.append(row);
                });
            } else {
                var emptyRow = $('<tr><td colspan="4" class="text-center">No saved searches found.</td></tr>');
                savedSearchesList.append(emptyRow);
            }
        },
        error: function(xhr, status, error) {
            console.error('Error fetching saved searches:', error);
            var errorRow = $('<tr><td colspan="4" class="text-center text-danger">Error loading saved searches.</td></tr>');
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
</style>

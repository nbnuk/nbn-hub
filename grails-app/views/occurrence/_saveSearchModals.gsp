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
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="saveSearch">Save Search</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="savedSearchesModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h4 class="modal-title" id="customiseFacetsLabel">
                    Saved Searches
                    <span id="customiseFacetsHint">(scroll to see full list)</span>
                </h4>
            </div>
            <div class="modal-body">
                <ul class="list-unstyled" id="savedSearchesList">

                </ul>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-dark btn-block" id="createSavedSearch">
                    <i class="fa fa-plus"></i> Create Saved Search
                </button>
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
        style: 'margin-left: 10px;',
        html: '<i class="fa fa-bookmark-o"></i> <span>Saved Searches</span>',
        click: function (e) {
            e.preventDefault();
            $('#savedSearchesModal').modal('show');
        }
    });
    customiseFilterButton.after(savedSearchesButton);
}


var savedSearches = [
    { id: 1, name: "Recent Search", query: "category:articles date:>2023-01-01" },
    { id: 2, name: "Popular Search", query: "category:products rating:>4" },
    { id: 3, name: "Common Search", query: "category:products rating:>4" },
    { id: 4, name: "Uncommon Search", query: "category:products rating:>4" }
];



var createSearchButton = $('<a>', {
    href: '#',
    'data-toggle': "modal",
    'class': 'btn btn-primary nbn-saved-searches-btn',
    style: 'margin-left: 10px;',
    html: '<i class="fa fa-search-plus"></i> <span>Create Search</span>',
    click: function (e) {
        e.preventDefault();
        $('#createSavedSearchModal').modal('show');
    }
});

$('#download-button-area .btn:first').before(createSearchButton);

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

        // Add the new search to the savedSearches array
        var newSearch = {
            id: savedSearches.length + 1,
            name: searchName,
            query: searchUrl // Now using the searchUrl as the query
        };
        savedSearches.push(newSearch);

        // Refresh the list in the main modal
        // TODO refreshSavedSearchesList();

        // Show success message
        $('#saveSuccessMessage').fadeIn().delay(2000).fadeOut();

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

</asset:script>

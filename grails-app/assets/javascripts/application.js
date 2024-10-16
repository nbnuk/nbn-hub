if (typeof jQuery !== 'undefined') {
    (function ($) {
        $('#spinner').ajaxStart(function () {
            $(this).fadeIn();
        }).ajaxStop(function () {
            $(this).fadeOut();
        });
    })(jQuery);
}

$(document).ready(function () {
    var jsFileLocation = $('script[src*="/assets/application.js"]').attr('src');
    jsFileLocation = jsFileLocation.substring(0, jsFileLocation.lastIndexOf("/"));
    $.getScript(jsFileLocation + '/application-last.js');

    // //temp fix only needed for 7 days - so can be removed
    // var userFacets = $.cookie("user_facets_new");
    // if (userFacets) {
    // 	$.cookie("user_facets_new", userFacets, { expires: 7 });
    // 	$.removeCookie('user_facets_new');
    // 	document.location.reload(true);
    // }
    // //end temp fix


    //add more options to radius drop downs, e.g like the one on exploreYourArea
    if ($('select#radius')) {
        var radiusSelect = $('select#radius');
        radiusSelect.children("option").eq(0).before($("<option></option>").val(0.1).text("0.1"));
        radiusSelect.children("option").eq(1).before($("<option></option>").val(0.5).text("0.5"));
        radiusSelect.children("option").eq(3).before($("<option></option>").val(2).text("2"));

        var url = new URL(document.location.href);
        var radius = url.searchParams.get("radius");
        if (radius) {
            $('select#radius').val(radius);
            //note: this selection gets overwritten in exploreYourArea.js function bookmarkedSearch
        }
    }

    customise_occurrence_home_page();

    customise_occurrence_show_page();

    customise_occurrence_list_page();

    customise_download_page();

    customise_explore_your_area_page();

    function customise_download_page() {
        $("#mydownloads").hide()
    }

    function customise_explore_your_area_page() {
        if (document.title.indexOf("Explore Your Area") < 0) {
            return;
        }
        $("#downloadData").hide();
        $('a[href="#downloadModal"]').hide();
    }

    function customise_occurrence_home_page() {
        if (!$(".searchPage").length) { //unique identifier for home page.
            return;
        }

        $('a[href="#eventSearch"]').parent().hide();


        //Change the batch taxon search form
        $("#batchModeMatched").prop("checked", true);
        $("#batchModeMatched").val("taxon_name")
        $("#raw_names").next("div").hide();
        $("#taxaUploadForm input[type='submit']").css("margin-top", "1rem");


    }

    function customise_occurrence_list_page() {
        if (!$('#listHeader').length) { return; }
        $.getScript(jsFileLocation + '/search-override.js');

        var customiseFilterButton = $('a[data-target="#facetConfigDialog"]');
        if (customiseFilterButton) {
            customiseFilterButton.removeClass("btn-default btn-sm").addClass("btn-primary");

            // Mock data for saved searches
            var savedSearches = [
                { id: 1, name: "Recent Search", query: "category:articles date:>2023-01-01" },
                { id: 2, name: "Popular Search", query: "category:products rating:>4" },
                { id: 3, name: "Common Search", query: "category:products rating:>4" },
                { id: 4, name: "Uncommon Search", query: "category:products rating:>4" }
            ];

            var savedSearchesModalHtml = `
                <div class="modal fade" id="savedSearchesModal" tabindex="-1" role="dialog">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h3 class="modal-title">Saved Searches</h3>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <ul class="list-unstyled" id="savedSearchesList">
                                    ${savedSearches.map(search => `
                                        <li class="saved-search-item" data-id="${search.id}">
                                            <h4>${search.name}</h4>
                                            <small class="text-muted">${search.query}</small>
                                            <div class="btn-group" role="group">
                                                <button class="btn btn-link edit-search" title="Edit"><i class="fa fa-pencil"></i></button>
                                                <button class="btn btn-link delete-search" title="Delete"><i class="fa fa-trash"></i></button>
                                                <button class="btn btn-link apply-search" title="Apply Search"><i class="fa fa-search"></i></button>
                                            </div>
                                        </li>
                                    `).join('')}
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
            `;

            // Add the create saved search modal HTML
            var createSavedSearchModalHtml = `
                <div class="modal fade" id="createSavedSearchModal" tabindex="-1" role="dialog">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h4 class="modal-title">Create Saved Search</h4>

                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
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
                                        <label>
                                            <input type="checkbox" id="makeSearchPublic"> Make this search public
                                        </label>
                                    </div>
                                </form>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                                <button type="button" class="btn btn-primary" id="saveNewSearch">Save Search</button>
                            </div>
                        </div>
                    </div>
                </div>
            `;

            // Append both modals to the body
            $('body').append(savedSearchesModalHtml);
            $('body').append(createSavedSearchModalHtml);

            // Bind click event to Create Saved Search button after it's been added to the DOM
            $('#savedSearchesModal').on('shown.bs.modal', function () {
                $('#createSavedSearch').off('click').on('click', function (e) {
                    e.preventDefault();
                    $('#createSavedSearchModal').modal('show');
                });
            });

            // Event handler for Save New Search button
            $('#createSavedSearchModal').on('click', '#saveNewSearch', function () {
                var searchName = $('#searchName').val();
                var searchDescription = $('#searchDescription').val();
                var isPublic = $('#makeSearchPublic').is(':checked');

                if (searchName) {
                    console.log('Saving new search:', { name: searchName, description: searchDescription, isPublic: isPublic });

                    // For demo purposes, add it to our list
                    var newSearch = {
                        id: savedSearches.length + 1,
                        name: searchName,
                        query: 'New search query' // You'd get this from your actual search parameters
                    };
                    savedSearches.push(newSearch);

                    // Refresh the list in the main modal
                    refreshSavedSearchesList();

                    // Close the create modal
                    $('#createSavedSearchModal').modal('hide');

                    // Reset the form
                    $('#createSavedSearchForm')[0].reset();
                } else {
                    alert('Please enter a search name');
                }
            });

            // Handle closing of createSavedSearchModal
            $('#createSavedSearchModal').on('hidden.bs.modal', function () {
                // This ensures the savedSearchesModal is still visible and focused
                $('#savedSearchesModal').modal('show');
            });

            var savedSearchesButton = $('<a>', {
                href: '#',
                class: 'btn btn-primary nbn-saved-searches-btn',
                style: 'margin-left: 10px;',
                html: '<i class="fa fa-cog"></i> <span>Saved Searches</span>',
                click: function (e) {
                    e.preventDefault();
                    $('#savedSearchesModal').modal('show');
                }
            });

            customiseFilterButton.after(savedSearchesButton);
        }

        //hide the ALA download button
        $("#downloads").hide();


        //add the Overview and download tab
        $('ul[data-tabs="tabs"]').append('<li><a id="t7" href="#overview" data-toggle="tab">Overview and download</a></li>');
        $('#t7').on('shown.bs.tab', function (e) {
            var tab = e.currentTarget.hash.substring(1);
            amplify.store('search-tab-state', tab);
            location.hash = 'tab_' + tab;
        });
        if (location.hash === '' && amplify.store('search-tab-state') === 'overview') {
            $('.nav-tabs a[href="#overview"]').tab('show');
        }

        var url = new URL(document.location.href);
        var sort = url.searchParams.get("sort");
        if (!sort) {
            $('select#sort').val('occurrence_date');
        }

        var dir = url.searchParams.get("dir");
        if (!dir) {
            $('select#dir').val('desc');
        }



        fixActiveFilterLinks();

    }

    function fixActiveFilterLinks() {
        //This adds fq= to the "remove active filter" links. This replicates what happened in legacy code, which is a bug actually but
        //without it, you cannot remove the default filter fq=-occurrence_status%3A"absent"
        var activeFilterDivs = document.querySelectorAll('.activeFilters');

        for (var j = 0; j < activeFilterDivs.length; j++) {
            var activeFilterDiv = activeFilterDivs[j];
            if (activeFilterDiv.textContent.includes("Selected filters")) {
                var links = activeFilterDiv.querySelectorAll('a');

                for (var i = 0; i < links.length; i++) {
                    var link = links[i];
                    var href = link.getAttribute('href');

                    if (href.includes('?')) {
                        link.setAttribute('href', href + '&fq=');
                    } else {
                        link.setAttribute('href', href + '?fq=');
                    }
                }
            }
        }
    }

    function customise_occurrence_show_page() {
        if (!$('body.occurrence-record').length) { //unique identifier for show page.
            return;
        }

        $.getScript(jsFileLocation + '/show-override.js');

        $('#showPassedPropResult').on('click', function (e) {
            $('.passedPropResult').toggle();
        });

        $('h1:not(.added)').remove();
        var origHtml = $("#recordHeadingLine2").html();
        $("#recordHeadingLine2").html('<h1 class="added"><span style="font-size: 75%">' +
            '<i id="userAnnotationsNavFlagTitle" class="glyphicon glyphicon-flag" style="color:red;display:none;margin-right:4px"></i>' +
            origHtml + (NBN.recordIsAbsent ? ' | ABSENT' : '') + '</span></h1>');

        $('#userAssertionStatusSelection').append('<option value="50006">' + NBN.userAssertions50006Label + '</option>');

        $('#copyRecordIdToClipboard-parent').hide();
        $(".copyLink").hide();

        //hide: Show/Hide xx passed properties
        $('#showPassedPropResult').hide();
        $('.missingPropResult').hide();


    }

    $(".accessControlHelpLink").popover({
        html: true,
        trigger: "click",
        title: function () {
            return "Location is sensitive";
        },
        content: function () {
            var dataProviderUid = $(this).data("dataprovideruid");
            var publicResolutionInMeters = $(this).data("publicresolutioninmeters");
            var dataProviderName = $(this).data("dataprovidername");
            var content = "Location has been generalised to " + publicResolutionInMeters + "m. To gain access to the supplied resolution, please contact the Data Provider: " +
                "<a href='https://registry.legacy.nbnatlas.org/public/show/" + dataProviderUid +
                "' target='_blank' title='More details on the data provider page'>" + dataProviderName + "</a>";

            return content;
        }
    }).click('click', function (e) { e.preventDefault(); });

})

function refreshSavedSearchesList() {
    var listHtml = savedSearches.map(search => `
        <li class="list-group-item" data-id="${search.id}">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="mb-0">${search.name}</h5>
                    <small class="text-muted">${search.query}</small>
                </div>
                <div class="btn-group" role="group">
                    <button class="btn btn-sm btn-light edit-search" title="Edit"><i class="fa fa-pencil"></i></button>
                    <button class="btn btn-sm btn-light delete-search" title="Delete"><i class="fa fa-trash"></i></button>
                    <button class="btn btn-sm btn-light apply-search" title="Apply Search"><i class="fa fa-search"></i></button>
                </div>
            </div>
        </li>
    `).join('');

    $('#savedSearchesList').html(listHtml);
}

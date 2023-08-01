
if (typeof jQuery !== 'undefined') {
	(function($) {
		$('#spinner').ajaxStart(function() {
			$(this).fadeIn();
		}).ajaxStop(function() {
			$(this).fadeOut();
		});
	})(jQuery);
}

$( document ).ready(function() {
	var jsFileLocation = $('script[src*="/assets/application.js"]').attr('src');
	jsFileLocation = jsFileLocation.substring(0,jsFileLocation.lastIndexOf("/"));
	$.getScript(jsFileLocation+'/application-last.js');

	// //temp fix only needed for 7 days - so can be removed
	// var userFacets = $.cookie("user_facets_new");
	// if (userFacets) {
	// 	$.cookie("user_facets_new", userFacets, { expires: 7 });
	// 	$.removeCookie('user_facets_new');
	// 	document.location.reload(true);
	// }
	// //end temp fix


	 //add more options to radius drop downs, e.g like the one on exploreYourArea
	 if ($('select#radius')){
		 var radiusSelect = $('select#radius');
		 radiusSelect.children("option").eq(0).before($("<option></option>").val(0.1).text("0.1"));
		 radiusSelect.children("option").eq(1).before($("<option></option>").val(0.5).text("0.5"));
		 radiusSelect.children("option").eq(3).before($("<option></option>").val(2).text("2"));

		 var url = new URL(document.location.href);
		 var radius = url.searchParams.get("radius");
		 if (radius){
			 $('select#radius').val(radius);
			 //note: this selection gets overwritten in exploreYourArea.js function bookmarkedSearch
		 }
	 }

	 customise_occurrence_home_page();

	 customise_occurrence_show_page();

	 customise_occurrence_list_page();

	customise_download_page();

	function customise_download_page() {
		$("#mydownloads").hide()
	}


	function customise_occurrence_home_page() {
		if (!$(".searchPage").length) { //unique identifier for home page.
			return;
		}

		$('#taxaUploadForm input[name=field]').val('taxon_names');
	}

	function customise_occurrence_list_page(){
		if (!$('#listHeader').length) { //unique identifier for list page.
			return;
		}
		$.getScript(jsFileLocation+'/search-override.js');

		//change style of the Customise filter button
		var customiseFilterButton = $('a[data-target="#facetConfigDialog"]');
		if (customiseFilterButton){
			customiseFilterButton.removeClass("btn-default");
			customiseFilterButton.removeClass("btn-sm");
			customiseFilterButton.addClass("btn-primary");
		}

		//hide the ALA download button
		$("#downloads").hide();

		//add the Overview and download tab
		$('ul[data-tabs="tabs"]').append('<li><a id="t7" href="#overview" data-toggle="tab">Overview and download</a></li>');
		$('#t7').on('shown.bs.tab', function(e) {
			var tab = e.currentTarget.hash.substring(1);
			amplify.store('search-tab-state', tab);
			location.hash = 'tab_' + tab;
		});
		if (location.hash === '' && amplify.store('search-tab-state') === 'overview'){
			$('.nav-tabs a[href="#overview"]').tab('show');
		}

		var url = new URL(document.location.href);
		var sort = url.searchParams.get("sort");
		if (!sort){
			$('select#sort').val('occurrence_date');
		}

		var dir = url.searchParams.get("dir");
		if (!dir){
			$('select#dir').val('desc');
		}
	}

	function customise_occurrence_show_page() {
		if (!$('body.occurrence-record').length) { //unique identifier for show page.
			return;
		}

		$.getScript(jsFileLocation+'/show-override.js');

		$('#showPassedPropResult').on('click', function(e){
			$('.passedPropResult').toggle();
		});

		$('h1:not(.added)').remove();
		var origHtml = $("#recordHeadingLine2").html();
		$("#recordHeadingLine2").html('<h1 class="added"><span style="font-size: 75%">'+
			'<i id="userAnnotationsNavFlagTitle" class="glyphicon glyphicon-flag" style="color:red;display:none;margin-right:4px"></i>'+
			origHtml+(NBN.recordIsAbsent?' | ABSENT':'')+'</span></h1>');

		$('#userAssertionStatusSelection').append('<option value="50006">'+NBN.userAssertions50006Label+'</option>');
	}


})

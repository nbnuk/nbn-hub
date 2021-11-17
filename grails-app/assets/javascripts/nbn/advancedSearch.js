//= require jquery.cookie.js

$(document).ready(function() {




    var mySlider;
    $(document).ready(function() {

        function populateDataProviders(selectedDataProviderUID) {
            $.getJSON(DATA_PROVIDER_WS_URL, function(data) {
                if (data) {
                    $.each(data, function (i, item) {
                        $('#data-provider').append($('<option>',{
                            value: item.uid,
                            text : item.name
                        }));
                    });
                    initDataProviderUID(selectedDataProviderUID)

                }
            })
        }

        function populateViceCounty(selectedViceCountyName) {
            $.getJSON(VICE_COUNTY_WS_URL, function(data) {
                if (data) {
                    $.each(data, function (i, item) {
                        $('#vice-county').append($('<option>', {
                            value: item.name,
                            text : item.name
                        }));
                    });
                    initViceCountyName(selectedViceCountyName)
                }
            })
        }

        $('#t2').click(function(){
            //This is a fix to get the slider to render properly when the form first becomes visible
            setTimeout(function(){
                    mySlider.sliderLeft = document.getElementById("yearRangeSlider").getBoundingClientRect().left;
                    mySlider.sliderWidth = document.getElementById("yearRangeSlider").clientWidth;
                    mySlider.updateScale();
                }
                ,500);

        });

        $('#advancedSearchForm').on('reset', function(){
            resetAll();
            return true;
        })

        function resetAll() {
            $('#occurrenceID').val('');
            $('#eventID').val('');
            $('#collectionCode').val('');
            initDateType('ANY');
            initLicenceType('ALL');
            $.cookie("advanced_search_form_state",null)
        }



            function initYearRangeSlider(){
            if (typeof mySlider == 'undefined') {
                mySlider = new rSlider({
                    target: '#slider',
                    values: {min:1600, max:(new Date()).getFullYear()},
                    step:1,
                    range: true, // range slider
                    scale:false,
                    tooltip:true,
                    disabled:true,
                    labels:false,
                });
            }
            else{
                mySlider.setValues(1600, (new Date()).getFullYear());
            }
        }

        $('input[type=radio][name=dateType]').click(function(){

            initDateType($('input:radio[name=dateType]:checked').val())

        });

        function initDateType(dateType, yearRange){

            $("[name=dateType][value="+dateType+"]").prop("checked", true);

            if ("ANY" == dateType){
                initSpecificDate(false);
                initYearRange(false,[1600,(new Date()).getFullYear()]);
            }
            else if ("SPECIFIC_DATE" == dateType){
                initSpecificDate(true);
                initYearRange(false,[1600,(new Date()).getFullYear()]);
            }
            else{
                initSpecificDate(false);
                initYearRange(true, yearRange);
            }
        }

        function initSpecificDate(enabled) {
            $('input[name=year]').prop('disabled', !enabled);
            $('input[name=month]').prop('disabled', !enabled);
            $('input[name=day]').prop('disabled', !enabled);
        }

        function initYearRange(enabled, yearRange) {
            if (mySlider) {
                mySlider.setValues(yearRange[0], yearRange[1]);
                mySlider.disabled(!enabled);
            }
        }


        $('input[type=radio][name=licenceType]').click(function(){
            initLicenceType($('input:radio[name=licenceType]:checked').val())
        });

        function initLicenceType(licenceType){
            $("[name=licenceType][value="+licenceType+"]").prop("checked", true);

            if ("SELECTED" == licenceType){
                $('#select_licence').show();
            }
            else {
                $('#select_licence').hide();
            }
        }

        function initDataProviderUID(dataProviderUID) {
            $("#data-provider").val(dataProviderUID);
        }

        function initViceCountyName(viceCountyName) {
            $("#vice-county").val(viceCountyName);
        }

        $( "#advancedSearchForm" ).submit(function( event ) {
            var yearRange = mySlider.getValue().split(",");
            var formState = {
                "licenceType:":$('input:radio[name=licenceType]:checked').val(),
                "dateType":$('input:radio[name=dateType]:checked').val(),
                "yearRange":[parseInt(yearRange[0]),parseInt(yearRange[1])],
                "dataProviderUID":$('#data-provider').children("option:selected").val(),
                "viceCountyName":$('#vice-county').children("option:selected").val()
            }

            $.cookie("advanced_search_form_state",JSON.stringify(formState));

            return true;
        });


        function init(){
            initYearRangeSlider();
            initLicenceType("ALL");
            initDateType("ANY");
            var cookieValue = $.cookie("advanced_search_form_state");
            var dataProvider = "";
            var viceCountyName = "";
            if (cookieValue){
                var formState = JSON.parse(cookieValue);
                initLicenceType(formState.licenceType?formState.licenceType:"ALL");

                initDateType(formState.dateType?formState.dateType:"SPECIFIC_DATE",
                     formState.yearRange?formState.yearRange:[1600,(new Date()).getFullYear()]);
                dataProvider = formState.dataProviderUID?formState.dataProviderUID:"";
                viceCountyName = formState.viceCountyName?formState.viceCountyName:""
            }

            populateDataProviders(dataProvider);
            populateViceCounty(viceCountyName);

        }

        resetAll();
        init();


    });



});
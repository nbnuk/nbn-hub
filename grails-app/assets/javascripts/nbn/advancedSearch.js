
$(document).ready(function() {




    var mySlider;
    $(document).ready(function() {

        function sortJSON(arr, key, ascending) {
            return arr.sort(function(a, b) {
                var x = a[key];
                var y = b[key];
                if (ascending) {
                    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                }
                else{
                    return ((x > y) ? -1 : ((x < y) ? 1 : 0));
                }
            });
        }



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
                    var sortedData = sortJSON(data,"name", true);
                    $.each(sortedData, function (i, item) {
                        $('#vice-county').append($('<option>', {
                            value: item.name,
                            text : item.name
                        }));
                    });
                    initViceCountyName(selectedViceCountyName)
                }
            })
        }


        function populateViceCountyIreland(selectedViceCountyIrelandName) {
            $.getJSON(VICE_COUNTY_IRELAND_WS_URL, function(data) {
                if (data) {
                    var sortedData = sortJSON(data,"name", true);
                    $.each(sortedData, function (i, item) {
                        $('#vice-county-ireland').append($('<option>', {
                            value: item.name,
                            text : item.name
                        }));
                    });
                    initViceCountyIrelandName(selectedViceCountyIrelandName)
                }
            })
        }

        function populateNorthernIrelandCountyBoundary(selectedNortherIrelandCountyBoundaryName) {
            $.getJSON(NORTHERN_IRELAND_COUNTY_BOUNDARY_WS_URL, function(data) {
                if (data) {
                    var sortedData = sortJSON(data,"name", true);
                    $.each(sortedData, function (i, item) {
                        $('#northernireland-county-boundary').append($('<option>', {
                            value: item.name,
                            text : item.name
                        }));
                    });
                    initNorthernIrelandCountyBoundaryName(selectedNortherIrelandCountyBoundaryName)
                }
            })
        }


        function populateLerc(selectedLercName) {
            $.getJSON(LERC_WS_URL, function(data) {
                if (data) {
                    $.each(data, function (i, item) {
                        $('#lerc').append($('<option>',{
                            value: item.name,
                            text : item.name
                        }));
                    });
                    initLercName(selectedLercName)

                }
            })
        }

        $('#t2').click(function(){

            //This is a fix to get the slider to render properly when the form first becomes visible
            setTimeout(function(){
                    mySlider.sliderLeft = document.getElementById("yearRangeSlider").getBoundingClientRect().left;
                    mySlider.sliderWidth = document.getElementById("yearRangeSlider").clientWidth;
                    mySlider.updateScale();
                    mySlider.onResize();
                }
                ,500);

        });

        $('#advancedSearchForm').on('reset', function(){
            resetAll();
            return true;
        })

        function resetAll() {
            $('#occurrenceID').val('');
            initDateType('ANY');
            initLicenceType('ALL');
            initLercName("");
            initViceCountyName("");
            initViceCountyIrelandName("");
            initNorthernIrelandCountyBoundaryName("");
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

        function  initDateType(dateType, yearRange){

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
                initYearRange(true, yearRange?yearRange:[1600,(new Date()).getFullYear()]);
            }
        }

        function initSpecificDate(enabled) {
            $('input[name=year]').prop('disabled', !enabled);
            $('input[name=month]').prop('disabled', !enabled);
            $('input[name=day]').prop('disabled', !enabled);
        }

        function initYearRange(enabled, yearRange) {
            if (mySlider && yearRange) {
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
            if (dataProviderUID) {
                $("#data-provider").val(dataProviderUID);
            }
        }

        function initLercName(lercName) {
            if (lercName) {
                $("#lerc").val(lercName);
            }
        }


        function initViceCountyName(viceCountyName) {
            if (viceCountyName) {
                $("#vice-county").val(viceCountyName);
            }
        }

        function initViceCountyIrelandName(viceCountyIrelandName) {
            if (viceCountyIrelandName) {
                $("#vice-county-ireland").val(viceCountyIrelandName);
            }
        }

        function initNorthernIrelandCountyBoundaryName(northernIrelandCountyBoundaryName) {
            if (northernIrelandCountyBoundaryName) {
                $("#northernireland-county-boundary").val(northernIrelandCountyBoundaryName);
            }
        }



        function validate() {
            var isValid = true
            //NOT needed. Can now search on day only
            // $('div.specific_date_input').removeClass('has-error');
            // $('#specific_date_input_error').removeClass("hidden");
            // $('#specific_date_input_error').addClass("hidden");
            // if ("SPECIFIC_DATE"==$('input:radio[name=dateType]:checked').val()) {
            //     if ($('input[name=day]').val() &&
            //         !($('input[name=month]').val() && $('input[name=year]').val())) {
            //         $('div.specific_date_input').addClass('has-error');
            //         $('#specific_date_input_error').removeClass("hidden");
            //         isValid =  false;
            //     }
            // }
            return isValid
        }

        $( "#advancedSearchForm" ).submit(function( event ) {
            if (!validate()) {
                event.preventDefault();
                return false;
            }

            return true;
        });


        function init(){
            initYearRangeSlider();

            initLicenceType("ALL");
            initDateType("ANY");

            populateDataProviders();
            populateViceCounty();
            populateViceCountyIreland();
            populateNorthernIrelandCountyBoundary();
            populateLerc();

        }

        // resetAll();
        init();


    });



});
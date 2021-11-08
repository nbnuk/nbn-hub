//= require jquery.cookie.js

$(document).ready(function() {
    $('.combobox').combobox({bsVersion: '3'});

    var mySlider;
    $(document).ready(function() {console.log("document load");console.log($('input[type=radio][name=dateType]').val());





        function initYearRangeSlider(){
            if (typeof mySlider == 'undefined') {console.log("!!!!!!!!!!!!!!!!!!!!!!!!!!slider undefined");
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

        function initDateType(dateType, yearRange){console.log("initDateType dateType:"+dateType);
            console.log(yearRange);
            $("[name=dateType][value="+dateType+"]").prop("checked", true);

            if ("SPECIFIC_DATE" == dateType){
                mySlider.disabled(true);
                $('input[name=year]').prop('disabled', false);
                $('input[name=month]').prop('disabled', false);
                $('input[name=day]').prop('disabled', false);
            }
            else{
                mySlider.disabled(false);
                if (yearRange){
                    mySlider.setValues(yearRange[0], yearRange[1]);
                    $('input[name=year]').prop('disabled', true);
                    $('input[name=month]').prop('disabled', true);
                    $('input[name=day]').prop('disabled', true);
                }
            }
        }


        $('input[type=radio][name=licenceType]').click(function(){

            initLicenceType($('input:radio[name=licenceType]:checked').val())

        });

        function initLicenceType(licenceType){ console.log(" licenceType:"+licenceType);
            $("[name=licenceType][value="+licenceType+"]").prop("checked", true);

            if ("SELECTED" == licenceType){
                $('#select_licence').show();
            }
            else {
                $('#select_licence').hide();
            }
        }

        $( "#advancedSearchForm" ).submit(function( event ) {
            var yearRange = mySlider.getValue().split(",");
            var formState = {
                "licenceType:":$('input:radio[name=licenceType]:checked').val(),
                "dateType":$('input:radio[name=dateType]:checked').val(),
                "yearRange":[parseInt(yearRange[0]),parseInt(yearRange[1])]
            }


            $.cookie("advanced_search_form_state",JSON.stringify(formState));
            console.log( "formState: "+formState );
            return true;
        });


        function init(){console.log("..............init()");
            initYearRangeSlider();
            var cookieValue = $.cookie("advanced_search_form_state");
            console.log(cookieValue);
            if (cookieValue){
                var formState = JSON.parse(cookieValue);
                console.log(formState);

                initLicenceType(formState.licenceType?formState.licenceType:"ALL");

                initDateType(formState.dateType?formState.dateType:"SPECIFIC_DATE",
                    formState.yearRange?formState.yearRange:[1600,(new Date()).getFullYear()]);
            }

        }

        init();

        function getDateType(formState){
            formState?.[1]?formState[1].split(":")[1]:"SPECIFIC_DATE"
        }

        function getYearRange(formState){
            var yearRangeState = formState[2]; //yearRange:1832,2010
            var yearRangeAsStr = yearRangeState.split(":")[1].split(",");
            var yearRange =[parseInt(yearRangeAsStr[0]),parseInt(yearRangeAsStr[1])]
        }


    });

});
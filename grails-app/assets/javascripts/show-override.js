

function updateDeleteEvents(enableDelete, disableDelete){

    for(var i = 0; i < enableDelete.length; i++){
        console.log(i);
        $('#userAnnotation_' + enableDelete[i] + ' .deleteAnnotation').off("click");
        $('#userAnnotation_' + enableDelete[i] + ' .deleteAnnotation').click({rec_uuid: OCC_REC.recordUuid, qa_uuid: enableDelete[i]}, deleteAssertionPrompt);

        /*
        $('#userAnnotation_' + enableDelete[i] + ' .deleteAnnotation').on("click", function (e) {
            e.preventDefault();
            console.log(e.data);
            var isConfirmed = confirm('Are you sure you want to delete this flagged issue?');
            if (isConfirmed === true) {
                $('#' + enableDelete[i] + ' .deleteAssertionSubmitProgress').css({'display':'inline'});
                console.log(OCC_REC);
                console.log(enableDelete[i]);
                console.log(i);
                console.log(enableDelete);
                deleteAssertion(OCC_REC.recordUuid, enableDelete[i]);
            }
        });
        */
        updateVerificationEvents(enableDelete[i]);
    }

    for(var i = 0; i < disableDelete.length; i++){
        $('#userAnnotation_' + disableDelete[i] + ' .deleteAnnotationButton').attr('disabled', 'disabled');
        $('#userAnnotation_' + disableDelete[i] + ' .deleteAnnotationButton').attr('title', 'Unable to delete, as this assertion has a verification');


        $('#userAnnotation_' + disableDelete[i] + ' .deleteAnnotation').off("click");
        $('#userAnnotation_' + disableDelete[i] + ' .deleteAnnotation').on("click", function (e) {
            e.preventDefault();
        });
        updateVerificationEvents(disableDelete[i]);
    }

}

/**
 * Override
 * Load and display the assertions for this record
 */
function refreshUserAnnotations(){

    if (!NBN.showFlaggedIssues) {
        $('#userAnnotationsDiv').hide('fast');
        return;
    }
    //console.log(OCC_REC.contextPath + "/assertions/" + OCC_REC.recordUuid);
    $.get( OCC_REC.contextPath + "/assertions/" + OCC_REC.recordUuid, function(data) {

        var flagRecordAsDodgy = false; //if it has any assertions with codes 50005 (unconfirmed) or 50001 (open, i.e. record is incorrect but not fixed yet) then set to true
        //because the 50005 doesn't seem to be adjusted when a verification is applied to that issue, we need to potentially remove these
        var flags = [];

        $.each(data.userAssertions, function( index, userAssertion ) {
            console.log(userAssertion);
            if (userAssertion.qaStatus == 50001 || userAssertion.qaStatus == 50005) {
                flags.push(userAssertion.uuid);
            }
        });
        console.log(flags);
        $.each(data.userAssertions, function( index, userAssertion ) {
            if ((userAssertion.qaStatus == 50002 || userAssertion.qaStatus == 50003 || userAssertion.qaStatus == 50000) && (userAssertion.relatedUuid > "")) {
                for (i = 0; i < flags.length; i++) {
                    if (flags[i] == userAssertion.relatedUuid) { flags.splice(i, 1); i-- }
                }
            }
        });
        console.log(flags);
        if (flags.length > 0) flagRecordAsDodgy = true;

        if (data.assertionQueries.length == 0 && data.userAssertions.length == 0) {
            $('#userAnnotationsDiv').hide('slow');
            $('#userAssertionsContainer').hide("slow");
            $('#userAnnotationsNav').css("display","none");
            $('#userAnnotationsNavFlag').css("display","none");
            $('#userAnnotationsNavFlagTitle').css("display","none");
        } else {
            $('#userAnnotationsDiv').show('slow');
            $('#userAssertionsContainer').show("slow");
            $('#userAnnotationsNav').css("display","block");
            if (flagRecordAsDodgy) {
                $('#userAnnotationsNavFlag').css("display","inline-block");
                $('#userAnnotationsNavFlagTitle').css("display","inline-block");
            }
        }
        $('#userAnnotationsList').empty();

        var userAssertionStatus = jQuery.i18n.prop("user_assertions." + data.userAssertionStatus);
        $("#userAssertionStatus").text(userAssertionStatus);

        for(var i=0; i < data.assertionQueries.length; i++){
            var $clone = $('#userAnnotationTemplate').clone();
            $clone.find('.issue').text(data.assertionQueries[i].assertionType);
            $clone.find('.user').text(data.assertionQueries[i].userName);
            $clone.find('.comment').text('Comment: ' + data.assertionQueries[i].comment);
            $clone.find('.created').text('Date created: ' + (moment(data.assertionQueries[i].createdDate).format('YYYY-MM-DD')));
            if(data.assertionQueries[i].recordCount > 1){
                $clone.find('.viewMore').css({display:'block'});
                $clone.find('.viewMoreLink').attr('href', OCC_REC.contextPath + '/occurrences/search?q=query_assertion_uuid:' + data.assertionQueries[i].uuid);
            }
            $('#userAnnotationsList').append($clone);
            $('#userAssertionsContainer').show("slow");
        }

        var verifiedAssertions = [];
        var disableDelete = [];
        var enableDelete = [];

        $.each(data.userAssertions, function( index, userAssertion ) {

            var $clone = $('#userAnnotationTemplate').clone();

            // if the code == 50000, then we have verification - so don't display here
            if (userAssertion.code != 50000) {
                $clone.prop('id', "userAnnotation_" + userAssertion.uuid);
                $clone.find('.issue').text(jQuery.i18n.prop(userAssertion.name));
                $clone.find('.user').text(userAssertion.userDisplayName);
                $clone.find('.comment').text('Comment: ' + userAssertion.comment);
                $clone.find('.userRole').text(userAssertion.userRole != null ? userAssertion.userRole : '');
                $clone.find('.userEntity').text(userAssertion.userEntityName != null ? userAssertion.userEntityName : '');
                $clone.find('.created').text('Date created: ' + (moment(userAssertion.created, "YYYY-MM-DDTHH:mm:ssZ").format('YYYY-MM-DD HH:mm:ss')));
                if (userAssertion.userRole != null) {
                    $clone.find('.userRole').text(', ' + userAssertion.userRole);
                }
                if (userAssertion.userEntityName != null) {
                    $clone.find('.userEntity').text(', ' + userAssertion.userEntityName);
                }

                //if the current user is the author of the annotation, they can delete
                //new: the collection admin can also delete
                console.log(OCC_REC);
                if((OCC_REC.userId == userAssertion.userId) || NBN.isCollectionAdmin){
                    $clone.find('.deleteAnnotation').css({display:'block'});
                    $clone.find('.deleteAnnotation').attr('id', userAssertion.uuid);
                } else {
                    $clone.find('.deleteAnnotation').css({display:'none'});
                }

                //display the verification button,
                $clone.find('.verifyAnnotation').css({display:'block'});
                $clone.find('.verifyAnnotation').attr('id', "verifyAnnotations_" +userAssertion.uuid);

                $clone.find(".verifications").hide();

                $('#userAnnotationsList').append($clone);
            } else {
                //this is a verification assertion, so it needs to be embedded in existing assertion
                verifiedAssertions.push(userAssertion);
                // if an assertion has a verification, disable the delete button
                if (disableDelete.indexOf(userAssertion.relatedUuid) < 0) {
                    disableDelete.push(userAssertion.relatedUuid);
                }
            }
        });

        //display verified
        var sortedVerifiedAssertion = verifiedAssertions.sort(compareModifiedDate);
        for(var i = 0; i < sortedVerifiedAssertion.length; i++){

            var $clone = $('#userVerificationTemplate').clone();
            $clone.prop('id', "userVerificationAnnotation_" + sortedVerifiedAssertion[i].uuid);
            var qaStatusMessage = jQuery.i18n.prop("user_assertions." + sortedVerifiedAssertion[i].qaStatus);
            $clone.find('.qaStatus').text(qaStatusMessage);
            $clone.find('.comment').text(sortedVerifiedAssertion[i].comment);
            $clone.find('.userDisplayName').text(sortedVerifiedAssertion[i].userDisplayName);
            $clone.find('.created').text((moment(sortedVerifiedAssertion[i].created, "YYYY-MM-DDTHH:mm:ssZ").format('YYYY-MM-DD HH:mm:ss')));

            //add the verification, and show the table
            $('#userAnnotationsList').find('#userAnnotation_' + sortedVerifiedAssertion[i].relatedUuid + " table.verifications tbody").append($clone);
            $('#userAnnotationsList').find('#userAnnotation_' + sortedVerifiedAssertion[i].relatedUuid + " table.verifications").show();
            updateDeleteVerificationEvents(sortedVerifiedAssertion[i].relatedUuid)
        }

        for(var i = 0; i < disableDelete.length; i++) {
            var $cloneHeader = $('#userVerificationTemplate').clone();
            $cloneHeader.prop('id', "userVerificationAnnotationHeader_" + disableDelete[i]);
            $cloneHeader.find('.qaStatus').text("User Verification Status");
            $cloneHeader.find('.comment').text("Comment");
            $cloneHeader.find('.userDisplayName').text("Verified By");
            $cloneHeader.find('.created').text("Created");
            $cloneHeader.find('.deleteVerification').html('Delete this Verification');
            $cloneHeader.css({display: 'block'});
            ($cloneHeader).insertAfter('#userAnnotation_' + disableDelete[i] + ' .userVerificationClass .userVerificationTemplate:first')
        }

        for(var i = 0; i < data.userAssertions.length; i++){
            if ((data.userAssertions[i].code != 50000) && (disableDelete.indexOf(data.userAssertions[i].uuid) < 0)) {
                enableDelete.push (data.userAssertions[i].uuid);
            }
        }

        updateDeleteEvents(enableDelete, disableDelete);
    });
}

refreshUserAnnotations();
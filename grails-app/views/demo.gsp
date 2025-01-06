<!doctype html>
<html>
<head>
    <meta name="layout" content="ala"/>
    <title>Demo</title>
    <asset:javascript src="nbn-savedsearch-web-components.js"/>
</head>
<body>
<content tag="nav">

</content>



<div id="content" role="main">
    <div class="container">
        <section class="row colset-2-its">
            <h1>Saved Search Component Demo</h1>

            <div role="navigation">
                <h2>List saved searches -  modal and button</h2>
                <div hx-get="/crossDomainProxy?url=http://localhost:8080/component/listModal?proxy=http://localhost:8085/crossDomainProxy" hx-trigger="load">

                </div>

                <h2>Create save search -  modal and button</h2>
                <div hx-get="/crossDomainProxy?url=http://localhost:8080/component/createModal" hx-trigger="load">

                </div>

%{--                <h2>List of saved searches - button and modal</h2>--}%

%{--                <div id="hmj" hx-get="/crossDomainProxy?url=http://localhost:8080/component/listModal" hx-trigger="load">--}%

%{--                </div>--}%

%{--                <h2>Save search - button and modal</h2>--}%
%{--                <div hx-get="/crossDomainProxy?url=http://localhost:8080/component/createModal" hx-trigger="load">--}%

%{--                </div>--}%



%{--                <h2>Save search web component</h2>--}%
%{--                <savedsearch-create-modal></savedsearch-create-modal>--}%
%{--                <savedsearch-create-modal component-service-url="https://savedsearch.nbnatlas.org"></savedsearch-create-modal>--}%
%{--                <savedsearch-create-modal component-service-url="https://records.nbnatlas.org/crossDomainProxy?url=https://savedsearch.nbnatlas.org"></savedsearch-create-modal>--}%

                <hr/>
%{--                <h2>Inject Save search web component</h2>--}%
%{--                The html below is where we want to inject the web component--}%
%{--                <div id="download-button-area" class="pull-right" >--}%
%{--                    <a href="#CopyLink" data-toggle="modal" role="button" class="tooltips btn copyLink" title="${g.message(code:"list.copylinks.dlg.copybutton.title")}"><i class="fa fa-file-code-o" aria-hidden="true"></i>&nbsp;&nbsp;<g:message code="list.copylinks" default="API"/></a>--}%
%{--                </div>--}%
%{--                <script>--}%
%{--                    window.onload = function() {--}%
%{--                        document.querySelector('#download-button-area .btn:first-child').insertAdjacentHTML('beforebegin', '<savedsearch-create-modal></savedsearch-create-modal>');--}%
%{--                    };--}%
%{--                </script>--}%

            </div>
        </section>
    </div>
</div>
%{--<script>--}%
%{--    document.body.addEventListener('htmx:afterSwap', function (event) {console.log("-------333333333");--}%
%{--        // Check if the swapped content contains the modal--}%
%{--        if (event.target.id === 'hmj') {--}%
%{--            console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!Modal content swapped into the DOM');--}%

%{--            // Add the event listener to the modal--}%
%{--            const modal = document.getElementById('savedSearch-listModalAndMenuButtonComponent');--}%
%{--            modal.addEventListener('show.bs.modal', function () {--}%
%{--                console.log('------------Modal shown');--}%
%{--                const target = document.getElementById('savedSearch-listInner');--}%
%{--                htmx.trigger(target, 'htmx:load');--}%
%{--            });--}%
%{--        }--}%
%{--    });--}%
%{--</script>--}%
</body>
</html>

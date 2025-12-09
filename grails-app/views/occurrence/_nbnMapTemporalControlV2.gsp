<script type="application/javascript">
    BC_CONF.groupedFacetsMap= ${(groupedFacetsMap as grails.converters.JSON).toString().encodeAsRaw()}
</script>


<div id="nbnTemporalToolbar"   aria-label="Timeline Control" style="display:none;" class="panel panel-default" data-temporal-control="main">
    <div class="panel-heading" style="padding: 0px">
        <div class="row">
            <div class="col-xs-8">
                <!-- Tabs -->
                <ul class="nav nav-pills nav-sm" role="tablist" >
                    <li role="presentation" class="active">
                        <a href="#year-tab" data-toggle="tab">Year</a>
                    </li>
                    <li role="presentation">
                        <a href="#month-tab" data-toggle="tab">Seasonal</a>
                    </li>
                </ul>
            </div>
            <div class="col-xs-4 text-right">
                <a id="resetMap" href="#" class="btn btn-link btn-sm">Close and reset map <i class="fa fa-times" aria-hidden="true"></i></a>
            </div>
        </div>
    </div>
    <div class="panel-body" >
    <div class="tab-content" style="padding-bottom:0px;padding-top:0px">
        <div id="year-tab" role="tabpanel" class="tab-pane active" >
<g:if test="${sr.activeFacetObj.year}">
    <div class="alert alert-warning" role="alert">
        Remove the year filter to explore changes over years.
    </div>
</g:if>
<div <g:if test="${sr.activeFacetObj.year}">style="display:none"</g:if>>

<div data-setting-panel="true" style="min-height: 80px;">
    <div class="row" style="display:flex; justify-content: center; margin-bottom:15px" >
        <label class="radio-inline">
            <input type="radio" name="which_months" value="all" checked> All months
        </label>
        <label class="radio-inline">
            <input type="radio" name="which_months" value="selected"> Select months
        </label>
    </div>

    <div id="year_month" class="row" style="display:flex; justify-content: center;">
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="1" disabled> Jan
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="2" disabled> Feb
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="3" disabled> Mar
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="4" disabled> Apr
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="5" disabled> May
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="6" disabled> Jun
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="7" disabled> Jul
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="8" disabled> Aug
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="9" disabled> Sep
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="10" disabled> Oct
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="11" disabled> Nov
        </label>
        <label class="checkbox-inline">
            <input type="checkbox" name="year_month" value="12" disabled> Dec
        </label>

    </div>

</div>
            <div class="row" style="display: flex; flex-wrap: wrap; align-items: flex-end;">
                <!-- Slider + labels -->
                <div class="col-xs-12 col-sm-12 col-md-6"  style="margin-bottom: 10px; ">
                <input data-slider="range" type="text" style="margin: 10px 0;"/>


                </div>


                <div class="col-xs-12 col-sm-12 col-md-3" style="margin-bottom: 10px; ">
                    <div class="row">
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm tooltips" title="Year interval">
                                <span class="input-group-addon">Step</span>
                                <input type="number" class="form-control"
                                       min="1" max="100" value="1" data-setting="step" style="min-width:55px;">
                            </div>
                        </div>
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm">
                                <span class="input-group-addon">Speed</span>
                                <input type="number" class="form-control"
                                       min="0.5" max="10" step="0.5" value="1" data-setting="speed" style="min-width:55px;">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Playback buttons -->
                <div class="col-xs-12 col-sm-12 col-md-3"  style="margin-bottom: 10px; ">
                    <div class="btn-group btn-group-justified" role="group" aria-label="Playback controls" style="white-space: nowrap;">
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="rewind" title="Restart"><i class="fa fa-fast-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="backward" title="Back"><i class="fa fa-step-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-success btn-sm" data-control="play" title="Play"><i class="fa fa-play"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-warning btn-sm" data-control="pause" title="Pause"><i class="fa fa-pause"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="forward" title="Forward"><i class="fa fa-step-forward"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>
        <div id="month-tab" role="tabpanel" class="tab-pane" >
            <g:if test="${sr.activeFacetObj.month}">
                <div class="alert alert-warning" role="alert">
                    Remove the month filter to explore changes of selected months over time.
                </div>
            </g:if>
            <div <g:if test="${sr.activeFacetObj.month}">style="display:none"</g:if>>
                <div style="min-height: 80px;" data-setting-panel="true">
                <div  class="row" style="display:flex; justify-content: center; margin-bottom:15px;" >

                        <button type="button" class="btn btn-default" name="season" value="Winter">Winter</button>

                        <button type="button" class="btn btn-default" name="season" value="Spring">Spring</button>

                        <button type="button" class="btn btn-default" name="season" value="Summer">Summer</button>

                        <button type="button" class="btn btn-default" name="season" value="Autumn">Autumn</button>



                </div>
                </div>
            <div class="row" style="display: flex; flex-wrap: wrap; align-items: flex-end;">
                <!-- Slider + labels -->
                <div class="col-sm-12 col-md-6"  style="margin-bottom: 10px; ">
                <input data-slider="range" type="text" style="margin: 10px 0;"/>

                </div>


                <div class="col-sm-12 col-md-3" style="margin-bottom: 10px; ">
                    <div class="row">
                        <div class="col-xs-6">
                            <input type="hidden" data-setting="step" value="1"/>
%{--                            <div class="input-group input-group-sm">--}%
%{--                                <span class="input-group-addon">Step</span>--}%
%{--                                <input type="number" class="form-control"--}%
%{--                                       min="1" max="12" value="1" data-setting="step" >--}%
%{--                            </div>--}%
                        </div>
                        <div class="col-xs-6">
                            <div class="input-group input-group-sm">
                                <span class="input-group-addon">Speed</span>
                                <input type="number" class="form-control"
                                       min="0.5" max="10" step="0.1" value="1" data-setting="speed">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Playback buttons -->
                <div class="col-sm-12 col-md-3"  style="margin-bottom: 10px; ">
                    <div class="btn-group btn-group-justified" role="group" aria-label="Playback controls" style="white-space: nowrap;">
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="rewind" title="Restart"><i class="fa fa-fast-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="backward" title="Back"><i class="fa fa-step-backward"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-success btn-sm" data-control="play" title="Play"><i class="fa fa-play"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-warning btn-sm" data-control="pause" title="Pause"><i class="fa fa-pause"></i></button>
                        </div>
                        <div class="btn-group" role="group">
                            <button type="button" class="btn btn-default btn-sm" data-control="forward" title="Forward"><i class="fa fa-step-forward"></i></button>
                        </div>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </div>
    </div>
</div>
<!-- Progress bar -->
<div class="progress" style="margin-bottom:0px">
    <div data-temporal-progress="current" class="progress-bar" role="progressbar"
         aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
        <span data-temporal-control="current">-</span>
    </div>
</div>

<asset:stylesheet src="nbn/ion.rangeSlider.min.css" />
<asset:javascript src="nbn/ion.rangeSlider.min.js" />

<asset:script type="text/javascript">
    class TemporalControl {
        constructor(selector, mode) {
            this.container = $(selector);


            this.mode = mode;
            this.monthNames = [
                'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov'
            ];

            this.init();

        }
        init(){
            this.isPlaying = false;
            this.setupSlider();
            this.bindEvents();
            // this.currentValue = this.sliderApi.result.from;
            this.step = 1;
            this.speed = 1000;
            this._refreshState(true)
        }

        getControl(type) {
            return this.container.find('[data-control="' + type + '"]');
        }

        getSetting(type) {
            return this.container.find('[data-setting="' + type + '"]');
        }

        getDisplay(type) {
            return this.container.find('[data-display="' + type + '"]');
        }

        displayCurrentValue() {
            if (this.mode === 'seasonal') {
                var monthName = this.monthNames[this.currentValue];
                $('[data-temporal-control="current"]').text(monthName);
            } else {
                $('[data-temporal-control="current"]').text(this.currentValue);
            }
            const totalSteps = ((this.sliderApi.result.to - this.sliderApi.result.from) / this.step) + 1;
            const stepsDone = ((this.currentValue - this.sliderApi.result.from) / this.step) + 1;
            $('[data-temporal-progress="current"].progress-bar').css('width', (stepsDone / totalSteps) * 100+"%");
        }

        getSlider() {
            return this.container.find('[data-slider="range"]');
        }



        setupSlider() {
            if (this.mode === 'seasonal') {
                this.setupMonthSlider();
            } else {
                this.setupYearSlider();
            }
        }

        setupMonthSlider() {
            var self = this;

             this.sliderApi = this.getSlider().ionRangeSlider({
                  type: 'double',
                  skin: 'round',
                  values: this.monthNames,
                  min: 'Dec',
                  max: 'Nov',
                  from: '0',
                  to: '11',
                  step: 1,
                  onChange: (data) => {
                    this.currentValue = undefined;
                  }

                }).data('ionRangeSlider');


        }

        setupYearSlider() {
            var currentYear = new Date().getFullYear();
            var minAndMaxYears = this._getMinMaxYears();
            var self = this;

            this.sliderApi = this.getSlider().ionRangeSlider({
              type: 'double',
              skin: 'round',
              min:  minAndMaxYears.min,
              max:  minAndMaxYears.max,
              from: minAndMaxYears.min,
              to:   minAndMaxYears.max,
              step: 1,
              prettify_enabled: false,
              onChange: (data) => {
                this.currentValue = undefined;
              }
            }).data('ionRangeSlider');

        }

        bindEvents() {
            var self = this;
            this.getControl('play').click(function() { return self.play(); });
            this.getControl('pause').click(function() { return self.pause(); });
            this.getControl('rewind').click(function() { return self.rewind(); });
            this.getControl('forward').click(function() { return self.forward(); });
            this.getControl('backward').click(function() { return self.backward(); });
            if (this.mode === 'year'){
                $('input[name="which_months"]').change(function() {
                    if ($(this).val() === 'all') {
                        $('#year_month input').prop('disabled', true);
                    } else {
                        $('#year_month input').prop('disabled', false);

                    }
                });
            }

           if (this.mode === 'seasonal'){

                $('button[name="season"]').on( "click", function(e) {

                    const val = $(this).attr("value");

                    if (val === 'Spring') {
                        self.sliderApi.update({
                            from: '3',
                            to: '5'
                        });
                    } else if (val === 'Summer') {
                        self.sliderApi.update({
                            from: '6',
                            to: '8'
                        });
                    } else if (val === 'Autumn') {
                        self.sliderApi.update({
                            from: '9',
                            to: '11'
                        });
                    } else if (val === 'Winter') {
                        self.sliderApi.update({
                            from: '0',
                            to: '2'
                        });
                    }

                    self.currentValue = undefined;
                    self._debug("season clicked currentValue:"+self.currentValue);

                });
            }
        }

        _getPlayerSettings(){
            this.step = parseInt(this.getSetting('step').val());
            this.speed = parseFloat(this.getSetting('speed').val()) * 1000;
            this.year_month  = [];
            var self=this;
            if (this.mode === 'year'){
                this.year_month = [];
                if ($('input[name="which_months"]').filter(':checked').val() === 'selected') {
                    $('input[name="year_month"]:checked').each(function() {
                        self.year_month.push($(this).val());
                    });

                    if (self.year_month.length == 0) {
                        $('input[name="which_months"][value="all"]').prop('checked', true);
                        $('#year_month input').prop('disabled', true);
                    }
                }
            }

            if ($('input[name="which_months"]').filter(':checked').val() === 'selected' && this.year_month.length == 0 && this.mode === 'year') {
                this.year_month = [];
            }
            this._debug("step:"+this.step+" speed:"+this.speed+" year_month:"+this.year_month);
        }

        play() {
            if (this.isPlaying) {
                return;
            }

            this._getPlayerSettings();
            this._debug("play "+this.sliderApi.result.from+" "+this.sliderApi.result.to+" currentValue:"+this.currentValue);
            if (this.currentValue == undefined || this.currentValue ==  this.sliderApi.result.to){
                this.currentValue = this.sliderApi.result.from;
            }

            this.isPlaying = true;
            this._refreshState();
            $('#resetMap').show();

            this._loadMap();

        }

        forward(){
            this._debug("forward currentValue:"+this.currentValue);
            if (this.isPlaying || this.currentValue >= this.sliderApi.result.to) {
                return true;
            }
            $('#resetMap').show();
            this._getPlayerSettings();

            this._next();
            return true;
        }



        backward(){

            if (this.isPlaying || this.currentValue <= this.sliderApi.result.from) {
                return true;
            }

            this._getPlayerSettings();

            this._back();
            return true;
        }

        pause() {
            this.isPlaying = false;
            this._refreshState();
        }

         rewind() {

            this.currentValue = this.sliderApi.result.from;
            this._refreshState()

            this.displayCurrentValue();
            this.displayMapForValue();
        }

        _disableAllExceptPlayAndPause(disable){
            this.sliderApi.update({ disable: disable });
            this.getControl('rewind').prop('disabled', disable);
            this.getControl('backward').prop('disabled', disable);
            this.getControl('forward').prop('disabled', disable);
            this.container.find('[data-setting-panel] input, [data-setting-panel] button').prop('disabled', disable);
            if (this.mode === 'year' && $('input[name="which_months"]').filter(':checked').val() =='all'){
                        $('#year_month input').prop('disabled', true);
            }
            this.getSetting('step').prop('disabled', disable);
            this.getSetting('speed').prop('disabled', disable);
        }

        _refreshState(initialising = false) {
            this._debug("_refreshState");
            const maxValue = this.sliderApi.result.to;
            const minValue = this.sliderApi.result.from;
            this._debug("currentValue:"+this.currentValue+" minValue:"+minValue+" maxValue:"+maxValue);

            if (this.isPlaying) this.getControl("play").parent().hide(); else this.getControl("play").parent().show();
            if (this.isPlaying)  this.getControl("pause").parent().show(); else this.getControl("pause").parent().hide();

            this.getControl('backward').prop('disabled', this.currentValue == undefined || this.currentValue <= minValue?true:false);

            this.getControl('rewind').prop('disabled', this.currentValue == undefined || this.currentValue <= minValue?true:false);
            this.getControl('forward').prop('disabled', this.currentValue >= maxValue?true:false);
            if (!initialising){
                if (this.isPlaying){
                    this._disableAllExceptPlayAndPause(true);
                }
                else{
                    this._disableAllExceptPlayAndPause(false);
                }
            }

        }



        _playNext(){

            if (!this.isPlaying) {
                return;
            }
           this._next();
        }

        _next(){

            const maxValue = this.sliderApi.result.to;
            if (this.currentValue && this.currentValue >= maxValue){
                return;
            }

            if (this.currentValue == undefined){
                this.currentValue = this.sliderApi.result.from;
            }
            else{
                this.currentValue += this.step;
            }

            if (this.currentValue >= maxValue) {
                this.currentValue = maxValue;
            }
            if (this.currentValue >= maxValue){
                this.isPlaying = false;

            }

            this._refreshState();
            this._loadMap();
        }

        _back(){
            const minValue = this.sliderApi.result.from;
            if (this.currentValue <= minValue){
                return;
            }

            this.currentValue -= this.step;

            if (this.currentValue < minValue) {
                this.currentValue = minValue;
            }


            this._refreshState();
            this._loadMap();
        }



        _loadMap(){
            this.displayCurrentValue();
            this.displayMapForValue();
        }



        displayMapForValue() {
            this._debug("displayMapForValue currentValue:"+this.currentValue);
            if (this.mode === 'seasonal') {
                const month = this.currentValue==0 ? 12:this.currentValue;
                MAP_VAR.additionalFqs = '&fq=month:' + month;
                MAP_VAR.removeFqs = MAP_VAR.additionalFqs
                this._debug("show month MAP_VAR.additionalFqs: " + MAP_VAR.additionalFqs);
                addQueryLayer(true);
            } else {
                MAP_VAR.additionalFqs = '&fq=year:' + this.currentValue;
                if (this.year_month && this.year_month.length > 0){
                    MAP_VAR.additionalFqs += '&fq=month:(' + this.year_month.join(" OR ") + ')';
                }
                MAP_VAR.removeFqs = MAP_VAR.additionalFqs
                this._debug("show year MAP_VAR.additionalFqs: " + MAP_VAR.additionalFqs);
                addQueryLayer(true);
            }

            const layer = MAP_VAR.currentLayers[MAP_VAR.currentLayers.length-1];
            var self = this;
            layer.on('load', function () {
                setTimeout(function() {
                    self._playNext();
                }, self.speed);
            });
        }

        _getMinMaxYears(){
            var minYear = 1600;
            var maxYear = new Date().getFullYear();

            if (BC_CONF.groupedFacetsMap && BC_CONF.groupedFacetsMap.year) {
                var yearFacet = BC_CONF.groupedFacetsMap.year;
                var years = [];


                if (yearFacet.fieldResult && yearFacet.fieldResult.length > 0) {
                    years = yearFacet.fieldResult.map(function(item) {
                        return parseInt(item.label, 10);
                    }).filter(function(year) {
                        return !isNaN(year);
                    });
                }



                if (years.length > 0) {
                    var dataMinYear = Math.min.apply(Math, years);
                    var dataMaxYear = Math.max.apply(Math, years);

                    minYear = dataMinYear;
                    maxYear = dataMaxYear;
                }

            }
            this._debug('Min year:'+minYear+' ,axYear:'+maxYear);
            return {
                min:minYear,
                max:maxYear
            }

        }

        _debug(msg) {
            if (false) {
                if (msg != undefined){
                    console.log(msg);
                }
                else {
                    console.log(this);
                }
            }
        }


    }

    // Leaflet Control
    const LaunchTemporalLeafletControl = L.Control.extend({
        options: { position: 'topright' },
        onAdd: function(map) {
            const container = L.DomUtil.create('div', 'leaflet-control-layers');
            container.id = 'launchTemporalLeafletControl';
            container.title = "Enter Tooltip Here"
            container.innerHTML = '<a id="nbnTemporalControl" href="#" class="launchTemporalLeafletControl tooltips" title="Explore changes over time"><i class="fa fa-clock-o fa-lg"></i></a>';
            L.DomEvent.disableClickPropagation(container);
            return container;
        }
    });

    // Initialize
    $(document).ready(function() {

       window.nbnTemporalControlYear = new TemporalControl('#year-tab','year');
       window.nbnTemporalControlMonth = new TemporalControl('#month-tab','seasonal');

        // MAP_VAR.map.addControl(new LaunchTemporalLeafletControl());
        // $('#nbnTemporalControl').tooltip({ container: 'body', placement: 'left' });


    function resetMap() {
            $('[data-temporal-progress="current"].progress-bar').css('width', "0%");
                MAP_VAR.additionalFqs = '';
                MAP_VAR.removeFqs = ''
                addQueryLayer(true);
        }

    $('a#resetMap, a.reset-map-mode').click(function(e) {
        e.preventDefault();
            $('#nbnTemporalToolbar').slideUp();
            $('a.reset-map-mode').removeClass("reset-map-mode");
            resetMap();

            });



    $(document).on('click', '#nbnTemporalControl', function (e) {
            e.preventDefault();
            $('.tooltip').hide();

            if ($(this).hasClass("reset-map-mode")){
                $('#nbnTemporalToolbar').slideUp();
                $('a.reset-map-mode').removeClass("reset-map-mode");
                resetMap();
                return false;
            }
            else{
                $('#nbnTemporalToolbar').slideDown();
                $(this).addClass("reset-map-mode");
            }

            return false;

            });

    function addTemporalControlToMap() {
      MAP_VAR.map.addControl(new LaunchTemporalLeafletControl());
      $('a.launchTemporalLeafletControl').tooltip({ container: 'body', placement: 'left' });
      MAP_VAR.nbnTemporalControl = true;
    }

    // helper: wait until MAP_VAR.map exists, then run callback
    function waitForMap(callback) {
      var check = setInterval(function () {
        if (MAP_VAR && MAP_VAR.map) {
          clearInterval(check);
          callback();
        }
      }, 100);
    }

    // 1. If map already exists, add immediately
    if (MAP_VAR && MAP_VAR.map && !MAP_VAR.nbnTemporalControl) {
      addTemporalControlToMap();
    }
    // 2. Else if user is already on Map tab, wait for map
    else if ($('.nav-tabs li.active a').attr('id') === "t2") {
      waitForMap(function () {
        if (!MAP_VAR.nbnTemporalControl) addTemporalControlToMap();
      });
    }
    // 3. Else listen to tab change event for Map tab
    else {
      $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        if ($(this).attr('id') === "t2") {
          waitForMap(function () {
            if (!MAP_VAR.nbnTemporalControl) addTemporalControlToMap();
          });
        }
      });
    }

    $('#colourBySelect').on('change', function() {
         // Check if nbnTemporalToolbar is showing
        if ($('#nbnTemporalToolbar').is(':visible')) {
            // Determine which temporal control is active
            var activeTemporalControl;
            if ($('#year-tab').hasClass('active')) {
                activeTemporalControl = window.nbnTemporalControlYear;
            } else if ($('#month-tab').hasClass('active')) {
                activeTemporalControl = window.nbnTemporalControlMonth;
            }

            // Call displayMapForValue on the active temporal control
            if (activeTemporalControl) {
                activeTemporalControl.displayMapForValue();
                return true;
            }
        }
    });

   });



</asset:script>

<style>

.nav-pills>li>a {
    border-radius: 0px;

}
#nbnTemporalToolbar .tab-content {border:none !important; border-bottom:0px}

#content #nbnTemporalToolbar  .nav-tabs li:not(.active) a{
    background-color: #fff;
    /*border:none;*/
}

#nbnTemporalToolbar {
    border:1px solid #ccc;
}
#launchTemporalLeafletControl{
    padding: 6px 10px;
    background-color: #fff;

}
#main-content .leaflet-container a.launchTemporalLeafletControl, #main-content .leaflet-container a.launchTemporalLeafletControl:visited, #main-content .leaflet-container a.launchTemporalLeafletControl:hover {
    color: #000;
    text-decoration: none;
}

.irs--round .irs-handle{
    border-color: #dcdcdc; /*#005A8E; e6e6e6 well grey: dcdcdc*/ /**body colour: 595d5f*/
    height: 20px;
    width: 20px;
}
.irs--round .irs-bar {
    background-color: #3498db; /*#005A8E;*/
}

.irs--round .irs-from, .irs--round .irs-to, .irs--round .irs-single {
    background-color: #3498db; /*#005A8E;*/
    /*color: #595d5f;*/
}

.playback-toolbar { white-space: normal; }                 /* allow wrap */
.playback-toolbar .btn-group { display: inline-block; }    /* align nicely */


</style>
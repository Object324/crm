
<script src="include/js/TrackPosition.js"></script>

<div style="height: 50px;border-bottom: 1px solid #eaeaea;display: flex;align-items: center;position: relative;z-index: 1;">
    <div id="mapsearchdate" style="display: none;align-items: center;margin-left: 20px;line-height: 32px;">
        <span id="choosedate_prev" onclick="TrackLocationMap.changeday('prev')" style="margin-right: 15px;cursor: pointer;text-decoration:underline;">{'THEDAYBEFORE'|@getFixedLabel}</span>
        <div class="ld-form-item-content" style="width: 180px;">
            <input name="trackmapdate" class="Wdate ld-input-inner" style="width: 100%;" autocomplete="off" tabindex="s" type="text"
                   fieldonly="0" size="20" maxlength="10" value="{$nowdate}"  onclick="setChooseMapMaxDate()";">
        </div>
        <span id="choosedate_next" style="margin-left: 15px;cursor: pointer;text-decoration:underline;display: none" onclick="TrackLocationMap.changeday('next')">{'THEDAYAFTER'|@getFixedLabel}</span>
    </div>
    <div id="tracksearchscope" style="margin-left: 30px;">
    </div>
    {include file="TrackLocationMapHead.tpl"}
    <a class="icon-range" href="javascript:void(0);" style="display: none;margin-top: 3px;margin-left: 6px;" onclick=""></a>
    {if $showeditbtn eq 'yes'}
        <div class="ld-button" style="height: 32px;margin-right: 20px;margin-left: auto;cursor: pointer;" onclick="TrackLocationMap.listtrack()" >{'TRACKPOSITONINGGROUP'|@getFixedLabel}</div>
    {else}
        <div style="margin-right: 20px;"></div>
    {/if}
    <div class="track_position_changemap">
        <div class="track_position_changemap_left track_select" id="mapshowposition" onclick="TrackLocationMap.changeMap('showposition',0)">
            <div class="track_position_changemap_right_icon"></div>
        </div>
        <div class="track_position_changemap_right" id="mapshowtrack" onclick="TrackLocationMap.changeMap('showtrack',0) ">
            <div class="track_position_changemap_left_icon"></div>
        </div>
    </div>
</div>
<div style="height: calc(100% - 50px);z-index: 0;position: relative;" id="TrackLocationContainer">


</div>
<script type="text/javascript">
    var chooseMaxMaxDate="{$nowdate}";
    var trackposition_arr= JSON.parse('{$trackpositionjsonstr}');
    TrackLocationMap.maptype="showposition";
    TrackLocationMap.searchdate=chooseMaxMaxDate;
    function setChooseMapMaxDate() {
        WdatePicker({ maxDate: chooseMaxMaxDate,onpicked:TrackLocationMap.DateChange,oncleared:TrackLocationMap.DateChange,isShowClear:false});
    }
    function trackSmOwnerScopehightuser() {

        if(tracksearchscope_selectobj && tracksearchscope_selectobj.optionList && tracksearchscope_selectobj.optionList.length > 0){
            var optionlists = tracksearchscope_selectobj.optionList;
            for(var i=0;i<optionlists.length;i++){
                if(optionlists[i]['value'] == 'smowner_search_senior'){
                    tracksearchscope_selectobj.eventChangeSelected(i);
                    break;
                }
            }
        }
    }

</script>
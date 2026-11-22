<script src="include/js/LocationPosition.js"></script>
<div style="height: 50px;border-bottom: 1px solid #eaeaea;display: flex;align-items: center;position: relative;z-index: 1;">
    <div id="tracksearchscope" style="margin-left: 20px;">
    </div>
    {include file="TrackLocationMapHead.tpl"}
    <a class="icon-range" href="javascript:void(0);" style="margin-top: 3px;margin-left: 6px;display: none"></a>
</div>
<div style="height: 50px;display: flex;align-items: center;">
    <div class="ld-button" style="height: 32px;margin-left: 20px;margin-right: auto;">轨迹定位组</div>
    <div class="track_position_changemap">
        <div class="track_position_changemap_left " onclick="TrackLocationMap.changeMap('showtrack')">
            <div class="track_position_changemap_left_icon"></div>
        </div>
        <div class="track_position_changemap_right track_select">
            <div class="track_position_changemap_right_icon"></div>
        </div>
    </div>
</div>

<div style="height: calc(100% - 100px);" id="LocationPositionMap">
</div>

<script type="text/javascript">
    {if isset($Merge_SmOwner_arr)}
    if(ld('#tracksearchscope').length > 0){
    }
    {/if}
</script>
{*<!--
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
-->*}
<script type="text/javascript">

    {*DocmentWriteJs("include/js/modules/{$RELATED_MODULE}/{$RELATED_MODULE}.js","{$RELATED_MODULE}_js")*}
</script>
<div class="DivC" id="contactsmap_div">
    <link type="text/css" href="{$CSSURL}themes/softed/ModuleMapView.css?v={$GLOBALMINVERSION}" rel="stylesheet"/>
    <div id="listmap_div" data-frommodule="{$MODULE}" data-module="{$RELATED_MODULE}" date-fromrecordid="{$ID}">

        <div id="listmap_button" class="contactsmap_btndiv" style="background-color: #f5f5f7;width: 100%;overflow: hidden;">
            {if $RELATEDMODULEEDIT eq 'yes'}
                <input id="map_edit" type="button" data-frommodule="{$MODULE}" data-module="{$RELATED_MODULE}" data-fromrecordid="{$ID}" data-relatedid="{$RELATIONID}" data-tip="{'UNLOCKHINTSBYCLICK'|@getFixedLabel}" data-direction="bottom" data-type="position"
                        {if $LOCKSTATE eq 'yes'}
                            class="createauto tip-map-edit editBtnDisabled" disabled style="margin-left: 20px;margin-top: 10px;float:left;height: 32px"
                        {else}
                            class="createauto" style="margin-left: 20px;margin-top: 10px;float:left;height: 32px"
                        {/if}
                       onclick="editModuleMap(this);" value="{'EDIT'|@getFixedLabel}">
            {/if}
            <div id="map_show_fullScreen" style="float: left;border: 1px solid #cecece;margin-top: 12px;margin-left: 20px;cursor: pointer;height: 28px" title="{'FULLSCREEN'|@getFixedLabel}">
                <img src="themes/softed/images/fullscreen.png" style="padding: 2px;height: 26px;width: 26px;">
            </div>
            {if $RELATEDMODULEEDIT eq 'yes'}
                <div class="modulemapview-lock-div" style="height: 28px;{if $LOCKSTATE eq '-1'}display: none{/if}">
                    <b id="map_lock"
                       {if $LOCKSTATE eq 'yes'}
                           class="modulemapview-lock"
                       {else}
                           class="modulemapview-unlock"
                       {/if}
                       lockstate="{$LOCKSTATE}" record="{$ID}" frommodule="{$MODULE}" module="{$RELATED_MODULE}" fromrecordid="{$ID}" onclick="moduleMapLockClick(this)"></b>
                </div>
            {/if}
            <div style="float: right;height: 26px;margin-right: 20px;margin-top: 12px;">
                <div  id="map_drag" data-status="nochose"  style="float: left;border: 1px solid #cecece;margin-right: 5px;cursor: pointer;height: 28px" title="{'DRAGMAP'|@getFixedLabel}">
                    <img src="themes/softed/images/Icon_grab.png" style="padding: 1px;">
                </div>
                <div style="float: left;border: 1px solid #cecece;margin-right: 5px;height: 28px">
                    <div id="map_zoom_value" style="float: left;width: 50px;text-align: center;line-height: 26px;border-right: 1px solid #cecece;">100%</div>
                    <div id="btu_zoom_in" title="{'AMPLIFIEDMAP'|@getFixedLabel}" data-type="in" style="float: left;border-right: 1px solid #cecece;cursor: pointer;"><img src="themes/softed/images/zoom-in.png" style="padding: 2px;width: 26px;height: 26px;"></div>
                    <div id="btu_zoom_out" title="{'TEDUCETHEMAP'|@getFixedLabel}" data-type="out" style="float: left;cursor: pointer;"><img src="themes/softed/images/zoom-out.png" style="padding: 2px;width: 26px;height: 26px;"></div>
                </div>
                <div id="btu_zoom_restore" data-type="restore"  title="{'RESTOREMAPSIZE'|@getFixedLabel}"  style="float: left;border: 1px solid #cecece;height: 28px">
                    <img src="themes/softed/images/collapse.png" style="padding: 2px;width: 26px;height: 26px;">
                </div>
            </div>
        </div>
        <!--模块图谱-->
        <div id="map_view_div" style="width: 100%;display: inline-block;height:100%;background-color:#f5f5f7;overflow:auto;">
            <div class="modulemapview-design">
                <div id="modulemapview" class="modulemapview" style="transform:translate(0px,0px) scale(1); transform-origin: 50% 0px 0px;">
                    <div class="node-wrap" id="node_wrap_div">
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
</div>
<script>
    // ljj 20230901 BUG0071478 联系人图谱无法移动，界面无滚动条也无法拖动，只显示部分图谱
    var popupobj=CrmPopup.getPopupObj('last');
    var divobj = ld('#'+popupobj.divid);
    var width=parseInt((CrmPopup.getClientWidth()-getLeftMenuWidth())*0.9)-16;
    divobj.find('#contactsmap_div').width(width);
    var button_height = divobj.find('#listmap_button').get(0).offsetHeight;
    var DivCTable_max_height = divobj.find('#contactsmap_div').parent().css('max-height');
    var height = DivCTable_max_height - button_height - 17;
    divobj.find('#map_view_div').css('height',height);
    {literal}
    if (ld('#'+popupobj.divid+' #map_edit') && ld('#'+popupobj.divid+' #map_edit').hasClass('tip-map-edit')){
        tooltip('.tip-map-edit',{transition: true, time: 200});
        popupobj.mapedit_tooltip='yes';
    }
    {/literal}
</script>
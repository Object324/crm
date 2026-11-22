<script type="text/javascript" src="{$JSURL}include/js/moduledata_tag.js?v={$GLOBALMINVERSION}"></script>
<div id="edit_listmap_div" data-frommodule="{$FROMMODULE}" data-module="{$MODULE}" date-fromrecordid="{$FROMRECORDID}">
    <!--模块列表-->
    <div id="edit_list_view_div"  style="width: 300px;float: left;height:100%;overflow:auto;">
        <div style="width: 100%;height:42px;fontsize:14px;padding:14px 20px 6px 20px;overflow:hidden;" >
            <p style="float:left;line-height:24px;font-size: 16px;">{$MODULELABEL}</p>
            {if $ALLOWCREATE eq 'yes'}<div style="float:right;line-height:24px;"><span>{$CREATEHTML}</span></div>{/if}
        </div>
        <div style="width: 100%;;height:42px;padding:8px 16px;">
            <input id="search_mapdatalist" class="detailedViewTextBox" style="width: 100%;height: 30px;" type="text"  tag="{$SEATCHTEXTPLACEHOLDER}" placeholder="{$SEATCHTEXTPLACEHOLDER}" onblur="" onfocus="" name="allmember">
        </div>
        <div  style="width: 100%;list-style:none;">
            <p id="data_list_tip" style="padding:0 16px;font-family: PingFang SC;font-style: normal;font-weight: 400;font-size: 12px;color: #91959e;margin-bottom: 10px;">{'DRAGCONTACTTOMAP'|@getFixedLabel}</p>
            <div id="data_list_div" >
                
            </div>
        </div>
    </div>
    <!--模块图谱-->
    <div id="edit_map_view_div" style="width: calc(100% - 300px);display: inline-block;height:100%;background-color:#f5f5f7;overflow: auto;max-height: 500px;">
        <div id="edit_map_view_drag" style="height: 26px;position: fixed;top: 66px;right: 20px;z-index: 25;">
            <div id="map_drag" data-status="nochose" style="float: left;border: 1px solid #cecece;margin-right: 5px;cursor: pointer;" title="{'DRAGMAP'|@getFixedLabel}">
                <img src="themes/softed/images/Icon_grab.png" style="padding: 1px;">
            </div>
            <div style="float: left;border: 1px solid #cecece;margin-right: 5px;">
                <div id="map_zoom_value" style="float: left;width: 50px;text-align: center;line-height: 26px;border-right: 1px solid #cecece;">100%</div>
                <div id="btu_zoom_in" title="{'AMPLIFIEDMAP'|@getFixedLabel}" data-type="in" style="float: left;border-right: 1px solid #cecece;cursor: pointer;"><img src="themes/softed/images/zoom-in.png" style="padding: 2px;width: 26px;height: 26px;"></div>
                <div id="btu_zoom_out" title="{'TEDUCETHEMAP'|@getFixedLabel}" data-type="out" style="float: left;cursor: pointer;"><img src="themes/softed/images/zoom-out.png" style="padding: 2px;width: 26px;height: 26px;"></div>
            </div>
            <div id="btu_zoom_restore"  data-type="restore" title="{'RESTOREMAPSIZE'|@getFixedLabel}"  style="float: left;border: 1px solid #cecece;cursor: pointer;">
                <img src="themes/softed/images/collapse.png" style="padding: 2px;width: 26px;height: 26px;">
            </div>
        </div>
        <div class="modulemapview-design">
            <div id="modulemapview" class="modulemapview" style="transform:translate(0px,0px) scale(1); transform-origin: 50% 0px 0px;">
                <div class="node-wrap" id="node_wrap_div">
                </div>
            </div>
        </div>
    </div>
    <!--模块标签-->
{*            // ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签*}
        <div id="edit_tag_div" class="edit_tag_div" style="width: 300px;float: right;height:100%;text-align: center;display: none;">
            <input type="hidden" name="modulemap_module" value="{$MODULE}">
            <input type="hidden" name="modulemap_frommodule" value="{$FROMMODULE}">
            <input type="hidden" name="modulemap_fromrecord" value="{$FROMRECORDID}">
            <input type="hidden" name="modulemap_relatedid" value="{$RELATEDID}">
            <div class="E_ptitc" value="关闭" title="关闭" id="modulemap_edittag"></div>
            <div id="edit_tag_table" class="edit_tag_table" style="padding: 20px 0;height: calc(100% - 50px)">
                {include file='Smarty/templates/modulemapdata_tag.tpl'}
            </div>
            <!--底部-->
            <div style="margin: 10px auto;">
                <input name="tagsave" class="E_pbtnok ld-button ld-button-primary" type="button" value="{'SaveTag'|@getFixedLabel}"/>
            </div>
        </div>

</div>

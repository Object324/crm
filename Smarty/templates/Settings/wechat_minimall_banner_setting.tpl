<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/wechat_minimall_setting.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/MsgPopup.js"></script>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_APPLET_BANNER_SETTING'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a onclick="editMallBanner('','create')" href="javascript:;" class="pg-btn-grey dinline-block lfloat" title="{'ADD'|@getFixedLabel}">{'ADD'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="selfconfig_module_div" class="cont_wrap clear_float">
            <table class="listEntries listSettingData" width="100%" cellspacing="1" cellpadding="0">
              <tr>
                <th align="left">#</th>
                <th  width="140" align="center" valign="middle">{'wxmall_banner_img'|@getFixedLabel}</th>
                <th align="left">{'wxmall_banner_path'|@getFixedLabel}</th>
                <th align="left">{'wxmall_banner_url'|@getFixedLabel}</th>
                <th width="200" align="left">{'OPERATING'|@getFixedLabel}</th>
              </tr>
              {foreach item = value from =$fileArr name=pname}
              <tr tag="module"  class="lvtColData">
                <td>{$smarty.foreach.pname.iteration}</td>
                <td width="140" align="center" valign="middle"><img style="margin: 10px 0" width="100" src="{$site_URL}{$value.path}{$value.filename}" alt=""></td>
                <td>{$value.path}{$value.filename}</td>
                <td>{$value.url}</td>
                <td>
                    <a class="Anu3_a"  href="javascript:void(0)" onclick="editMallBanner({$value.id},'edit')">编辑</a>
                    <a class="Anu3_a"  tag="move_up" onclick="mallBanner_moveupmodule(this,'up',{$value.id})" {if $smarty.foreach.pname.iteration eq 1}hidden{/if}>{'MOVEUP'|@getFixedLabel}</a>
                    <a class="Anu3_a" tag="move_down" onclick="mallBanner_moveupmodule(this,'down',{$value.id})" {if $smarty.foreach.pname.iteration eq $fileArrLength}hidden{/if}>{'MOVEDOWN'|@getFixedLabel}</a>
                    <a class="Anu3_a" onclick="deleteMallBanner({$value.id},this)">{'DELETE'|@getFixedLabel}</a>
                </td>
              </tr>
              {/foreach}
            </table>
        </div>
    </div>
</div>

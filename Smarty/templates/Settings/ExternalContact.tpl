<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/ExternalContact.js"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'ExternalContactSetting'|@getFixedLabel}{if $HelpHtml.ExternalContact neq '' }{$HelpHtml.ExternalContact}{/if}<font>（{'CRMWeatherShowExternalContact'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="settings_ExternalContact.edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'IMPORTDATATTITLE3'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'WHETHERTOENABLE'|@getFixedLabel}</td>
                    <td width="80%">
                    <input type="checkbox" onclick="change_tablefield_presence(this,'external_contact','wx_config_switch')" class="second_switch"  
                    {if $SWITCH eq 'open'}checked=""{/if}/></td>
                </tr>
                <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>{'IMPORTDATATTITLE6'|@getFixedLabel} </td>
                    <td>{$USERSCOPE}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'ExternalContactUsersSetting'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'APPLICABLESCOPE'|@getFixedLabel}</td>
                    <td width="80%">
                        <a href="https://work.weixin.qq.com/wework_admin/frame#customer/mng" target="_blank">{'IMPORTDATATTITLE5'|@getFixedLabel}</a>
                        <span class="colorC0">({'IMPORTDATATTITLE4'|@getFixedLabel})</span>
                    </td>
                </tr>
                {*editor:gyq_20190306 0036330: 系统设置->企业微信客户联系设置界面：若客户联系接口设置“不启用”，则“数据导入”行应该不显示*}
                {if $CONTACTACTIVE eq 'active' && $SWITCH eq 'open'}
                    <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td>{'IMPORTDATATTITLE2'|@getFixedLabel} </td>
                        <td><a href="javascript:;" onclick="import_get_external_contact()">{$IMPORTEXCONTACT}</a></td>
                    </tr>
                {/if}
            </table>
            <div class="listRloesHelp">
                <font color="red">{'EXPLAIN'|@getFixedLabel}：</font>
                <ul>
                    <li>{'ExplainOfExternalContact'|@getFixedLabel}</li>
                </ul>
            </div>
        </div>
    </div>
</div>
{*editor:gyq_94 reason:企业微信外部联系人批量导入  2019/1/2 12:59*}

<div id="dvUpdate" class="E_pop_box LdPopWidth600px"
	 style="position: fixed; z-index: 9999; top: 50%; left: 50%; display: none; margin-top: -147.5px; margin-left: -202px;">
	<div class="E_pop_tit">
		<strong class="E_ptita">{'IMPORTDATATTITLE'|@getFixedLabel}</strong>
		<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" onclick="import_get_external_contact_okbutton();return false;"></button>
	</div>
	<table class="D_pop_bod" width="100%" cellspacing="0" cellpadding="0" border="0" align="center">
		<tbody>
		<tr>
			<td style="text-align:center;">
				<div>
					<div id="dv" style="float: left;">
					</div>
					<div style="float: right;">
						<?php if($common_version['oem_crm'] == 'no'){ ?>
						<a href="javascript:void(0);"
						   style="float: right;cursor: pointer;display: inline-block;background-image: url(../../themes/softed/images/home-icons.png);background-repeat: no-repeat;vertical-align: middle;position: relative;width: 20px;height: 17px;background-position: -5px -251px;"
						   onclick="window.open('<?php echo $linkurl; ?>')"></a>
						<?php } ?>
					</div>
				</div>
				<div style="float:left;background-color:#FFFFFF;width:410px;height:24px;padding:1px;border:1px solid #ddd;border-radius: 5px;overflow:hidden;margin-bottom:20px;">
					<div id="dvprogress"
						 style="float:left;width:0;height:20px;background-color:#3B7CFF;overflow:hidden;">&nbsp;
					</div>
				</div>
				<div class="clear"></div>
				<div style="display: -webkit-inline-box;" id="dvc">{'EXPORTINGDATA'|@getFixedLabel}</div>
				<div class="clear"></div>
				<div id="total_num"></div>
			</td>
		</tr>
		</tbody>
	</table>
	<div class="E_pbtn">
		<input class="E_pbtnok" value="确认" type="button" onclick="import_get_external_contact_okbutton()">
	</div>
</div>

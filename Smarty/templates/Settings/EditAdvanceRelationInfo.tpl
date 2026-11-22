{*推进关系的任务编辑界面弹出层 *}
<input type="hidden" name="advanceid" value="{$ADVANCEID}" />
<input type="hidden" name="frommodule" value="{$FROMMODULE}" />
<div style="height:auto;">
    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="ld-public-content-paddingright">
        <tr>
            <td class="ld-form-item-label">
                <span style="font-size:13px;">{'CURRENTCIRCULATION'|@getFixedLabel}:</span>
            </td>
            <td class="ld-form-item-content">
                <div style="float:left;margin: 10px 15px 10px;">
                    <span  class="stagement_border">{$STAGENAME_START}</span>
                </div>
                <div style="float:left;border-left: 10px solid #609bd0;margin-top:18px;
                border-bottom: 8px solid transparent;border-top:8px solid transparent;" class="little_trigle"></div>
                <div  style="float:left;margin: 10px 0px 10px;">
                    <span class="stagement_border">{$STAGENAME_TARGET}</span>
                </div>
            </td>
        </tr>
    </table>
    {* 推进任务描述 *}
    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="ld-public-content-paddingright">
    	<tbody><tr>
    		<td colspan="4" style="padding-left: 30px;">
                <div class="ld-from-headblock-title">
                    <b style="font-size:14px;">{"ADVANCE"|@getFixedLabel}{"TaskDescription"|@getFixedLabel}</b>
                </div>
    		</td>
    	</tr>
        </tbody>
    </table>
    <table class="ld-public-content-paddingright" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
        <tr>
			<td class="ld-form-item-label">
                {'TaskDescription'|@getFixedLabel}
            </td>
			<td class="ld-form-item-content">
                <textarea id="taskdescription" name="taskdescription" type="text" value="" class="ld-textarea-inner" style="height: 50px;">{$TaskDescription}</textarea>
			</td>
		</tr>
    </table>
    {* 推进操作权限 *}
    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="ld-public-content-paddingright">
    	<tbody><tr>
    		<td colspan="4" style="padding-left: 30px;">
                <div class="ld-from-headblock-title">
                    <b style="font-size:14px;">{"PUSHOPERATIONPERMISSION"|@getFixedLabel}</b>
                    <span style="font-size:14px;font-weight: initial;">({"PUSHPERMISSIONDESCRIPTION"|@getFixedLabel})</span>
                </div>
    		</td>
    	</tr>
        </tbody>
    </table>
    <table class="ld-public-content-paddingright" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
        <tr id="role_name_tr">
			<td class="ld-form-item-label">
                {'SPECIFYROLE'|@getFixedLabel}
            </td>
			<td class="ld-form-item-content">
                <div>
                    <input class="ld-input-inner-div ld-input-inner-add" type="text" name="role_name" id="role_name" readonly="true" value="{$PROFILENAME}" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}')"/>
                    <input type="hidden" name="user_role" id="user_role" value="{$PROFILEID}"/>
                    <a class="ld-text-clear" href="javascript:;" title="清除" onclick="ld('#role_name').val('');ld('#user_role').val('');">+</a>
                    <a class="ld-text-select" href="javascript:selectPopupProfile('user_role','{'SPECIFYROLE'|@getFixedLabel}');">+</a>
                </div>
			</td>
		</tr>
        <tr id="username_tr" >
			<td class="ld-form-item-label">{'SPECIFYUSER'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
                <div>
                    <div class="ld-input-inner-div ld-input-inner-add" type="text" name="userid_name" id="userid_name" readonly="true"  onclick="approve_selectuser();" value="{$USERNAME}" style="overflow: hidden;">{$USERNAME}</div>
                    <input type="hidden" name="userid" id="userid" value="{$USERID}"/>
                    <a class="ld-text-clear" href="javascript:;" title="清除" onclick="ld('#userid_name').html('');ld('#userid').val('');">+</a>
                    <a class="ld-text-select" href="javascript:;" onclick="approve_selectuser();">+</a>
				</div>        
			</td>
		</tr>
        <tr class="ChangeApprove">
            <td class="ld-form-item-label">{'USERFIELD'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="selectuserfields" class="selectfields" multiple="">
                    {foreach key=fieldid  item=fieldlabel from=$SELECT_USERFIELD_TYPE}
                        <option value="{$fieldid}" {if $fieldid|in_array:$USERFIELDID}selected{/if} >{$fieldlabel}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
    </table>
    {* 推进任务 *}
    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="ld-public-content-paddingright">
    	<tbody><tr>
            <td colspan="4" style="padding-left: 30px;">
                <div class="ld-from-headblock-title">
                    <b style="font-size:14px;">{"ADVANCETASK"|@getFixedLabel}</b>
                    <input type="button" class="createauto" onclick="AdvanceRelation.createTask()" style="float:right;margin-right:10px" value="{"AddTask"|@getFixedLabel}">
                </div>
            </td>
    	</tr>
        </tbody>
    </table>
    <table class="settingPopTable lasttdbordernon ld-public-content-big" id="AdvanceTaskTable" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
        <tbody>
            <tr trindex="0">
                <td width="20%"><span>{'TASK'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}</span></td>
                <td width="40%"><span>{'LBL_AUTOMATICTASK_CONTENT'|@getFixedLabel}</span></td>
                <td width="10%"><span>{'ACTIVATE'|@getFixedLabel}</span></td>
                <td width="10%"><span>{'COMPLETEREQUEST'|@getFixedLabel}</span></td>
                <td width="20%"><span>{'OPERATING'|@getFixedLabel}</span></td>
            </tr>
        {* {assign var=stagenum value =0} *}
        {foreach item=TaskInfo key=index  from = $ADVANCETASKINFO}
            {assign var=type value=$TaskInfo.tasktype}
            {assign var=taskvalue value=$TaskInfo.$type}
            {assign var=stagenum value = $index+1}
            <tr class="ld-category-draggable" tasktype="{$type}" trindex="{$stagenum}" saved="yes" style="border-bottom: 1px solid #F1F1F1;">
                <td align="left" style="border-bottom: 1px solid #F1F1F1;" >
                    {$TaskInfo.typelabel}
                </td>
                {* 任务信息 *}
                <td style="overflow: inherit;border-bottom: 1px solid #F1F1F1;">
                    <div name="div_content_{$stagenum}">
                        {include file='Settings/advancetaskinfo.tpl'}
                    </div>
                </td>
                <td style="border-bottom: 1px solid #F1F1F1;">
                    <input type="checkbox" tasktype='{$type}' stagenum='{$stagenum}' name="presence" onclick="AdvanceRelation.enabletask(this)" {if $taskvalue.0.presence eq 'yes'}checked{/if} class="second_switch"/>    
                </td>
                
                <td style="border-bottom: 1px solid #F1F1F1;">
                    <input type="checkbox" tasktype='{$type}' stagenum='{$stagenum}' name="completerequest" {if $taskvalue.0.completerequest eq 'yes'}checked{/if} style="{if $type eq 'validata'}display:none;{/if}" class="second_switch"/>
                </td>
                <td style="border-bottom: 1px solid #F1F1F1;">
                    <a class="ld-category-icon ld-category-edit tip-items-list" name="setAdvancetask" href="javascript:void(0);" onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','edit')" style="white-space:nowrap;margin-left:8px;" data-tip="{'EDIT'|@getFixedLabel}"></a>
                    <a class="ld-category-icon ld-category-del tip-items-list" href="javascript:void(0);" onclick="AdvanceRelation.deleteTask(this)" style="white-space:nowrap;margin-left:6px;" data-tip="{'DELETE'|@getFixedLabel}"></a>
                    <a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;margin-left:6px;" data-tip="{'drag'|@getFixedLabel}" data-direction="right"></a>
                </td>
            </tr>
        {/foreach}
        </tbody>
    </table>
    <div style="line-height: 42px">
        <input style="margin: 8px 10px 10px;" type="checkbox" name="autopush" {if $AUTOPUSH eq 'yes'}checked{/if} />
        <span>{'AUTOMATICPROPULSION'|getFixedLabel}</span>
    </div>
</div>
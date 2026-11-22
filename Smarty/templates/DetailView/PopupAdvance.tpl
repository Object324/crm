<script language="JavaScript" type="text/javascript" src="include/js/AdvanceStage.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/cls_advance_process.js?version={$GLOBALMINVERSION}"></script>
<link rel="stylesheet" href="{$CSSURL}themes/softed/multistep/MultiStep.min.css" type="text/css" />
<link rel="stylesheet" href="{$CSSURL}themes/softed/multistep/MultiStep-theme.min.css" type="text/css">
{assign var=defaultshow value=$MODULEADVANCE['moduleadvance']['defaultshow']}
<div class="DivCName DivCNamehover tip-items-list {if $defaultshow eq 'no'}ld-shadow-first{/if}" {if $defaultshow eq 'no'}data-setevent="no"{else}data-setevent=""{/if} id="advance_show_btn" data-direction="left" data-type="position" data-tip="{if $defaultshow eq 'no'}{'EXPANSION'|@getFixedLabel}{else}{'COLLAPSE'|@getFixedLabel}{/if}" onclick="showHideStatus('PROGRESSTRACKING','PROGRESSTRACKING_span');">
    {*新加可收起标题栏*}
    <span class="{if $defaultshow eq 'no'}On{/if}" id="PROGRESSTRACKING_span" name="PROGRESSTRACKING_span" title="隐藏"></span>
    {if $MODULEADVANCE['module_field_label']!=''}
        {$MODULEADVANCE['module_field_label']}-{'PROGRESSTRACKING'|@getFixedLabel}
    {else}
        {'PROGRESSTRACKING'|@getFixedLabel}
    {/if}

</div>
<div class="multi-step ld-shadow-first" id="PROGRESSTRACKING" name="PROGRESSTRACKING" style="position: relative;{if $defaultshow eq 'no'}display:none;{else}display:block;{/if}" >
    {if $MODULEADVANCE['moduleadvance']['method'] eq 'field'}

    <div id="parent_node" name="parent_node" class="HorizontalProcess-design" style="height: 100%;flex: 1;background-color: transparent;display: none;"></div>
    {else}
    <div class="modal-header" style="margin-left:5px;">
        <div class="modal-steps" >
            {assign var=hastime value='no'}
			{if $MODULEADVANCE['data_error'] eq 'yes'}
                <span style="margin-left: 80px;margin-bottom: 5px;">{$MODULEADVANCE['fieldlabel_isempty']}</span>
			{else}
				{foreach key=index item=fld_advance from=$MODULEADVANCE['advancestage_values']}

					{if $fld_advance['completed'] eq 'yes'}
                        {if $fld_advance['skip'] eq 'yes'}
						<div class="step skip" data-step="{$index}" {if $MODULEADVANCE['with_time'] eq 'yes'}style='margin-bottom:35px;'{/if} >
                        {elseif is_array($MODULEADVANCE['advancestage_values']) && sizeof($MODULEADVANCE['advancestage_values']) eq 1}
                        <div class="step alone" data-step="{$index}" {if $MODULEADVANCE['with_time'] eq 'yes'}style='margin-bottom:35px;'{/if} >
                        {else}
                        <div class="step completed" data-step="{$index}" {if $MODULEADVANCE['with_time'] eq 'yes'}style='margin-bottom:35px;'{/if} >
                        {/if}
					{else}
						{if $fld_advance['cur_flag'] eq 'yes'}
							<div class="step current" flag ="yes" data-step="{$index}" {if $MODULEADVANCE['with_time'] eq 'yes'}style='margin-bottom:35px;'{/if} >
						{else}
							<div class="step" data-step="{$index}" {if $MODULEADVANCE['with_time'] eq 'yes'}style='margin-bottom:35px;'{/if} >
						{/if}
					{/if}

                        <label class="label label-advancevalue"  data-direction="top" data-type="position" style="height: 16px;">
                            {if $fld_advance['staytimecontent'] neq '' &&$MODULEADVANCE['moduleadvance']['showadvancelog'] eq 'no'}
                                {if $MODULEADVANCE['moduleadvance']['method'] eq 'field' && $MODULEADVANCE['moduleadvance']['logshowstyle'] eq 'inpopup' }
                                    <b onclick="CrmPopup.getPopupObj('last').AdvanceStageobj.ShowAdvanceDetail('{$fld_advance['value']}');" data-tip="{'SHOWADVANCEDETAIL'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help tip-items-list"></b>
                                {/if}
                            {/if}
                            <span class="tip-items-list" data-tip="{$fld_advance['value']}">{$fld_advance['value']}</span>
                        </label>
                        <div class="dot" name="advancestage" tag="{$index}" modulename="{$MODULEADVANCE['module']}" record="{$MODULEADVANCE['record']}" stagename="{$fld_advance['value']}" ></div>

                        {if $MODULEADVANCE['moduleadvance']['method'] eq 'field' }
                            {if $MODULEADVANCE['moduleadvance']['operatestyle'] eq 'inpopup' }

                                {if $fld_advance['cur_flag'] eq 'yes'&& is_array($ALLTASKINFO) && sizeof($ALLTASKINFO)>0 && $MODULEADVANCE['hidebtn'] neq 'yes'}
        							<div class="label"><input name="pushbutton" tag="{$index}" class="push-button" style="height: 24px;" type="button" value="{'ADVANCE'|@getFixedLabel}" onclick="detailbutton_click(this,'{$MODULEADVANCE['module']}','Advance',{$MODULEADVANCE['record']});return false;" /></div>
        						{else}
                                    {if is_array($MODULEADVANCE['advancestage_values']) && sizeof($MODULEADVANCE['advancestage_values']) > 1}
                                        <label class="label">&nbsp;</label>
                                    {/if}
        						{/if}
                            {/if}
                        {else}
                            {if $fld_advance['cur_flag'] eq 'yes'&& $MODULEADVANCE['is_permit'] eq 'yes'}
    							{if $fld_advance['pushback'] eq 'no'}
    								{if $fld_advance['finish'] eq 'no'}
    									<div class="label"><input name="pushbutton" tag="{$index}" class="createautonew" style="height: 24px;" type="button" value="{'ADVANCE'|@getFixedLabel}" onclick="detailbutton_click(this,'{$MODULEADVANCE['module']}','Advance',{$MODULEADVANCE['record']});return false;" /></div>
    								{else}
    									<div class="label"><input name="pushbutton" tag="{$index}" class="createautonew" style="height: 24px;" type="button" value="{'TEMPLATECOMPLETE'|@getFixedLabel}" onclick="detailbutton_click(this,'{$MODULEADVANCE['module']}','AdvanceComplete',{$MODULEADVANCE['record']});return false;" /></div>
    								{/if}
    							{else}
    								<div class="label"><input name="pushbutton" tag="{$index}" class="createautonew" style="height: 24px;" type="button" value="{'ADVANCE'|@getFixedLabel}" onclick="detailbutton_click(this,'{$MODULEADVANCE['module']}','Advance',{$MODULEADVANCE['record']});return false;" /></div>
    							{/if}
    						{else}
                                <label class="label">&nbsp;</label>
    						{/if}

                        {/if}
                        <label class="label labelMT" style="margin-bottom: 0;" >{if $fld_advance['userfullname'] neq ''}{$fld_advance['userfullname']}{else}&nbsp;{/if}
                        </label>
						<label class="label">{if $fld_advance['changedon'] neq ''}
                            {assign var=hastime value='yes'}
                            <span>{$fld_advance['changedon']}</span>
                            <label class="label" >
                        {else}&nbsp;{/if}
                        {if $fld_advance['staytimecontent'] neq '' &&$MODULEADVANCE['moduleadvance']['showadvancelog'] neq 'no'}
                            {if $MODULEADVANCE['moduleadvance']['method'] eq 'field' && $MODULEADVANCE['moduleadvance']['logshowstyle'] eq 'inpopup' }
                                <b onclick="CrmPopup.getPopupObj('last').AdvanceStageobj.ShowAdvanceDetail('{$fld_advance['value']}');" title="{'SHOWADVANCEDETAIL'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                            {/if}
                            {'STAGEDETENTIONDURATION'|@getFixedLabel}:{$fld_advance['staytimecontent']}</label>
                        {/if}
                        </label>
					</div>
				{/foreach}

			{/if}
            <br />
        </div>

        {if $MODULEADVANCE['moduleadvance']['logshowstyle'] eq 'underadvance' }
        {assign var=SHOWTYPE   value='detail'}
        <div class="modal-tasks">
            {foreach key=index item=fld_advance from=$MODULEADVANCE['advancestage_values']}
                {assign var=DetailTaskinfo  value=$fld_advance['DetailTaskInfo']}

                {if is_array($DetailTaskinfo['taskinfo']) && sizeof($DetailTaskinfo['taskinfo'])>0}
                    {assign var=TASKLOG   value=$DetailTaskinfo['tasklog']}
                    {assign var=TASKINFO   value=$DetailTaskinfo['taskinfo']}
                    {assign var=ALLOWEDIT   value=$DetailTaskinfo['allow_edit']}
                    {assign var=STAGENAME   value=$DetailTaskinfo['stagename']}
                    <div name="advanceHeader" stagename="{$STAGENAME}" class="advanceHeader" id="advanceHeader" tag="{$index}" tasknum="{$DetailTaskinfo['tasknum']}" style="" >
                        {include file="Taskprogress.tpl"}
                    </div>
                {else}
                    <div name="advanceHeader" stagename="{$fld_advance['value']}" class="advanceHeader" id="advanceHeader" tag="{$index}" tasknum="0" style="" >
                    </div>
                {/if}

            {/foreach}
        </div>
        {assign var=SHOWTYPE  value=''}
        {/if}

    </div>

    {/if}
    {*自动化任务div*}
        {if $MODULEADVANCE['moduleadvance']['method'] eq 'field' && $MODULEADVANCE['moduleadvance']['operatestyle'] eq 'underadvance' && $MODULEADVANCE['hidebtn'] neq 'yes'}
            {*hidebtn参数--判断详情页进度追踪推进按钮是否隐藏*}
            {assign var=fieldtask_num value=0}
            {if is_array($ALLTASKINFO) && sizeof($ALLTASKINFO)>0}
            <div id="task" class="pad10 marTB5LR20 bordertadius4" style="width:calc(100% - 40px);background-color: transparent;border: 1px solid #CFDFFF;">
                <div name="nextstage_div" class="height45">
                    <div class="lfloat fontbold padT4 padR15"><span class="hlineheight30">{'NEXTSTAGE'|@getFixedLabel}:</span></div>
                {foreach key=advanceid item=relationinfo from=$ALLTASKINFO }
                    {if $relationinfo['selected'] eq 'yes'}
                        {assign var=TASKLOG   value=$relationinfo['tasklog']}
                        {assign var=TASKINFO   value=$relationinfo['taskinfo']}
                        {assign var=ALLOWEDIT   value=$relationinfo['allow_edit']}
                        {assign var=STAGENAME   value=$relationinfo['stagename']}
                        {assign var=RECORD   value=$MODULEADVANCE['record']}
                        {assign var=MODULENAME   value=$MODULEADVANCE['module']}
                        {assign var=tmp_fieldtask_num   value=$relationinfo['fieldtask_num']}
                        {assign var=tmp_style value='color: #3B7CFF;border-color:#3B7CFF;'}
                        {assign var=next_advanceid value=$advanceid}
                        {assign var=next_stagename value=$relationinfo['stagename_target']}
                        {assign var=next_mapmodule value=$relationinfo['mapmodule']}
                        {assign var=bdisplay value="display:'';" }
                    {else}
                        {assign var=tmp_style value='color: #333333;border-color:#DCDFE6;'}
                        {assign var=bdisplay value="display:none;" }
                    {/if}
                    <div class="prelative lfloat"><span name="advancestagebtn" class="module-tagger-fm-button" onclick="CrmPopup.getPopupObj('last').AdvanceStageobj.ChangeAdvanceStage(this)" style="{$tmp_style};margin:5px;line-height: 28px;" advanceid="{$advanceid}" stagename="{$relationinfo['stagename_target']}" data-mapmodule="{$relationinfo['mapmodule']}" >{$relationinfo['stagename_target']}</span>
                        <b style="{$bdisplay}" class="icon-choosed"></b>
                    </div>
                {/foreach}
                {if $ISADMIN eq 'on' && $MODULENAME eq 'Leads'}
    				<span class="lineheight35"><a id="advance_stage_upgrade"
                    {if empty($next_mapmodule) || $next_mapmodule eq 'close'}style="display:none;"{/if}
                    onclick="advance_stage_upgrade({$RECORD})" title="{'SETTINGS'|@getFixedLabel}" class="cursorPointer">{'FIELDMAPPING'|@getFixedLabel}</a></span>
    			{/if}
                </div>
                <input name="next_advanceid" value="{$next_advanceid}" type="hidden" />
                <input name="next_stagename" value="{$next_stagename}" type="hidden" />
                <input name="next_mapmodule" value="{$next_mapmodule}" type="hidden" />
                {if is_array($TASKINFO['taskvalue']) && sizeof($TASKINFO['taskvalue']) > 0}
                    <div id="AllTaskvalue" name="AllTaskvalue" class="ld-advance-task marB10 gwidth100">
                        {include file="Taskprogress.tpl"}
                    </div>
                {else}
                    <div id="AllTaskvalue" name="AllTaskvalue" class="marB10 gwidth100">
                        <span class="marT10"></span>
                    </div>
                {/if}
                {if $MODULENAME eq 'Leads'}
                    <div class="marTB10">
                        <table class="" border="0" cellpadding="0" cellspacing="0" width="50%" style="max-height: 50px;">
                            <tr name="fileurereason_tr" style="{if $next_mapmodule neq 'close'}display:none;{/if}">
                                <td align="left">
                                    <font color="red">*</font>
                                    {'FAILLEDTOCOLSE'|@getFixedLabel}{'Reason'|@getFixedLabel}
                                </td>
                                <td align="right">
                                    <textarea name="fileurereason" rows="4" tag="{'FAILLEDTOCOLSE'|@getFixedLabel}{'Reason'|@getFixedLabel}" style="height:50px;overflow:hidden;overflow-wrap:break-word;" class="ld-textarea-inner"></textarea>
                                </td>
                            </tr>
                        </table>
                    </div>
    			{/if}
                <div class="clear_float">
                    <input name="savebutton" id="savebutton" tag="{$index}" class="ld-button ld-button-primary" style="{if $tmp_fieldtask_num <= 0}display:none;{/if}" type="button" value="{'SAVE'|@getFixedLabel}" onclick="CrmPopup.getPopupObj('last').AdvanceStageobj.SaveFieldValue('save')" />
                    <input name="saveandpushbutton" id="saveandpushbutton" tag="{$index}" class="ld-button ld-button-primary" type="button" value="{'ADVANCE'|@getFixedLabel}" onclick="CrmPopup.getPopupObj('last').AdvanceStageobj.SaveFieldValue('push')" />
                </div>
            </div>
            {else}

            {/if}
        {/if}
    <div style="height: 1px;"></div>
</div>
{*BUG0070118 txy 20230726 kfbcrm-自动化进度设置 改成新的tipS *}
<script>
    {literal}
    //tooltip('.tip-items-list', {transition: true, time: 200});
    {/literal}
</script>
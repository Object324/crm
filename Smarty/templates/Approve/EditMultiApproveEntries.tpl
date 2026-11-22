<table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td>#</td>
        <td title="{'STEPNAME'|@getFixedLabel}">{'STEPNAME'|@getFixedLabel}</td>
        <td title="{'APPROVERTYPE'|@getFixedLabel}">{'APPROVERTYPE'|@getFixedLabel}</td>
        <td title="{'APPROVER'|@getFixedLabel}">{'APPROVER'|@getFixedLabel}</td>
        {if $editprofile neq 'no'}
        <td title="{'CURAPPROVESTEPALLOWEDIT'|@getFixedLabel}" style="overflow:inherit;word-break:break-all;white-space:inherit;width:100px;line-height: 130%;">{{'CURAPPROVESTEPALLOWEDIT'|@getFixedLabel}}</td>
        {/if}
        <td title="{'WHETHERAPPROVALPROCESS'|@getFixedLabel}" style="overflow:inherit;word-break:break-all;white-space:inherit;width:100px;line-height: 130%;">{'WHETHERAPPROVALPROCESS'|@getFixedLabel}</td>
        <td title="{'editingprocessd'|@getFixedLabel}" style="overflow:inherit;word-break:break-all;white-space:inherit;width:100px;line-height: 130%;">{'editingprocessd'|@getFixedLabel}</td>
        <td title="{'specifytheapproval'|@getFixedLabel}" style="overflow:inherit;word-break:break-all;white-space:inherit;width:100px;line-height: 130%;">{'specifytheapproval'|@getFixedLabel}</td>
        <td title="{'Isitallowedtoaddapproversincurrentstep'|@getFixedLabel}" style="overflow:inherit;word-break:break-all;white-space:inherit;width:100px;line-height: 130%;">{'Isitallowedtoaddapproversincurrentstep'|@getFixedLabel}</td>
        {if $LANGUAGETYPE eq 'zh'}
        <td width="200" nowrap="nowrap">
        {else}
        <td width="250" nowrap="nowrap">
        {/if}
        {'OPERATING'|@getFixedLabel}
        </td>
    </tr>
    {foreach item=step from=$STEP}
        {if $step.approvetype eq 0}
            {assign var="approvetype" value = 'SPECIFYUSER'|@getFixedLabel}
        {elseif $step.approvetype eq 1}
            {assign var="approvetype" value = 'SPECIFYROLE'|@getFixedLabel}
        {elseif $step.approvetype eq 2}
            {assign var="approvetype" value = 'SPECIFYPROMOTERDEP'|@getFixedLabel}
        {elseif $step.approvetype eq 3}
            {assign var="approvetype" value = 'LBL_POSITIONLEVEL'|@getFixedLabel}
        {elseif $step.approvetype eq 5}
            {assign var="approvetype" value = 'DATACREATOR'|@getFixedLabel}
        {elseif $step.approvetype eq 6}
            {assign var="approvetype" value = 'DATASSIGNEDTO'|@getFixedLabel}
       {elseif $step.approvetype eq 4}
            {assign var="approvetype" value = 'LBL_POSITIONDEPARTMENT'|@getFixedLabel}
		{else}
			{foreach key=fieldid item=fieldlabel from=$SELECT_APPRIVE_TYPE}
				{if $step.approvetype eq $fieldid}
					{assign var="approvetype" value = $fieldlabel}
				{/if}
			{/foreach}
        {/if}
         {assign var='rowpsan' value=$step.rowspan}
      
        <tr>
       
          	<td align="center" rowspan="{$rowpsan}">{$step.rowseq}</td>
          	<td style="max-width: 200px;">{$step.name}</td>
            <td>{$approvetype}</td>
            <td>{$step.approvevalue}</td>
            {if $editprofile neq 'no'}
            <td align="center">
                <input name="alloweditbill" onclick="change_tablefield_presence(this,{$step.id},'approvestep_alloweditbill')"
                  type="checkbox" class="second_switch"  {if $step.alloweditbill eq 'yes'}checked{/if} {if $ISUSED eq 'yes'}disabled{/if} />
            </td>
            {/if}
        	<td align="center">
                <input name="ended" onclick="change_tablefield_presence(this,{$step.id},'approvestep_ended')"
                  type="checkbox" class="second_switch"  {if $step.ended eq 0}checked{/if} {if $ISUSED eq 'yes'||$step.concurrentstepinfo|sizeof >0}disabled{/if} />
            </td>
            <td align="center">
            
                <input name="step" onclick="change_tablefield_presence(this,{$step.id},'approvestep_step')"
                  type="checkbox" class="second_switch"  {if $step.step eq 0&&  $step.concurrentid lte 0}checked{/if} {if $step.countersigner eq 'yes'||$ISUSED eq 'yes'|| $step.concurrentid gt 0}disabled{/if} />
           
            </td>
            <td align="center">
                <input name="specifyapproverid" onclick="change_tablefield_presence(this,{$step.id},'approvestep_specifyapproverid')"
                  type="checkbox" class="second_switch"  {if $step.specifyapproverid eq 0}checked{/if} {if $ISUSED eq 'yes'}disabled{/if} />
            </td>
            <td align="center">
                {*duan 2022-3-30 设定是否加签不可以在界面上修改，但是先把保存做出来*}
                <input name="augmentsinger" onclick="change_tablefield_presence(this,{$step.id},'approvestep_augmentsinger')"
                type="checkbox" class="second_switch"  {if $step.augmentsinger neq ''}checked{/if} disabled="disabled" />
            </td>
            <td align="center">
                <a class="Anu3_a" href="javascript:void(0);" onclick="getCreateApproveStepForm('{$RECORD}','{$step.id}','{$BLOCKID}','{$step.name}','{$step.sequence}','edit','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="deleteApproveStep('{$step.id}','{$RECORD}','{$BLOCKID}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" >{'DELETE'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="gotomove('{$step.id}','{$RECORD}','{$BLOCKID}','up');">{'MOVEUP'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="gotomove('{$step.id}','{$RECORD}','{$BLOCKID}','down');">{'MOVEDOWN'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="AddConcurrentStep('{$step.id}','{$RECORD}','{$BLOCKID}');">{'AddConcurrent'|@getFixedLabel}</a>
            </td>
        </tr>
        {if $step.concurrentstepinfo|sizeof >0}
        
            {foreach item=concurrentstepinfo from=$step.concurrentstepinfo}
                <tr>
                  
                  	<td>{$concurrentstepinfo.name}</td>
                    <td> 
                        {if $concurrentstepinfo.approvetype eq 0}
                            {assign var="approvetype" value = 'SPECIFYUSER'|@getFixedLabel}
                        {elseif $concurrentstepinfo.approvetype eq 1}
                            {assign var="approvetype" value = 'SPECIFYROLE'|@getFixedLabel}
                        {elseif $concurrentstepinfo.approvetype eq 2}
                            {assign var="approvetype" value = 'SPECIFYPROMOTERDEP'|@getFixedLabel}
                        {elseif $concurrentstepinfo.approvetype eq 3}
                            {assign var="approvetype" value = 'LBL_POSITIONLEVEL'|@getFixedLabel}
                        {elseif $concurrentstepinfo.approvetype eq 5}
                            {assign var="approvetype" value = 'DATACREATOR'|@getFixedLabel}
                        {elseif $concurrentstepinfo.approvetype eq 6}
                            {assign var="approvetype" value = 'DATASSIGNEDTO'|@getFixedLabel}
                       {elseif $concurrentstepinfo.approvetype eq 4}
                            {assign var="approvetype" value = 'LBL_POSITIONDEPARTMENT'|@getFixedLabel}
                		{else}
                			{foreach key=fieldid item=fieldlabel from=$SELECT_APPRIVE_TYPE}
                				{if $concurrentstepinfo.approvetype eq $fieldid}
                					{assign var="approvetype" value = $fieldlabel}
                				{/if}
                			{/foreach}
                        {/if}
                    
                        {$approvetype}
                    </td>
                    <td>{$concurrentstepinfo.approvevalue}</td>
                    {if $editprofile neq 'no'}
                    <td align="center">
                        {*ls BUG0066440 20230516 kfbcrm-审批流程定制-自定义表单179-审批步骤中有步骤启用不了(并发步骤的id取值错误)*}
                        <input name="alloweditbill" onclick="change_tablefield_presence(this,{$concurrentstepinfo.id},'approvestep_alloweditbill')"
                          type="checkbox" class="second_switch"  {if $concurrentstepinfo.alloweditbill eq 'yes'}checked{/if} {if $ISUSED eq 'yes'}disabled{/if} />
                    </td>
                    {/if}
                	<td align="center">
                        <input name="ended" onclick="change_tablefield_presence(this,{$concurrentstepinfo.id},'approvestep_ended')"
                          type="checkbox" class="second_switch"  {if $concurrentstepinfo.ended eq 0}checked{/if} disabled />
                    </td>
                    <td align="center">
                        <input name="step" onclick="change_tablefield_presence(this,{$concurrentstepinfo.id},'approvestep_step')"
                          type="checkbox" class="second_switch"  {if $concurrentstepinfo.step eq 0}checked{/if} 
                          {if $concurrentstepinfo.countersigner eq 'yes'||$ISUSED eq 'yes'}disabled{/if} />
                    </td>
                    <td align="center">
                        <input name="specifyapproverid" onclick="change_tablefield_presence(this,{$concurrentstepinfo.id},'approvestep_specifyapproverid')"
                          type="checkbox" class="second_switch"  {if $concurrentstepinfo.specifyapproverid eq 0}checked{/if} {if $ISUSED eq 'yes'}disabled{/if}/>
                    </td>
                    <td align="center">
                        {*duan 2022-3-30 设定是否加签不可以在界面上修改，但是先把保存做出来*}
                        <input name="augmentsinger" onclick="change_tablefield_presence(this,{$concurrentstepinfo.id},'approvestep_augmentsinger ')"
                          type="checkbox" class="second_switch"  {if $concurrentstepinfo.augmentsinger neq ''}checked{/if} 
                          disabled="disabled" />
                    </td>
                    <td align="left">
                        <a class="Anu3_a" href="javascript:void(0);" onclick="getCreateApproveStepForm('{$RECORD}','{$concurrentstepinfo.id}','{$BLOCKID}','{$concurrentstepinfo.name}','{$step.sequence}','edit','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');">{'EDIT'|@getFixedLabel}</a>
                        <a class="Anu3_a" href="javascript:void(0);" onclick="deleteApproveStep('{$concurrentstepinfo.id}','{$RECORD}','{$BLOCKID}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" >{'DELETE'|@getFixedLabel}</a>
                        
                    </td>
                </tr>
            {/foreach}
        {/if}
    {/foreach}
</table>
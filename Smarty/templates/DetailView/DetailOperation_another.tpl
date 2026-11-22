<table width="100%" border="0" cellpadding="8" cellspacing="0">       
    <tr>
        <td align="left" class="genHeaderSmall" style='padding-top:9px;padding-left:7px;'>&nbsp;{'ASSOCIATIONTOCREATE'|@getFixedLabel}</td>
    </tr><tr>
    {assign var='isprint' value=0}
	{foreach key=key item=item from=$QUICKACTIONLINK}
		{if $item.permit eq 'yes'}
		{if $key > 0 && $key neq 64 && $key neq 9}<!-- 关联模块 -->
            <td align="left" style="padding-left:12px;">

			{if $item.click eq ''}
				<a href="index.php?module={$item.module}&action=EditView&return_module={$item.return_module}&return_action={$item.return_action}&parent_id={$ID}&parent_module={$MODULE}&Create=yes{$item.tag}" target="_blank">
					<span class="icon-homeimg icon-pointer"></span>{$item.label}
                </a>
			{elseif $item.module eq 'Stock'}
				<a href="javascript:;" onclick="{$item.click}" tag="{$item.tag}">
                    <img src="themes/images/pointer.gif" hspace="5" align="absmiddle" border="0" />{$item.label}
                </a>
            {else}
                <a href="javascript:;" onclick='ActionUserd_click(this,"{$MODULE}","{$item.module}","{$ID}");return false;' tag="{$item.tag}">
                    <span class="icon-homeimg icon-pointer"></span>{$item.label}
                </a>
			{/if}

            </td>


		{else}<!-- 特别判断 -->
            {if 64 eq $key}
				
				 <td align="left" style="padding-left:12px;">
					{if $item.click eq ''}
						<a href="index.php?module={$item.module}&action=EditView&return_module={$item.return_module}&return_action={$item.return_action}&parent_id={$ID}&parent_module={$MODULE}&Create=yes{$item.tag}" target="_blank">
							<span class="icon-homeimg icon-pointer"></span>{$item.label}
						</a>
					{else}
						<a href="javascript:;" onclick='ActionUserd_click(this,"{$MODULE}","{$item.module}","{$ID}");return false;' tag="{$item.tag}">
							<span class="icon-homeimg icon-pointer"></span>{$item.label}
						</a>
					{/if}
				
            </td>
            {elseif 9 eq $key}{* editor:gyq_13 reason:关联创建日程事件重写 date:20160608 *}
            <td align="left" style="padding-left:12px;">
                <a href=" javascript:createTemplateCalendars('index.php?module={$item.module}&action=EditView&return_module={$item.return_module}&return_action={$item.return_action}&parent_id={$ID}&parent_module={$MODULE}&Create=yes{$item.tag}');">
                    <span class="icon-homeimg icon-pointer"></span>{$item.label}
                </a>
            </td>
			{elseif -1 eq $key}<!-- 字段日志 -->
                <td align="left" style="padding-left:12px;">
				    <a href="javascript:showFieldHistory({$item.record},'{$MODULE}');"><span class="icon-homeimg icon-pointer"></span>{$item.label}</a>
                </td>
			{elseif '-10' eq $key}<!-- 负责人变更历史 -->
                <td align="left" style="padding-left:12px;">
				<a href="javascript:showAssignedUserHistory({$item.record},'{$MODULE}');"><span class="icon-homeimg icon-pointer"></span>{$item.label}</a>
                </td>
            {elseif -2 eq $key}<!-- 创建下级联系人 -->
                <td align="left" style="padding-left:12px;">
				<a href="index.php?module=Contacts&action=EditView&return_action=DetailView&parenttab=Parent Accounts&Create=true&contact_id={$ID}&account_id={$ACCOUNTID}" target="_blank">
                    <span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {$item.label}
                </a>
                </td>
            {elseif -3 eq $key}<!-- 查看上下级联系人 -->
                <td align="left" style="padding-left:12px;">
                <a href="index.php?module=Contacts&action=ContactsHierarchy&contact_id={$ID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'VIEW'|@getFixedLabel} {$item.label}</a>
                </td>
            {elseif -4 eq $key}<!-- 查看上下级客户 -->
                <td align="left" style="padding-left:12px;">
                <a href="javascript:void(0);" target="_blank" onclick="getAccountHierarchy('{$ID}','{$CONTACTSSTATUS}')"><span class="icon-homeimg icon-pointer"></span>{'LBL_SHOW_ACCOUNT_HIERARCHY'|@getFixedLabel}</a>
                </td>
            {elseif '-6' eq $key && $DLD_TYPE eq 'I' && $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
                <td align="left" style="padding-left:12px;">
                <!-- 下载附件 -->
                <a href="index.php?module=uploads&action=downloadfile&fileid={$FILEID}&entityid={$NOTESID}"  onclick="javascript:dldCntIncrease({$NOTESID});" >
                    <span class="icon-homeimg icon-pointer"></span>
                    {'DOWNLOADFILE'|@getFixedLabel}</a>
                </td>
            {elseif '-7' eq $key && $CHECK_INTEGRITY_PERMISSION eq 'yes'}<!-- 检查附件完整性 -->
                <td align="left" style="padding-left:12px;">
                    <a href="javascript:;" onClick="checkFileIntegrityDetailView({$NOTESID});">
                        <span class="icon-homeimg icon-pointer"></span>
                        {'CHECKATTACHMENTINTEGRITY'|@getFixedLabel}
                    </a>
                    <input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}">
                    <span id="vtbusy_integrity_info" style="display:none;">
                    <img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
                    <span id="integrity_result" style="display:none"></span>
                </td>
            {elseif '-8' eq $key && $DLD_TYPE eq 'I' &&  $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
                <td align="left" style="padding-left:12px;">
                <!-- 把附件作为电子邮件附件发送 -->
                <input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}"><!--attachment.gfi-->
                <a href="javascript: document.DetailView.return_module.value='Documents'; document.DetailView.return_action.value='DetailView'; document.DetailView.module.value='Documents'; document.DetailView.action.value='EmailFile'; document.DetailView.record.value={$NOTESID}; document.DetailView.return_id.value={$NOTESID}; sendfile_email();" class="webMnu"><span class="icon-homeimg icon-pointer"></span>{'SENTEMAILATTACHMENTS'|@getFixedLabel}</a>
                </td>
              {elseif '-11' eq $key}<!-- 考勤统计 -->
                <td align="left" style="padding-left:12px;">
                     <a href="javascript:var objoa=new JSOA('{$MODULE}',{$ID});objoa.showAttencePop(this);">
                    <span class="icon-homeimg icon-pointer"></span>
                    {'VIEWADDJOBBILLHISTORY'|@getFixedLabel}</a>
                </td>
            {elseif '-9' eq $key && $SMS_ISSET eq 'YES'}<!-- 发送短信 -->
                <td align="left" style="padding-left:12px;">
                <a href="javascript:CreateSendInform('{$MODULE}',document.getElementById('sendInformid'),'divSendInform',{$ID});">
                    <span class="icon-homeimg icon-pointer"></span>
                    {'Send_SMS'|@getFixedLabel}</a>
                </td>
            {elseif '-5' eq $key}<!-- 打印工具 -->
                {assign var='isprint' value=1}
			{/if}
		{/if}
	</tr>
		{/if}
	{/foreach}
    {if $isprint eq 1}<!-- 打印工具 -->
        {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'&& $MODULE neq 'Attachment'}
            <tr>
                <td align="left" class="genHeaderSmall" style='padding-top:9px;padding-left:7px;'>&nbsp;{'TOOLS'|@getFixedLabel}</td>
            </tr>
        {/if}
    {/if}
    <tr>
        {if $isprint eq 1}<!-- 打印工具 -->
            <td align="left" style="padding-left:8px;">
                {include file="DetailView/Toolbox_action.tpl"}
            </td>
        {/if}
    </tr>
</table>
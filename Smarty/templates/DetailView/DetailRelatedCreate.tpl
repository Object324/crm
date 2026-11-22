{if $QUICKACTIONLINK eq ''}
<ul class="D_btn_box">
	<li class="D_anu_a D_menu_hova D_menu_rcreate">
		<a title="{'ASSOCIATIONTOCREATE'|@getFixedLabel}" href="javascript:void(0);" style="color: #fff;">
			<b class="icon-homeimg icon-rcreate"></b>
            <span>{'ASSOCIATIONTOCREATE'|@getFixedLabel}</span>
		</a>
		<ol class="D_more_menua">
			<li>
                {foreach key=key item=item from=$QUICKACTIONLINK}
        		{if $item.permit eq 'yes'}
        		{if $key > 0 && $key neq 64 && $key neq 9}<!-- 关联模块 -->
        			{if $item.click eq ''}
        				<a href="index.php?module={$item.module}&action=EditView&return_module={$item.return_module}&return_action={$item.return_action}&parent_id={$ID}&parent_module={$MODULE}&Create=yes{$item.tag}" target="_blank">
        					{$item.label}
                        </a>
        			{elseif $item.module eq 'Stock'}
        				<a href="javascript:;" onclick="{$item.click}" tag="{$item.tag}">
                            {$item.label}
                        </a>
                    {else}
                        <a href="javascript:;" onclick='ActionUserd_click(this,"{$MODULE}","{$item.module}","{$ID}");return false;' tag="{$item.tag}">
                            {$item.label}
                        </a>
        			{/if}
        
        		{else}<!-- 特别判断 -->
                    {if 64 eq $key}
        				
        				
        					{if $item.click eq ''}
        						<a href="index.php?module={$item.module}&action=EditView&return_module={$item.return_module}&return_action={$item.return_action}&parent_id={$ID}&parent_module={$MODULE}&Create=yes{$item.tag}" target="_blank">
        							{$item.label}
        						</a>
        					{else}
        						<a href="javascript:;" onclick='ActionUserd_click(this,"{$MODULE}","{$item.module}","{$ID}");return false;' tag="{$item.tag}">
        							{$item.label}
        						</a>
        					{/if}

                    {elseif 9 eq $key}{* editor:gyq_13 reason:关联创建日程事件重写 date:20160608 *}
                        <a href=" javascript:createTemplateCalendars('index.php?module={$item.module}&action=EditView&return_module={$item.return_module}&return_action={$item.return_action}&parent_id={$ID}&parent_module={$MODULE}&Create=yes{$item.tag}');">
                            {$item.label}
                        </a>
                    {elseif -2 eq $key}<!-- 创建下级联系人 -->
        				<a href="index.php?module=Contacts&action=EditView&return_action=DetailView&parenttab=Parent Accounts&Create=true&contact_id={$ID}&account_id={$ACCOUNTID}" target="_blank">
                            {'LBL_Creates'|@getFixedLabel} {$item.label}
                        </a>
                    {elseif '-6' eq $key && $DLD_TYPE eq 'I' && $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
                        <!-- 下载附件 -->
                        <a href="index.php?module=uploads&action=downloadfile&fileid={$FILEID}&entityid={$NOTESID}"  onclick="javascript:dldCntIncrease({$NOTESID});" >
                            {'DOWNLOADFILE'|@getFixedLabel}</a>
                    {elseif '-7' eq $key && $CHECK_INTEGRITY_PERMISSION eq 'yes'}<!-- 检查附件完整性 -->
                            <a href="javascript:;" onClick="checkFileIntegrityDetailView({$NOTESID});">
                                {'CHECKATTACHMENTINTEGRITY'|@getFixedLabel}
                            </a>
                            <input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}">
                            <span id="vtbusy_integrity_info" style="display:none;">
                            <img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
                            <span id="integrity_result" style="display:none"></span>
                    {elseif '-8' eq $key && $DLD_TYPE eq 'I' &&  $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
                        <!-- 把附件作为电子邮件附件发送 -->
                        <input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}"><!--attachment.gfi-->
                        <a href="javascript: document.DetailView.return_module.value='Documents'; document.DetailView.return_action.value='DetailView'; document.DetailView.module.value='Documents'; document.DetailView.action.value='EmailFile'; document.DetailView.record.value={$NOTESID}; document.DetailView.return_id.value={$NOTESID}; sendfile_email();" class="webMnu">{'SENTEMAILATTACHMENTS'|@getFixedLabel}</a>
                    {elseif '-11' eq $key}<!-- 考勤统计 -->
                             <a href="javascript:var objoa=new JSOA('{$MODULE}',{$ID});objoa.showAttencePop(this);">
                            {'VIEWADDJOBBILLHISTORY'|@getFixedLabel}</a>
                    {elseif '-9' eq $key && $SMS_ISSET eq 'YES'}<!-- 发送短信 -->
                        <a href="javascript:CreateSendInform('{$MODULE}',document.getElementById('sendInformid'),'divSendInform',{$ID});">
                            {'Send_SMS'|@getFixedLabel}</a>
        			{/if}
        		{/if}
        		{/if}
        	{/foreach}
            </li>
		</ol>
	</li>
    {if ''|@checkCurrentUserIsAdmin eq 'on'}
        <li class="D_anu_a D_menu_hova D_menu_rcreate" style="border-left: 1px solid #fff;margin-left: -6px;border-top-left-radius: 0;border-top-right-radius: 4px;border-bottom-right-radius: 4px;border-bottom-left-radius: 0;">
            <a title="{'SETTINGS'|@getFixedLabel}" href="javascript:QuickSetaction(this,'{$MODULE}','','');">
                <b class="icon-homeimg icon-rcreateset"></b>
                <span style="margin-right: -10px;"> </span>
            </a>
        </li>
    {/if}
</ul>
{/if}
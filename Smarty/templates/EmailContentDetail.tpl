{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
 <!--修改编码格式:统一编码：UTF-8-->
-->*}
{*ls 2021-11-09 【ID1002161】模块相关信息邮件管理功能优化（用友-马朝军）(查看邮件)*}
    <div class="clear"></div>
{if $popup neq 'yes'}
    <div class="emailBtnlist">
        <!--分页-->
        <div class="PageDiv0">
            <ul class="rfloat">
            {if $PREVRECORDID gt 0}
                <li><a href="javascript:void(0);" style="margin-right: 15px;" onclick="getPrevEmail({$PAGESTART}, {$MAILINFO->mailrecordid})" >上一封</a></li>
            
            {else}
                <li><a href="javascript:void(0);" style="margin-right: 15px;" class="no-prevpage" >上一封</a></li>
            {/if}
            {if $NEXRECORDID gt 0}
                <li><a href="javascript:void(0);" onclick="getNexEmail({$PAGESTART},{$MAILINFO->mailrecordid})">下一封</a></li>
            {else}
                <li><a href="javascript:void(0);" class="no-nextpage">下一封</a></li>
            {/if}
            </ul>
        </div>
        <!--分页  end-->  
        <div class="emailBtn">
            <ul class="ulbtn" style="margin-right: 15px;">
                <li>
                    <span class="ld-button ld-button-primary" onclick="EmailContent_Back()">返回</span>
                </li>
                <li>
                    <span class="ld-button ld-button-primary" onclick="Email_Reply({$MAILINFO->mailrecordid})">回复</span>
                </li>
                <li>
                    <span class="ld-button ld-button-primary" onclick="Email_Reply_All({$MAILINFO->mailrecordid})">回复全部</span>
                </li>
                <li>
                    <span class="ld-button ld-button-primary" onclick="Email_Transfer({$MAILINFO->mailrecordid})">转发</span>
                </li>
            </ul>
        </div>
    </div>
{/if}

    <div class="clear"></div>
    <!--列表being-->
    <div class="emialList" style="margin-top: -1px !important;border-top: 1px solid #ddeaf7;">
    <div id="rssScroll" class="emailDetailDiv">
        <table cellspacing="1" border="0" cellpadding="0" width="100%" class="listEntries fir-center emailListcontent" style="border-collapse:separate !important;">
            <tr>
                <td height="24" valign="middle" style="word-break:break-all;padding:9px 8px 2px 14px;background-color: #eff5fb;">
                     <p>主题：{$MAILINFO->msubject}</p>
                    <p>发件人：{$MAILINFO->mfrom|@htmlentities}</p>
                    <p>时   间：{$MAILINFO->mdate}</p>
                    <p>收件人：{$MAILINFO->mto|@htmlentities}</p>
                    {if $MAILINFO->mcc eq ""}
                    {else}
                        <p>抄送：{$MAILINFO->mcc|@htmlentities}</p>
                    {/if}
                     {if $MAILINFO->attachments|@count>0}
                            <p>附   件：{$MAILINFO->attachments|@count}个</p>
                     {/if}
                </td>
            </tr>
        </table>
        <div style="padding: 15px 15px 10px 15px;">
            {$MAILINFO->mbody|@html_entity_decode}
        </div>
        {if $MAILINFO->attachments|@count>0}
            <div class="attachment-email">附件({$MAILINFO->attachments|@count}个)</div>
            <div class="attachment-email-list">
                <p class="attachment-email-title">普通附件</p>
                {foreach from =$MAILINFO->attachments item =attachmentinfo}
                    <div class="attachitem">
                        <div class="ico_big">
                            <a href="javascript:void(0);"><img style="width:auto;" src="themes/softed/images/fu_txt.gif"></a>
                        </div>
                        <div>
                            <span>{$attachmentinfo['filename']}</span>
                            <div>
                                <a target="_blank" href="index.php?module=Emails&action=EmailsAjax&file=emailfilepreview&filename={$attachmentinfo['filename']}&mailrecordid={$MAILINFO->mailrecordid}" title="预览" >预览</a>&nbsp;&nbsp;
                                <a title="点击下载" href="index.php?module=Emails&action=EmailsAjax&file=emailfiledownload&filename={$attachmentinfo['filename']}&mailrecordid={$MAILINFO->mailrecordid}">下载</a>
                            </div>
                        </div>
                    </div>        
                 {/foreach}     
            {/if}         
        </div>
    </div>
</div>
<!--列表end-->
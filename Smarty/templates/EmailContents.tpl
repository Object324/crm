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
<input name="idlist" type="hidden">
<input id="search_url" type="hidden" value="" name="search_url">
<input id="excludedRecords" type="hidden" value="" name="excludedRecords">
<input id="numOfRows" type="hidden" value="" name="numOfRows">
<input id="allids" type="hidden" value="" name="allids">
<input id="selectedboxes" type="hidden" value="" name="selectedboxes">
<input id="allselectedboxes" type="hidden" value="" name="allselectedboxes">
<input id="current_page_boxes" type="hidden" value="" name="current_page_boxes">
<div class="allEmail">
    {if $LISTYPE eq 'receive' ||$LISTYPE eq ''}
        <span id="mail_recevive">
        收件箱<font class="font12 fontnormal">（共<span name='totalemailcount'>{$TOTALROWS}</span>封邮件，其中&nbsp;
        <a href="javascript:void(0);" onclick="getUnReadMailList()">{$UNREADCOUNT}未读邮件</a>&nbsp;<span name="unreadcount"></span>封）</font>
        </span>
    {elseif $LISTYPE eq 'deleted'}
        <span id="mail_delete">
        已删除<font class="font12 fontnormal">（共<span name='totalemailcount'>{$TOTALROWS}</span>封邮件）</font>
        </span>
    {elseif $LISTYPE eq 'smtp'}
        <span id="mail_delete">
        已发送<font class="font12 fontnormal">（共<span name='totalemailcount'>{$TOTALROWS}</span>封邮件）</font>
        </span>
    {elseif $LISTYPE eq 'starmail'}
        <span id="mail_star">
        星标邮件<font class="font12 fontnormal">（共<span name='totalemailcount'>{$TOTALROWS}</span>封邮件）</font>
        </span>
    {/if}
</div>
<div class="emailBtn" style="text-align: center;position: relative;">
    <ul class="ulbtn" style="position: relative;left: 50%;">
        <li style="position: relative;right: 50%;">
            <select class="ld-select-inner" name="search_field" id="search_field" onchange="email_Searchfn();">
                <option value="all" {if $SEARCHFIELD eq 'all'}selected{/if}>邮件全文检索</option>
                <option value="msubject" {if $SEARCHFIELD eq 'msubject'}selected{/if}>主题</option>
                <option value="mfrom" {if $SEARCHFIELD eq 'mfrom'}selected{/if}>发件人</option>
                <option value="mto" {if $SEARCHFIELD eq 'mto'}selected{/if}>收件人</option>
                <option value="mbody" {if $SEARCHFIELD eq 'mbody'}selected{/if}>内容</option>
            </select>
        </li>
        <li style="position: relative;right: 50%;">
            <input class="ld-input-inner" type="text" name="search_text" id="search_text" value="{$SEARCHTEXT}" onkeyup="searchmail_keyup(event);" style="width: 230px;">
        </li>
        <li style="position: relative;right: 50%;"><input type="button" class="ld-button ld-button-primary" name="find" value="查找" onclick="email_Searchfn();"></li>
    </ul>
</div>
<div class="clear"></div>
<div class="emailBtnlist">
    <!--分页-->
    <div class="PageDiv0" {if $TOTALROWS lte 0} style="display:none"{/if}>
        <ul style="float:right;">

            <li> 共 {$TOTALROWS} 条记录</li>
            {if $PAGESTART gt 1}
                <li><span class="icon-prevpage" title="{'PREVPAGE'|@getFixedLabel}" onclick="EmailPageList('Emails','{$PAGESTART-1}');"></span></li>

            {else}
                <li><span class="no-icon-prevpage"></span></li>
            {/if}
            <input name="pagenum" type="text" class="txtBox btn-radius-system pagenum_system" value="{$PAGESTART}" onchange="EmailPageList('Emails',this.value);" onkeypress="return VT_disableFormSubmit(event);">
            <li style="float:right;padding-left:5px;padding-right:5px;">
                <span title="GO"><a href="javascript:void(0);">GO</a></span>
            </li>
            <li class="Input">{$PAGESTART}/{$TOTALPAGES}</li>
            {if $PAGESTART lt $TOTALPAGES}
                <li>
                    <span class="icon-nextpage" title="{'NEXTPAGE'|@getFixedLabel}" onclick="EmailPageList('Emails','{$PAGESTART+1}');"></span>
                </li>
            {else}
                <li><span class="no-icon-prevpage"></span></li>
            {/if}
        </ul>
    </div>
    <!--分页  end-->
    <div class="emailBtn"">
    <ul class="ulbtn" style="margin-right: 15px;">
        {if $LISTYPE neq 'deleted'}
            <li>
                <span class="ld-button ld-button-primary" onClick="return EmailDelete(1);">{'DELETE'|@getFixedLabel}</span>
            </li>
        {else}
            <li>
                <span class="ld-button ld-button-primary" onClick="EmailReduction();">{'REDUCTION'|@getFixedLabel}</span>
            </li>
        {/if}
        <li>
            <span class="ld-button ld-button-primary" onClick="return EmailDelete(2);">{'COMPLETELYDELETED'|@getFixedLabel}</span>
        </li>
        <li class="a_btn_more">
                    <span class="ld-button ld-button-primary">
                        <a href="javascript:void(0);">
                            <span class="greyFontF">{'MARKEDAS'|@getFixedLabel}...</span>
                            <span class="icon-homeimg ico_select_s"></span>
                        </a>
                        <div class="emailbtn-list">
                            <a href="javascript:void(0);" onclick="updateMailSeen(1)">{'READMAIL'|@getFixedLabel}</a>
                            <a href="javascript:void(0);" onclick="updateMailSeen(0)">{'UNREADMAIL'|@getFixedLabel}</a>
                            <a href="javascript:void(0);" onclick="updateStarMail('yes')">{'STARMAIL'|@getFixedLabel}</a>
                            <a href="javascript:void(0);" onclick="updateStarMail('no')">{'NOSTARMAIL'|@getFixedLabel}</a>
                        </div>
                    </span>
        </li>
        <li class="a_btn_more">
            {*                    <span class="ld-button ld-button-primary">*}
            {*                        <a href="javascript:void(0);">*}
            {*                            <span class="greyFontF" onclick="return EmailDelete(1);">{'DELETE'|@getFixedLabel}</span>*}
            {*                            <span class="icon-homeimg ico_select_s"></span>*}
            {*                        </a>*}
            {*                        <div class="emailbtn-list">*}
            {*                            48973: 邮箱管理》已删除列表，选择邮件后无法恢复到收件箱、已发送(没有这个方法)*}
            {*                            <a href="javascript:void(0);" onclick="('receive')">{'INBOX'|@getFixedLabel}</a>*}
            {*                            <a href="javascript:void(0);" onclick="emailmove('send')">{'LBL_SENT_MAILS'|@getFixedLabel}</a>*}
            {*                            <a href="javascript:void(0);" style="display:none">{'DUSTBIN'|@getFixedLabel}</a>*}
            {*                            {if $LISTYPE neq 'deleted'}*}
            {*                                <a href="javascript:void(0);" onclick="return EmailDelete(1);">{'DELETED'|@getFixedLabel}</a>*}
            {*                            {else}*}
            {*                                <a href="javascript:void(0);" onclick="return EmailDelete(1);">{'LBL_SENT_MAILS'|@getFixedLabel}</a>*}
            {*                            {/if}*}
            {*                        </div>*}
            {*                    </span>*}
        </li>
    </ul>
    <div style="display:none">{include file='EmailSearchScope.tpl'}</div>
</div>
</div>
<div class="clear"></div>
<!--列表being-->
<div class="emialList">

    <div id="rssScroll" class="emailListDiv" style="max-height: 720px">
        <input type="hidden" name="onePageNum" id="onePageNum" value="{if $MAILLIST|@is_array}{$MAILLIST|@count}{else}0{/if}"/>
        <table cellspacing="0" border="0" cellpadding="0" width="100%" class="listEntries fir-center emailListcontent" style="border-collapse:separate !important;">
            <tr>
                <th class="ctextalign BgcolorF8" width="25px"><input type="checkbox"  name="selectall" onclick="selectallmails(this.checked)"/></th>
                <th width="20%" class="BgcolorF8" onclick="email_orderlist('mfrom','{$ORDERTYPE}')">
                    发件人
                    {if $ORDERBY eq 'mfrom'}
                        <span class="arrow {$ORDERTYPE}" ></span>

                    {/if}
                </th>
                <th width="27%" class="BgcolorF8" onclick="email_orderlist('msubject','{$ORDERTYPE}')">
                    {'Theme'|@getFixedLabel}
                    {if $ORDERBY eq 'msubject'}
                    <span class="arrow {$ORDERTYPE}">

                    {/if}
                </th>
                <th width="15%" class="BgcolorF8" onclick="email_orderlist('mdate','{$ORDERTYPE}')">
                    {'TIMES'|@getFixedLabel}
                    {if $ORDERBY eq 'mdate'}
                    <span class="arrow {$ORDERTYPE}">
               
                {/if}
                </th>
                <th width="25%" class="BgcolorF8">附件</th>
                <th width="8%" class="BgcolorF8">大小</th>
                <th width="5%" class="BgcolorF8">星标</th>
            </tr>
            {if $AJAX eq 'yes'}
                <tr style="display:none" id="email_tr_detail_all" >
                    <td align="center" colspan="5" class="bgwhite" >
                        <span class="selectall" style="display:none"  id="email_span_detail_all" onclick="emailselectallrecord()">
                        全选所有{$TOTALROWS}条记录
                        </span>
                        <span class="selectall" style="display:none" id="email_span_detail_unall" onclick="emailunselectallrecord()">
                        取消所有选择
                        </span>
                    </td>
                </tr>
                {foreach from=$MAILLIST item=listInfo }
                    {*BUG0072203 ls 20230905 kfbcrm-邮件管理 隔行换色不可用 以前邮件的隔行换色方法废弃了,使用listview.js的公共方法*}
                    <tr bgcolor="white" onmouseover="listOnMouseOver(ld(this), 'tag');" onmouseout="listOnMouseOut(ld(this),'on');" class="Hover {if $listInfo->seen neq 1} folder{/if}" id="row_{$listInfo->mailrecordid}" >
                        <td class="ctextalign"><input type="checkbox" name="mc_box" onclick="return email_chkclick(event)" ondblclick="return email_chkclick(event)"  tag="{$listInfo->mailrecordid}"></td>
                        <td width="20%" onclick ="EmailContentClick(ld(this),{$listInfo->mailrecordid})">{$listInfo->mfrom}</td>
                        <td width="40%" onclick ="EmailContentClick(ld(this),{$listInfo->mailrecordid})">{$listInfo->msubject}</td>
                        <td width="15%" onclick ="EmailContentClick(ld(this),{$listInfo->mailrecordid})">{$listInfo->mdate}</td>
                        <td width="20%">
                            {*ls 2021-11-09 【ID1002161】模块相关信息邮件管理功能优化（用友-马朝军）*}
                            {if $listInfo->attachments|@is_array && $listInfo->attachments|@count>0}
                                {foreach from =$listInfo->attachments item=attachmentinfo}
                                    <div style="clear: both; padding-top: 1px;">
                                        <div style="display: flex;">
                                            <span data-tip="{$attachmentinfo['filename']}" onmouseenter="tooltip.bind(this)" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;display: inline-block;">{$attachmentinfo['filename']}</span>
                                            <span style="width: 100px;">
                                                <a target="_blank" href="index.php?module=Emails&action=EmailsAjax&file=emailfilepreview&filename={$attachmentinfo['filename']}&mailrecordid={$listInfo->mailrecordid}" title="{'PREVIEW'|@getFixedLabel}" >{'PREVIEW'|@getFixedLabel}</a>&nbsp;&nbsp;
                                                <a title="{'DOWNLOAD'|@getFixedLabel}" href="index.php?module=Emails&action=EmailsAjax&file=emailfiledownload&filename={$attachmentinfo['filename']}&mailrecordid={$listInfo->mailrecordid}">{'DOWNLOAD'|@getFixedLabel}</a>
                                            </span>
                                        </div>
                                    </div>
                                {/foreach}
                            {/if}
                        </td>
                        <td>
                            {if $listInfo->attachments|@is_array && $listInfo->attachments|@count>0}
                                {foreach from =$listInfo->attachments item=attachmentinfo}
                                    <div style="clear: both; padding-top: 1px;">
                                        <span style="float: left;">{$attachmentinfo['filesize']}</span>
                                    </div>
                                {/foreach}
                            {/if}
                        </td>
                        <td>
                            {if $listInfo->starmail eq 'yes'}
                                <input class="star-icon star_icon_yes" onclick="setstarmail({$listInfo->mailrecordid})" type="button" hidefocus="">
                            {else}
                                <input class="star-icon star_icon_no" onclick="setstarmail({$listInfo->mailrecordid})" type="button" hidefocus="">
                            {/if}
                        </td>
                    </tr>
                    {foreachelse}
                    <tr bgcolor="#fff">
                        <td align="center" colspan="5" class="bgwhite" style="height:0px;padding: 0;">

                            {* <div class="warningTableContent" style="z-index:600;">
                                <div class="wtc_img">
                                    <img src="themes/icon2023/ld-no-records.png"/>
                                </div><div class="wtc_content">{'NOTFOUNDANYRECORD'|@getFixedLabel}</div>
                                <div class="wtc_btn"></div>
                                <div></div>
                            </div> *}
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                {/foreach}
            {else}
                <tr bgcolor="#fff">
                    <td align="center" colspan="5" class="bgwhite" style="height:0px;padding: 0;">

                        {* <div class="warningTableContent" style="z-index:600;">
                            <div class="wtc_img">
                                <img src="themes/icon2023/ld-no-records.png"/>
                            </div><div class="wtc_title"></div>
                            <div class="wtc_btn"></div>
                            <div></div>
                        </div> *}
                        {include file="NoRecords.tpl"}
                    </td>
                </tr>
            {/if}
        </table>
    </div>
    <div id="EmailDetails"></div>
</div>
<!--列表end-->
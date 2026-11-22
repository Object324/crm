{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************** *}
<!--修改编码格式:统一编码：UTF-8-->
{if $COMMENTMODE neq 'concise'}
<div class="ld-detail-ModComments-show" id="modcomment_id_{$record}">
    <div class="ld-detail-ModComments-show-Publisher">
        <div class="ld-detail-ModComments-show-portrait" style="background-image: url({$COMMENTMODEL->userimagestr()});"></div>
        <div class="ld-detail-ModComments-show-Publisher-info">
            <div class="ld-detail-ModComments-show-Publisher-name">{$COMMENTMODEL->author()}<span style="font-size: 12px;font-weight: 500;color: #666;margin-left: 8px;">{'PUBLISHModComments'|@getFixedLabel}</span></div>
            <div class="ld-detail-ModComments-show-Publisher-time">{$COMMENTMODEL->timestamp()}&nbsp;&nbsp;{if $COMMENTMODEL->getccrangeCount() neq ''}<span><a href="javascript:void(0);" data-modcommentid="{$record}" data-type="commnet" data-remindusers="{$COMMENTMODEL->getRemindUsers()}" data-tag="modcommenttip">{$COMMENTMODEL->getccrangeCount()}</span>{/if}</div>
        </div>
    </div>
    <div class="ld-detail-ModComments-show-content">
        <div class="ld-detail-ModComments-show-content-txt">
            <span style="color:#181C25;font-size:14px;line-height: 20px;">{$COMMENTMODEL->content()|@nl2br}</span>
        </div>
        <div class="ld-detail-ModComments-show-content-image" {if $COMMENTMODEL->isFileImgShow('image') eq 'no'}style="display: none" {/if}>
            {$COMMENTMODEL->getFileImgContent('image')}
        </div>
        <div class="ld-detail-ModComments-show-content-attach" {if $COMMENTMODEL->isFileImgShow('filename') eq 'no'}style="display: none" {/if}>
            <div class="ld-detail-ModComments-show-attachlist">
                <div class="ld-detail-ModComments-show-attachtop">
                    <span>{'Attachment'|@getFixedLabel}：{$COMMENTMODEL->getFileImgCounts('filename')}{'GECOUNT'|@getFixedLabel}</span>
                </div>
                <div class="ld-detail-ModComments-show-attach-list">
                    {$COMMENTMODEL->getFileImgContent('filename')}
                </div>
            </div>
        </div>
        <div class="ld-detail-ModComments-show-content-return">
            {if $COMMENTMODEL->isReply() eq 'yes'}
                <div class="ld-detail-reply" data-type="comment" onclick="ModCommentsCommon.showReplydiv('{$record}', '{$record}');" >
                    <span>{'Reply'|@getFixedLabel}{if $COMMENTREPLYCOUNT[$record]>0}(<label id="comment_{$record}_reply_count">{$COMMENTREPLYCOUNT[$record]}</label>){/if}</span>
                </div>
            {/if}
            {if $COMMENTMODEL->isDelete() eq 'yes' && $COMMENTREPLYCOUNT[$record]<=0}
                <div class="ld-detail-del" data-type="comment" data-parentid="" onclick="delModComment(this,{$record})">
                    <span>{'DELETE'|@getFixedLabel}</span>
                </div>
            {/if}
        </div>
    </div>
    {assign var='replyedid' value=$record}
    {assign var='parentid' value=$record}
    {assign var='defaultcontent' value=$COMMENTMODEL->getDefalutReplyContent()}
    {include file="modules/ModComments/widgets/ModCommentReplydiv.tpl"}
    {foreach item=REPLYMODEL from=$REPLYS}
        {assign var='parentcomment' value=$REPLYMODEL->getParentComments()}
        {assign var='replyid' value=$REPLYMODEL->getRecord()}
        {assign var='replyedid' value=$replyid}
        {assign var='defaultcontent' value=$REPLYMODEL->getDefalutReplyContent()}
        {if $parentcomment eq $record}
            <div style="margin-left: 25px;margin-bottom: 30px;{if $COMMENTREPLYCOUNT[$record]>5 && $REPLYLISTHIDDEN eq 'yes'}display:none;{/if}" id="modcomment_replyid_{$replyid}" date-type="reply_div">
                <div class="ld-detail-ModComments-show-Publisher" style="padding-top: 0px;">
                    <div class="ld-detail-ModComments-show-portrait" style="background-image: url({$REPLYMODEL->userimagestr()});"></div>
                    <div class="ld-detail-ModComments-show-Publisher-info">
                        <div class="ld-detail-ModComments-show-Publisher-name">{$REPLYMODEL->author()}<span style="font-size: 12px;font-weight: 500;color: #666;margin-left: 8px;">{if $REPLYMODEL->getParentReply()>0}{else}{'REPLIED'|@getFixedLabel}{'ModComments'|@getTranstab}{/if}</span></div>
                        <div class="ld-detail-ModComments-show-Publisher-time">{$REPLYMODEL->timestamp()}&nbsp;&nbsp;{if $REPLYMODEL->getccrangeCount() neq ''}<span><a href="javascript:void(0);" data-modcommentid="{$replyid}"  data-type="reply" data-remindusers="{$REPLYMODEL->getRemindUsers()}" data-tag="modcommenttip">{$REPLYMODEL->getccrangeCount()}</span>{/if}</div>
                    </div>
                </div>
                <div class="ld-detail-ModComments-show-content">
                    <div class="ld-detail-ModComments-show-content-txt">
                        <span style="color:#181C25;font-size:14px;line-height: 26px;">{$REPLYMODEL->content()|@nl2br}</span><span style="color: #0a8cff"></span>
                    </div>
                    <div class="ld-detail-ModComments-show-content-image" {if $REPLYMODEL->isFileImgShow('image') eq 'no'}style="display: none" {/if}>
                        {$REPLYMODEL->getFileImgContent('image')}
                    </div>
                    <div class="ld-detail-ModComments-show-content-attach" {if $REPLYMODEL->isFileImgShow('filename') eq 'no'}style="display: none" {/if}>
                        <div class="ld-detail-ModComments-show-attachlist">
                            <div class="ld-detail-ModComments-show-attachtop">
                                <span>{'Attachment'|@getFixedLabel}：{$REPLYMODEL->getFileImgCounts('filename')}{'GECOUNT'|@getFixedLabel}</span>
                            </div>
                            <div class="ld-detail-ModComments-show-attach-list">
                                {$REPLYMODEL->getFileImgContent('filename')}
                            </div>
                        </div>
                    </div>
                    <div class="ld-detail-ModComments-show-content-return">
                        {if $REPLYMODEL->isReply() eq 'yes'}
                            <div class="ld-detail-reply" data-type="reply" onclick="ModCommentsCommon.showReplydiv('{$replyid}', '{$record}');">
                                <span class="blueFont">{'Reply'|@getFixedLabel}</span>
                            </div>
                        {/if}
                        {if $REPLYMODEL->isDelete() eq 'yes'}
                            <div class="ld-detail-del" data-type="reply" data-parentid="{$record}" onclick="delModComment(this,{$replyid})">
                                <span style="color:red;">{'DELETE'|@getFixedLabel}</span>
                            </div>
                        {/if}
                    </div>
                </div>
                {include file="modules/ModComments/widgets/ModCommentReplydiv.tpl"}
            </div>
        {/if}
    {/foreach}
</div>

{else}
<div class="ld-detail-ModComments-show" id="modcomment_id_{$record}" style="border: none; margin: 0;">
    <div class="ld-detail-ModComments-show-Publisher" style="padding-left: 0; padding-top: 6px;">
        <div class="ld-detail-ModComments-show-Publisher-info" style="max-width: 100%; width: 100%;">
            <div class="ld-detail-ModComments-show-Publisher-name ld-detail-ModComments-show-Publisher-name-dark" style=" float: left; width: fit-content; font-weight: normal; color: #181C25;">{$COMMENTMODEL->author()}<span style="font-size: 12px;font-weight: 500;color: #666;margin-left: 10px;"></div>

            <div class="ld-detail-ModComments-show-Publisher-time" style=" float: left; color:#181C25; font-size: 13px; line-height: 20px; margin-right: 10px;">{$COMMENTMODEL->timestamp()}</div>

            <div class="ld-detail-ModComments-show-content-txt" style=" float: left;">
            <span style="font-size:14px;line-height: 20px;">{$COMMENTMODEL->content()|@nl2br}</span>
            </div>

            <div class="ld-detail-del" data-type="comment" data-parentid="" onclick="delModComment(this,{$record})" style="position: absolute; right: 0; margin-right: 20px;">
                {*BUG0069689 txy 20230718 kfbcrm-单据评论区-发布和删除字段头对齐*}
                {if $COMMENTMODEL->isDelete() eq 'yes'}
                <span style="color: #3B7CFF;padding-right: 9px; ">{'DELETE'|@getFixedLabel}</span>
                {/if}
            </div>

        </div>
    </div>
</div>  
{/if}
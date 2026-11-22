{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************
 *}
<!--修改编码格式:统一编码：UTF-8-->

{foreach item=COMMENTMODEL from=$COMMENTS}
	{assign var='record' value=$COMMENTMODEL->getRecord()}
	{include file="modules/ModComments/widgets/DetailViewBlockCommentItem.tpl" COMMENTMODEL=$COMMENTMODEL}
{foreachelse}
    {* zkt 20230417 BUG0064911 评论没有消息时，下方增加文字提示信息“暂无内容”，英文标签：No content *}
    <div id="modcomment_nocomment_{$ID}" style="height: 40px; line-height: 40px; text-align: center;">{'NOCONTENT'|@getFixedLabel}</div>
{/foreach}
	
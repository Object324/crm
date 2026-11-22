<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <style>
        .attachitem{
            font-size: 14px;
            overflow: hidden;
            margin: 0;
            padding: 5px 2px;
            clear: both;
            min-height: 40px;
        }
        .attachitem .ico_big {
            float: left;
            margin: 2px 8px 0 0;
        }
        .ico_big a {
            text-decoration: none;
        }

    </style>
</head>
<body style="width: 1200px; margin: 0 auto;">
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
                    <a href="javascript:void(0);"><img style="width:auto;" src="../../themes/softed/images/fu_txt.gif"></a>
                </div>
                <div>
                    <span>{$attachmentinfo['filename']}</span>
                    <div>

                        <a title="点击下载" href="../../index.php?module=CustomForm48&action=CustomForm48Ajax&file=yuwangemailfiledownload&filename={$RECORD}_{$attachmentinfo['filename']}&record={$RECORD}">下载</a>
                    </div>
                </div>
            </div>
            {/foreach}
            {/if}
        </div>
    </div>
</div>
<!--列表end-->
</body>
</html>
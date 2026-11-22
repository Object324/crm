<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<div id="editContent" style="max-height: 500px;overflow-y: scroll;">
    <form action="index.php?module=CardSettings&action=SaveCompanyBrief" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
        <input type="hidden" name="organization_id" value="{$OrganizationInfo.organization_id}"/>
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td align="right" width="10%"><font color="red">*</font>{'MAILTITLE'|@getFixedLabel}</td>
                <td align="left" width="90%"><input type="text" name="brief_title" class="detailedViewTextBox btn-radius-system" value="{$OrganizationInfo.brief_title}"/></td>
            </tr>
            <tr>
                <td align="right" width="10%"><font color="red">*</font>{'BRIEF'|@getFixedLabel}</td>
                <td align="left" width="90%">
                    <textarea class="diy-textarea" id="brief" name="brief" class="detailedViewTextBox btn-radius-system" style="margin-top:10px;margin-bottom:10px;">{$OrganizationInfo.brief}</textarea>
                </td>
            </tr>
            <tr>
                <td align="right" width="10%">{'Uploadpictures'|@getFixedLabel}</td>
                <td align="left" width="90%">
                    <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                        <input type="file" name="brief_image" accept="image/*" id="brief_image" onchange="CardSettingsobj.validateFilename(this)">
                    </a>
                    <span class="info" name="span_brief_image" style="padding-left:5px;">{$OrganizationInfo.image_main}</span>
                </td>
            </tr>
            <tr>
                <td align="right" width="10%">{'VIDEOLINK'|@getFixedLabel}</td>
                <td align="left" width="90%">
                    <input type="text" name="video_link" class="detailedViewTextBox btn-radius-system" value="{$OrganizationInfo.video_link}"/></td>
                </td>
            </tr>
            <tr>
                <td align="right" width="10%">{'VIDEOCOVER'|@getFixedLabel}</td>
                <td align="left" width="90%">
                    <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                        <input type="file" name="video_cover" accept="image/*" id="brief_image" onchange="CardSettingsobj.validateFilename(this)">
                    </a>
                    <span class="info" name="span_video_cover" style="padding-left:5px;">{$OrganizationInfo.video_cover}</span>
                </td>
            </tr>

        </table>
    </form>
</div>

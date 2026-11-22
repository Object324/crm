<!--*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ('License'); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<div class="mailClient mailClientBg" style="width:700px">
    <form name="commentwidget">
        <table border="0" cellpadding="5" cellspacing="0" width="100%">
        <tbody>
            <tr>
                <td class="mailSubHeader" align="left">
                    <b style="font-size:14px">{'ADDCOMMENT'|@getFixedLabel}</b>
                </td>
                <td class="mailSubHeader" align="right">
                    <a class="icon-homeimg icon-close" href="javascript:fninvshnew('_relationpopupdiv_');"></a>
                </td>
            </tr>
        </tbody>
        </table>

        <table align="center" border="0" cellpadding="0" cellspacing="5" width="98%">
        <tbody>
            <tr>
                <td>
                    <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr>
                            <td><textarea cols="90" rows="10" style="width: 685px; height: 100px;" class="detailedViewTextBox small" name="commentcontent"
                                    onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" ></textarea>
                            </td>
                        </tr>
                    </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
        </table>

        <table class="layerPopupTransport" border="0" cellpadding="5" cellspacing="0" width="100%">
        <tbody><tr>
                <td align="center">
                    <input class="save" onclick="if(MailManager.addCommentValidate(this.form)) MailManager.mail_associate_create(this.form);" value="{'SAVE'|getFixedLabel}" type="button">&nbsp;&nbsp;
                    <input class="cancel" onclick="fninvshnew('_relationpopupdiv_');" value="{'CANCEL'|getFixedLabel}" type="button">
                </td>
            </tr>
        </tbody>
        </table>
        <input type="hidden" name="_mlinkto" value="{$PARENT}">
        <input type="hidden" name="_mlinktotype" value="{$LINKMODULE}">
        <input type="hidden" name="_msgno" value="{$MSGNO}">
        <input type="hidden" name="_folder" value="{$FOLDER}">

    </form>
</div>
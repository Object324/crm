{*<!--
/*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div id='editpopup' class='layerPopup' style='display:none;' >
    <div id='editpopup_draghandle' style='cursor: move;'>
        <table width="100%" cellspacing="0" cellpadding="5" border="0" class="layerHeadingULine">
            <tr>
                <td width="60%" align="left" class="layerPopupHeading">
                {'TARGETFIELD'|@getFixedLabel}
                </td>
                <td width="40%" align="right">
                    <a href="javascript:void(0);" id="editpopup_close">
                        <img border="0" align="middle" src="{'Close.png'|@lingdang_imageurl:$THEME}"/>
                    </a>
                </td>
            </tr>
        </table>
    </div>
    <table width="100%" bgcolor="white" align="center" border="0" cellspacing="0" cellpadding="5">
        <tr valign="top">
            <td class='dvtCellInfo' align="left">
                <table width="100%" border="0" cellspacing="0" cellpadding="2" align="center">
                    <tr valign="top">
                        <td>
                            <select id='editpopup_expression_type' class='small'>
                                <option value="rawtext">{'LBL_RAW_TEXT'|@getFixedLabel}</option>
                                <option value="fieldname">{'LBL_FIELD'|@getFixedLabel}</option>
                                <option value="expression">{'LBL_EXPRESSION'|@getFixedLabel}</option>
                            </select>

                            <select id='editpopup_fieldnames' class='small'>
                                <option value="">{'LBL_USE_FIELD_VALUE_DASHDASH'|@getFixedLabel}</option>
                            </select>

                            <select id='editpopup_functions' class='small'>
                                <option value="">{'LBL_USE_FUNCTION_DASHDASH'|@getFixedLabel}</option>
                            </select>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td>
                            <input type="hidden" id='editpopup_field' />
                            <input type="hidden" id='editpopup_field_type' />
                            <textarea name="Name" rows="10" cols="50" id='editpopup_expression'></textarea>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <table width="100%" cellspacing="0" cellpadding="5" border="0" class="layerPopupTransport">
        <tr><td align="center">
                <input type="button" class="save" value="{'SAVE'|@getFixedLabel}" name="save" id='editpopup_save'/>
                <input type="button" class="cancel" value="{'CANCEL'|@getFixedLabel}" name="cancel" id='editpopup_cancel'/>
            </td></tr>
    </table>

    <div class="helpmessagebox" id="text_help" style="display:none;">
        <table width="100%" cellspacing="1" cellpadding="5" border="0">
            <tr valign="top">
                <td><b>{'LBL_RAW_TEXT'|@getFixedLabel}</b></td>
            </tr>
            <tr valign="top">
                <!--by LD TIFA   -->
                <td>2000</td>
            </tr>
            <tr valign="top">
            <!--by LD TIFA  
                <td>lingdang</td>
             -->
             <td></td>
            </tr>
        </table>
    </div>

    <div class="helpmessagebox" id="fieldname_help" style="display:none;">
        <table width="100%" cellspacing="1" cellpadding="5" border="0">
            <tr valign="top">
                <td><b>{'LBL_FIELD'|@getFixedLabel}</b></td>
            </tr>
            <tr valign="top">
            <td><i>{$MOD.LBL_annual_revenue}</i></td>
               <!-- <td><i>annual_revenue</i></td>-->
            </tr>
            <tr valign="top">
                <!--<td><i>notify_owner</i></td>-->
                <td><i>{$MOD.LBL_notify_owner}</i></td>
            </tr>
        </table>
    </div>

    <div class="helpmessagebox" id="expression_help" style="display:none;">
        <table width="100%" cellspacing="1" cellpadding="5" border="0">
            <tr valign="top">
                <td><b>{'LBL_EXPRESSION'|@getFixedLabel}</b></td>
            </tr>
            <tr valign="top">
                <td><i>annual_revenue</i> / 12</td>
            </tr>
            <tr valign="top">
                <td>
                    <font color=blue>if</font> <i>mailingcountry</i> == 'India' <font color=blue>then</font> <font color=blue>concat</font>(<i>firstname</i>,' ',<i>lastname</i>) <font color=blue>else</font> <font color=blue>concat</font>(<i>lastname</i>,' ',<i>firstname</i>) <font color=blue>end</font>
                </td>
            </tr>
        </table>
    </div>
</div>
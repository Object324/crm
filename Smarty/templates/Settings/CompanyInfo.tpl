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
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/OrganizationConfig.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/cutImg.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/cropper.min.js"></script>
<link rel="stylesheet" href="themes/softed/cropper.min.css">
<link rel="stylesheet" href="themes/softed/cropperImg.css">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_COMPANY_DETAILS'|@getFixedLabel}{if $HelpHtml.OrganizationConfig neq '' }{$HelpHtml.OrganizationConfig}{/if}<font>（{'LBL_COMPANY_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="OrganizationConfig.edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="OrganizationConfig.restorethedefaultlogo()" title="{'RESTORETHEDEFAULTLOGO'|@getFixedLabel}">{'RESTORETHEDEFAULTLOGO'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
          <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <th colspan="2">
                {'LBL_COMPANY_DETAILS'|@getFixedLabel}
              </th>
            </tr>
            <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td width="20%" name="company_name" value="{'COMPANYNAME'|@getFixedLabel}">{'COMPANYNAME'|@getFixedLabel}</td>
              <td width="80%">{$ORGANIZATIONNAME}</td>
            </tr>
            <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'LOGO_name'|@getFixedLabel}</td>
              <td width="48" height="48" border="0">
                  <img id="LOGO_name" name="LOGO_name" src="{$ORGANIZATIONLOGOPATH}/{$ORGANIZATIONLOGONAME}?a={$RANDNUM}" class="Logo"  tag="logo-pic" style="width: 130px;height: 36px;">
              </td>
            </tr>
			      <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'smailllogname'|@getFixedLabel}</td>
              <td width="48" height="48" border="0">
                  <img id="smailllogname" name="smailllogname" src="{$ORGANIZATIONLOGOPATH}/{$ORGANIZATIONSMAILLLOGONAME}?a={$RANDNUM}" class="Logo"  tag="logo-pic" style="width: 36px;height: 36px;">
              </td>
            </tr>
            <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYCOUNTRY'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONCOUNTRY}</td>
            </tr>
            <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYPROVINCE'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONSTATE}</td>
            </tr>
            <tr id="setting_6" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYCITY'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONCITY}</td>
            </tr>
            <tr id="setting_7" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYZIPCODE'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONCODE}</td>
            </tr>
            <tr id="setting_8" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYADDRESS'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONADDRESS}</td>
            </tr>
            <tr id="setting_9" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYPHONE'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONPHONE}</td>
            </tr>
            <tr id="setting_10" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYFAX'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONFAX}</td>
            </tr>
            <tr id="setting_11" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'COMPANYWEBSITE'|@getFixedLabel}</td>
              <td>{$ORGANIZATIONWEBSITE}</td>
            </tr>
              <tr id="setting_12" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                  <td>{'CRMADDRESS'|@getFixedLabel}</td>
                  <td>{$ORGANIZATIONCRMADDRESS}</td>
              </tr>
            {* edit zhouxiaomei 2020-9-23 公司信息增加公司简介与公司产品简介*}
            {*<tr>
              <td>{'ABOUTUS'|@getFixedLabel}</td>
              <td>
                  <a href="javascript:;" class="dinline-block lfloat" onclick="OrganizationConfig.aboutusedit()" title="{'Setup'|@getFixedLabel}">{'Setup'|@getFixedLabel}</a>
              </td>
            </tr>
            <tr>
              <td>{'PRODUCTINTRODUCTION'|@getFixedLabel}</td>
              <td colspan="3">
                <a href="javascript:;" class="dinline-block lfloat" onclick="OrganizationConfig.productview()" title="{'VIEW'|@getFixedLabel}">{'VIEW'|@getFixedLabel}</a>
              </td>
            </tr>*}
          </table>
            <div class="listRloesHelp">
                <font color="red">{'TIP'|@getFixedLabel}：</font>
                <ul>
                    <li>1、{'ORGANIZATIONSETTINGSREMIND01'|@getFixedLabel}</li>
                </ul>
            </div>
        </div>
    </div>
</div>
</form>
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
<div class="divPopOverflow">
<form action="index.php?module=Settings&action=add2db" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/OrganizationConfig.js?v={$GLOBALMINVERSION}"></script>
  <input type="hidden" name="return_module" value="Settings"/>
  <input type="hidden" name="parenttab" value="Settings"/>
  <input type="hidden" name="return_action" value="OrganizationConfig"/>
  <input type="hidden" name="companyname" value="{'COMPANYNAME'|@getFixedLabel}"/>
  <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td class="ld-form-item-label"><font color="red">*</font>{'COMPANYNAME'|@getFixedLabel}</td>
      <td class="ld-form-item-content">
  		<input type="text" name="organization_name" class="ld-input-inner" value="{$ORGANIZATIONNAME}"/>
  		<input type="hidden" name="org_name" value="{$ORGANIZATIONNAME}"/>
     </td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'LOGO_name'|@getFixedLabel}</td>
      <td class="ld-form-item-content" style="display: flex;">
        <div class="imgContainer big" style="width: 145px;height:40px;display: flex;" data-tip="{'SELECTNEWLOGO'|@getFixedLabel}" data-direction="top" data-type="position">
        {if $ORGANIZATIONLOGONAME neq ''}
          <img src="dataCache/test/logo/{$ORGANIZATIONLOGONAME}?a={$RANDNUM}" id="logo_img" class="Logo" style="width: 121px;height: 40px;" >
        {else} 
          <img src="include/images/noimage.gif" id="logo_img" class="Logo" style="width: 121px;height: 40px;">
        {/if}  
          <img src="include/images/addimage.png" class="overlay-Img" id="overlay_Img_big" style="margin-top: 10px;width: 24px;height:24px;" data-showbox="logo_img"  data-showname="logo_name"data-prevname="{$ORGANIZATIONLOGONAME}" data-suggest="suggestedsize145x40px" data-width="145" data-height="40">  
        </div>
        <div class="imgContainer" style="padding-left: 20px;line-height:40px;" id="logo_name">
          {$ORGANIZATIONLOGONAME}
        </div>
      </td>
    </tr>
	<tr>
      <td class="ld-form-item-label">{'smailllogname'|@getFixedLabel}</td>
      <td class="ld-form-item-content" style="display: flex;">
        <div class="imgContainer small" style="width: 145px;height:40px;display: flex;" data-tip="{'selectsmalllogo'|@getFixedLabel}" data-direction="bottom" data-type="position">
        {if $ORGANIZATIONSMAILLLOGONAME neq ''}
            <img src="dataCache/test/logo/{$ORGANIZATIONSMAILLLOGONAME}?a={$RANDNUM}" id="minilogo_img" class="Logo" style="width: 36px;height: 36px;">
        {else}
            <img src="include/images/noimage.gif" id="minilogo_img" class="Logo" style="width: 36px;height: 36px;">
        {/if}      
          <img src="include/images/addimage.png" class="overlay-Img" id="overlay_Img_small"style="margin-top: 10px;width: 24px;height:24px;" data-showbox="minilogo_img" data-showname="minilogo_name" data-prevname="{$ORGANIZATIONSMAILLLOGONAME}" data-suggest="suggestedsize" data-width="36" data-height="36">
        </div>
        <div class="imgContainer" style="padding-left: 20px;line-height:40px;" id="minilogo_name">
          {$ORGANIZATIONSMAILLLOGONAME}
        </div>
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYCOUNTRY'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_country" class="ld-input-inner" value="{$ORGANIZATIONCOUNTRY}"/></td>
    </tr>
    <tr> 
      <td class="ld-form-item-label">{'COMPANYPROVINCE'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_state" class="ld-input-inner" value="{$ORGANIZATIONSTATE}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYCITY'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_city" class="ld-input-inner" value="{$ORGANIZATIONCITY}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYZIPCODE'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_code" class="ld-input-inner" value="{$ORGANIZATIONCODE}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYADDRESS'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_address" class="ld-input-inner" value="{$ORGANIZATIONADDRESS}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYPHONE'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_phone" class="ld-input-inner" value="{$ORGANIZATIONPHONE}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYFAX'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_fax" class="ld-input-inner" value="{$ORGANIZATIONFAX}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'COMPANYWEBSITE'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_website" class="ld-input-inner" value="{$ORGANIZATIONWEBSITE}"/></td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'CRMADDRESS'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><input type="text" name="organization_crmaddress" class="ld-input-inner" value="{$ORGANIZATIONCRMADDRESS}"/></td>
    </tr>
  </table>
</form>
</div>
<!--
  /*********************************************************************************
    ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
     * ("License"); You may not use this file except in compliance with the License
     * The Original Code is:  lingdang CRM Open Source
     * The Initial Developer of the Original Code is lingdang.
     * Portions created by lingdang are Copyright (C) lingdang.
     * All Rights Reserved.
    *
   ********************************************************************************/
  -->
<div class="divPopOverflow">
  <form action="index.php?module=Settings&action=watermark_setting_sava" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
  <script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/watermark_setting.js?v={$GLOBALMINVERSION}"></script>
  <input type="hidden" name="return_module" value="Settings"/>
  <input type="hidden" name="parenttab" value="Settings"/>
  <input type="hidden" name="return_action" value="watermark_setting"/>
  <input type="hidden" name="companyname" value="{'COMPANYNAME'|@getFixedLabel}"/>
  <table  class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}
      </td>
      <td class="ld-form-item-content">
        <input name="open_watermark_setting" type="checkbox"  class="second_switch" {if $presence eq 'yes'} checked {/if} />
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'watermark_display'|@getFixedLabel}
      </td>
      <td  class="ld-form-item-content">
        <!-- BUG0068276 txy 06.15 kfbcrm 后台设置--水印设置---编辑界面--图中两个框没有对齐 -->
        <div class="ld-flex-start">
          <select id="watermark_content_select" class="ld-select-inner" onchange="watermark_setting.watermark_content_select(this)">
            <option value="username" hint="{'loginusername_hint'|@getFixedLabel}" {if $watermark_display eq 'username'} selected {/if}>{'loginusername'|@getFixedLabel}</option>
            <option value="username_date" hint="{'username_date_hint'|@getFixedLabel}" {if $watermark_display eq 'username_date'} selected {/if}>{'username_date'|@getFixedLabel}</option>
            <option value="username_phone" hint="{'username_phone_hint'|@getFixedLabel}" {if $watermark_display eq 'username_phone'} selected {/if}>{'username_phone'|@getFixedLabel}</option>
            <option value="Companyname_username" hint="{'Companyname_username_hint'|@getFixedLabel}" {if $watermark_display eq 'Companyname_username'} selected {/if}>{'Companyname_username'|@getFixedLabel}</option>
            <option  value="Companyname_username_phone" hint="{'Companyname_username_phone_hint'|@getFixedLabel}" {if $watermark_display eq 'Companyname_username_phone'} selected {/if}>{'Companyname_username_phone'|@getFixedLabel}</option>
            <option value="companyname_username_date" hint="{'companyname_username_date_hint'|@getFixedLabel}" {if $watermark_display eq 'companyname_username_date'} selected {/if}>{'companyname_username_date'|@getFixedLabel}</option>
            <option value="custom_content" hint="{'Custom_content_hint'|@getFixedLabel}" {if $watermark_display eq 'custom_content'} selected  {/if}>{'Custom_content'|@getFixedLabel}</option>
          </select>  
        </div>
        {if $watermark_display eq 'custom_content'}
          <tr>
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content">
              <input id="watermark_content_input" type="text"  class="ld-input-inner" value="{$custom_content}" >
            </td>
          </tr>
        {else}
          <tr>
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content">
              <input id="watermark_content_input" type="text"  class="ld-input-inner" style='display: none;' >
          </td>
          </tr>
        </div>
        {/if}    
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-label padT0"></td>
      <td class="ld-form-item-content padT0">
        <span id="watermark_remark" class="grid-view-name dinline-block">{$watermark_hint}</span>
      </td>
    </tr>
  </table>
  </form>
</div>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
  <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <th colspan="2">
          <div class="ld-pop-contnet-title-items">
              <div class="ld-pop-contnet-title-item">{'CHECKINSETTINGDINGTALK1'|@getFixedLabel}</div>
          </div>
      </th>
    </tr>
    <tr>
        <td class="ld-form-item-label" style="width: 240px;">{'CHECKINSETTINGDINGTALK2'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <select name="interfaceType" class="ld-select-inner" onChange="selectCheckinType(this)">
                <option value="weixin" >{'LBL_ENTERPRISEWECHAT'|@getFixedLabel}</option>
                <option value="dingtalk" {if $INTERFACETYPE eq 'dingtalk'}selected{/if}>{'DINGTALK'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>
  </table>
  <div id="weixinSetting" {if $INTERFACETYPE eq 'dingtalk'}hidden{/if}>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <th colspan="2">
            <div class="ld-pop-contnet-title-items">
                <div class="ld-pop-contnet-title-item">{'CHECKINSETTING'|@getFixedLabel}</div>
            </div>
        </th>

      </tr>
      <tr>
        <td class="ld-form-item-label" style="width: 240px;">{'CHECKINSETTING_TITLE1'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <input type="text" size="50" name="corpid" value="{$CORPID}" class="ld-input-inner">
        </td>
      </tr>
      <tr>
          <td class="ld-form-item-label">{'CHECKINSETTING_TITLE2'|@getFixedLabel}</td>
          <td class="ld-form-item-content">
              <input type="text" size="100" name="secret"  value="{$SECTRET}" class="ld-input-inner">
          </td>
      </tr>
      {*editor:gyq_139 reason:月度考勤增加帮助链接  2019/8/28 11:02*}
      <tr>
          <td class="ld-form-item-label">{'CHECKINSETTING_TITLE3'|@getFixedLabel}</td>
          <td class="ld-form-item-content">
              <input type="text" size="100" name="secret_approve"  value="{$SECTRET_APPROVE}" class="ld-input-inner">
          </td>
      </tr>
    </table>
  </div>
</form>
</div>
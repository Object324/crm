{if $MODE neq 'edit'}
  <form action="index.php" method="post" name="SMS_VOICE" onsubmit="puyoungJS_DialogBox.block();">
{else}
  {literal}
  <form action="index.php" method="post" name="SMS_VOICE" onsubmit="if(validate(SMS_VOICE)){ puyoungJS_DialogBox.block(); return true; } else { return false; }">
  {/literal}
{/if}
<input type="hidden" name='mode'/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="SMSVoiceSetting"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
 {if $MODE neq 'edit'}
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_SMS_VOICE_SETTINGS'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" class="pg-btn-grey dinline-block lfloat" onclick="editSmsVoiceSetting()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            <a href="javascript:;" class="pg-btn-grey dinline-block lfloat" onclick="CancelSmsVoiceSetting()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
            <a class="pg-btn-grey dinline-block lfloat" href="http://www.51mis.com.cn/forum.php?mod=viewthread&tid=378" target="_blank" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <div class="TitleHeading noborderB">{'LBL_SMS_VOICE_SETTINGS'|@getFixedLabel}</div>
            <table border="0" cellspacing="1" cellpadding="0" width="100%"  class="ControlTable1 listEntries singleList">
                <tr  bgcolor="white">
                  <td width="20%" nowrap  style="text-align:left;padding-left:10px;"><span title="SDK AppID">{'Tencent'|@getFixedLabel}访问密钥SecretId</span> </td>
                  <td colspan="3" class="cellText" style="border:0px;"><span title="{$secretId}">{$secretId}&nbsp;</span> </td>
                </tr>
                <tr bgcolor="white">
                  <td nowrap class="controlInfoTd" style="text-align:left;padding-left:10px;"><span title="App Key">{'Tencent'|@getFixedLabel}访问密钥SecretKey</span> </td>
                  <td colspan="3" class="cellText" style="border:0px;">{if $secretKey neq ''}<span title="******">******</span>{/if}&nbsp;</td>
                </tr>
                <tr bgcolor="white">
                  <td nowrap class="controlInfoTd" style="text-align:left;padding-left:10px;"><span title="App Key">{'Tencent'|@getFixedLabel}语音消息应用SDK AppId</span> </td>
                  <td colspan="3" class="cellText" style="border:0px;"><span title="{$sdkAppId}">{$sdkAppId}</span></td>
                </tr>
                 {foreach item=templateinfo key=id from=$templates}
                <tr bgcolor="white">
                  <td width="20%" nowrap class="controlInfoTd" style="text-align:left;padding-left:10px;"><span title="语音模板ID">{'Tencent'|@getFixedLabel}语音模板ID</span> </td>
                  <td width="30%" class="cellText" style="border:0px;"><span title="{$id}">{$id}</span></td>
                  <td width="20%" nowrap class="controlInfoTd" style="text-align:left;padding-left:10px;"><span title="语音模板名称">{'Tencent'|@getFixedLabel}语音模板名称</span> </td>
                  <td width="30%" class="cellText" style="border:0px;"><span title="{$templateinfo}">{$templateinfo}</span></td>
                </tr>
                 {/foreach}
            </table>
            <div class="listRloesHelp pad10">
              <font color="red">{'TIP'|@getFixedLabel}:</font>
                <ul>
                  <li>1、SecretId和SecretKey必须与腾讯云账户中访问密钥保持一致</li>
                  <li>2、SDK AppId必须与腾讯云账户中语音消息应用设置的SDK AppId保持一致</li>
                  <li>3、语音模板至少填写一个</li>
                </ul>
            </div>
        </div>
    </div>
</div>
{else}
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr">
      <td  width="20%" align="right" class="controlInfoTd" style="text-align:left;padding-left:10px;"><font color="red">*</font><span title="SecretId">{'Tencent'|@getFixedLabel}访问密钥SecretId</span> </td>
      <td width="80%">
          <input class="commonTextBoxPop"  type="text" value="{$secretId}" name="SecretId"/>
      </td>
    </tr>
     <tr>
      <td width="20%" class="controlInfoTd" style="text-align:left;padding-left:10px;"><font color="red">*</font><span title="SecretKey">{'Tencent'|@getFixedLabel}访问密钥SecretKey</span> </td>
      <td width="80%">
          <input class="commonTextBoxPop" type="password" value="{$secretKey}" name="SecretKey"/>
      </td>
    </tr>
    <tr>
      <td width="20%" class="controlInfoTd" style="text-align:left;padding-left:10px;"><font color="red">*</font><span title="SDK AppId">{'Tencent'|@getFixedLabel}语音消息应用SDK AppId</span> </td>
      <td width="80%">
         <input class="commonTextBoxPop" type="SDK AppId" value="{$sdkAppId}" name="SDKAppId"/>
      </td>
    </tr>
    <tr>
      <td width="50%" class="controlInfoTd" style="text-align:left;padding-left:10px;">
        <font color="red">*</font>语音模板ID
       </td>
      <td width="50%">
         <font color="red">*</font>语音模板名称
      </td>
    </tr>
    {foreach item=templateinfo key=id from=$templates}
    <tr>
      <td width="50%" class="controlInfoTd" style="text-align:left;padding-left:10px;">
        <input class="commonTextBoxPop" placeholder="" type="text" value="{$id}" name="templateId[]"/>
       </td>
      <td width="50%">
        <input class="commonTextBoxPop" type="text" value="{$templateinfo}" name="templateName[]"/>
      </td>
      <td width="50%">
         <a onclick="delSmsVoiceTemplate(this)">删除</a>
      </td>
    </tr>
    {/foreach}
    <tr>
    <td colspan="3" class="controlInfoTd" style="text-align:left;padding-left:10px;"><a onclick="addSmsVoiceTemplate(this)">+新增模板</a></td>
    </tr>
</table>
{/if}

<script>
    //删除一个模板
    function delSmsVoiceTemplate(obj){
        var trobj = Tools.getParentobjByChild(ld(obj),'tr');
        trobj.remove();
    }
    //增加一个模板
    function addSmsVoiceTemplate(obj){
        var trobj = Tools.getParentobjByChild(ld(obj),'tr');
        var tr_html = '<tr>\n' +
            '      <td width="50%" class="controlInfoTd" style="text-align:left;padding-left:10px;">\n' +
            '        <input class="commonTextBoxPop" placeholder="" type="text" value="" name="templateId[]"/>\n' +
            '       </td>\n' +
            '      <td width="50%">\n' +
            '        <input class="commonTextBoxPop" type="text" value="" name="templateName[]"/>\n' +
            '      </td>\n' +
            '      <td width="50%">\n' +
            '         <a onclick="delSmsVoiceTemplate(this)">删除</a>\n' +
            '      </td>\n' +
            '    </tr>';
        ld(trobj).before(tr_html);
    }
</script>
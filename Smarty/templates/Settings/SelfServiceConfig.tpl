<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/SelfServiceConfig.js"></script>


<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    	<input type="hidden" name="module" value="Settings"/>
    	<input type="hidden" name="parenttab" value="Settings"/>
	    <input type="hidden" name="action"/>
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
        <div class="DivCR">
          <div class="ControlDiv1">
            {if $LANGUAGETYPE eq 'en'}
            <span class="Url2">
            {else}
            <span class="Url fontbold">
            {/if}
            {'CONTROLPANEL'|@getFixedLabel} &gt; {'CUSTOMERSELFSERVICECONFIG'|@getFixedLabel}
            </span>
            <div style="float:right;padding-right:28px;padding-top:8px;">
                <div class="icon-homeimg icon-askgrey" style="float:right;margin-right:5px;position: absolute;">
        		<p>
                {'INTENTIONOFSELFSERVICE'|@getFixedLabel}<br/>
                {'ANSWER2'|@getFixedLabel}：{'INTENTIONOFSELFSERVICEDETAIL'|@getFixedLabel}<br/>
                </p>
	           </div>
            </div>
          </div>
          <div class="ControlDiv2">
             <div class="F_l"> </div>
             <div class="F_r">
               <input id="setsubmit" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}" name="save" class="saveauto" style="float:right" type='button'>
             </div>
          </div>
        <div class="ControlDiv2 bgcolorF7">
            <div class="F_l">
                <b>{'CUSTOMERSELFSERVICEHOME'|@getFixedLabel}</b>
            </div>
        </div>
            <div class="pad10">
                <span>{'CUSTOMERSELFSERVICEHOME'|@getFixedLabel}{'SETTINGS'|@getFixedLabel}</span>
                <select  class="btn-radius-system"  id="weixinmp_bindtype">
                    {foreach item=item key=key from=$MPBINDTYPEARR}
                        <option value="{$item.value}" {$item.selected}>{$item.label}</option>
                    {/foreach}
                </select>
            </div>
          <div class="ControlDiv2 bgcolorF7">
            <div class="F_l">
            	<b>{'SETTINGOFMEDIAPLATFORM'|@getFixedLabel}</b>
            </div>
          </div>
          <div class="pad10">
            <span>{'SELECTMODULE'|@getFixedLabel}</span>
            <select  class="btn-radius-system" id="WeixinMpModule" >
                {foreach item=item key=key from=$SELECTMODULES}
                    <option value="{$item}" >{$item|@getTransTab}</option>
                {/foreach}
            </select>
            <b onclick="SelfServiceConfig.set_Save_SelfConfig_Module()" title="{'SETTINGS'|@getFixedLabel}" class="icon-homeimg icon-setgrey marT2 marL5" style="cursor:pointer;"></b>
          </div>
          <div class="pad10" id="MpModuleViewall">
            {$VIEWALLHTML}
          </div>
            <div  class="pad10">
                <div class="TitleHeading bgwhite noborderB">
                    {'THESETTINGOFSELFSERVICEFIELDS'|@getFixedLabel}
                    <input style="float:right" class="createauto" type="button" id="selfconfig_field_create"  name="New" value="{'NEW'|@getFixedLabel}"/>
                </div>
                <div id="MpModuleFields">
                    {$MPMODULEFIELDSHTML}
                </div>
            </div>
            <div  class="pad10" id="ModuleListFields">
                <div class="TitleHeading bgwhite noborderB">
                    {'THESETTINGOFSELFSERVICELISTFIELDS'|@getFixedLabel}
                    <input style="float:right" class="createauto" type="button" id="selfconfig_listfield_create"  name="New" value="{'NEW'|@getFixedLabel}"/>
                </div>
                <div id="MpModuleListFields">
                    {$MPMODULELISTFIELDSHTML}
                </div>
            </div>
       </div>
     </form>
    </td>
   </tr>
</table>

</div>
<!--中间 end-->
<div id="selfconfig_create"style="display:none;width:450px;">
<div id="selfconfig_create_div"></div>
</div>
<div id="selfconfig_module"style="display:none;width:450px;">
<div id="selfconfig_module_div"></div>
</div>
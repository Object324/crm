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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<script language="javascript" type="text/javascript" src="include/js/DataInterface.js"> </script>


<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
	<form action="index.php?module=Settings&action=SaveKIS" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();">
     	<input type="hidden" name="return_module" value="Settings"/>
     	<input type="hidden" name="parenttab" value="Settings"/>
     	<input type="hidden" name="return_action" value="KISSetting"/>
        <input type="hidden" name="sa" value="{$SA}"/>
        <input type="hidden" name="pwd" value="{$PASSWORD}"/>
        <input type="hidden" name="hostname" value="{$HOSTNAME}"/>
        <input type="hidden" name="databasename" value="{$DATABASENAME}"/>
        <input type="hidden" name="demo_name" value="{$DEMONAME}" />
        <input type="hidden" id="connect_mode" name="connect_mode" value="{$CONNECTMODE}" />
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
        
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'EDIT'|@getFixedLabel} {'LBL_DATAINTERFACE_SETTING'|@getFixedLabel}
                <font>（{'LBL_SETTING_DATAINTERFACE_DEMOINFO'|@getFixedLabel}）</font>
            </span>
        </div>
        <div class="ControlDiv2">
          <div class="settingsbtn">
            <input title="{'SAVE'|@getFixedLabel}" class="saveauto" type="button" name="button" value="{'SAVE'|@getFixedLabel}" onclick="return verify_data();" >
            <input title="{'CANCEL'|@getFixedLabel}" class="cancelauto" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}">
          </div>
	   </div>
        <div class="pad10 nopadding mar-1" >
			<div class="TitleHeading">
             {'LBL_DATAINTERFACE_SETTING'|@getFixedLabel}
      </div>
      <table border=0 cellspacing=0 cellpadding=0 width=100%>
            <tr>
				<td valign=top ><table class="singleList" width="100%"  border="0" cellspacing="0" cellpadding="5">
                  <tr>
                    <td width="20%" class="cellLabel ">
                      <font color="red">*</font> {'SOFTWAREVENDORS'|@getFixedLabel}
                    </td>
                    <td width="80%" class="borderBR"> {$SOFTFACTORYHTML}
                    </td>
                  </tr>
                  <tr>
                    <td class="cellLabel "> {'SOFTWAREVERSION'|@getFixedLabel}</td>
                    <td class="borderBR" >
                        <div id="jindie" {if $SOFTVERSION <100 || $SOFTVERSION==''}style="display:block;"{else}style="display:none;"{/if}>{$VERSIONHTML}</div>
                        <div id="yongy" {if $SOFTVERSION >=100 && $SOFTVERSION<200}style="display:block;"{else}style="display:none;"{/if}>{$VERSIONYY}</div>
                        <div id="dingjie" {if $SOFTVERSION >=200}style="display:block;"{else}style="display:none;"{/if}>{$VERSIONDJ}</div>
                    </td>
                  </tr>
                  <tr> 
                    <td class="cellLabel "><font color="red">*</font> {'ZHANGTAONAME'|@getFixedLabel} </td>
                    <td class="borderBR" id="td_demo_name" style="color:#666;">
                    </td>
                  </tr>
                  <tr id="order_style">
                    <td class="cellLabel"> {'ENABLEORDERINTERFACE'|@getFixedLabel} </td>
                        <td class="borderBR"><input type="checkbox" name="using_order" value="{$USINGORDER}" onclick="chkbox(this)" class="small" {if $USINGORDER eq 1}checked{/if} /></td>
                  </tr>
                 
                  <!--<tr style="display:none;">
                    <td class="cellLabel ">&nbsp;&nbsp; {'ENABLECERTIFICATEINTERFACE'|@getFixedLabel} </td>
                    <td class="borderBR"><input type="checkbox" name="using_credence" value="{$USINGCREDENCE}" onclick="chkbox(this)" class="small" {if $USINGCREDENCE eq 1}checked{/if} /></td>
                  </tr>-->
                  
                  <tr  id="quantity_style" {if $SOFTFACTORY eq '鼎捷'} style="display:none;"{else} style="display:;"{/if}>
                    <td class="cellLabel ">
                       {'ENABLEINVENTORYINTERFACE'|@getFixedLabel}
                    </td>
                    <td class="borderBR"><input type="checkbox" name="using_inventory" value="{$USINGINVENTORY}" onclick="chkbox(this)" class="small" {if $USINGINVENTORY eq 1}checked{/if} /></td>
                  </tr>
                  
                  <tr id="using_order_read" style="display:none;">
                    <td class="cellLabel ">
                       {'ENABLEREADORDERINTERFACE'|@getFixedLabel}
                    </td>
                    <td class="borderBR"><input type="checkbox" name="using_order_read" value="{$USINGORDERREAD}" onclick="chkbox(this)" class="small" {if $USINGORDERREAD eq 1}checked{/if} /></td>
                  </tr>
                  
                  <tr id="using_quote_read" style="display:none;">
                    <td class="cellLabel ">
                       {'ENABLEREADQUOTEINTERFACE'|@getFixedLabel}
                    </td>
                    <td class="borderBR"><input type="checkbox" name="using_quote_read" value="{$USINGQUOTEREAD}" onclick="chkbox(this)" class="small" {if $USINGQUOTEREAD eq 1}checked{/if} /></td>
                  </tr>
                  
                  <tr id="using_ticket_read" style="display:none;">
                    <td class="cellLabel ">
                       {'ENABLEREADTICKETINTERFACE'|@getFixedLabel}
                    </td>
                    <td class="borderBR"><input type="checkbox" name="using_ticket_read" value="{$USINGTICKETREAD}" onclick="chkbox(this)" class="small" {if $USINGTICKETREAD eq 1}checked{/if} /></td>
                  </tr>
                 
                </table>
				
				</td>
			  </tr>
              
			</table>
			<table border=0 cellspacing=0 cellpadding=5 width=100% >
             <tr>
                  <td>
                  <div class="listRloesHelp">
                      <font color="red">{'TIP'|@getFixedLabel}：</font>
                        <ul  id="DATAINTERFACESTEP7" style="display:block;">
                            {assign var="i" value=1}
                            <li>{$i++}.{'DATAINTERFACESTEP1'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP2'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP3'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP4'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP8'|@getFixedLabel}</li>
                        </ul>
                        <ul  id="SHOWDATAINTERFACESTEP7" style="display:none;">
                            {assign var="i" value=1}
                            <li>{$i++}.{'DATAINTERFACESTEP1'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP2'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP3'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP4'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP7'|@getFixedLabel}</li>
                            <li>{$i++}.{'DATAINTERFACESTEP8'|@getFixedLabel}</li>
                        </ul>
                  </div>
                  </td>
             </tr>
			</table>
                
        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->

<div id="KISHeader" class="D_pop_box LdPopWidth350px" style="display:none;">	
    <div class="D_pop_tit">
    	<strong class="D_ptita" id="setting_mode_id">{if $SETTING_MODE eq 1}{'ZHANGTAOCHOOSE'|@getFixedLabel} {else}  {'SELECTDATABASE'|@getFixedLabel}   {/if} </strong>
        <a href="javascript:fninvshnew('KISHeader');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>	
    <div id="KIS_form_div"></div>
</div>
<iframe name="hd" id="hd" style="display:none;"></iframe>
<script>
 function jsSelectItemByValue(objSelect,objItemText) 
 {ldelim}
       for(var i=0;i<objSelect.options.length;i++) 
       {ldelim}  
            if(objSelect.options[i].value == objItemText)
             {ldelim}
             var setting_mode = '{$SETTING_MODE}';
                 objSelect.options[i].selected = true;  
                 changesel(objSelect,setting_mode);
                break;  
            {rdelim}
        {rdelim}  
    {rdelim}  
var VersionIndex='{$SOFTVERSION}';
if(VersionIndex >=200)
    jsSelectItemByValue(ld('form[name=index]').find('[name=soft_version_2]').get(0),VersionIndex);
else if(VersionIndex >= 100 && VersionIndex < 200)
    jsSelectItemByValue(ld('form[name=index]').find('[name=soft_version_1]').get(0),VersionIndex);
else
    jsSelectItemByValue(ld('form[name=index]').find('[name=soft_version]').get(0),VersionIndex);
if(VersionIndex == ''){
    changesel();
}
if(document.getElementById("sp_demo_name") != undefined)
{ldelim}
	if(document.all)
	{ldelim}
		document.getElementById("sp_demo_name").innerText="{$DEMONAME}";
	{rdelim}
	else 
	{ldelim}
	  document.getElementById("sp_demo_name").textContent="{$DEMONAME}";
	{rdelim}
{rdelim}

//document.forms['EditForm'].soft_version.value=VersionIndex;

</script>

<script>

function verify_data()
{ldelim}
    if(document.forms['index'].setting_mode != undefined && document.forms['index'].setting_mode.value == 1)
    {ldelim}
        if(document.forms['index'].demo_name.value == null || document.forms['index'].demo_name.value=='')
        {ldelim}
            var confirm_str = arrJsPopLabel['ZHANGTAONAME']+arrJsPopLabel['CANOTEMPTY']+'！';
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return;
        {rdelim}
    {rdelim}
     //var obj=document.forms['index'].soft_version;
     if(document.getElementById('soft_factory').value == '金蝶')
     {ldelim}
        var obj = ld('form[name=index]').find('[name=soft_version]').get(0);
     {rdelim}
     else if(document.getElementById('soft_factory').value == '用友')
     {ldelim}
        var obj = ld('form[name=index]').find('[name=soft_version_1]').get(0);
     {rdelim}
     else if(document.getElementById('soft_factory').value == '鼎捷')
     {ldelim}
        var obj = ld('form[name=index]').find('[name=soft_version_2]').get(0);
     {rdelim}
     var fform=document.forms['index'];
    puyoungJS_DialogBox.block();
     var setting_mode = document.getElementById('setting_mode');
     setting_mode.removeAttribute('disabled');
     if(obj.options[obj.selectedIndex].value <= 0 )
     {ldelim}
        var confirm_str = arrJsPopLabel['SOFTWAREVERSION']+arrJsPopLabel['CANOTEMPTY']+'！';
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
         puyoungJS_DialogBox.unblock();
        return false;
     {rdelim}
     if(obj.options[obj.selectedIndex].value==1||obj.options[obj.selectedIndex].value==2||obj.options[obj.selectedIndex].value==5||obj.options[obj.selectedIndex].value>=100)//k3系统,kis专业版
    {ldelim}
       
        fform.action="index.php?module=Settings&action=SaveKIS";
        fform.method="POST";
        fform.submit();
       
       return true;
    {rdelim}
    
    else if (obj.options[obj.selectedIndex].value==3||obj.options[obj.selectedIndex].value==4)//kis标准版,kis迷你版
    {ldelim}
      //var facetype=fform.demo_name.getAttribute('facetype');
      //alert(filefacetype);
       fform.action="index.php?module=Settings&action=SaveKIS&facetype="+filefacetype;
       fform.enctype="multipart/form-data";
       fform.target="hd";
       fform.method="POST";
       fform.submit();
    {rdelim}
    puyoungJS_DialogBox.unblock();
{rdelim}
</script>
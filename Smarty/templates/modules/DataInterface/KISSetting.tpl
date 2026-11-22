<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>


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
            <span class="Url fontbold">{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_DATAINTERFACE_SETTING'|@getFixedLabel}
                <font>（{'LBL_SETTING_DATAINTERFACE_DEMOINFO'|@getFixedLabel}）</font></span>{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="help_txt" href="javascript:;" onclick="getLinksUrl('','Settings','erplist');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
        </div>
        <div class="ControlDiv2">
        	<div class="F_r">
            <input class="editauto" title="{'EDIT'|@getFixedLabel}" onclick="this.form.action.value='KISEdit'" type="submit" name="Edit" value="{'EDIT'|@getFixedLabel}">
          </div>
	     </div>
        <div class="pad10 nopadding mar-1" >
       
			<div class="TitleHeading">
         {'LBL_DATAINTERFACE_SETTING'|@getFixedLabel}
      </div>
                <table  class=" singleList" width="100%"  border="0" cellspacing="0" cellpadding="5" style="color:#555;">
                  <tr>
                    <td width="20%" class="cellLabel"> {'SOFTWAREVENDORS'|@getFixedLabel} </td>
                    <td width="80%" class="borderBR">{$SOFTFACTORY}</td>
                  </tr>
                  <tr >
                    <td class=" cellLabel"> {'SOFTWAREVERSION'|@getFixedLabel} </td>
                    <td width="80%" class="borderBR">{$SOFTVERSION}</td>
                  </tr>
                  <tr>
                    <td class=" cellLabel"> {'ZHANGTAONAME'|@getFixedLabel} </td>
                    <td class=" borderBR">{$DEMONAME}</td>
                  </tr>
                  <tr > 
                    <td class=" cellLabel"> {'ENABLEORDERINTERFACE'|@getFixedLabel} </td>
                    <td class=" borderBR">{$USINGORDER}</td>
                  </tr>
                  
                  <!--<tr style="display:none;">
                    <td class=" cellLabel"> {'ENABLECERTIFICATEINTERFACE'|@getFixedLabel} </td>
                    <td class=" borderBR">{$USINGCREDENCE}</td>
                  </tr>-->
                  
                  <tr {if $SOFTFACTORY eq '鼎捷'} style="display:none;"{else} style="display:;"{/if}>
                    <td class=" cellLabel"> {'ENABLEINVENTORYINTERFACE'|@getFixedLabel} </td>
                    <td class=" borderBR">{$USINGINVENTORY}</td>
                  </tr>
                  {if ($SOFTFACTORY eq '金蝶' && $SOFTVERSION eq 'K3系统') || $SOFTFACTORY eq '鼎捷'}
                  
                  <tr>
                    <td class=" cellLabel"> {'ENABLEREADORDERINTERFACE'|@getFixedLabel} </td>
                    <td class=" borderBR">{$USINGORDERREAD}</td>
                  </tr>
                  {/if}
                  {if $SOFTFACTORY eq '金蝶' && $SOFTVERSION eq 'K3系统'}
                  <tr>
                    <td class=" cellLabel"> {'ENABLEREADQUOTEINTERFACE'|@getFixedLabel} </td>
                    <td class=" borderBR">{$USINGQUOTEREAD}</td>
                  </tr>
                  {/if}
                  {if $SOFTFACTORY eq '鼎捷'}
                  <tr>
                    <td class=" cellLabel"> {'ENABLEREADTICKETINTERFACE'|@getFixedLabel} </td>
                    <td class=" borderBR">{$USINGTICKETREAD}</td>
                  </tr>
                  {/if}
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
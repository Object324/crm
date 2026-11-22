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
<script type="text/javascript" src="include/js/general.js"></script>
<script type="text/javascript" src="modules/Settings/Mask.js"></script>
<!-- header - level 2 tabs -->
{*{include file='Buttons_List1.tpl'}*}

<div style="padding:0px 2px;">
    <form  name="Export_Records"  method="POST" onsubmit="puyoungJS_DialogBox.block();">
    	<input type="hidden" name="module" value="{$MODULE}"/>
      
    	<input type="hidden" name="action" value="Export{$MODULE}"/>
         <input  type="hidden" name="startexportindex" value="{$STARTEXPORTINDEX}"/>
    	<input type="hidden" name="idstring" value="{$IDSTRING}"/>
    	<input type="hidden" name="id_cur_str" value="{$IDCURSTR}"/>
        <input type="hidden" name="accounttype" value="{$AccountType}" />
        <input type="hidden" name="wareid" id="wareid" value="{$wareid}" />
        <input type="hidden" id="ExportAllRows" value="{$ALLROWS}">
        <input type="hidden" id="ExportSelectedRows" value="{$SELECTEDROWS}">
    	<table align="center" cellpadding="0" cellspacing="0" width="100%" class="ImportFirst" border="0">
    		<tr bgcolor="#f5f5f5">
                <td class="fontStyle borderALL" align="left" colspan="3">
                    <table border="0" width="100%" cellspacing="0" cellpadding="0">
                        <tr>
                            <td>{if $AccountType == 1}{$MODULELABEL}&{'Contacts'|@getTranstab}{else if $MODULELABEL !=''}{$MODULELABEL}{else}{$MODULE|@getTranstab}{/if} &gt;&gt; {'EXPORT'|@getFixedLabel}<span style="font-size: 13px;"></span></td>
                            <td align ="right">
                                {if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 7px;    font-size: 13px;font-weight: normal;" onclick="getLinksUrl('','Export','module_export');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
          <tr>
              <td class="fontStyle borderALL"  width="15%" align="center" {if $MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery'}rowspan="2"{/if} bgcolor="#eeeeee">{'EXPORTDATATITLE'|@getFixedLabel}
              </td>
               <td class="borderB"  width="20%">

               </td>
               <td class="borderBR" align="left">
                {if $SESSION_WHERE neq ''}        
                    <input type="radio" name="search_type" checked="checked" class="input-btn-align marL10" value="includesearch"/>{'ExportSearchResults'|@getFixedLabel}
                {else}    
                    <input type="radio" name="search_type" checked="checked" class="input-btn-align marL10" value="includesearch"/>{'ExportSearchResults'|@getFixedLabel}
                {/if}

               </td>
          </tr>
         {if $MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery'}
            <tr>
                <td class="borderB"  width="20%">

                </td>
                <td class="borderBR" align="left">
                  {if  $IDSTRING neq ''}
                      <input type="radio" name="search_type"  class="input-btn-align marL10" value="selecteddata"/>{'ExportSelectedRecords'|@getFixedLabel}
                  {else}
                      <input type="radio" name="search_type"  class="input-btn-align marL10" value="selecteddata"/>{'ExportSelectedRecords'|@getFixedLabel}
                  {/if}
                </td>
            </tr>
         {/if}

         <tr>
             <td class="fontStyle borderALL"  width="15%" align="center" rowspan="3" bgcolor="#eeeeee">
                 {'EXPORT'|@getFixedLabel}{'STYLE'|@getFixedLabel}
             </td>
             <td class="borderB"  width="20%">
                
             </td>
             <td class="borderBR" align="left"><input type="radio" name="exportformat" {if $EXPORTFORMAT eq 'exportexcel' ||$EXPORTFORMAT eq ''||$ALLROWS lte 2000} checked="checked" {/if} class="input-btn-align marL10" value="exportexcel"/>导出excel文件（2000条数据以内）</td>
         </tr>
         <tr>
             <td class="borderB"  width="20%">
                 
             </td>
             <td class="borderBR" align="left"><input type="radio" name="exportformat"  {if $EXPORTFORMAT eq 'exportcsv' ||$ALLROWS gt 2000} checked="checked" {/if} class="input-btn-align marL10" value="exportcsv"/>导出csv文件（超过2000条数据）</td>
         </tr>
    		<tr>
    			<td class="borderBR" align="center" colspan="3">	
    				<input type="button" name="{'EXPORT'|@getFixedLabel}" value="{'EXPORT'|@getFixedLabel}" class="createauto" onclick="record_export('{$MODULE}','{$CATEGORY}',this.form,'{$IDSTRING}')"/>&nbsp;&nbsp;<!--$smarty.request.idstring-->
    				<input type="button" name="{'CANCEL'|@getFixedLabel}" value="{'CANCEL'|@getFixedLabel}" class="cancelauto" onclick="window.history.back()" />
    			</td>
    		</tr>
    	</table>
    </form>
</div>
<div id="layer" style=" {if $STARTEXPORTINDEX>0 }display: block ;{else} display:none;{/if}height: 100%; width: 100%; position: fixed; left: 0px; top: 0px; background-color: rgb(128, 128, 128); z-index: 9998; opacity: 0.6;"></div>
<div id="not_search" style="position:absolute;display:none;width:400px;height:25px;"></div>



<div id="selectpopup_1" class="D_pop_box LdPopWidth600px ui-popup" style=" {if $STARTEXPORTINDEX>0 }display: block ;{else} display:none;{/if} 
position: fixed; z-index: 9999; top: 40%; left: 50%;  background-color: rgb(255, 255, 255); margin-top: -94.5px; margin-left: -302px;padding-bottom: 15px;">
  <div class="D_pop_tit">
    <strong class="D_ptita" id="titlename">{'EXPORTDATATITLE'|@getFixedLabel}</strong>
    <a href="index.php?module={$MODULE}&action=ListView" class="D_ptitc" ><img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/></a>
  </div>
  <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0" align="center">
    <tr>
      <td style="padding-bottom: 10px;">
        <div style="font-size: 16px;font-weight: 600;color: #868686;text-align: center;" id="dvc" >{'EXPORTINGDATA'|@getFixedLabel}</div>
        <div style="margin-top:10px;text-align:center" id="dvctimedescription" ></div>
        <div id="dv"></div>
        <div class="progress" style="display:block">
          <div id="dvExportprogress" class="bar">&nbsp;</div>
        </div>
        <div class="clear"></div>        
      </td>
    </tr>    
  </table>
</div>

<!--导出 begin-->
<div id="exportResult" class="D_pop_box LdPopWidth500px" style="display:none;">

    <div class="D_pop_tit">
        <strong class="D_ptita">{$MODULE|@getTranstab}>{'EXPORT'|@getFixedLabel}</strong>
        <a href="index.php?module={$MODULE}&action=ListView" class="D_ptitc">
            <img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>      
    <table class="D_pop_bod marB10" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td>
            <div class="padT10 ctextalign font16">{'EXPORT'|@getFixedLabel}{'SUCCESS'|@getFixedLabel}</div>
            <div class="padTB10 ctextalign font16">
                <a href="index.php?module=uploads&frommodule={$MODULE}&action=downloadxls&exportformat={$EXPORTFORMAT}" class="cursorPointer font14">{if $EXPORTFORMAT eq 'exportcsv'}点击下载csv表{else}点击下载Excel表{/if}</a>
            </div>
        </td>
      </tr>
    </table>
</div>

<!--导出 end-->

<script type="text/javascript">
  {literal}
    var pagewidth=Math.max(document.body.clientWidth ,document.body.scrollWidth );
    var pageheight=Math.max(document.body.clientHeight ,document.body.scrollHeight );

    var updatewidth=document.getElementById('selectpopup_1').offsetWidth;
    var updateheight=document.getElementById('selectpopup_1').offsetHeight;

    // document.getElementById('dvExport').style.left=(pagewidth-updatewidth)/2+"px";
    // document.getElementById('dvExport').style.top=(pageheight-updateheight)/2+"px";
    /*function fninvshnew(idname)
    {
      var newbox=document.getElementById(idname);
      newbox.style.display="none";
    }   */
    function showExportResult()
    {
        ld("#selectpopup_1").hide();
     
        fnvshobj("","exportResult");
     
    } 
  {/literal}
</script>

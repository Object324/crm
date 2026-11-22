
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/MailManager/Mask.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/XlsImport/XlsImport.js?v=123"></script>

<script type="text/javascript">

    calendarParentid="ImportXlsDiv";
    var searchandlabel='{'SEARCHAND'|@getFixedLabel}';
   var jsoncheckdupimportfields='{$JSONSELECTCOLUMNS}';
   var jsonmoduleblocks='{$JSONMODULEFIELDBLOCKS}';
   var deletelabel='{'DELETE'|@getFixedLabel}';
    var searchorlabel='{'OR'|@getFixedLabel}';
    var nonelabel="{'CAMCARDNONE'|@getFixedLabel}";
     jsoncheckdupimportfields=eval('('+ jsoncheckdupimportfields +')')?eval('('+ jsoncheckdupimportfields +')'):JSON.parse(jsoncheckdupimportfields);
     jsonmoduleblocks=eval('('+ jsonmoduleblocks +')')?eval('('+ jsonmoduleblocks +')'):JSON.parse(jsonmoduleblocks);
    {literal}
        function deleteimportdupfieldtr(obj)
        {
            var tableobj=document.getElementById('table_importcheckfield');
            var trobj=obj.parentNode.parentNode;
            var rowindex=(trobj.rowIndex);
            tableobj.deleteRow(rowindex);
            if(tableobj.rows.length<3)
            {
                var cellobj_two=tableobj.rows[0].cells[1];
                cellobj_two.innerHTML="";
                
            }
            
        }
       function btn_addCondition()
       {
          var tableobj=document.getElementById('table_importcheckfield');
          var newTR=tableobj.insertRow(tableobj.rows.length-1);
          
          var cellobj_one=newTR.insertCell(0);
          cellobj_one.align="left";
          cellobj_one.width="10%";
          
          var cellobj_two=newTR.insertCell(1);
          cellobj_two.align="left";
          cellobj_two.width="60%";
          var strhtml='<option value="">'+nonelabel+"</option>";
      
         for(var j=0;j<jsonmoduleblocks.length;j++)
         {
            strhtml+="<optgroup label='"+jsonmoduleblocks[j].blocklabel+"'>";
            
             for(var i=0 ;i<jsoncheckdupimportfields.length;i++)
              {
                if(jsoncheckdupimportfields[i].blockid==jsonmoduleblocks[j].blockid)
                     strhtml+='<option value="'+jsoncheckdupimportfields[i].columnname+'">'+jsoncheckdupimportfields[i].fieldlabel+'</option>';                         
              }
               strhtml+="</optgroup>";
               
         }
         
          cellobj_one.innerHTML='<select name="importdupcheckfields[]">'+strhtml+' </select>';
          
          cellobj_two.innerHTML="<label onclick='deleteimportdupfieldtr(this)' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label>";
          
          
          var prev_celltwo=tableobj.rows[tableobj.rows.length-3].cells[1];
          if(tableobj.rows.length>=3)
            prev_celltwo.innerHTML='<select name="importdupfields_condition[]"><option value="or">'+searchorlabel+
                                           '</option><option value="and">'+searchandlabel+"</option></select>";
          if(tableobj.rows.length>3)
          {
              prev_celltwo.innerHTML+="<label onclick='deleteimportdupfieldtr(this)' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label>";
          }
          
                                            
          
       }
    function Import_dupfield_checked(e,WithCheckbox) {
        var str = '';
        var strname='';
        var options = document.getElementsByName(e.name);
        var count = 0;
        for (var i = 0; i < options.length; i++) {
            if (options[i].checked) {
                str += options[i].getAttribute('tag') + ',';
                strname += options[i].value + ',';
                count++;
            }
        }
        if (count > 3) {
            e.checked = false;
            alert(arrJsPopLabel['SELECTUPTOTHREE']);
            str = str.replace(e.getAttribute('tag') + ',', '');
            strname = strname.replace(e.value + ',', '');
        }
        str = str.substring(0, str.length - 1);
        strname = strname.substring(0, strname.length - 1);
        if (str == "" || strname=="") {
             document.getElementById('cmb_span_1_'+WithCheckbox).innerHTML = '';
             document.getElementById('cmb_span_2_'+WithCheckbox).innerHTML = '';
        } else {
            
            document.getElementById('cmb_span_1_'+WithCheckbox).innerHTML = str;
            document.getElementById('cmb_span_2_'+WithCheckbox).innerHTML = strname;
        }
    }
         function ImportXlsSecondStep(obj,importmodel)
         {
         
            
             var mappfields=document.getElementsByName('mapped_fields[]');
             var optvalues='';
             var optvalues2='';
             var arrimport;
             var opt_array = [];
             var opt_array2 = [];
             //判断查重字段是否已经映射
            
             for(var i=0;i<mappfields.length;i++)
             {
                optvalues=optvalues+mappfields[i].options[mappfields[i].selectedIndex].value+',';
                opt_array[i] = mappfields[i].options[mappfields[i].selectedIndex].value;
             }
            
             for(var i=0;i<mappfields.length;i++)
             {
                    
                    importopt=mappfields[i].options[mappfields[i].selectedIndex].value;
                  
                     for(var j=0;j<mappfields.length;j++)
                     {
                        if(mappfields[i].options[mappfields[i].selectedIndex].value!='none-field'&&j!=i&&mappfields[i].options[mappfields[i].selectedIndex].value==mappfields[j].options[mappfields[j].selectedIndex].value&&mappfields[j].options[mappfields[j].selectedIndex].value != 'taxclass-field')
                        {
							var jspop = arrJsPopLabel['FIELDMATCHESTIMES'];
							jspop = jspop.replace("$fldname$",mappfields[i].options[mappfields[i].selectedIndex].text);
                            RemindsMsg("","LdPopWidth400px","","yes","",jspop);
                             return false;
                        }
                     }
                     
             }
            
                                                              
            ImportXlsSecondStepAjax(obj,importmodel);
         }
         function chooseAlert(msg){
            RemindsMsg("","LdPopWidth400px","","yes","",msg);
            return false;
         }
    {/literal}
</script>
<form action="index.php" name="frmimport" method="post">

<div style="padding:0px 2px;">
<table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0">
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<tr>
					<td>{$MODULELABEL} >> {'IMPORT'|@getFixedLabel}</td>
					<td align ="right"></td>
				</tr>
			</table>
		</td>
    </tr> 
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2">{'Stage'|@getFixedLabel} 3 <span style="padding-left:20px">{'SETDUPFIELD'|@getFixedLabel}</span></td>
    </tr> 
    <tr>
        <td class="fontStyle borderALL" colspan="2">
            <div style="margin-top:2mm; font-size:12px; font-weight:normal"><font color="red">{'EXPLAIN'|@getFixedLabel}:</font></div>
            <div style="margin-top:1mm; margin-left:5mm; font-size:12px; font-weight:normal"><font color="#666666">1.{'IMPORTRELATESHIPOR'|@getFixedLabel}</font></div>
            <div style="margin-top:1mm; margin-left:5mm; font-size:12px; font-weight:normal"><font color="#666666">2.{'IMPORTRELATESHIPAND'|@getFixedLabel}</font></div>
            <div>
                <table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0" bgcolor="#ffffff" id='table_importcheckfield'>      
                    <!--下拉框-->
                    {assign var=dupfieldcount value=$CHECKEDCOLUMNS|@count}
                    {math equation="x-1" x=$dupfieldcount assign=dupfieldcount_minus_one}
                    {foreach  key=index  item=selectedcolumnname from=$CHECKEDCOLUMNS}
                        <tr>
                            <td width="15%" align="left">
                           
                                <select name='importdupcheckfields[]'{if $SELECTCOLUMNS|@count eq "1"} disabled="disabled" {/if}>
                                    <option value=" " >{'CAMCARDNONE'|@getFixedLabel}</option>
                                    {foreach item=blockinfo key=blockindex  from=$MODULEFIELDBLOCKS}
                                        <optgroup label="{$blockinfo.blocklabel}">
                                            {foreach item=selinfo from=$SELECTCOLUMNS}
                                                {if $selinfo.blockid eq $blockinfo.blockid}  
                                                    {if $selinfo.columnname eq $selectedcolumnname.column} 
                                                        <option value="{$selinfo.columnname}" selected="">{$selinfo.fieldlabel}</option>
                                                    {else}             
                                                       <option value="{$selinfo.columnname}">{$selinfo.fieldlabel}</option>  
                                                     {/if}  
                                                  {/if}           
                                            {/foreach}
                                        </optgroup>
                                    {/foreach}
                                </select>
                             </td>
                             <td align="left" width="85%">
                                {if $index < $dupfieldcount_minus_one}
                                    <select name="importdupfields_condition[]">
                                        {if $selectedcolumnname.condition eq 'and'}
                                            <option value="or">{'OR'|@getFixedLabel}</option>
                                            <option value="and" selected="">{'SEARCHAND'|@getFixedLabel}</option>
                                            
                                        {else}
                                            <option value="or" selected="">{'OR'|@getFixedLabel}</option>
                                            <option value="and">{'SEARCHAND'|@getFixedLabel}</option>
                                            
                                        {/if}
                                    </select>
                                {/if}
                                {if $index>=1}
                                    <label onclick='deleteimportdupfieldtr(this)' class="icon-homeimg icon-sdel popupselectdiv" style="margin-top:2px;cursor:pointer;"></label>
                                {/if}
                             </td>
                         </tr>
                    {/foreach}
                    <tr>
                        <td colspan="2">
                        {if $SELECTCOLUMNS|@count eq "1"}
                        {else}
                            <input type="button" class='editauto' value="{'NEWCONDITIONS'|@getFixedLabel}" onclick="btn_addCondition()"/>
                        {/if}
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2">{'Stage'|@getFixedLabel} 4 <span style="padding-left:20px">{'SETTINGS'|@getFixedLabel}{$MODULELABEL}{'REPEAT_IMPORT_MODE'|@getFixedLabel}</span></td>
    </tr> 
    <tr> 
        <td colspan="2" class="fontStyle borderALL" style="border-bottom:none">
            <div style="margin-top:2mm; margin-bottom:2mm; font-size:12px; font-weight:normal">
                <label style="margin-right: 25px;"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Update' } checked="checked"{/if} value="Update" {if $importxbx eq 'xbx'} disabled=""{/if} onclick="chooseAlert('{'coveragemethodwillupdate'|@getFixedLabel}')" />{'IMPORTUPDATE'|@getFixedLabel} </label>  
                {if $MODULE eq 'Users'}
                     <label style="margin-right: 25px; display:none"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Insert'} checked="checked"{/if} {if $importxbx eq 'xbx'} disabled=""{/if} value="Insert" />{'IMPORTADD'|@getFixedLabel}</label>
                {else}
                    <label style="margin-right: 25px;"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Insert'} checked="checked"{/if}  {if $importxbx eq 'xbx'} disabled=""{/if} value="Insert" />{'IMPORTADD'|@getFixedLabel}</label>
                {/if}
                <label style="margin-right: 25px;"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Abort'|| $IMPORTCHOOSE eq ""} checked="checked"{/if} value="Abort" {if $importxbx eq 'xbx'} disabled=""{/if} />{'IMPORTABORT'|@getFixedLabel}</label>
                <label style="margin-right: 25px;"><input name="filetype" id="filetype" type="text"  value="{$FILETYPE}"  style="display:none;"/></label>
            </div>
        </td>         
    </tr>
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" style="border-bottom:none" {if $MODULENAME eq 'Accounts' || $MODULENAME eq 'ServiceCharge' || $MODULENAME eq 'ServiceContracts'}colspan="4" {else} colspan="2"{/if}>
            <div>{'Stage'|@getFixedLabel} 5 <span style="padding-left:20px">{'TCMFTMF'|@getFixedLabel}</span></div>    
        </td>
    </tr>
    <tr >
        <td valign="top" colspan="2" style="padding:0px;">
            <div id="ImportXlsDiv">
                <table id="Importtable" class="listEntries_1 unset-overf" width="100%" cellspacing="1" cellpadding="0" style="border-collapse:separate;">
                    <tr>
                        <th width="15%" style="padding-right:10%">{'Field_title'|@getFixedLabel}</th>
                        <th width="25%" style="padding-right:20%">{'Row'|@getFixedLabel}</th>
                        <th width="35%" style='padding-right:16%'>CRM&nbsp;{'LBL_Field'|@getFixedLabel}</th>
                        <th width="25%" style="padding-right:20%">{'Default'|@getFixedLabel}</th>
                    </tr>
                    {foreach item=value key=ky from=$IMPORTDATA name=import}
                        {if $smarty.foreach.import.index %2 ==0}
                        <tr class="fieldIdentifier lvtColData">
                        {else}
                        <tr class="fieldIdentifier lvtColDataBj">
                        {/if}
                        {assign var='V3' value=$value.3 }
                        <td>{$value.0}<input type="hidden" name="isfieldname[]" value="{$value.0}" /> </td>
                        <td>{$value.1}<!--<input type="hidden" name="isfieldnamevalue[]" value="{$value.1}" />--></td>
                        <td>
                            <!--<select  style="width: 75%" name="mapped_fields[]" onchange="defaultImportXls(this,'{$ky}')">
                                {foreach item=drp  from=$IMPORTCOLUMN}
                                     {if $value.3 eq $drp.1}
                                        <option value="{$drp.1}" selected="true">{$drp.2} </option>
                                     {else}
                                         <option value="{$drp.1}" >{$drp.2} </option>
                                     {/if}
                                {/foreach}
                            </select>-->
                            {assign var='fldname' value=$ky}
                            {include file="ImportXls/importfielddrop.tpl"}
                        </td>
                        <td>
                            <span id="{$V3}-defaultvalue-container" name="{$V3}-defaultvalue">
                                {if $value.2 eq 15}
                                    <select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue">
                                        {foreach item=drp key=drpky from=$DROPHTML.$V3}     
                                                <option value="{$drpky}">{$drpky}</option>
                                        {/foreach}
                                    </select>
                                {elseif $value.2 eq 56}
                                    <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                                {elseif $value.2 eq 5}
                                    <input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate" value="" onClick="WdatePicker()" size="15" />
                                    <!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
                                {elseif $value.2 neq 0}
                                    <input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                                {/if}
                             </span>
                        </td>
                    </tr> 
                    {/foreach}
                </table>
            </div>
        </td>
    </tr>
    <tr>
        <td align="middle"  colspan="2" class="borderALL" style="border-top:none;">
            <input type="hidden" value="{$MODULE}" name="module"/>
            {if $importxbx eq 'xbx'}
                <input  type="hidden" value="XBXImportXls" name="action"/>
            {else}
                <input  type="hidden" value="ImportXls" name="action"/>
            {/if}
            <input  type="hidden" name="mapped_fields" id="mapped_fields"/>
            <input  type="hidden" name="defaultvalue" id="defaultvalue"/>
            <input  type="hidden" name="isfieldnamevalue" id="isfieldnamevalue"/>
            <input  type="hidden" name="isfieldname" id="isfieldname"/>
            <input  type="hidden" name="select1" id="select1"/>
            <input  type="hidden" name="select2" id="select2"/>
            <input  type="hidden" name="xlsfiletype" id="xlsfiletype"/>
            
            <input type="hidden" value="Third" name="xlsStep"/>
           
            <input  type="hidden" value="{$MODULE}" name="module"/>
            <input  type="hidden" value="{$MODULE}" name="importmodel"/>
            <input class="editauto" type="button" id="edittype" value="{'IMPORT'|@getFixedLabel}" onclick="return ImportXlsSecondStep(this,'{$MODULE}')"/>
            <input class="cancelauto" type="button" id="canceltype" onclick="window.history.back()" value="{'CANCEL'|@getFixedLabel}" name="cancel">&nbsp;
        </td>
    </tr>   
</table>
</div>
</form>
<div id="defaultValuesElementsContainer" style="visibility: hidden; height: 0px;">

{foreach item=value from=$IMPORTCOLUMN}
    {assign var='V3' value=$value.1}
    {if $V3|@array_key_exists:$SELCOLUMN neq true}
        <span id="{$V3}-defaultvalue-container" name="{$V3}-defaultvalue">
         {if $value.0 eq 15}
            <select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue">
                {foreach item=drp key=drpky from=$DROPHTML.$V3}
                    
                        <option value="{$drpky}">{$drpky}</option>
                    
                {/foreach}
            </select>
          {elseif $value.0 eq 56}
             <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
          {elseif $value.0 eq 5}
         	<input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate" value="" onClick="WdatePicker()" size="15" />
            <!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
          {elseif $value.0 neq 0 or $value.0 eq ''}
            <input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
          {/if}
        </span>
       
    {/if}
{/foreach}
</div>
<div id="actiondiv" class="D_pop_box LdPopWidth600px" style="display:none;"></div>


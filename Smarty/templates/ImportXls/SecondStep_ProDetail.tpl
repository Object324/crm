
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/MailManager/Mask.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/XlsImport/XlsImport.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>

<script type="text/javascript">

    calendarParentid="ImportXlsDiv";
    is_detail_Active = "{$DETAILACTIVE}";
    is_productDetail= "{$IS_PRODUCTDETAIL}";
    is_module="{$MODULENAME}";
    var nonelabel="{'CAMCARDNONE'|@getFixedLabel}";
    
      var searchandlabel='{'SEARCHAND'|@getFixedLabel}';
   var jsoncheckdupimportfields='{$JSONSELECTCOLUMNS}';
   var jsonproductcheckdupfields='{$JSONPRODUCTSELECTCOLUMNS}';
    var jsonmoduleblocks='{$JSONMODULEFIELDBLOCKS}';
   var deletelabel='{'DELETE'|@getFixedLabel}';
    var searchorlabel='{'OR'|@getFixedLabel}';
    jsoncheckdupimportfields=eval('('+ jsoncheckdupimportfields +')')?eval('('+ jsoncheckdupimportfields +')'):JSON.parse(jsoncheckdupimportfields);
    jsonproductcheckdupfields=eval('('+ jsonproductcheckdupfields +')')?eval('('+ jsonproductcheckdupfields +')'):JSON.parse(jsonproductcheckdupfields);
    jsonmoduleblocks=eval('('+ jsonmoduleblocks +')')?eval('('+ jsonmoduleblocks +')'):JSON.parse(jsonmoduleblocks);
    {literal}
        function deleteimportdupfieldtr(obj,type)
        {
             if(type=='main')
             {
                var tableid='table_importcheckfield';
             }
             else
             {
                var tableid='table_productimportcheckfield';
             }
             var tableobj=document.getElementById(tableid);
             var trobj=obj.parentNode.parentNode;
             var rowindex=(trobj.rowIndex);
             tableobj.deleteRow(rowindex);
             if(tableobj.rows.length<=3)
            {
                var cellobj_two=tableobj.rows[1].cells[1];
                cellobj_two.innerHTML="";
                
            }
        }
        function btn_addCondition(type)
        {
            if(type=='main')
            {
                var tableid='table_importcheckfield';
                var selectdupfieldname="importdupcheckfields[]";
                var selectconditioname="importdupfields_condition[]";
                var jsondupfields=jsoncheckdupimportfields;
                
            }
            else if(type=='detail')
            {
                var tableid='table_productimportcheckfield';
                var selectdupfieldname="product_importdupcheckfields[]";
                var selectconditioname="product_importdupfields_condition[]";
                var jsondupfields=jsonproductcheckdupfields;
            }
            var tableobj=document.getElementById(tableid);
            
            var newTR=tableobj.insertRow(tableobj.rows.length-1);
              
              var cellobj_one=newTR.insertCell(0);
              cellobj_one.align="left";
              cellobj_one.width="30%";
              var cellobj_two=newTR.insertCell(1);
              cellobj_two.align="left";
              cellobj_two.width="70%";
             var strhtml="";//'<option value="">'+nonelabel+"</option>";
             if(type=='main')
             {
                 for(var j=0;j<jsonmoduleblocks.length;j++)
                 {
                    strhtml+="<optgroup label='"+jsonmoduleblocks[j].blocklabel+"'>";
                    
                      for(var i=0 ;i<jsondupfields.length;i++)
                      {
                         if(jsoncheckdupimportfields[i].blockid==jsonmoduleblocks[j].blockid)
                            {
                           
                                strhtml+='<option value="'+jsondupfields[i].columnname+'">'+jsondupfields[i].fieldlabel+'</option>'; 
                            }                        
                      }
                    strhtml+="</optgroup>";
                   
                    }
             }
             else
             {
               
                  for(var i=0 ;i<jsondupfields.length;i++)
                  {
                    
                       
                            strhtml+='<option value="'+jsondupfields[i].columnname+'">'+jsondupfields[i].fieldlabel+'</option>'; 
                                           
                  }
               
               
             }
              cellobj_one.innerHTML='<select class="ld-select-inner gwidth30" name="'+selectdupfieldname+'">'+strhtml+' </select>';
              if(tableobj.rows.length>3)
              cellobj_two.innerHTML=" <label onclick='deleteimportdupfieldtr(this,\""+type+"\")' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label>";
              
              
              var prev_celltwo=tableobj.rows[tableobj.rows.length-3].cells[1];
         
              if(tableobj.rows.length>=3)
                prev_celltwo.innerHTML='<select name="'+selectconditioname+'" class="btn-radius-system"><option value="or">'+searchorlabel+
                                               '</option><option value="and">'+searchandlabel+"</option></select>";
              if(tableobj.rows.length>4)
              {
                prev_celltwo.innerHTML+=" <label onclick='deleteimportdupfieldtr(this,\""+type+"\")' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label>";
                
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
            var confirm_str = arrJsPopLabel['SELECTUPTOTHREE'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
             var maindupcheckfields=document.getElementsByName('importdupcheckfields[]');//主表查重字段
             var contactdupcheckfields=document.getElementsByName('product_importdupcheckfields[]');//明细查重字段
             var optvalues='';
             var optvalues2='';
             var arrimport;
             var opt_array=[];//导入中的CRM映射字段
             
             
             if(is_productDetail==2){
                var detail_moudle = "-products";
             }else{
                var detail_moudle = "-detailfield";
             }
           
             for(var i=0;i<mappfields.length;i++)
             {
                    importopt=mappfields[i].options[mappfields[i].selectedIndex].value;
                    opt_array[i]=mappfields[i].options[mappfields[i].selectedIndex].value;
                    
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
             
             for(var i=0;i<maindupcheckfields.length;i++){//主表判断查重字段是否映射
                checkMainfield=maindupcheckfields[i].options[maindupcheckfields[i].selectedIndex].value;
                
                if(checkMainfield!=''&& ld.inArray(checkMainfield+'-field',opt_array) < 0){
                        var ss = maindupcheckfields[i].options[maindupcheckfields[i].selectedIndex].text;
                        var confirm_str = arrJsPopLabel['CHECKIMPORTFIELDNOMAPPING']+"\""+ss+"\""+arrJsPopLabel['NOTMAPPEDIMPORTFAILED'];

                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                }
             }

            if((is_module=='Accounts' || is_module =='ServiceCharge') && is_detail_Active!=1){//判断客户首要联系人查重字段是否映射
                
                for(var i=0;i<contactdupcheckfields.length;i++){//明细判断查重字段是否映射
                    checkContactfield=contactdupcheckfields[i].options[contactdupcheckfields[i].selectedIndex].value;
    
                    if(checkContactfield!=''&& ld.inArray(checkContactfield+'-detailfield',opt_array) < 0){
                            var ss = contactdupcheckfields[i].options[contactdupcheckfields[i].selectedIndex].text;
                            var confirm_str = arrJsPopLabel['CHECKIMPORTFIELDNOMAPPING']+"\""+ss+"\""+arrJsPopLabel['NOTMAPPEDIMPORTFAILED'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                    }
                 }
            }
           
            if(is_productDetail==2){//带产品明细模块查重字段判断是否映射

                for(var i=0;i<contactdupcheckfields.length;i++){//明细判断查重字段是否映射
                    checkDetailfield=contactdupcheckfields[i].options[contactdupcheckfields[i].selectedIndex].value;
                  
                    if(checkDetailfield!=''&& ld.inArray(checkDetailfield+'-products',opt_array) < 0){
                            var ss = contactdupcheckfields[i].options[contactdupcheckfields[i].selectedIndex].text;
                            
                            var confirm_str = arrJsPopLabel['CHECKIMPORTFIELDNOMAPPING']+"\""+ss+"\""+arrJsPopLabel['NOTMAPPEDIMPORTFAILED'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                    }
                 }
            }

            var val_radio_choose = ld('#radio_choose input[name="choose"]:checked ').val(); //获取查重方式
            if(val_radio_choose == 'Update' && (importmodel !='Accounts' || importmodel !='ServiceCharge')){
                if(!confirm(arrJsPopLabel['COVERAGETOCONTINUE'])){
                    return false;
                }
            }
            //openNewDiv('newDiv');
            //document.forms['frmimport'].submit();                                                        
            ImportXlsSecondStepAjax(obj,importmodel);
         }
		 //选择产品查重字段时。设置设置产品不存在时导入方式
         function setProductImportType(obj){
			if(obj.value == ''){
				ld('#NoImportRow_label').hide();
				ld('#NoImportData_label').hide();
				ld("input[type=radio][name='product_import_type'][value=AddProduct]").attr("checked",'checked');
			}else{
				ld('#NoImportRow_label').show();
				ld('#NoImportData_label').show();
			}
		 }
        function chooseAlert(msg){
            RemindsMsg("","LdPopWidth400px","","yes","",msg);
            return false;
        }   
    {/literal}
</script>
<form action="index.php" name="frmimport">

<div style="padding:0px 2px;">
<table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0" >
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
        <td class="fontStyle borderALL" colspan="2" style="padding-left: 0px;padding-right: 0px;">
            <div style="margin-top:2mm; font-size:12px; font-weight:normal;padding-left: 3px;"><font color="red">{'EXPLAIN'|@getFixedLabel}:</font></div>
            <div style="margin-top:1mm; margin-left:5mm; font-size:12px; font-weight:normal"><font color="#666666">1.{'IMPORTRELATESHIPOR'|@getFixedLabel}</font></div>
            <div style="margin-top:1mm; margin-left:5mm; font-size:12px; font-weight:normal"><font color="#666666">2.{'IMPORTRELATESHIPAND'|@getFixedLabel}</font></div>
            <table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0" id='table_importcheckfield'>
                <tr style="border-bottom: 1px solid #dadada;"><td colspan="2">{$MODULE|@getTranstab}{'CHECKIMPORTFIELD'|@getFixedLabel}</td></tr>
                {assign var=dupfieldcount value=$CHECKEDCOLUMNS|@count}
                {math equation="x-1" x=$dupfieldcount assign=dupfieldcount_minus_one}
                {foreach  key=index  item=selectedcolumnname from=$CHECKEDCOLUMNS}
                <tr>
                    <td width="30%" align="left">
                        <select  name='importdupcheckfields[]' class="ld-select-inner gwidth30">
                            <option value="" >{'CAMCARDNONE'|@getFixedLabel}</option>
                                {foreach item=blockinfo key=blockindex  from=$MODULEFIELDBLOCKS}
                                     <optgroup label="{$blockinfo.blocklabel}">
                                        {foreach item=selinfo from=$SELECTCOLUMNS}  
                                            {if $selinfo.blockid eq $blockinfo.blockid}  
                                                {if $selinfo.columnname eq $selectedcolumnname.column} 
                                                <option  value="{$selinfo.columnname}" selected="">{$selinfo.fieldlabel}</option>
                                                {else}             
                                                <option value="{$selinfo.columnname}">{$selinfo.fieldlabel}</option>  
                                                {/if}
                                            {/if}             
                                        {/foreach}
                                    </optgroup>
                                {/foreach}
                        </select>
                    </td>
                    <td align="left" width="70%">
                        {if $index < $dupfieldcount_minus_one}
                            <select name="importdupfields_condition[]" class="btn-radius-system">
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
                            <label onclick='deleteimportdupfieldtr(this,"main")' class="icon-homeimg icon-sdel popupselectdiv" style="margin-top:2px;cursor:pointer;"></label>
                        {/if}
                    </td>
                </tr>
                {/foreach}
                <tr>
                    <td colspan="2" align="left">
                        <input  type="button" class='editauto addConditionRow' value="{'NEWCONDITIONS'|@getFixedLabel}" onclick="btn_addCondition('main')"/>
                    </td>
                </tr>
            </table>
            {if $PRODUCTCHECKEDCOLUMNS|@count>0}
                <table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0" id="table_productimportcheckfield">
                {if $MODULE eq 'Accounts'||$MODULE eq 'ServiceCharge'}
                    <tr style="border-bottom: 1px solid #dadada;"><td colspan="2" align="left">{'Contacts'|@getTranstab}{'CHECKIMPORTFIELD'|@getFixedLabel}
                    <span style="margin-top:1mm; font-size:12px; font-weight:normal"><font color="#666666">{'NOTNEEDTOIMPORTCONTACTS'|@getFixedLabel}</font></span>
                    </td></tr>
                {else}
                    <tr style="border-bottom: 1px solid #dadada;"><td colspan="2" align="left">{'Products'|@getTranstab}{'CHECKIMPORTFIELD'|@getFixedLabel}</td></tr>
                {/if}
                {assign var=dupfieldcount value=$PRODUCTCHECKEDCOLUMNS|@count}
                {math equation="x-1" x=$dupfieldcount assign=dupfieldcount_minus_one}
                {foreach  key=index  item=selectedcolumnname from=$PRODUCTCHECKEDCOLUMNS}
                    <tr>
                        <td width="30%" align="left">
                            <select class="ld-select-inner gwidth30" name='product_importdupcheckfields[]' onchange="setProductImportType(this)">
                                {foreach item=selinfo from=$PRODUCTSELECT}  
                                    {if $selinfo.columnname eq $selectedcolumnname.column} 
                                    <option  value="{$selinfo.columnname}" selected="">{$selinfo.fieldlabel}</option>
                                    {else}             
                                    <option  value="{$selinfo.columnname}">{$selinfo.fieldlabel}</option>  
                                    {/if}             
                                {/foreach}
                            </select>
                        </td>
                        <td align="left" width="70%" >
                            {if $index < $dupfieldcount_minus_one}
                                <select name="product_importdupfields_condition[]" class="btn-radius-system">
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
                                <label onclick='deleteimportdupfieldtr(this,"detail")' class="icon-homeimg icon-sdel popupselectdiv" style="margin-top:2px;cursor:pointer;"></label>
                            {/if}
                        </td>
                    </tr>
                {/foreach}
                    <tr>
                        <td colspan="2" align="left">
                            <input  type="button" class='editauto addConditionRow' value="{'NEWCONDITIONS'|@getFixedLabel}" onclick="btn_addCondition('detail')"/>
                        </td>
                    </tr>
                </table>
            {/if}
        </td>
    </tr>  
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2">{'Stage'|@getFixedLabel} 4 <span style="padding-left:20px;">{'SETTINGS'|@getFixedLabel}{$MODULELABEL}{'REPEAT_IMPORT_MODE'|@getFixedLabel}</span></td>
    </tr>
    <tr>
        <td class="borderALL" colspan="2">
            <div id="radio_choose" style="margin-top:2mm; margin-bottom:2mm; font-size:12px; font-weight:normal">
                <label style="margin-right: 25px;"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Update' } checked="checked"{/if} value="Update" onclick="chooseAlert('{'coveragemethodwillupdate'|@getFixedLabel}')" />{'IMPORTUPDATE'|@getFixedLabel} </label>  
                <label style="margin-right: 25px;"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Insert' } checked="checked"{/if} value="Insert" />{'IMPORTADD'|@getFixedLabel}</label>
                <label style="margin-right: 25px;"><input name="choose" id="choose" type="radio" {if $IMPORTCHOOSE eq 'Abort'|| $IMPORTCHOOSE eq ''} checked="checked"{/if} value="Abort" />{'IMPORTABORT'|@getFixedLabel}</label>
                <label style="margin-right: 25px;"><input name="filetype" id="filetype" type="text"  value="{$FILETYPE}"  style="display:none;"/></label><!--为了获取导入文件的后缀名-->
            </div> 
        </td>
    </tr>
	<tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2">{'Stage'|@getFixedLabel} 5 <span style="padding-left:20px;">{'howtodowhentheproductsisnotexists'|@getFixedLabel}</span></td>
    </tr>
	<tr>
        <td class="borderALL" colspan="2">
            <div id="radio_choose" style="margin-top:2mm; margin-bottom:2mm; font-size:12px; font-weight:normal">
                <label style="margin-right: 25px;" id="NoImportRow_label"><input name="product_import_type" id="product_import_type" type="radio"{if $PRODUCTIMPORTTYPE eq 'NoImportRow'}checked="checked"{/if} value="NoImportRow" />{'Ignoretheproducts'|@getFixedLabel} </label>  
                <label style="margin-right: 25px;" id="NoImportData_label"><input name="product_import_type" id="product_import_type" type="radio" {if $PRODUCTIMPORTTYPE eq 'NoImportData'}checked="checked"{/if} value="NoImportData" />{'Ignoretheorder'|@getFixedLabel}</label>
                <label style="margin-right: 25px;" id="AddProduct_label"><input name="product_import_type" id="product_import_type" type="radio" {if $PRODUCTIMPORTTYPE eq 'AddProduct' || $PRODUCTIMPORTTYPE eq ''}checked="checked"{/if} checked="checked" value="AddProduct" />{'Automaticallyaddproducts'|@getFixedLabel}</label>
            </div> 
        </td>
    </tr>
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2" style="border-bottom: none !important;">{'Stage'|@getFixedLabel} 6 <span style="padding-left:20px;">{'TCMFTMF'|@getFixedLabel}</span></td>
    </tr>
    <tr>
        <td valign="top" colspan="2"  style="padding:0px;">
            <div id="ImportXlsDiv">
            <table id="Importtable" class="listEntries unset-overf" width="100%" cellspacing="1" cellpadding="0" style="border-collapse:separate;">
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
						{if $V3 neq 'none-field'}
							<span id="{$V3}-defaultvalue-container" name="{$V3}-defaultvalue">
							  {if $value.2 eq 15}
								<select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="btn-radius-system">
									{foreach item=drp key=drpky from=$DROPHTML.$V3}
										
											<option value="{$drpky}">{$drpky}</option>
									{/foreach}
								</select>
							  {elseif $value.2 eq 56}
								 <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
							  {elseif $value.2 eq 5}
								
								<input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate btn-radius-system" value="" onClick="WdatePicker()" size="15" />
								<!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
							  {else}
								<input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="btn-radius-system"/>
							  {/if}
							 </span>
						{/if}
                    </td>
                    </tr>
                {/foreach}
            </table>
            </div>
        </td>
    </tr>
    <tr>
        <td align="middle" colspan="2"  class="borderALL" style="border-top:none !important;">
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
            <input class="editauto" type="button" id="edittype" value="{'IMPORT'|@getFixedLabel}" onclick="ImportXlsSecondStep(this,'{$MODULE}')"/>
            <input class="cancelauto" type="button" id="canceltype" onclick="window.history.back()" value="{'CANCEL'|@getFixedLabel}" name="cancel">
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
            <select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="btn-radius-system">
                {foreach item=drp key=drpky from=$DROPHTML.$V3}
                    
                        <option value="{$drpky}">{$drpky}</option>
                    
                {/foreach}
            </select>
          {elseif $value.0 eq 56}
             <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
          {elseif $value.0 eq 5}
         	<input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate btn-radius-system" value="" onClick="WdatePicker()" size="15" />
            <!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
          {elseif $value.0 neq 0 or $value.0 eq ''}
            <input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="btn-radius-system" />
          {/if}
        </span>
       
    {/if}
{/foreach}
</div>
<div id="actiondiv" class="D_pop_box LdPopWidth600px" style="display:none;"></div>
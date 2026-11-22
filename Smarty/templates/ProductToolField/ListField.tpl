<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/producttool/toolField.js?v={$GLOBALMINVERSION}"></script>
{* editor:gyq_10 reason:引入费用报销特殊处理JS文件 date:20160420 *}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/producttool/TabDetailFields.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/reverseformula.js?v={$GLOBALMINVERSION}"></script>
<script language="javascript">

var columnStringarr;
{literal}
var formulaCombox;
var letters=new Array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z');
function closeEditFieldPopup()
{
    fninvshnew('dvProductToolEditField');
    CrmPopup.global_listPopupObj.pop();
}
function addFormulaCombox(name)
{
  
    var combox="<select id='"+name+"' name='"+name+"' class='ld-select-inner gwidth70'>";
    
    for(var i=0;i<objField.length;i++)
    {
        combox+=" <option value='"+objField[i].columnname+"'>"+objField[i].fieldlabel+"</option> ";
    }
    combox+='</select>';
    
    return combox;
}
/*
eidt:can
reasoN:增加字段公司下拉框
rowcount:增加的行数
*/
function addFormulaTableTr(rowcount){
  var tableobj=document.getElementById('toolfieldFormula');
  var rowobj;
  var cellobj;
  if(tableobj.rows.length>26){
    alert('最多只能新增26个变量！');
    return false;
  }
  for(var i=0;i<rowcount;i++){
    var totalrow=tableobj.rows.length-1;
    var rowobj=tableobj.insertRow(totalrow);
    rowobj.id='formual_row_'+totalrow;
    rowobj.setAttribute('deleted',0);
    cellobj=rowobj.insertCell(0);
    cellobj.innerHTML=addFormulaCombox('formualcombox_'+totalrow);
    cellobj=rowobj.insertCell(1);
    cellobj.innerHTML="<input class='ld-input-inner gwidth90' type='text' name='formualtext_"+totalrow+"' id='formualtext_"+totalrow+"' value='"+letters[totalrow]+"'>";
    cellobj=rowobj.insertCell(2);
    cellobj.innerHTML='<a href="javascript:;" id="formualdeleteimg_'+totalrow+'" title="'+arrJsPopLabel["DELETE"]+'" onclick="deleteFormulaRow(\''+totalrow+'\')">'+arrJsPopLabel['DELETE']+'</a>';
  }
  document.getElementById('definingContentDiv').style.display='';
}
function deleteFormulaRow(rowIndex)
{
    var tableobj=document.getElementById('toolfieldFormula');
    tableobj.deleteRow(rowIndex);
    var totalrow=tableobj.rows.length-1;
   
    if(rowIndex>=totalrow)
    {
        return ;
    }
    var rowobj;
    var idIndex=0;
    var objlettertext;
    var objdeleteimg;
    var formulafieldsCombox;
    for(var i=rowIndex;i<totalrow;i++)
    {
         idIndex=parseInt(i,10)+1;
         rowobj=document.getElementById('formual_row_'+idIndex);
         rowobj.setAttribute('id','formual_row_'+i);
         formulafieldsCombox=document.getElementById('formualcombox_'+idIndex);
          formulafieldsCombox.setAttribute('id','formualcombox_'+i);
         formulafieldsCombox.setAttribute('name','formualcombox_'+i);
         objlettertext=document.getElementById('formualtext_'+idIndex);
         objlettertext.setAttribute('id','formualtext_'+i);
         objlettertext.setAttribute('name','formualtext_'+i);
         objlettertext.value=letters[i];
         rowobj.cells[2].innerHTML='<a  href="javascript:;" id="formualdeleteimg_'+totalrow+'" title="'+arrJsPopLabel["DELETE"]+'" onclick="deleteFormulaRow(\''+i+'\')">'+arrJsPopLabel["DELETE"]+'</a>';
        
        
    }
}
function clearFormulaTable()
{
     var tableobj=document.getElementById('toolfieldFormula');
    
     var i=1;
    
     while(true)
     {  if(i>tableobj.rows.length-1)
        {
            break;
        }
        tableobj.deleteRow(0);
        
        i++;
     }
    
}
/**
formulacontent:字段公式内容
formualvar:字段公式变量(数组)
*/
function formualValidata(formulacontent,formualvar)
{
    var onechar;
    var nextchar;
    var operations=new Array('+','-','*','/','%');
    var Brackets=new Array('(',')','[',']','（','）');
    var digits=new Array('0','1','2','3','4','5','6','7','8','9','.');
	var errpr_msg = '';
    for(i=0;i<formulacontent.length;i++)
    {
             onechar=formulacontent.substr(i,1);
             nextchar=formulacontent.substr(i+1,1);
             if(nextchar=='' ||trim(onechar)=='')
             {
                continue;
             }
             if(ld.inArray(onechar,letters)>=0)//如果该字符为变量
             {
                 //如果该字符为变量,下一个字符串不能为变量
                 if(ld.inArray(nextchar,letters)>=0)
                 {
                    errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
					return errpr_msg;
                 }
                if(formualvar[onechar]=='')
                {
					errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
					return errpr_msg;
                    //alert('字段公式验证错误');
                   // return false;
                }
             }
             else if(ld.inArray(onechar,operations)>=0)//如果是运算符号
             {
                 
                if(ld.inArray(nextchar,operations)>=0)//下一个字符一定不能是运算符号
                {
                    errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
					return errpr_msg;
                }
             }
             else if(ld.inArray(onechar,Brackets)>=0)
             {
                
             }
             else if(ld.inArray(onechar,digits)>=0)
             {
                
             }
             else
             {
              
              
                errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
				return errpr_msg;
             }    
    } 
    
    return errpr_msg;
}
//审批要求 - 其他要求
function get_detail_effective_condition(columnname){
	var reference_module = ld('#referencemodule').val();
	get_effective_condition(columnname,reference_module);
}
/*
* reason: 自定义字段保存事件
* edit: chj 2015/6/15
*/
function saveFieldInfo(tabid,producttoolfieldid){
    var formulacontent='';
    var formulavar="";
    var formulacolumn="";

	var urlstring = '';
    //中文标签
	if($('zh_fieldlabel') != undefined){
		if($('zh_fieldlabel').value == ''){
            var confirm_str = arrJsPopLabel['CHINESEBLOCKNAMENOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
      			$('zh_fieldlabel').focus();
      			return false;
		}
		else{
			urlstring +='zh_fieldlabel='+encodeURIComponent($('zh_fieldlabel').value);
		}
	}
	//英文标签
	if($('en_fieldlabel') != undefined){
		if($('en_fieldlabel').value == ''){
            var confirm_str = arrJsPopLabel['ENGLISHBLOCKNAMENOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            $('en_fieldlabel').focus();
			      return false;
		}else{
			urlstring +='&en_fieldlabel='+encodeURIComponent($('en_fieldlabel').value);
		}
	}
	//宽度
	if($('width') != undefined){
		if($('width').value == ''){
            var confirm_str = $('width').alt+arrJsPopLabel['CANOTEMPTY']+'!';
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    			$('width').focus();
    			return false;
		}else{
			urlstring +='&width='+$('width').value;
		}
	}
	//必填字段
	if($('mandatory_check') != null){
		if($('mandatory_check').checked == true){
			urlstring += '&ismandatory=0';	
		}else{
			urlstring += '&ismandatory=1';	
		}
	}
	//是否启用
	if($('presence_check') != null){
		if($('presence_check').checked == true){
			urlstring += '&ispresence=0';	
		}else{
			urlstring += '&ispresence=1';
		}
	}
	//允许编辑
	if($('is_edit') != null){
		if($('is_edit').checked == true){
			urlstring += '&isedit=0';	
		}else{
			urlstring += '&isedit=1';	
		}
	}
    //仅允许从价格表选择
    if (ld('#tr_selectpricefrombook').length > 0){
        var selectpricefrombook = ld('#selectpricefrombook').prop('checked') ? 'yes' : 'no'
        urlstring += '&selectpricefrombook='+selectpricefrombook;
    }
	if($('uitype') != null){
		if($('uitype').checked == true){
			urlstring += '&uitype='+$('uitype').value;	
		}else{
			urlstring += '&uitype='+$('uitype').value;	
		}
	}
    //zkt 20231221 BUG0077183  	带有产品分录的模块，如正常订单/费用货补模块，比如我件数字段是数字类型的字段，我点击"是否计算小计"勾选后，再点击旁边的字段权限，选择“全部”再保存，保存后再次打开，发现"是否计算小计"是没被勾选上了。如图。
	//hzx 是否小计
    if(ld('#subtotal_attr_check').length > 0 && ld('#subtotal_attr_check').prop('checked')){
        urlstring += '&subtotal_attr=yes';
    }else{
        urlstring += '&subtotal_attr=no';
    }
    //xxy 2023-11-15 自动换行
	if(ld('#auto_wordwrap_check').length > 0 && ld('#auto_wordwrap_check').prop('checked')){
        urlstring += '&auto_wordwrap=yes';	
    }else{
        urlstring += '&auto_wordwrap=no';	
	}
    //xxy 2024-06-05 帮助信息
	if(ld('#helptips').length > 0){
        urlstring += '&helptips='+encodeURIComponent(ld('#helptips').val());
	}

	//适用范围
	// if(ld('#profile_field_type') != undefined){
	// 	var profile_field_type = ld('input:radio[name="profile_field_type"]:checked').val();
	// 	urlstring += '&profile_field_type='+profile_field_type;
	// 	if(profile_field_type > 0){
	// 		var profile_field_value = ld('#hidden_pro_profile_value').val();
	// 		urlstring += '&profile_field_value='+profile_field_value;
	// 	}
	// }
    //hzx 分录字段权限
    if(ld('#fields_access_div') != undefined && ld('#fields_access_div').length > 0){
        var profile_field_type = 0;
        if(ld('#hidden_pro_profilefieldtype').val() == 'all'){
            profile_field_type = 0;
        }else if(ld('#hidden_pro_profilefieldtype').val() == 'user'){
            profile_field_type = 1;
        }else if(ld('#hidden_pro_profilefieldtype').val() == 'group'){
            profile_field_type = 2;
        }else if(ld('#hidden_pro_profilefieldtype').val() == 'role'){
            profile_field_type = 3;
        }
        var profile_field_value = '';
        if(ld('#entry_fields_scope').val() == 'all' || ld('#entry_field_scope_list table tr').length <= 0){
            profile_field_value = '';
            var create_profile = 'hidden';
            if(ld('#entry_field_scope_list_top table tr').find('input[name=all_createview_visible]').prop('checked') == true && ld('#entry_field_scope_list_top table tr').find('input[name=all_createview_edit]').prop('checked') == true){
                create_profile = 'write';
            }else if(ld('#entry_field_scope_list_top table tr').find('input[name=all_createview_visible]').prop('checked') == true && ld('#entry_field_scope_list_top table tr').find('input[name=all_createview_edit]').prop('checked') == false){
                create_profile = 'read';
            }
            var edit_profile = 'hidden';
            if(ld('#entry_field_scope_list_top table tr').find('input[name=all_editview_visible]').prop('checked') == true && ld('#entry_field_scope_list_top table tr').find('input[name=all_editview_edit]').prop('checked') == true){
                edit_profile = 'write';
            }else if(ld('#entry_field_scope_list_top table tr').find('input[name=all_editview_visible]').prop('checked') == true && ld('#entry_field_scope_list_top table tr').find('input[name=all_editview_edit]').prop('checked') == false){
                edit_profile = 'read';
            }
            var details_profile = 'hidden';
            if(ld('#entry_field_scope_list_top table tr').find('input[name=all_detailsview_visible]').prop('checked') == true){
                details_profile = 'read';
            }
            profile_field_array = {
                'create_profile': create_profile,
                'edit_profile': edit_profile,
                'details_profile': details_profile
            }
            var profile_field_json = JSON.stringify(profile_field_array);
            profile_field_value = profile_field_json;
        }else{
            var profile_field_array = {};
            ld.each(ld('#entry_field_scope_list table tr'),function (index,obj){
                var create_profile = 'hidden';
                if(ld(this).find('input[name=createview_visible]').prop('checked') == true && ld(this).find('input[name=createview_edit]').prop('checked') == true){
                    create_profile = 'write';
                }else if(ld(this).find('input[name=createview_visible]').prop('checked') == true && ld(this).find('input[name=createview_edit]').prop('checked') == false){
                    create_profile = 'read';
                }
                var edit_profile = 'hidden';
                if(ld(this).find('input[name=editview_visible]').prop('checked') == true && ld(this).find('input[name=editview_edit]').prop('checked') == true){
                    edit_profile = 'write';
                }else if(ld(this).find('input[name=editview_visible]').prop('checked') == true && ld(this).find('input[name=editview_edit]').prop('checked') == false){
                    edit_profile = 'read';
                }
                var details_profile = 'hidden';
                if(ld(this).find('input[name=detailsview_visible]').prop('checked') == true){
                    details_profile = 'read';
                }
                profile_field_array[ld(this).data('relatedid')] = {
                    'fieldid': ld(this).data('relatedid'),
                    'create_profile': create_profile,
                    'edit_profile': edit_profile,
                    'details_profile': details_profile
                }
            });
            var profile_field_json = JSON.stringify(profile_field_array);
            profile_field_value = profile_field_json;
        }
        urlstring += '&profile_field_type='+profile_field_type;
        urlstring += '&profile_field_value='+profile_field_value;
    }
    //duan 字段在移动端明细页签是否显示
	if(ld('#mobiledetailshow') != undefined){
		if(ld('#mobiledetailshow').prop('checked')){
            urlstring += '&mobiledetailshow=yes';
		}else{
            urlstring += '&mobiledetailshow=no';
		}
	}
	//字段类型
	var selectFieldType = ld('#selectFieldType').val();
	if(selectFieldType == 100  || selectFieldType == 'Reference'){
		urlstring += '&referencemodule='+ld('#referencemodule').val();
		urlstring += '&datarange='+ld('#datarange').val();
		urlstring += '&approve_demand='+ld('#approve_demand').val();
		urlstring += '&maxrowsshow='+ld('#maxrowsshow').val();
		urlstring += '&advft_criteria_groups='+ld('#reference_advft_criteria_groups').val();
		urlstring += '&advft_criteria='+ld('#reference_advft_criteria').val();
	}
    //edit: xll 2023/05/22 XUQIU1001203 产品分录-关联选择单、选择源单、引用字段增加显示超链接
    //引用字段：101
    //edit: xll 2023/09/02 BUG0071780 页面设置-客户管理，新增“关联选择单据（多选）”字段，设置“显示超链接”，无法保存该设置，第二次编辑设置才能保存。
    var selectFieldType_arr = new Array('100','101','200','201','202','reference','selectsource','relatedmodulefield','multireference','1');
    if(selectFieldType_arr.includes(selectFieldType.toLowerCase())){
        if(ld('#ShowHyperlinks_check') != null){
            var ShowHyperlinks = ld('#ShowHyperlinks_check').prop('checked') ? 'yes' : 'no';
            urlstring += '&ShowHyperlinks=' + ShowHyperlinks;
    	}
	}
    var columnname=ld("#columnname").val();

	//文本类型
	   var selectFieldType = $('selectFieldType').value;
    //zkt 0048676: （http://42.194.219.75:85/crm [^] ）客户问题（广州源丰）自营管理-产值及成本核算-单据分录设置，新增引用字段后点编辑出现错误
    //特殊处理已移出值下方，此处代码已无用
    /* editor:gyq_10  reason:费用报销分录特殊处理 date:20160420*/
    //var tabDetailFields = TabDetailFields.getInstance().saveFieldInfo(selectFieldType);
    var tabDetailFields = '';
	var fldPickList = '';
    
	if(columnname!='wareid'&&(selectFieldType == 60 || selectFieldType == 63 || selectFieldType == 'SelectComBox'|| selectFieldType == 'Select')){
        //@edit:liushuai,2020-12-22,reason： 038352: （1.6）项目工时新建界面，分录明细中【类型】字段下拉选项值显示错误（系统设置-单据分录-项目工时-类型-下拉框列表值固定值为Direct、Indirect。但要显示成中文，即不根据textarea的值去取）
	    if (columnname == 'timetype' && tabid == 122){//producttoolfieldid == 13
            fldPickList = encodeURIComponent("Direct\n" + "Indirect");
        }else{
            //fldPickList = encodeURIComponent(document.getElementById("picklist_value").value);
            //BUG0077891 xxy 2024-1-2 产品分录定制和模块页面设置新建下拉框字段，下拉框列表值风格不一致，建议改成模块页面设置的那种风格 
            var fldPickList = getMultiPickListSelectValueByObj(ld('#fldpicklist'));
            fldPickList = fldPickList.replace(/########/g,'\n');
            fldPickList = encodeURIComponent(fldPickList);
        }
		if(empty(fldPickList)){
			var confirm_str = document.getElementById("picklist_value").getAttribute('tag');
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']+'!');
            return false;
		}
		urlstring +='&fldPickList='+fldPickList;
	}
    
    if(tabDetailFields == 'exit'){
        /* 内容异常终止保存 */
        return false;
    }else if(tabDetailFields){
        /* 费用报销保存 */
        urlstring += tabDetailFields;
    } else {
        /* 常规模块保存 */
        var tmpselectsource_fieldbigtype = '';
        if (ld('#selectsource_fieldbigtype').val() != undefined && ld('#selectsource_fieldbigtype').val() != '') {
            tmpselectsource_fieldbigtype = ld('#selectsource_fieldbigtype').val();
        }

        if (selectFieldType == 'Date'||selectFieldType == 51||selectFieldType == 52||selectFieldType == 53||selectFieldType == 54) {//日期
            var dateStyle = $('selectDateStyle').value;
            urlstring += '&selectFieldType=' + dateStyle;
            if ($('dateOption') != undefined) {
                urlstring += '&dataOption=' + $('dateOption').value;
            }
			urlstring += "&savedatabase=yes"; 
        } else {
            //文本
            if (selectFieldType == '1'||selectFieldType == 'Text') {
                //字段长度
                if ($('textlength') != undefined) {
                    if ($('textlength').value == '') {
                        var confirm_str = $('textlength').alt + arrJsPopLabel['CANOTEMPTY'] + '!';
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        $('textlength').focus();
                        return false;
                    } else {
                        urlstring += '&textlength=' + $('textlength').value;
                    }
                }
            } else if (selectFieldType == 'Num'||selectFieldType=='20' || ((selectFieldType == 101 || selectFieldType == 'RelatedModuleField')&&tmpselectsource_fieldbigtype=='number')) {//数字
                //精度
                if ($('precisionvalue') != undefined) {
                    var precisionvalue = $('precisionvalue').value;
                    if (precisionvalue == '' || precisionvalue < 0) {
                        var confirm_str = arrJsPopLabel['PRECISIONVALUE']+arrJsPopLabel['cannotbelessthan1']+'0';
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						$('precisionvalue').focus();
                        return false;
                        //urlstring += '&precision=0';
                    } else {
                        urlstring += '&precision=' + precisionvalue;
                    }
                }
            } else if (selectFieldType == 10||selectFieldType == 'Number') {	//数量
                urlstring += '&precision=8';//数量默认精度为8
            } else if ((selectFieldType == 163)) {	//单价
                //精度
                if ($('precisionvalue') != undefined) {
                    var precisionvalue = $('precisionvalue').value;
                    if (precisionvalue == '' || precisionvalue <= 0) {
                        urlstring += '&precision=2';
                    } else {
                        urlstring += '&precision=' + precisionvalue;
                    }
                }
            }else if (selectFieldType == 50||selectFieldType=='Amount') {	//金额 
                //精度
                if ($('precisionvalue') != undefined) {
                    var precisionvalue = $('precisionvalue').value;
                    //zkt 20240702 BUG20240626-66  后台设置小数位为0，但是订单页面金额还是显示6位小数（kfbcrm合计展示有问题，价税合计没有问题）
                    if (precisionvalue == '' || precisionvalue < 0) {
                        urlstring += '&precision=6';
                    } else {
                        urlstring += '&precision=' + precisionvalue;
                    }
                }
            } else if (selectFieldType == 56||selectFieldType=='CheckBox') {
                if ($('checkcolumn').checked == true) {
                    urlstring += '&checkcolumn=1';
                } else {
                    urlstring += '&checkcolumn=0';
                }
            }
			//引用字段
			if(selectFieldType == 101 || selectFieldType == 'RelatedModuleField'){
					if ($('savedatabase').checked == true) {
						urlstring += "&savedatabase=yes";
					} else {
						urlstring += "&savedatabase=no";
					}
                    //精度
                    if ($('precisionvalue') != undefined) {
                        var precisionvalue = $('precisionvalue').value;
                        urlstring += '&precision=' + precisionvalue;
                    }
					urlstring += '&related_module=' + $('select_related_module').value;
					if(producttoolfieldid > 0)
						urlstring += '&related_module_column=' + ld('#select_related_module').val();
					else{
						urlstring += '&related_module_column=' + ld('#select_related_module').find("option:selected").attr('column');
					}
					urlstring += '&related_module_field=' + $('relatedmodulefield').value;
			}else{
			    //duan 20240329 新增时默认允许保存到数据库，录入方式为产品属性的在后台有处理，其他情况下，读界面上设置的内容
                if($('savedatabase').checked == true || producttoolfieldid <= 0) {
                    urlstring += "&savedatabase=yes";
                } else {
                    urlstring += "&savedatabase=no";
                }
            }
			//引用字段 - 源单
			if(selectFieldType == 101 || selectFieldType == 'RelatedModuleField'){
				if(producttoolfieldid > 0)
					var bigtype = ld('#fromvalue_type').val();
				else
					var bigtype = ld('#select_related_module').find("option:selected").attr('bigtype');
				if(bigtype == 'selectsource'){
					var optionmodule_string = ld('#optionmodule_string').val();
					if(!empty(optionmodule_string)){
						var optionmodules = [];
						optionmodules = optionmodule_string.split(',');
						var optionmodule_param ={}; //传值变量
                        var tmpbigtype = '';//字段类型
                        var tmpreferencemodule = '';//引用关联选择单据字段对应模块
                        if(ld('#selectsource_fieldbigtype').val() != undefined &&ld('#selectsource_fieldbigtype').val() != ''){
                            tmpbigtype =ld('#selectsource_fieldbigtype').val();
                            if(tmpbigtype == 'moduleno'){
                                tmpbigtype = 'text';
                            }
                         }
                         if(ld('#selectsource_fieldreferencemodule').val() != undefined &&ld('#selectsource_fieldreferencemodule').val() != ''){
                            tmpreferencemodule =ld('#selectsource_fieldreferencemodule').val();
                         }
						ld.each(optionmodules,function(index,module){
							if(ld('#relatedsourcefield_'+module).val() != undefined && ld('#relatedsourcefield_'+module).val() != ''){
							     var columntype = '';
                                 if(ld('#relatedsourcefield_'+module).find("option:selected").attr("columntype")!=undefined){
                                    columntype = ld('#relatedsourcefield_'+module).find("option:selected").attr("columntype");
                                 }
                                 var columnname = ld('#relatedsourcefield_'+module).val();
                                 var tmpcolumninfoarr = {"columntype":columntype,"columnname":columnname};
								optionmodule_param[module] = tmpcolumninfoarr;
                                var selectbigtype = ld('#relatedsourcefield_'+module).find("option:selected").attr("bigtype");
                                if(selectbigtype == 'moduleno'){
                                    selectbigtype = 'text';
                                }
                                if(tmpbigtype==''){
                                    tmpbigtype = selectbigtype;
                                }
                                else if(tmpbigtype != selectbigtype){
                                    tmpbigtype = 'false';
                                    return false;
                                }
                                if(tmpbigtype == 'reference'){
                                    var selectreferencemodule = ld('#relatedsourcefield_'+module).find("option:selected").attr("referencemdoule");
                                    if(tmpreferencemodule==''){
                                        tmpreferencemodule = selectreferencemodule;
                                    }
                                    else if(tmpreferencemodule != selectreferencemodule){
                                        tmpreferencemodule = 'false';
                                        return false;
                                    }
                                }
							}
						});
                        if(tmpbigtype == 'false'){
                            var confirm_str = arrJsPopLabel['referencefieldtypedifferent'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                        }
                        if(tmpreferencemodule == 'false'){
                            var confirm_str = arrJsPopLabel['referencefieldmoduledifferent'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                        }
                        if(empty(tmpbigtype)){//引用源单字段不能为空
                            var confirm_str = arrJsPopLabel['CANOTEMPTY'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                        }
                        //界面保存可选择数据范围等条件
                        if(tmpbigtype == 'reference'){
                            if(ld('#selectsource_fieldreferencemodule').val() != undefined &&ld('#selectsource_fieldreferencemodule').val() != ''){
                                urlstring += '&referencemodule='+ld('#selectsource_fieldreferencemodule').val();
                             }
                             else{
                                urlstring += '&referencemodule='+tmpreferencemodule;
                             }
                    		urlstring += '&datarange='+ld('#datarange').val();
                    		urlstring += '&approve_demand='+ld('#approve_demand').val();
                    		urlstring += '&maxrowsshow='+ld('#maxrowsshow').val();
                    		urlstring += '&advft_criteria_groups='+ld('#reference_advft_criteria_groups').val();
                    		urlstring += '&advft_criteria='+ld('#reference_advft_criteria').val();
                        }
                        urlstring += '&related_optionmodule_field_bigtype='+ tmpbigtype;
						urlstring += '&related_optionmodule_field='+ JSON.stringify(optionmodule_param);
                        
					}
				}
			}
			/*
			var optionmodule_string = ld('#optionmodule_string').val();
		if(!empty(optionmodule_string)){
			var optionmodules = [];
			optionmodules = optionmodule_string.split(',');
			ld.each(optionmodules,function(index,module){
			*/
            //默认值
            if(columnname!='wareid'&&(selectFieldType == 60 || selectFieldType == 63 || selectFieldType == 'SelectComBox'|| selectFieldType == 'Select')){//下拉框多选框默认值
                if(ld('#defaultvalue_picklist').val() != undefined){
                    urlstring += '&defaultvalue=' + encodeURIComponent(ld('#defaultvalue_picklist').val());
                }
            }else{
                if ($('defaultvalue') != undefined) {
                    urlstring += '&defaultvalue=' + encodeURIComponent($('defaultvalue').value);
                }
            }
            
            urlstring += '&selectFieldType=' + selectFieldType;
            //数字、数量、金额、整数
            var reg = /^\d*$/;
            var f = /^\d*\.\d{1,}$/;
            if (selectFieldType == 24 || selectFieldType == 20 || selectFieldType == 10 || selectFieldType == 50||
                selectFieldType == 'Int' || selectFieldType == 'Num' || selectFieldType == 'Number' || selectFieldType == 'Amount') {
                var defaultvalue = $('defaultvalue').value;
                if (defaultvalue != '') {
                    if (!defaultvalue.match(reg) && !defaultvalue.match(f)) {
                        var confirm_str = arrJsPopLabel['LBL_DEFAULTVALUE'] + arrJsPopLabel['FORMATERROR'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
                }
            }
            //数字精度
            if (selectFieldType == 20 || selectFieldType == 'Num') {
                var precisionvalue = $('precisionvalue').value;
                if (precisionvalue != '') {
                    var reg = /^\d+$/;
                    if (!precisionvalue.match(reg) && !defaultvalue.match(f)) {
                        var confirm_str = arrJsPopLabel['PRECISIONVALUE'] + arrJsPopLabel['FORMATERROR'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
                }
            }
        }
    }
	//录入方式
    var inputModeType = $('inputModeType').value;
   	urlstring += '&inputModeType='+inputModeType;
	if($('inputModeType') != undefined && $('defaultcolumn') != undefined && ($('defaultcolumn').value == 1||$('defaultcolumn').value == 3||$('defaultcolumn').value == 4))
    {
		var attributeField = 0;
		
		if(inputModeType == 0)
        {//手动录入
			urlstring += '&attributeField='+attributeField;
		}else if(inputModeType == 1)
        {//分录已有基础资料属性
                
    			attributeField = $('attributeField').value;
                
    			if($('attributeField') != undefined){
    				urlstring += '&attributeField='+attributeField;
    			}
		}
        
	}
	ld('#rptContentLoading').show();
    if(inputModeType == 2)
    {
            //通过公式计算
			formulacontent=trim(document.getElementById('definitionformula').value);
			if(formulacontent==''){
				ld('#rptContentLoading').hide();
                var confirm_str = arrJsPopLabel['Formulacontentcannotbeempty'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			var tableobj=document.getElementById('toolfieldFormula');
			for(i=0;i<tableobj.rows.length-1;i++)
			{
    			 var tmpcol=document.getElementById('formualcombox_'+i).options[document.getElementById('formualcombox_'+i).selectedIndex].value;
                 var tmpletter=document.getElementById('formualtext_'+i).value;
                 if(tmpcol=='none'||ld.trim(tmpletter)=='')
                 {
                    continue;
                 }
				formulavar+=document.getElementById('formualtext_'+i).value;
				formulacolumn+=document.getElementById('formualcombox_'+i).options[document.getElementById('formualcombox_'+i).selectedIndex].value;
				if(i!=tableobj.rows.length-2){
					formulavar+=",";
					formulacolumn+=",";
				}
				tableobj[document.getElementById('formualtext_'+i).value]=document.getElementById('formualcombox_'+i).options[document.getElementById('formualcombox_'+i).selectedIndex].value;
			}

			var formulacontent=document.getElementById('definitionformula').value;
			formulacontent=formulacontent.replace(/(^\s*)|(\s*$)/g, "");
			var formualValidata_msg = formualValidata(formulacontent,tableobj);
			//chj 2021/1/13 44093: 单据分录字段公式不正确的时候：程序处理异常
			if(formualValidata_msg != ''){
				ld('#rptContentLoading').hide();
				RemindsMsg("","LdPopWidth400px","","yes","yes",formualValidata_msg);
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					ld('#rptContentLoading').show();
                    saveFieldInfo_showTipsBeforeConfirm(selectFieldType,urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn);
				})
				return false;

			}else{
                saveFieldInfo_showTipsBeforeConfirm(selectFieldType,urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn);
			}
			/*if(!formualValidata(formulacontent,tableobj)){
				return false;
			}*/
    }else{
        saveFieldInfo_showTipsBeforeConfirm(selectFieldType,urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn);
	}
	
    
}

//ljj 20240521 XUQIU20240507-04 单据分录定制优化 新建保存增加提示
function saveFieldInfo_showTipsBeforeConfirm(selectFieldType,urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn) {
    ld('#rptContentLoading').hide();
    var pattern = /^\d+$/;//正则表达式 用来判断是否是数字
    if ((producttoolfieldid == '0' || empty(producttoolfieldid)) && pattern.test(selectFieldType) && selectFieldType != '100' && selectFieldType != '101'){ //新增 产品分录（是数字则为产品分录） 关联选择单据 引用字段
        MessagePopup.TipTwo_warning(arrJsPopLabel['PRODUCTTOOLFIELDSAVETIP']);
        var messagepopupobj = CrmPopup.getPopupObj('last');
        var confirm_button = ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]');
        confirm_button.bind('click',function () {
            saveFieldInfo_confirm(urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn);
        });
    }else {
        saveFieldInfo_confirm(urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn);
    }

}


function saveFieldInfo_confirm(urlstring,tabid,producttoolfieldid,formulacontent,formulavar,formulacolumn){
    //zxm2021-1230 字段颜色 字段说明
    var fieldplaceholder = ld('#fieldplaceholder').val();
    var fieldvaluecolor = ld('#fieldvaluecolor').val();
    //zkt 20220725 获取选择的源单类型（收款单、付款单）
    var selectsourcetype = '';
    var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
    if(selecttypeobj.length>0&&selecttypeobj!=undefined){
        selectsourcetype = ld(selecttypeobj).find("option:selected").val();
    }
	var data={'module':'Settings','action':'SettingsAjax',"file":'ProductToolField',
            "submode":'SaveProductToolField','tabid':tabid,'producttoolfieldid':producttoolfieldid,
            'ajax':true,'formulacontent':formulacontent,'formulavar':formulavar,'formulacolumn':formulacolumn,'fieldplaceholder':fieldplaceholder,'fieldvaluecolor':fieldvaluecolor,'selectsourcetype':selectsourcetype};

    var tmp_urlstring_arr = urlstring.split('&');
    var new_urlstring = '';
    if(tmp_urlstring_arr.length > 0){
        for(let i = 0;i<tmp_urlstring_arr.length;i++){
            if(tmp_urlstring_arr[i].split('=')[0] == 'profile_field_value'){
                data['profile_field_value'] = tmp_urlstring_arr[i].split('=')[1];
            }else{
                if(i == 0){
                    new_urlstring += tmp_urlstring_arr[i];
                }else{
                    new_urlstring += '&'+tmp_urlstring_arr[i];
                }
            }
        }
    }
    ldAjax('index.php?'+new_urlstring,data,function (data) {
        if (data.code == 1){
            ld("#cfList").html(data.result.content);
            DelProgressObjs();
            var popupobj = CrmPopup.getPopupObj('last');
            popupobj.CancelEvent();

            //设置当前字段所在为黄色
            //ld('input[name=producttoolfield'+producttoolfieldid+']').parent().parent().addClass('selectedbj');
        }else {
            if(data.msg == 'HERROR'){
                var confirm_str = arrJsPopLabel['ZHLABELALREADYEXISTS'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                DelProgressObjs();
                return false;
            }else if(data.msg == 'ENERROR'){
                var confirm_str = arrJsPopLabel['ENLABELALREADYEXISTS'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                DelProgressObjs();
                return false;
            }
        }
    })

   /* ld.ajax(
        {
            type:'POST',
            url:'index.php?'+new_urlstring,
            data:data,
            success:function(response)
            {
				var response_arr =  eval("("+response+")")?eval("("+response+")"):json.parse(response);
              
				if(response_arr.code == 1){
					ld('#rptContentLoading').hide();
                    fninvshnew('dvProductToolEditField');
					ld("#cfList").html(response_arr.result.content);
					
					//设置当前字段所在为黄色
					//ld('input[name=producttoolfield'+producttoolfieldid+']').parent().parent().addClass('selectedbj');
				}else{
					if(response_arr.msg == 'HERROR'){
						var confirm_str = arrJsPopLabel['ZHLABELALREADYEXISTS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						ld('#rptContentLoading').hide();
						return false;
					}else if(response_arr.msg == 'ENERROR'){
						var confirm_str = arrJsPopLabel['ENLABELALREADYEXISTS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						ld('#rptContentLoading').hide();
						return false;
					}
				}
            }
        }
    );*/
}
function enableEditCheckBox(obj){
	if (obj == null) return;
	if (obj.checked == true) {
		$('mandatory_check').disabled = false;
	} else {
		$('mandatory_check').checked = false;
		$('mandatory_check').disabled = true;
	}	
}
/*
* reason: 保存到数据库：不勾选“允许编辑、必填字段”自动反选，并且置灰不允许设置   如果勾选，则字段属性“允许编辑”、“必填字段”允许编辑
* edit: chj 2015/5/29
*/
function enableSavedatabaseCheckBox(obj){
	if (obj == null) return;
	if (obj.checked == true) {
		$('is_edit').disabled = false;
		$('mandatory_check').disabled = false;
	} else {
		$('is_edit').checked = false;
		$('mandatory_check').checked = false;
		$('is_edit').disabled = true;
		$('mandatory_check').disabled = true;
	}	
}
/*
* reason: 勾选必填字段，则是否启用默认勾选，并且不允许反选
* edit: chj 2015/5/29
*/
function enableDisableCheckBox(obj, elementName) {
	
	var ele = $(elementName);
    
	if (obj == null || ele == null) return;
     if(ele.getAttribute('allowhide')=='no')
     {
        return ;
     }
	if (obj.checked == true) {
		ele.checked = true;
		ele.disabled = true;
	} else {
		var defaultcolumn = ld('#defaultcolumn').val();
		if(defaultcolumn == 1 || defaultcolumn == 5|| defaultcolumn == 7){
			ele.disabled = false;
		}
		
	}	
}
/*
* reason: 选中文本类型
* edit: chj 2015/5/29
*/
function selectFieldType(obj){
	var fieldType = obj.value;
	$("is_edit_tr").style.display='';
	$("defaultvalue").style.display='';
    ld("#defaultvalue").val('');
	$("dateDesc").style.display='none';
	$("checkDiv").style.display='none';
	$("picklist_tr").style.display='none';
	$("defaultvalue_tr").style.display='';
	$("tr_referencemodule").style.display='none';
	$("tr_optionmodulefield").style.display='none';
	$("tr_datarang").style.display='none';
	$("tr_approvedemand").style.display='none';
	$("tr_maxrowsshow").style.display='none';
	$("tr_relatedmodule").style.display='none';
	$("tr_relatedmodulefield").style.display='none';
	$("tr_savedatabase").style.display='none';
	$("producttool_formula").style.display='';
    ld("#width").val(20);
	ld("#inputModeType").removeAttr('disabled');
    ld("#inputModeType option").css("display", "");
    ld("#is_edit").prop('disabled',false);
	ld('#tr_fieldplaceholder').hide();
	ld('#tr_fieldvaluecolor').hide();
    ld("#auto_wordwrap_check").prop('checked',false);
    ld('#auto_wordwrap_tr').show();
    ld('#defaultvalue_picklist_div').hide();
    
    //edit: xll 2023/06/06 XUQIU1001203 增加“显示超链接”字段属性
    ld("#ShowHyperlinks_tr").css("display","none");
    ld("#helptips").val('');// 清空帮助信息
	//1->文本，2->文本区域,24->整数,20->数字,10->数量,50->金额,51~55->日期,163->单价
	if(fieldType == 1 || fieldType == 'Text'){
		$("textlen").style.display='';
		$("precision").style.display='none';
		$("dateStyle").style.display='none';
        ld('#tr_fieldplaceholder').show();
        ld('#tr_fieldvaluecolor').show();
	}
	else if(fieldType == 2 || fieldType == 24|| fieldType == 50|| fieldType == 163 || fieldType == 'TextArea' || fieldType == 'Int' || fieldType == 'Amount' || fieldType == 'Price'){
		$("textlen").style.display='none';
		$("precision").style.display='none';
		$("dateStyle").style.display='none';
        if(fieldType == 2||fieldType == 'TextArea'){
            ld('#tr_fieldplaceholder').show();
            ld('#tr_fieldvaluecolor').show();
            ld("#auto_wordwrap_check").prop('checked',true);
        }
        if(fieldType == 24 || fieldType == 50|| fieldType == 163 || fieldType == 'Int' || fieldType == 'Amount' || fieldType == 'Price'){
            ld('#tr_fieldvaluecolor').show();
        }
	}
	else if(fieldType == 20 || fieldType == 'Num'){
		$("precisionvalue").value = 2;
		$("textlen").style.display='none';
		$("dateStyle").style.display='none';
		$("precision").style.display='';
        ld('#tr_fieldvaluecolor').show();
	}
	else if(fieldType == 10 || fieldType == 'Number'){
		$("textlen").style.display='none';
		$("dateStyle").style.display='none';
		$("precision").style.display='none';
        ld('#tr_fieldvaluecolor').show();
	}
	else if((fieldType >= 51 && fieldType <= 55) || fieldType == 'Date'){
		$("textlen").style.display='none';
		$("dateStyle").style.display='';
		$("defaultvalue").style.display='none';
		$("dateDesc").style.display='';
		$("precision").style.display='none';
        ld("#inputModeType option[value=0]").prop("selected", "selected");
        ld("#inputModeType option[value=2]").css("display", "none");
	}
	else if(fieldType == 56 || fieldType == 'CheckBox'){
		$("textlen").style.display='none';
		$("dateStyle").style.display='none';
		$("defaultvalue").style.display='none';
		$("checkDiv").style.display='';
		$("precision").style.display='none';
	}
	else if(fieldType == 63 || fieldType == 'SelectComBox'){
		$("textlen").style.display='none';
		$("precision").style.display='none';
		$("dateStyle").style.display='none';
		$("picklist_tr").style.display='';
        ld("#is_edit").prop('checked',true);
        ld("#is_edit").prop('disabled',true);
		ld("#width").val(50);
	}
	else if(fieldType == 60 || fieldType == 'Select'){
		$("textlen").style.display='none';
		$("precision").style.display='none';
		$("dateStyle").style.display='none';
		$("picklist_tr").style.display='';
		ld("#width").val(30);
	}
	else if(fieldType == 100 || fieldType == 'Reference'){	//关联选择单据（单选）
		$("textlen").style.display='none';
		$("precision").style.display='none';
		$("dateStyle").style.display='none';
		$("picklist_tr").style.display='none';
		$("is_edit_tr").style.display='none';
		$("defaultvalue_tr").style.display='none';
		ld("#width").val(55);
        //zkt 20240117 BUG0077450 kfbcrm-自定义表单13-单据分录定制-新增关联选择单据（单选）字段，没有“允许编辑”参数，保存后字段无法编辑
		ld("#is_edit").prop('checked',true);
		$("tr_referencemodule").style.display='';
		$("tr_datarang").style.display='';
		$("tr_approvedemand").style.display='';
		$("tr_maxrowsshow").style.display='';
		//$("producttool_formula").style.display='none';
		ld("#inputModeType option[value=0]").prop("selected", "selected");
		$("attributeDiv").style.display='none';
		$("definingDiv").style.display='none';
		ld("#inputModeType").attr('disabled','disabled');
        ld("#ShowHyperlinks_tr").css("display","");
	}
	else if(fieldType == 101 || fieldType == 'RelatedModuleField'){	//关联选择单据（单选）
		$("textlen").style.display='none';
		$("precision").style.display='none';
		$("dateStyle").style.display='none';
		$("picklist_tr").style.display='none';
		$("is_edit_tr").style.display='';
		ld("#is_edit").prop("checked",false);
		
		$("defaultvalue_tr").style.display='none';
		ld("#width").val(22);
		$("tr_referencemodule").style.display='none';
		$("tr_datarang").style.display='none';
		$("tr_approvedemand").style.display='none';
		$("tr_maxrowsshow").style.display='none';
		ld("#inputModeType option[value=0]").prop("selected", "selected");
		$("attributeDiv").style.display='none';
		$("definingDiv").style.display='none';
		ld("#inputModeType").attr('disabled','disabled');
		$("tr_relatedmodule").style.display='';
		$("tr_relatedmodulefield").style.display='';
		$("tr_savedatabase").style.display='';
		$('is_edit').disabled = true;
		$('mandatory_check').disabled = true;
		getReferencemoduleField(ld("#select_related_module"));
	}
    else if(fieldType == 69 || fieldType == 'Image'){
       //ls 2022-04-06 【1002543】页面设置，增加“图片”字段类型【选中时】
       $("textlen").style.display='none';
       $("precision").style.display='none';
       $("dateStyle").style.display='none';
       ld("#is_edit").prop('checked',true);

       $("defaultvalue_tr").style.display='none';
       ld("#width").val(50);

       ld("#inputModeType option[value=0]").prop("selected", "selected");
       $("attributeDiv").style.display='none';
       $("definingDiv").style.display='none';
       $("definingContentDiv").style.display='none';
       $("mulaDiv").style.display='none';
       $("mulaContentDiv").style.display='none';
       ld("#inputModeType").attr('disabled','disabled');
       ld('#auto_wordwrap_tr').hide();
   }
    else if(fieldType == 1109 || fieldType == 'Attachment'){
        //edit: xll 2023/06/19 XUQIU1000357 单据分录定制，增加“附件”字段类型（李发林）
        $("textlen").style.display='none';
        $("precision").style.display='none';
        $("dateStyle").style.display='none';
        ld("#is_edit").prop('checked',true);

        $("defaultvalue_tr").style.display='none';
        ld("#width").val(50);

        //edit: xll 2023/07/18 BUG0069655 kfbcrm-销售退款单-新增附件字段-应控制不能修改字段公式
        //字段公式设置的行隐藏
        ld("#inputModeType option[value=0]").prop("selected", "selected");
        $("attributeDiv").style.display='none';
        $("definingDiv").style.display='none';
        $("definingContentDiv").style.display='none';
        $("mulaDiv").style.display='none';
        $("mulaContentDiv").style.display='none';
        ld("#inputModeType").attr('disabled','disabled');
        ld('#auto_wordwrap_tr').hide();
    }

    //hzx 是否小计
    var cansubtotal_arr = ['10','7','20','24','28','29','32','50'];
    var cansubtotal_tab_arr = ['Num','Number','Int','Amount','RMB_Amount'];
    if(cansubtotal_arr.indexOf(fieldType) >= 0 || cansubtotal_tab_arr.indexOf(fieldType) >= 0){
        ld('#subtotal_attr_tr').css('display','');
        ld('#subtotal_attr_check').prop('checked',true);
    }else{
        ld('#subtotal_attr_tr').css('display','none');
        ld('#subtotal_attr_check').prop('checked',false);
    }
    //下拉框，多选框默认值
    if(fieldType == 63 || fieldType == 'SelectComBox' || fieldType == 60 || fieldType == 'Select'){
        ld("#defaultvalue_tr").find("#defaultvalue").css("display",'none');
        ld("#defaultvalue_tr").find("#defaultvalue_picklist_div").css("display",'');
        ld("#fldpicklist").select2({
            tags:true,width:'90%',
            closeOnSelect: true,
            minimumResultsForSearch: Infinity
        });
        ld("#fldpicklist").select2("val", " ");
		ld("#fldpicklist").on("select2:close", function (e)  {
			var select2obj=ld("#fldpicklist").select2('data');
            ld("#defaultvalue_picklist").empty();
			if(fieldType == 'SelectComBox' || fieldType == 63){
                ld("#defaultvalue_picklist").append("<option value=''></option>");
                ld.each(select2obj,function(index,info){
                    var text=info.text;
                    ld("#defaultvalue_picklist").append("<option value='"+text+"'>"+text+'</option>');
                });
            }
            else
            {
                
                ld("#defaultvalue_picklist").append("<option value=''></option>");
                ld.each(select2obj,function(index,info){
                    var text=info.text;
                    ld("#defaultvalue_picklist").append("<option value='"+text+"'>"+text+'</option>');
                });
            }
            //修改下拉框的样式
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_picklist");
            cls_resetComboxHtmlobj.setComboxObjHtml();

            ld("[name=dv_cmb_defaultvalue_picklist]").css("display",'block');
        });
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_picklist");
        cls_resetComboxHtmlobj.setComboxObjHtml();
        ld("[name=dv_cmb_defaultvalue_picklist]").css("display",'block');
	 	
    }
}
/*
获取相关对象的引用字段
*/
function getReferencemoduleField(obj)
{
	var popupobj=CrmPopup.getPopupObj('last');
	var bigtype = ld(obj).find("option:selected").attr('bigtype');
	if(bigtype == 'selectsource'){
		$("tr_relatedmodulefield").style.display='none';
		$("tr_optionmodulefield").style.display='';
        ld("#ShowHyperlinks_tr").css("display","");
		/*var optionmodule_string = ld('#optionmodule_string').val();
		if(!empty(optionmodule_string)){
			var optionmodules = [];
			optionmodules = optionmodule_string.split(',');
			ld.each(optionmodules,function(index,module){
				var name = 'relatedsourcefield_' + module;
				if(ld('#'+name).val() != undefined){
					var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
					cls_resetComboxHtmlobj.setComboxObjHtml();
                    //zkt 20220624 1000143  采购订单、收付款单、出入库单，分录明细增加“合同订单”字段（咏睿）
				    var tdobj = Tools.getParentobjByChild(ld('#'+name),'td');
				    var width = ld(tdobj).width();
                    var cmb_divobj = ld(tdobj).find(' [name=dv_chzn_'+name+']');
                    var cmb_divwidth = ld(cmb_divobj).width();
                    var leftpadding = (width-cmb_divwidth)/2;
                    ld(cmb_divobj).css('left',leftpadding+'px');
				}
			});
		}*/
	}else{
		var name="relatedmodulefield"
		$("tr_relatedmodulefield").style.display='';
		$("tr_optionmodulefield").style.display='none';
		ld.ajax({

			url:'index.php?module=Settings&action=SettingsAjax&file=getReferenceField&fld_module='+ld(obj).val()+'&fromtabletype=detail',
			timeout:10000,
			type: 'POST',
			data:'',
			dataType:'json',
			success:function(data)
			{

				if(data.code==1)
				{
					ld("#"+popupobj.divid+" [name="+name+"]").empty();
					var relatedmodule_column = ld("#"+popupobj.divid+" [name=relatedmodule_column]").val();
					ld.each(data.result.list,function(index,info){
						var fieldname=info.fieldname;
						var fieldlabel=info.fieldlabel;
						var field_selected = '';
						if(relatedmodule_column == fieldname){
							field_selected = 'selected';
						}
                        //edit: xll 2023/06/06 XUQIU1001203 分录-引用字段增加“显示超链接”字段属性
                        var isHrefField = info.isHrefField;
						ld("#"+popupobj.divid+" [name="+name+"]").append("<option value='"+fieldname+"' isHrefField='" + isHrefField + "'"+field_selected+">"+fieldlabel+"</option>");
					});
					
					var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
					cls_resetComboxHtmlobj.setComboxObjHtml();
                    selectedIsHrefFiled(ld("#"+popupobj.divid+" [name="+name+"]")[0]);
				}
			}
		})
	}
}
/*
 *edit: xll
 *2023/06/07 XUQIU1001203
 *判断引用的字段是否是超链接字段
 */
function selectedIsHrefFiled(obj){
    var isHrefField = ld(obj.options[obj.selectedIndex]).attr('isHrefField');
    if(isHrefField == 'yes'){
        ld("#ShowHyperlinks_tr").css("display","");
    }else{
        ld("#ShowHyperlinks_tr").css("display","none");
    }
}
/*
* reason: 选择基本属性、高级属性
* edit: chj 2015/5/29
*/
function changeProductToolMenu(menutype,obj){
	ld('.ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
    ld('#advanceDiv,#basicDiv,#dvreverse,#fields_access_div').hide();
	if(menutype == 1){
		ld('.ld-ui-tabs-nav li:first').addClass('ld-ui-tabs-active');
		ld('#basicDiv').show();
	}else if(menutype==2){
		ld('.ld-ui-tabs-nav li[tag=2]').addClass('ld-ui-tabs-active');
		ld('#advanceDiv').show();
	}
    else if(menutype==3){
        ld('.ld-ui-tabs-nav li[tag=3]').addClass('ld-ui-tabs-active');
		ld('#dvreverse').show();
    }else if(menutype==4){
        ld('.ld-ui-tabs-nav li[tag=4]').addClass('ld-ui-tabs-active');
        ld('#fields_access_div').show();
        getJsScript('include/js/modules/Settings/Entry_Fields_Access.js', function () {
            Entry_Fields_Accessobj = new Entry_Fields_Access();
        })
    }
}
/*
* reason: 高级属性 - 选择录入方式
* edit: chj 2015/5/29
*/
function selectInputMode(obj){
	var inputmode = obj.value;
    document.getElementById('definingContentDiv').style.display='none';
    clearFormulaTable();//删除字段公式行
	if(inputmode == 0 || inputmode == 1){		
		$("mulaDiv").style.display='none';
		$("mulaContentDiv").style.display='none';
		if(inputmode == 0){	//手动录入
			$("attributeDiv").style.display='none';
			$("definingDiv").style.display='none';
		}else if(inputmode == 1){	//分录已有基础资料属性
			$("attributeDiv").style.display='';
			$("definingDiv").style.display='none';
		}
	}else if(inputmode == 2){	//通过公式计算
		$("attributeDiv").style.display='none';
		$("definingDiv").style.display='';
		$("mulaDiv").style.display='';
		$("mulaContentDiv").style.display='';
        addFormulaTableTr(2);
	}
}
/*
* reason: 选择模块
* edit: 2015/6/15
*/
function selectModule(obj){


	/*window.location.href='index.php?module=Settings&action=ProductToolField&parenttab=Settings&blockidsetting=6&fieldidsetting=53'+
					'&selectTabid='+obj.value*/;
    ld.ajax({
        url:"index.php?module=Settings&file=ProductToolField&action=SettingsAjax&ajax=yes&selectTabid="+obj.value,
        dataType:"json",
        timeout:20000,
        type:"post",
        success:function(data)
        {
            ld("[name=producttoofieldlist]").html(data.result.content);
            var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
            if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                var sourcetypeparentdivobj = Tools.getParentobjByChild(selecttypeobj,'div');
                ld(sourcetypeparentdivobj).css('display','none');
                
                if(ld(sourcetypeparentdivobj).find('div[name=dv_cmb_selectmoduletype]').length>0){
                    var selecttypenextdivobj = ld(sourcetypeparentdivobj).find('div[name=dv_cmb_selectmoduletype]');
                    ld(selecttypenextdivobj).remove();
                }
                ld(selecttypeobj).empty();

                if(!empty(data.result.selectsourcetypearr)){
                    var selectsourcetypearr = data.result.selectsourcetypearr;


                    //wym 240105 BUG0078402 收款单/付款单设置成“自动带出所选源单的分录明细”时，如果在分录定制中增加了关联选择单据字段，那么分录会错误 选择空选项后点新增字段会有bug 目前直接把空选项去了
                    //ld(selecttypeobj).append("<option value=''></option>");
                    ld.each(selectsourcetypearr,function(index,sourcetypeinfo){
                        if(sourcetypeinfo.isdefault=='1'){//BUG0070795 xxy 2023-8-10 付款单 收款单-单据分录定制-选择源单类型应有个默认值来显示列表（跟随页面设置选择源单字段的默认值显示）
						    ld(selecttypeobj).append("<option value='"+sourcetypeinfo.value+"' selected>"+sourcetypeinfo.text+"</option>");
                            selectSourcetype(selecttypeobj.get(0));
                        }else{
                            ld(selecttypeobj).append("<option value='"+sourcetypeinfo.value+"'>"+sourcetypeinfo.text+"</option>");
                        }
                    })
                    var obj = CrmPopup.global_listPopupObj[0];
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selecttypeobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(obj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selecttypeobj,150);
                    var sourcetypedivobj  =Tools.getParentobjByChild(selecttypeobj,'div');
                    ld(' .chzn-container').css('margin-top', '17px');
                    ld(' .chzn-drop').css('margin-left', '10px');
                    ld(sourcetypeparentdivobj).css('display','');

                }
            }
            //zxm 20220909 设置冻结前几列
            ld('[name=selectSetStickyNums] option').removeAttr("Selected");
            ld('[name=selectSetStickyNums] option[value="'+data.result.detail_issticky+'"]').attr("Selected",true);
            CrmPopup.findHtmlobj("SettingRightContent",'cmb_span_optiontext_selectSetStickyNums').val(data.result.detail_issticky);
        }
    })
	return false;
}


/*
* reason: 选择源单类型
* edit: 2022/7/21
*/
function selectSourcetype(obj){
	var url = "index.php?module=Settings&file=ProductToolField&action=SettingsAjax&ajax=yes";
    var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]");
    if(selectobj.length>0&&selectobj!=undefined){
        var moduleid = ld(selectobj).find("option:selected").val();
        url += "&selectTabid="+moduleid;
    }
    url += "&selectsourcetype="+obj.value;
    ld.ajax({
        url:url,
        dataType:"json",
        timeout:20000,
        type:"post",
        success:function(data)
        {
            ld("[name=producttoofieldlist]").html(data.result.content);

        }
    })
	return false;
}
function selectedColumnClick(oSel)
{
	var error_msg = '';
	var error_str = false;
	if(oSel.selectedIndex > -1) {
				for(var i = 0; i < oSel.options.length; ++i) {
						if(oSel.options[i].selected == true && oSel.options[i].disabled == true) {
								error_msg = error_msg + oSel.options[i].text+',';
				error_str = true;
								oSel.options[i].selected = false;
						}
				}
		}
	if(error_str)
	{
		error_msg = error_msg.substr(0,error_msg.length-1);
		alert(arrJsPopLabel['ALLOWEDEDITTHESEFIELDS']+"\n"+error_msg);
		return false;
	}
	else
		return true;
}

function moveUp(){getJsScript('include/js/ldcrm.list.js',function(){moveUps();});}
function moveDown(){getJsScript('include/js/ldcrm.list.js',function(){moveDowns();});}

//下拉框样式优化，以下为新增和删除下拉框值函数
function setPicklistValueTag(obj,settype,event){
    if(settype == 'create'){
        var tagInput = ld(obj).get(0);
        if (event.key === 'Enter') {
            var tagText = tagInput.value.trim();
            if (tagText !== '') {
                delBtntitle = arrJsPopLabel["DELETE"];
                var tag_html = '<span class="ld-picklistfield-tag" value="'+tagText+'"><span>'+tagText+'</span>'
                                +'<button class="ld-picklistfield-tag_delbtn" onclick="setPicklistValueTag(this,\'delete\',event)" title="'+delBtntitle+'">×</button><span>'
                ld("#tagInput").before(tag_html);
                tagInput.value = '';
            }
        }
    }
    else if(settype == 'delete'){
        ld(obj).parent().remove();
    }
}
{/literal}
</script>



<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_ProductTool_field'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        {* editor:gyq_10 reason：表示出当前处于哪个处理文件中，用于jS区分出费用报销模块 date:20160420 *}
        {*<input type="hidden" value="{$DETAILFIELDHTMLSEXIST}">*}
        <select fieldtype="select" onchange="selectModule(this)" name="selectmodule" id="selectmodule" class="btn-radius-system width150 lfloat" style="display:none;">
            {foreach name="selectmodule" item=moduleinfo from=$SELECTMODULE}
                {foreach key=tabid item=modulename from=$moduleinfo}
                <option value="{$tabid}" {if $TABID eq $tabid}selected{/if}>{$modulename}</option>
                {/foreach}
            {/foreach}
        </select>
    </div>
    <div class="grid-view-title lfloat overflow-hidden" {if !$SELECTMODULESOURCETYPE|@is_array || $SELECTMODULESOURCETYPE|@count<=0}style="display:none;"{/if}>
        <span class="grid-view-choose dinline-block lfloat">选择源单类型</span>
        <select fieldtype="selecttype" onchange="selectSourcetype(this)"  name="selectmoduletype" id="selectmoduletype" class="btn-radius-system width150 lfloat" style="display:none;">
            {*wym 240105 BUG0078402 收款单/付款单设置成“自动带出所选源单的分录明细”时，如果在分录定制中增加了关联选择单据字段，那么分录会错误
            wym 选择空选项后点新增字段会有bug 目前直接把空选项去了*}
            {*<option value="" ></option>*}
            {foreach key=modulename item=modulenamelabel from=$SELECTMODULESOURCETYPE}
                <option value="{$modulename}" >{$modulenamelabel}</option>
            {/foreach}
        </select>
    </div>
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-choose dinline-block lfloat">{'SETFREEZECOLUMN'|@getFixedLabel}</span>
        <select name="selectSetStickyNums" id="selectSetStickyNums"  class="btn-radius-system width150 lfloat">
            <option {if $detail_issticky==0}selected{/if} value="0">0</option>
            <option {if $detail_issticky==1}selected{/if} value="1">1</option>
            <option {if $detail_issticky==2}selected{/if} value="2">2</option>
            <option {if $detail_issticky==3}selected{/if} value="3">3</option>
            <option {if $detail_issticky==4}selected{/if} value="4">4</option>
            <option {if $detail_issticky==5}selected{/if} value="5">5</option>
            <option {if $detail_issticky==6}selected{/if} value="6">6</option>
            <option {if $detail_issticky==7}selected{/if} value="7">7</option>
            <option {if $detail_issticky==8}selected{/if} value="8">8</option>
        </select>
    </div>
    <div class="grid_tool">
        <div class= "dispalyflex">
            <input type="hidden" id="hiddentabid" name="hiddentabid" value="{$TABID}" />
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="ProductToolEditField(this,'dvProductToolEditField','')" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="ShowFieldSort(this,'sortview','Sort')" title="{'SORT'|@getFixedLabel}">{'SORT'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="ShowFieldSort(this,'sortview','Dis')" title="{'HIDDENFIELDS'|@getFixedLabel}">{'HIDDENFIELDS'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" name="producttoofieldlist" class="ld-table-container ld-table-container-line ld-table-container-bgcolor">
            {include file="ProductToolField/ListFieldEntries.tpl"}
        </div>
    </div>
</div>
</form>

<div id="dvProductToolEditField" class="E_pop_box LdPopWidth650px" style="display:none;"></div>
<!-- 数据分类排序 -->
<div id="sortview" class="E_pop_box LdPopWidth400px" style="display:none;">
<div id="sortview_form_div"></div>
</div>


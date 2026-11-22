/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
var typeofdata = new Array();
typeofdata['V'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
typeofdata['N'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['T'] = ['e','n','l','g','m','h','bw','isnull','isnotnull'];
typeofdata['I'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['C'] = ['e','n'];
typeofdata['D'] = ['bw','e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['DT'] = ['bw','e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['NN'] = ['e','n','l','g','m','h','isnull','isnotnull'];
typeofdata['E'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
typeofdata['M'] = ['c','e','n','s','ew','k','isnull','isnotnull'];

var noneLabel;

var advft_column_index_count = -1;
var advft_group_index_count = 0;
var column_index_array = [];
var group_index_array = [];

function trimfValues(value) {
    var string_array;
    string_array = value.split(":");
    return string_array[4];
}
function isExistsDateTimeStr(value)
{
	ld('.Wdate').attr('autocomplete','off');
	var isexists='no';
    if(datetimestr!=undefined){
        ld.each(datetimestr,function(key,resultobj){
                if(value==key)
                {
                    isexists='yes';
                    return false ;
                }
        });
    }
    
    return isexists;
}

function updatefOptions(sel, opSelName) {
    var selObj = document.getElementById(opSelName);
    var fieldtype = null ;
 
    //获取字段信息
    var popupobj = CrmPopup.getPopupObj("last");
    var fieldsinfo = [];
    if(CrmPopup.global_listPopupObj.length>0){
        for(var i=CrmPopup.global_listPopupObj.length-1;i>=0;i--)
        {
             if(CrmPopup.global_listPopupObj[i].module==popupobj.module&&CrmPopup.global_listPopupObj[i].fields!= undefined)
             {
                 fieldsinfo = CrmPopup.global_listPopupObj[i].fields;
                 break;
             }
        }
    }

 if(selObj==undefined ||selObj==null ||sel==undefined || sel==null)
 {
     return;
 }
  if(selObj.selectedIndex<0 ||sel.selectedIndex<0 )
  {
    //return ;
  }
    var currOption = selObj.options[selObj.selectedIndex];
    var currField = sel.options[sel.selectedIndex];
	if(currField.value != null && currField.value.length != 0) {
		fieldtype = trimfValues(currField.value);
		if(typeofdata[fieldtype] == undefined){//BUG0074467 xxy 2023-11-1 消息中心-高级查找-先选择“提醒时间”字段，选择条件下拉框内字段正常，把选择字段修改为“相关模块”，选择条件下拉框内字段不会跟着改变
			fieldtype = 'V';
		}
		ops = typeofdata[fieldtype];
        //alert(fieldtype);
		var off = 0;
		if(ops != null) {
	
			var nMaxVal = selObj.length;
			for(nLoop = 0; nLoop < nMaxVal; nLoop++) {
				selObj.remove(0);
			}
           //by LD Can 20121130 none修改为无
			selObj.options[0] = new Option (jsnone, '');
			if (currField.value == '') {
				selObj.options[0].selected = true;
			}
			off = 1;
            var k=0;
           
			for (var i = 0; i < ops.length; i++) {
				var label = fLabels[ops[i]];
               
				if (label == null) continue;
               
                if(currField.value.indexOf('publicaccount:publicaccount:Accounts')>0||currField.value.indexOf('currency_id')>0)//客户模块中是否公海字段
                {
                     if(ops[i]!='e'&& ops[i]!='n')
                     {
                        continue;
                     }
                }
                if(currField.value.indexOf('content:content:PublicAnnouncement')>0)//客户模块中是否公海字段
                {
                     if(ops[i]!='c')
                     {
                        continue;
                     }
                }
                if(currField.value.indexOf("conversion_rate")>0)
                {
                     
                     if(ops[i]=='isnull'|| ops[i]=='isnotnull')
                     {
                        continue;
                     }
                }
                
				var option = new Option (fLabels[ops[i]], ops[i]);
				selObj.options[k + off] = option;
                k++;
				if (currOption != null && currOption.value == option.value) {
					option.selected = true;
				}
			}
            //36087: 单据列表界面>高级查找弹出层>选择时间字段：区间字段默认放在第二。（所有的帐套都要更改）
          
             if(fieldtype=='D'||fieldtype=='DT')
           {
			   var resultobj=datetimestr;//eval('.popupobj.datatimestr.');
				/* var option = new Option (arrJsPopLabel['Interval'], 'bw');
				 selObj.options[k + off] = option;
				 k++;*/
                 
                 
                ld.each(datetimestr,function(value,resultobj){
                         
                    
                       var option = new Option (resultobj[2], value);
				        selObj.options[k + off] = option;
                         k++;             
                } );
                 
           }
           //zkt 20220518 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
          
           if(fieldsinfo.length>0){
                //判断字段类型，若为用户字段类型则条件下拉框增加当前用户
                var string_array = currField.value.split(":");
                var fieldname = string_array[2];
                var tablename = string_array[0];
                ld.each(fieldsinfo,function(index,tmpfieldinfo){
                    var fieldinfo = tmpfieldinfo;


                    if(fieldinfo['fieldname']==fieldname){

						if(global_multiuser_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
							var option = new Option (fLabels['includeuser'], 'curuser');
							selObj.options[k + off] = option;
							k++;
						}
						else if(global_user_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
                            var option = new Option (fLabels['curuser'], 'curuser');
    				        selObj.options[k + off] = option;
                             k++;   
                        }
						//wym XUQIU1002044 手写签名需要切换下拉框选项
						if(fieldinfo['uitype']==222){
							ld(selObj).find('option').each(function() {
								if (ld(this).val() != 'isnull' && ld(this).val() != 'isnotnull') {
									ld(this).hide();
								}
							});
						} else {
							ld(selObj).find('option').each(function() {
								if (ld(this).val() != 'isnull' && ld(this).val() != 'isnotnull') {
									ld(this).show();
								}
							});
						}
                        return  false;
                    }
                })
           }
		}
    } else {
		if (currField.value == '') {
			selObj.options[0].selected = true;
		}
    }
}

function showHideDivs(showdiv, hidediv) {
	if(document.getElementById(showdiv)) 
		document.getElementById(showdiv).style.display = "block";
	
	if(document.getElementById(hidediv)) 
		document.getElementById(hidediv).style.display = "none";
}

function hideAllElementsByName(name) {
	var allElements = document.getElementsByTagName('div');
	for(var i=0; i<allElements.length; ++i) {
		var element = allElements[i];
		if (element.getAttribute('name') == name)
			element.style.display='none';
	}
    puyoungJS_DialogBox.unblock();
	return true;
}

function removeElement(elementId) {
	var element = document.getElementById(elementId);
	if(element) {
		var parent = element.parentNode;
		if(parent) {
			parent.removeChild(element);
		} else {
			element.remove();
		}
	}
}

function deleteGroup(groupIndex) {
	removeElement('conditiongroup_'+groupIndex);
	 
   //edit:can 54697:高级查找，添加多个组合条件的后，删除一个组合条件，对应的且（与）关系没有自动清除 
	var keyOfTheGroup = group_index_array.indexOf(parseInt(groupIndex));
      
	var isLastElement = true;
	
	for(var i=keyOfTheGroup; i<group_index_array.length; ++i) {
		var nextGroupIndex = group_index_array[i];
        console.log(nextGroupIndex);
		var nextGroupBlockId = "conditiongroup_"+nextGroupIndex;
		if(document.getElementById(nextGroupBlockId)) {
			isLastElement = false;
			break;
		}
	}
	console.log(isLastElement)
	
	if(isLastElement) {
		for(var i=keyOfTheGroup-1; i>=0; --i) {
			var prevGroupIndex = group_index_array[i];
			var prevGroupGlueId = "gpcon"+prevGroupIndex;
			if(document.getElementById(prevGroupGlueId)) {
				removeElement(prevGroupGlueId);
				break;
			}
		}
	}	
}
// 无本地搜索条件新行添加后初始化
//ie:不能设置默认值
function addConditionRowInit(type) {
	var index = ld('#conditiongrouptable_' + advft_group_index_count + ' tr[name=conditionColumn]').length;
	var conditionColumnRowElement = document.getElementById('fcol' + advft_column_index_count);
	if (type=='init'){
		// 为新加的列初始化
		//chj 2020/12/14 43746: 【http://51mis.com/ys/swl1234567/ [^]】系统设置>参数设置>公海参数设置>修改数字（详情请看说明/附件图片）> 保存；结果无法修改数字，并弹出“请输入查找关键字！” 字样   新增时候，应该默认为空
		//conditionColumnRowElement.value =ld("#fcol" + advft_column_index_count).find("option").eq(index).val();
	}
	//选择条件赋值
	addConditionRowInitafter(advft_column_index_count);
}
// @edit:dong @date:2020/09/11 @reason: 高级搜索 搜索条件默认值
function addConditionRowInitafter(columnIndex){
	var conditionColumnRowElement = document.getElementById('fcol' + columnIndex);
	updatefOptions(conditionColumnRowElement, 'fop' + columnIndex);
	//选择条件 改变关键字类型
	//wym XUQIU1002044 手写签名需要切换下拉框默认选项
	ld("#fop"+columnIndex+" option").filter(function() {
		return ld(this).css("display") != "none" && ld(this).val() != "";
	}).first().prop("selected", true);
	addRequiredElements(columnIndex);
	//wym XUQIU1002478 高级查找条件--切换选择字段时，关键字填写的值清空
	clearKeywordsinput(columnIndex);
}
function clearKeywordsinput(columnIndex) {
	var popupobj = CrmPopup.getPopupObj("last");
	if(popupobj!=undefined&&popupobj.searchtype == 'advance') {
		ld('#'+popupobj.divid).find("#fval"+columnIndex).val('');
		if(ld('#'+popupobj.divid).find("#fval_ext"+columnIndex).length>0){
			ld('#'+popupobj.divid).find("#fval_ext"+columnIndex).val('');
		}
	}
}

function addNewConditionGroup(parentNodeId) {

	addConditionGroup(parentNodeId);	
	addConditionRow(advft_group_index_count);
	addConditionRowInit('init');
    //zkt 20220830 BUG0055064高级查找，添加组合条件之后，希望右边的拖动条能划到屏幕底部（BUG0054711、BUG0055777、BUG0055064）
    var popupobj = CrmPopup.getPopupObj("last");
    if(popupobj!=undefined&&popupobj.searchtype == 'advance' &&ld('#'+popupobj.divid).find(' [name=adv_filter_div]')!=undefined && ld('#'+popupobj.divid).find(' [name=adv_filter_div]').length>0)
    {
        var adv_filter_divobj = ld('#'+popupobj.divid).find(' [name=adv_filter_div]');
        ld(adv_filter_divobj).scrollTop(ld(adv_filter_divobj).get(0).scrollHeight+10);
    }
}

function deleteColumnRow(groupIndex, columnIndex) {
	removeElement('conditioncolumn_'+groupIndex+'_'+columnIndex);
	var groupColumns = column_index_array[groupIndex];
	var keyOfTheColumn = groupColumns.indexOf(columnIndex);
	var isLastElement = true;
	
	for(var i=keyOfTheColumn; i<groupColumns.length; ++i) {
		var nextColumnIndex = groupColumns[i];
		var nextColumnRowId = 'conditioncolumn_'+groupIndex+'_'+nextColumnIndex;
		if(document.getElementById(nextColumnRowId)) {
			isLastElement = false;
			if(ld("select[id^='fcon']").length < 1){
				ld('#advfiltershow').css('display','none');
			}
			break;
		}
	}
	if(isLastElement) {
		for(var i=keyOfTheColumn-1; i>=0; --i) {
			var prevColumnIndex = groupColumns[i];
			var prevColumnGlueId = "fcon"+prevColumnIndex;
			if(document.getElementById(prevColumnGlueId)) {
				removeElement(prevColumnGlueId);
				if(ld("select[id^='fcon']").length < 1){
					ld('#advfiltershow').css('display','none');
				}
				break;
			}
		}
	}
    //ld("#conditiongrouptable_"+groupIndex+" .deleteauto").click();
   // alert(ld("#conditiongrouptable_"+groupIndex+" tr").length);
   //高级查询>添加新组合：填写数据，当第一行的内容删除时第一行下面的下拉框中的内容也清除。
   if(ld("#conditiongrouptable_"+groupIndex+" tr").length<=2)
        deleteGroup(groupIndex);
}

function addRequiredElements(columnindex) {
    var colObj = document.getElementById('fcol'+columnindex);
	var opObj = document.getElementById('fop'+columnindex);
    var valObj = document.getElementById('fval'+columnindex);
	//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
	var value = ld(valObj).val();
    if(colObj==undefined ||colObj==null ||opObj==undefined || opObj==null) {
		 return;
	}
	//wym BUG0075490 kfbcrm-采购询价单-高级查找-条件为“是空值/不是空值”时，应不显示关键字输入框 BUG0077911 客户管理--高级查找--选择销售负责人，条件为选择当前操作员，后面关键字的输入框应该不显示
	if(ld(opObj).val() == 'isnull' || ld(opObj).val() == 'isnotnull'|| ld(opObj).val() == 'has_changed' || ld(opObj).val() == 'curuser'){
		ld(valObj).css('display','none');
		ld(valObj).siblings('.icon-clear').css('display','none');
		ld(valObj).siblings('.Wdate').css('display','none');
		return;
	}else{
		ld(valObj).css('display','');
		ld(valObj).siblings('.icon-clear').css('display','');
	}
	if(colObj.selectedIndex<0 || opObj.selectedIndex<0 ) {
		return ;
	}
	var currField = colObj.options[colObj.selectedIndex];
    var currOp = opObj.options[opObj.selectedIndex];
    var fieldtype = null ;
    if(currField.value != null && currField.value.length != 0) {
		var fieldInfo = currField.value.split(":");
		var tableName = fieldInfo[0];
		var fieldName = fieldInfo[2];
		fieldtype = fieldInfo[4];
		//如果选择的不是日期和时间，移除日期显示格式
        if(fieldtype!='D'&&fieldtype!='DT'&&fieldtype!='T'){
            var parentObj = valObj.parentNode;
            //edit:can 14275: 所有模块-列表：高级查询，错误。;
            var childs=parentObj.childNodes;
            for(var i=childs.length-1;i>=0;i--) {
				parentObj.removeChild(childs.item(i));
            }
           	var node5 = document.createElement('input');
        	node5.setAttribute('type', 'text');
			//wym 240611 BUG20240606-25 高级查找，关键字输入框加长一点，将属于条件的提示信息显示全
        	node5.setAttribute('class', 'width180 ld-input-inner');// node5.setAttribute('style', 'width:138px');
        	node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
			//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
			if(value!=undefined){
				node5.setAttribute('value',value);
			}
			//wym 2405278 BUG20240527-55 高级查找、平铺查找中，属于和不属于的时候关键字中没有对应的提示，由于分隔符号变更，提示同步需要修改为“多个值用|隔开”
			if(ld(opObj).val() == 'belong' || ld(opObj).val() == 'notbelong'){
				node5.setAttribute('placeholder',arrJsPopLabel['SEARCHBELONGTIP']);
			}
            //18763: 常用报表>销售预测分析表：转到高级查询，录入查找关键字后，按键盘上的Enter键，结果：页面跳转到了首页。
            node5.onkeypress=function(event){
                var e=event||window.event;
                var prevpopupobj=CrmPopup.getPopupObj('lastprev');
                if(e.keyCode==13) {
                    if(prevpopupobj.module=='OftenUseReport')
						generateReport(node5);
                    return false;
                }
            }
            parentObj.appendChild(node5);
        }
		else {
            //直接删除onclick事件，时间和日期切换的时候，控件无法自动切换，先删除橡皮擦，新增个时间或日期输入框，再删除老的输入框
            if(document.getElementById('fval_ext'+columnindex)){
				//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
				var fval_ext_obj=document.getElementById('fval_ext'+columnindex);
				var fval_ext_value = ld(fval_ext_obj).val();
				removeElement('fval_ext'+columnindex);
			}
            if(document.getElementById('clear_text_ext'+columnindex)) removeElement('clear_text_ext'+columnindex);
			var timeformat = " %H:%M:%S";
			var showtime = ' HH:mm:ss';
			if(fieldtype == 'D' || (tableName == 'ld_activity' && fieldName == 'date_start')) {
				timeformat = '';
				showtime = '';
			}
        	var node5 = document.createElement('input');
            node5.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
        	node5.setAttribute('class', 'Wdate maxWidth160 WdateImage');
        	node5.setAttribute('type', 'text');
        	node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
			//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
			if(value!=undefined){
				node5.setAttribute('value',value);
			}
			// node5.setAttribute('style','width:138px;');
			var parentObj = valObj.parentNode;
			parentObj.appendChild(node5);
			ld(node5).css('height','30px');
            if(document.getElementById('fval'+columnindex)) removeElement('fval'+columnindex);
			valObj = document.getElementById('fval'+columnindex);
			if(document.getElementById('clearfval_'+columnindex)) removeElement('clearfval_'+columnindex);
        }

		switch(fieldtype) {
			case 'D':
			case 'DT':
			case 'T':
				if(fieldtype=='T' && tableName.indexOf('ld_crmentity')<0){
					defaultRequiredElements(columnindex);
					break;
				}
                //edit:can 2021-01-14 044263: （https://61mis.com/kfbcrm [^]）页面设置->布局规则，触发字段选择“日期”类型字段，设置触发字段条件弹出层中“关键字”类型显示错误
				var dateformat = "YYYY-mm-dd";
				var timeformat = " %H:%M:%S";
				var showtime = ' HH:mm:ss';
				// duan 20240729 去掉原来的日程管理特殊判断,很久以前的代码了,不知道意义是什么,测试是可以的 || (tableName == 'ld_activity' && (fieldName == 'date_start' || fieldName == 'due_date'))
				if(fieldtype == 'D' ) {
					timeformat = '';
					showtime = '';
				}
				if(!document.getElementById('jscal_trigger_fval'+columnindex)) {
					var node = document.getElementById('fval'+columnindex);
					node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
					node.setAttribute('class','Wdate maxWidth160 WdateImage');
					ld(node).css('height','30px');
					// node.setAttribute('style','width:138px;');
				}
				var isexistsdatestr=isExistsDateTimeStr(currOp.value);
				if(currOp.value == 'bw'||isexistsdatestr=='yes') {
					if(!document.getElementById('fval_ext'+columnindex)) {
						//var fillernode = document.createElement('br');
						var node1 = document.createElement('input');
						node1.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
						node1.setAttribute('class', 'Wdate maxWidth160 WdateImage');
						node1.setAttribute('type', 'text');
						node1.setAttribute('id','fval_ext'+columnindex);
						node1.setAttribute('name','fval_ext'+columnindex);
						//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
						if(fval_ext_value!=undefined){
							node1.setAttribute('value',fval_ext_value);
						}
						// node1.setAttribute('style','width:138px;');
						var parentObj = valObj.parentNode;
						//parentObj.appendChild(fillernode);
						parentObj.appendChild(node1);
						ld(node1).css('height','30px');
					}
					var resultobj=datetimestr;
					for(var timekey in  datetimestr) {
						if(timekey==currOp.value){
						if(fieldtype=='DT') {
							document.getElementById('fval'+columnindex).value=resultobj[timekey][0]+" 00:00:00";
							document.getElementById('fval_ext'+columnindex).value=resultobj[timekey][1]+" 23:59:59";
						} else {
							document.getElementById('fval'+columnindex).value=resultobj[timekey][0];
							document.getElementById('fval_ext'+columnindex).value=resultobj[timekey][1];
						}
						document.getElementById('fval'+columnindex).disabled=true;
						document.getElementById('fval_ext'+columnindex).disabled=true;
						break;
						}
					}
					if(!document.getElementById('jscal_trigger_fval_ext'+columnindex)) {
						var node = document.getElementById('fval'+columnindex);
						node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
						node.setAttribute('class','Wdate maxWidth160 WdateImage');
						node.setAttribute('style','margin-right: 8px;');
						ld(node).css('height','30px');
					}
				}else {
					if(document.getElementById('fval_ext'+columnindex)) removeElement('fval_ext'+columnindex);
					if(document.getElementById('jscal_trigger_fval_ext'+columnindex)) removeElement('jscal_trigger_fval_ext'+columnindex);
					if(document.getElementById('clear_text_ext'+columnindex)) removeElement('clear_text_ext'+columnindex);
				}
				break;
			default	:defaultRequiredElements(columnindex);
		}

		if(isexistsdatestr!='yes') {
			var node6 = document.createElement('input');
			node6.setAttribute('type','button');
			node6.setAttribute('id','clear_text_ext'+columnindex);
			node6.setAttribute('class','icon-homeimg icon-clear inpb-advSearchreset marL5');
			node6.setAttribute('style','display:none');
			node6.style.cursor = "pointer";
			node6.onclick = function() {
				document.getElementById('fval'+columnindex).value='';
				document.getElementById('fval_ext'+columnindex).value='';
				return false;
			}
			parentObj.appendChild(node6);
		}
		ld('#clear_text_ext'+columnindex).show();
	}
}

function defaultRequiredElements(columnindex) {
    if(document.getElementById('jscal_trigger_fval'+columnindex)) removeElement('jscal_trigger_fval'+columnindex);
	if(document.getElementById('fval_ext'+columnindex)) removeElement('fval_ext'+columnindex);
	if(document.getElementById('jscal_trigger_fval_ext'+columnindex)) removeElement('jscal_trigger_fval_ext'+columnindex);
	if(document.getElementById('clear_text_ext'+columnindex)) removeElement('clear_text_ext'+columnindex);
}
function checkAdvancedFilter() {
	var escapedOptions = new Array('account_id','contactid','contact_id','product_id','parent_id','campaignid','potential_id','assigned_user_id1','quote_id','accountname','salesorder_id','vendor_id','time_start','time_end','lastname','accountid');

	var conditionColumns = vt_getElementsByName('tr', "conditionColumn");
	var criteriaConditions = [];
	for(var i=0;i < conditionColumns.length ; i++) {
		
		var columnRowId = conditionColumns[i].getAttribute("id");
		var columnRowInfo = columnRowId.split("_");
		var columnGroupId = columnRowInfo[1];
		var columnIndex = columnRowInfo[2];
		
		var columnId = "fcol"+columnIndex;
		var columnObject = getObj(columnId);
		var selectedColumn = trim(columnObject.value);
		var selectedColumnIndex = columnObject.selectedIndex;	
		var selectedColumnLabel = columnObject.options[selectedColumnIndex].text;
		
		var comparatorId = "fop"+columnIndex;
		var comparatorObject = getObj(comparatorId);
		var comparatorValue = trim(comparatorObject.value);
		
		var valueId = "fval"+columnIndex;
		var valueObject = getObj(valueId);
		var specifiedValue = trim(valueObject.value);
		//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
		var noAlertOfSalestage = ld('#noAlertOfSalestage').val();
        //zkt 20220518 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
        if(specifiedValue=='' && comparatorValue!=""&& comparatorValue != 'isnull' && comparatorValue != 'isnotnull'&& comparatorValue != 'curuser')
        {//32089: 单据序时簿界面：高级查找弹出层中，选择字段和条件后，不输入关键字立即查找，结果没有提示请输入查找关键字
        	if(noAlertOfSalestage!='yes'){
				var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			}
			return false;
        }
		
		var extValueId = "fval_ext"+columnIndex;
		var extValueObject = getObj(extValueId);
		if(extValueObject) {
			extendedValue = trim(extValueObject.value);
            //zkt 20220518 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
            if(extendedValue=='' && comparatorValue != 'isnull' && comparatorValue != 'isnotnull'&& comparatorValue != 'curuser')
            {//32089: 单据序时簿界面：高级查找弹出层中，选择字段和条件后，不输入关键字立即查找，结果没有提示请输入查找关键字
				var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
		}
		
		var glueConditionId = "fcon"+columnIndex;
		var glueConditionObject = getObj(glueConditionId);
		var glueCondition = '';
		if(glueConditionObject) {
			glueCondition = trim(glueConditionObject.value);
		}
		
		// If only the default row for the condition exists without user selecting any advanced criteria, then skip the validation and return.
		if(conditionColumns.length == 1 && selectedColumn == '' && comparatorValue == '' && specifiedValue == '')
			return true;

		//if (!emptyCheck(columnId," Column ","text"))
        if (!emptyCheck(columnId," "+arrJsPopLabel['SelectField'],"text"))
			return false;
		//2023428 BUG0065648 fengxh修改字段提示信息
		//if (!emptyCheck(comparatorId,selectedColumnLabel+" Option","text"))
        if (!emptyCheck(comparatorId,arrJsPopLabel['SELECTIONCRITERIA'],"text"))
			return false;

		var col = selectedColumn.split(":");
		
			if(escapedOptions.indexOf(col[3]) == -1) {
				if(col[4] == 'T' || col[4] == 'DT') {
					var datime = specifiedValue.split(" ");
					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"){
						if(datime.length > 1) {
							if(!re_dateValidate(datime[0],selectedColumnLabel,"OTH")) {
								return false
							}
							if(!re_patternValidate(datime[1],selectedColumnLabel,"TIMESECONDS")) {
								return false
							}
						} else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
							if(ld('#'+comparatorId).val() != 'isnull' && ld('#'+comparatorId).val() != 'isnotnull'){
								if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
									return false;
							}
						}else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
							if(ld('#'+comparatorId).val() != 'isnull' && ld('#'+comparatorId).val() != 'isnotnull'){

								if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
									return false;
							}
						}else if(ld('#'+comparatorId).val() != 'isnull' && ld('#'+comparatorId).val() != 'isnotnull'){

							if(!re_patternValidate(datime[0],selectedColumnLabel,"TIMESECONDS")) {
								return false
							}
						}
					}

					if(extValueObject) {
						var datime = extendedValue.split(" ");
						if (extendedValue.charAt(0) != "$" && extendedValue.charAt(extendedValue.length-1) != "$"){
							if(datime.length > 1) {
								if(!re_dateValidate(datime[0],selectedColumnLabel,"OTH")) {
									return false
								}
								if(!re_patternValidate(datime[1],selectedColumnLabel,"TIMESECONDS")) {
									return false
								}
							} else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
								if(!dateValidate(extValueId,selectedColumnLabel,"OTH"))
									return false
							} else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
								if(!dateValidate(extValueId,selectedColumnLabel,"OTH"))
									return false
							}else {
								if(comparatorValue!='isnull'&&comparatorValue!='isnotnull'&&!re_patternValidate(datime[0],selectedColumnLabel,"TIMESECONDS")) {
									return false
								}
							}
						}
					}
				}
				else if(col[4] == 'D')
				{
					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"&& ld('#'+comparatorId).val() != 'isnull' && ld('#'+comparatorId).val() != 'isnotnull'){
						if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
							return false
					}
					if(extValueObject&&ld('#'+comparatorId).val() != 'isnull' && ld('#'+comparatorId).val() != 'isnotnull') {
						if(!dateValidate(extValueId,selectedColumnLabel,"OTH"))
							return false
					}
				}else if(col[4] == 'I')
				{
					if(!intValidate(valueId,selectedColumnLabel+i))
						return false
				}else if(col[4] == 'N')
				{
					if (!numValidate(valueId,selectedColumnLabel,"any",true))
						return false
				}
				/*else if(col[4] == 'E')
				{
					if (!patternValidate(valueId,selectedColumnLabel+" (Email Id)","EMAIL"))
						return false
				}*/
			}
        
		//Added to handle yes or no for checkbox fields in reports advance filters. 
		if(col[4] == "C") {
			if(specifiedValue == "1")
				specifiedValue = getObj(valueId).value = 'yes';
			else if(specifiedValue =="0")
				specifiedValue = getObj(valueId).value = 'no';
		}
		if (extValueObject && extendedValue != null && extendedValue != '') specifiedValue = specifiedValue +','+ extendedValue;
		
		criteriaConditions[columnIndex] = {"groupid":columnGroupId, 
											"columnname":selectedColumn,
											"comparator":comparatorValue,
											"value":specifiedValue,
											"columncondition":glueCondition
										};
	}
    
    document.getElementById('advft_criteria').value = JSON.stringify(criteriaConditions);
	//$('advft_criteria').value = JSON.stringify(criteriaConditions);
	
	var conditionGroups = vt_getElementsByName('div', "conditionGroup");
	var criteriaGroups = [];
	for(var i=0;i < conditionGroups.length ; i++) {
		var groupTableId = conditionGroups[i].getAttribute("id");
		var groupTableInfo = groupTableId.split("_");
		var groupIndex = groupTableInfo[1];
		
		var groupConditionId = "gpcon"+groupIndex;
		var groupConditionObject = getObj(groupConditionId);
		var groupCondition = '';
		if(groupConditionObject) {
			groupCondition = trim(groupConditionObject.value);
		}
		criteriaGroups[groupIndex] = {"groupcondition":groupCondition};
		
	}
    document.getElementById('advft_criteria_groups').value = JSON.stringify(criteriaGroups);
	//$('advft_criteria_groups').value = JSON.stringify(criteriaGroups);
	return true;
}

/**
 * IE has a bug where document.getElementsByName doesnt include result of dynamically created 
 * elements
 */
function vt_getElementsByName(tagName, elementName) {
	var inputs = document.getElementsByTagName( tagName );
	var selectedElements = [];
	for(var i=0;i<inputs.length;i++){
	  if(inputs.item(i).getAttribute( 'name' ) == elementName ){
		selectedElements.push( inputs.item(i) );
	  }
	}
	return selectedElements;
}
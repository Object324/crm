/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************
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
*/


var noneLabel;
//230505 wym 以下四个变量名存在冲突，需要调用时请先改名
//var advft_column_index_count = -1;
//var advft_group_index_count = 0;
//var column_index_array = [];
//var group_index_array = [];
/*
function trimfValues(value) {
    var string_array;
    string_array = value.split(":");
    return string_array[4];
}*/

/*
function isExistsDateTimeStr(value)
{
   
    var isexists='no';
    ld.each(datetimestr,function(key,resultobj){
            if(value==key)
            {
                isexists='yes';
                return false ;
            }
    });
    
    return isexists;
}*/

function New_updatefOptions(sel, opSelName) {


   var popupobj=CrmPopup.getPopupObj('last');
   
    var selObj =ld("#"+popupobj.advanceSearchDivid+" [name="+opSelName+"]").get(0);// document.getElementById(opSelName);
    var fieldtype = null ;
    //获取字段信息
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
    return ;
  }

    var currOption = selObj.options[selObj.selectedIndex];
    var currField = sel.options[sel.selectedIndex];
    if(currField.value != null && currField.value.length != 0) {
		fieldtype = trimfValues(currField.value);
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
                //zkt 20221104 BUG0057767页面设置，自定义关联选择单据（单选）字段弹出层中，设置其他条件，选择“日期”字段，选择“区间”比较关系后，关键字只显示了一个日期插件
                if(datetimestr!=undefined){
                    var resultobj=datetimestr;//eval('.popupobj.datatimestr.');  
    				// var option = new Option (arrJsPopLabel['Interval'], 'bw');
    			//	 selObj.options[k + off] = option;
    				// k++;
                    ld.each(datetimestr,function(value,resultobj){
                             
                        
                           var option = new Option (resultobj[2], value);
    				        selObj.options[k + off] = option;
                             k++;             
                    } );
                }
                 
           }
           //zkt 20220519 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
           if(fieldsinfo.length>0){
                //判断字段类型，若为用户字段类型则条件下拉框增加当前用户
                var string_array = currField.value.split(":");
                var fieldname = string_array[2];
                var tablename = string_array[0];
                ld.each(fieldsinfo,function(index){
					var fieldinfo = fieldsinfo[index];
					//231031 wym BUG0074723 详情页的fields中是fieldname,fieldName不知道在哪里会用做判断,先不删除
					if(fieldsinfo[index]['fieldName']==fieldname||fieldsinfo[index]['fieldname']==fieldname){
						if(global_multiuser_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
							var option = new Option (fLabels['includeuser'], 'curuser');
							selObj.options[k + off] = option;
							k++;
						}
						else if(global_user_uitype_arr.indexOf(fieldsinfo[index]['uitype'])>-1){
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
						//wym XUQIU1002044 手写签名需要切换下拉框默认选项
						ld(selObj).find('option').filter(function() {
							return ld(this).css("display") != "none" && ld(this).val() != "";
						}).first().prop("selected", true);
						return  false;
                    }
                })
           }
           //edit:can 57183  在服务合同的产品分录，点击产品的+号，在查找的界面的高级查找的条件默认改为包含 
           if(selObj.selectedIndex==0)
            selObj.selectedIndex=1;
		}
    } else {
		if (currField.value == '') {
			selObj.options[0].selected = true;
		}
    }

}

function New_showHideDivs(showdiv, hidediv) {
    var popupobj=CrmPopup.getPopupObj('last');
    
	if(ld("#"+popupobj.advanceSearchDivid+" [name="+showdiv+"]").length>0) 
		ld("#"+popupobj.advanceSearchDivid+" [name="+showdiv+"]").get(0).style.display = "block";
	
	if(ld("#"+popupobj.advanceSearchDivid+" [name="+hidediv+"]").length>0) 
		ld("#"+popupobj.advanceSearchDivid+" [name="+hidediv+"]").get(0).style.display = "none";
}

function New_hideAllElementsByName(name) {
     var popupobj=CrmPopup.getPopupObj('last');
	var allElements = document.getElementsByTagName('div');
	for(var i=0; i<allElements.length; ++i) {
		var element = allElements[i];
		if (element.getAttribute('name') == name)
			element.style.display='none';
	}
    puyoungJS_DialogBox.unblock();
	return true;
}

function New_removeElement(elementId) {
     var popupobj=CrmPopup.getPopupObj('last');

	var element = ld("#"+popupobj.advanceSearchDivid+" [name="+elementId+"]");
    
	if(element!=undefined&&element.length>0) {
	   //element=element.get(0);
		var parent = element.parent().get(0);
		if(parent) {
			parent.removeChild(element.get(0));
		} else {
			element.get(0).remove();
		}
	}
}

function New_deleteGroup(groupIndex) {
    var popupobj=CrmPopup.getPopupObj('last');
    
	New_removeElement('conditiongroup_'+groupIndex);
	
	var keyOfTheGroup = popupobj.group_index_array.indexOf(groupIndex);
	var isLastElement = true;
	//var popupobj=CrmPopup.getPopupObj('last');
	for(var i=keyOfTheGroup; i<popupobj.group_index_array.length; ++i) {
		var nextGroupIndex = popupobj.group_index_array[i];
		var nextGroupBlockId = "conditiongroup_"+nextGroupIndex;
        var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+nextGroupBlockId+"]");//ls 20220812 BUG0054697客户详情页，相关信息-联系人，点击高级查找，添加组合条件再删除后，对应的且或没有删除
        
		if(tmpobj!=undefined&&tmpobj.length>0) {
			isLastElement = false;
			break;
		}
	}
	
	
	if(isLastElement) {
		for(var i=keyOfTheGroup-1; i>=0; --i) {
			var prevGroupIndex = popupobj.group_index_array[i];
			var prevGroupGlueId = "gpcon"+prevGroupIndex;
            var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+prevGroupGlueId+"]");
			if(tmpobj!=undefined&&tmpobj.length>0) {
				New_removeElement(prevGroupGlueId);
				break;
			}
		}
	}	
}

function New_addNewConditionGroup(parentNodeId) {
   
    var popupobj=CrmPopup.getPopupObj('last');
	New_addConditionGroup(parentNodeId);	
	New_addConditionRow(popupobj.advft_group_index_count);
}

function New_deleteColumnRow(groupIndex, columnIndex) {
    var popupobj=CrmPopup.getPopupObj('last');
	removeElement('conditioncolumn_'+groupIndex+'_'+columnIndex);
	var groupColumns = popupobj.column_index_array[groupIndex];
	var keyOfTheColumn = groupColumns.indexOf(columnIndex);
	var isLastElement = true;
	
	for(var i=keyOfTheColumn; i<groupColumns.length; ++i) {
		var nextColumnIndex = groupColumns[i];
		var nextColumnRowId = 'conditioncolumn_'+groupIndex+'_'+nextColumnIndex;
        var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+nextColumnRowId+"]");
        
		if(tmpobj!=undefined&&tmpobj.length>0) {
			isLastElement = false;
			if(ld("#"+popupobj.advanceSearchDivid+" select[name^='fcon']").length < 1){
				ld('#advfiltershow').css('display','none');
			}
			break;
		}
	}
	if(isLastElement) {
		for(var i=keyOfTheColumn-1; i>=0; --i) {
			var prevColumnIndex = groupColumns[i];
			var prevColumnGlueId = "fcon"+prevColumnIndex;
             var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+prevColumnGlueId+"]");
			if(tmpobj!=undefined&&tmpobj.length>0) {
				New_removeElement(prevColumnGlueId);
				if(ld("#"+popupobj.advanceSearchDivid+" select[name^='fcon']").length < 1){
					//wym BUG0074249
					if(ld("#"+popupobj.advanceSearchDivid+" #advfiltershow")){
						ld("#"+popupobj.advanceSearchDivid+" #advfiltershow").css('display','none');
					}else{
						ld("#advfiltershow").css('display','none');
					}
				}
				break;
			}
		}
	}
    //ld("#conditiongrouptable_"+groupIndex+" .deleteauto").click();
   // alert(ld("#conditiongrouptable_"+groupIndex+" tr").length);
   //高级查询>添加新组合：填写数据，当第一行的内容删除时第一行下面的下拉框中的内容也清除。
   
   if(ld("#"+popupobj.advanceSearchDivid+" [name=conditiongrouptable_"+groupIndex+"] tr").length<=2)
        New_deleteGroup(groupIndex);
}

function New_addRequiredElements(columnindex) {
    var popupobj=CrmPopup.getPopupObj('last');
	var colObj =ld("#"+popupobj.advanceSearchDivid+" [name=fcol"+columnindex+"]").get(0);// document.getElementById('fcol'+columnindex);
	var opObj = ld("#"+popupobj.advanceSearchDivid+" [name=fop"+columnindex+"]").get(0);// document.getElementById('fop'+columnindex);
    var valObj =ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0);// document.getElementById('fval'+columnindex);
	//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
	var value = valObj.value;
    if(colObj==undefined ||colObj==null ||opObj==undefined || opObj==null) {
		return;
	}
	//wym BUG0076544 kfbcrm-选择产品弹窗-高级查找 选择条件“是空值” 关键字一栏应该隐藏 BUG0077911 客户管理--高级查找--选择销售负责人，条件为选择当前操作员，后面关键字的输入框应该不显示 BUG20240126-56 审批流程定制，设置分支条件时，选择签约日期是空值，后边仍有输入框
	if(ld(opObj).val() == 'isnull' || ld(opObj).val() == 'isnotnull'|| ld(opObj).val() == 'has_changed' || ld(opObj).val() == 'curuser'){
		ld(valObj).css('display','none');
		ld(valObj).siblings('.icon-clear').css('display','none');
		ld(valObj).siblings('.Wdate').css('display','none');
		return;
	} else{
		ld(valObj).css('display','');
		ld(valObj).siblings('.icon-clear').css('display','');
	}
	if(colObj.selectedIndex<0 ||opObj.selectedIndex<0 ) {
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
		//如果选择的是不日期和时间移除日期显示格式
        if(fieldtype!='D'&&fieldtype!='DT'&&fieldtype!='T'){
            var parentObj = valObj.parentNode;
            //edit:can 14275: 所有模块-列表：高级查询，错误。;
            var childs=parentObj.childNodes;    
            for(var i=childs.length-1;i>=0;i--) {
				parentObj.removeChild(childs.item(i));
            }
           	var node5 = document.createElement('input');
        	node5.setAttribute('type', 'text');
        	node5.setAttribute('class', 'width150 commonTextBoxPop');
        	node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
			//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
			if(value!=undefined){
				node5.setAttribute('value',value);
			}
			if(ld(opObj).val() == 'belong' || ld(opObj).val() == 'notbelong'){
				node5.setAttribute('placeholder',arrJsPopLabel['SEARCHBELONGTIP']);
			}
            //18763: 常用报表>销售预测分析表：转到高级查询，录入查找关键字后，按键盘上的Enter键，结果：页面跳转到了首页。
            node5.onkeypress=function(event){
                var e=event||window.event;
				var prevpopupobj=CrmPopup.getPopupObj('lastprev');
                if(e.keyCode==13)
                {
					if(prevpopupobj.type==RelateListPage.type) {
						//相关信息查询
						DetailViewRelation.callSearch();
					}
                    if(prevpopupobj.module=='OftenUseReport')
						generateReport(node5);
                    return false;
                }
            }
            parentObj.appendChild(node5);
        }
		else{
            //直接删除onclick事件，时间和日期切换的时候，控件无法自动切换，先删除橡皮擦，新增个时间或日期输入框，再删除老的输入框
            var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]");
            if(tmpobj!=undefined&&tmpobj.length>0) {
				//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
				var fval_ext_value = tmpobj.value;
				New_removeElement('fval_ext'+columnindex);
			}
            tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=clear_text_ext"+columnindex+"]");
            if(tmpobj!=undefined&&tmpobj.length>0) removeElement('clear_text_ext'+columnindex);
            var timeformat = " %H:%M:%S";
            var showtime = ' HH:mm:ss';
            if(fieldtype == 'D' || (tableName == 'ld_activity' && fieldName == 'date_start')) {
							timeformat = '';
							showtime = '';
            }		
        	var node5 = document.createElement('input');
            node5.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
        	node5.setAttribute('class', 'Wdate btn-radius-system WdateImage');
        	node5.setAttribute('type', 'text');
        	node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
			node5.setAttribute('style','width:148px;');	//zxm 20230802 BUG0070521   kfbcrm-首页-库存资料组件，点击更多，首页穿透高级查找页面，选择字段选择时间相关字段，选择条件为时间区间时，两个时间框具体太近且时间长度会覆盖日历小图
			//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
			if(value!=undefined){
				node5.setAttribute('value',value);
			}
			var parentObj = valObj.parentNode;
			parentObj.appendChild(node5);
            tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]");
            if(tmpobj!=undefined&&tmpobj.length>0)  removeElement('fval'+columnindex);
                 valObj = tmpobj.get(0);
            tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=clearfval_"+columnindex+"]");
			if(tmpobj!=undefined&&tmpobj.length>0) removeElement('clearfval_'+columnindex);
        }

		switch(fieldtype) {
			case 'D':
			case 'DT':
			case 'T':
				if(fieldtype=='T' && tableName.indexOf('ld_crmentity')<0){
					New_defaultRequiredElements(columnindex);
					break;
				}
				var dateformat = $('jscal_dateformat').value;
				var timeformat = " %H:%M:%S";
				var showtime = ' HH:mm:ss';
				if(fieldtype == 'D' || (tableName == 'ld_activity' && (fieldName == 'date_start' || fieldName == 'due_date'))) {
					timeformat = '';
					showtime = '';
				}
				tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval"+columnindex+"]");
				if(tmpobj==undefined||tmpobj.length<=0) {
					var node = ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0);//
					node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
					node.setAttribute('class','Wdate btn-radius-system WdateImage');
					node.setAttribute('style','width:148px;');
				}
				var isexistsdatestr=isExistsDateTimeStr(currOp.value);

				if(currOp.value == 'bw'||isexistsdatestr=='yes') {
					if(!document.getElementById('fval_ext'+columnindex+"]")) {
						//var fillernode = document.createElement('br');
						var node1 = document.createElement('input');
						node1.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
						node1.setAttribute('class', 'Wdate btn-radius-system WdateImage');
						node1.setAttribute('type', 'text');
						node1.setAttribute('id','fval_ext'+columnindex);
						node1.setAttribute('name','fval_ext'+columnindex);
						node1.setAttribute('style','width:148px;');
						//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
						if(fval_ext_value!=undefined){
							node1.setAttribute('value',fval_ext_value);
						}
						//	var parentObj = valObj.parentNode;
						var parentObj=ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").parent().get(0);
						//parentObj.appendChild(fillernode);
						parentObj.appendChild(node1);
					}
					var resultobj=datetimestr;
					for(var timekey in  datetimestr) {
						if(timekey==currOp.value){
							if(fieldtype=='DT') {
								ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val(resultobj[timekey][0]+" 00:00:00");
								ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").val(resultobj[timekey][1]+" 23:59:59");
							} else {
								ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val(resultobj[timekey][0]);
								ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").val(resultobj[timekey][1]);
							}
							ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0).disabled=true;
							ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").get(0).disabled=true;
							break;
						}
					}
					if(ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval_ext"+columnindex+"]").length>0) {
						var node =  ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0);//document.getElementById('fval'+columnindex);
						node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
						node.setAttribute('class','Wdate btn-radius-system WdateImage');
						node.setAttribute('style','width:108px;margin-right: 8px;');
					}
				} else {
					New_defaultRequiredElements(columnindex) ;
				}
				break;
			default	:New_defaultRequiredElements(columnindex); 
		}

		if(isexistsdatestr!='yes') {
			var node6 = document.createElement('input');
			node6.setAttribute('type','button');
			node6.setAttribute('id','clear_text_ext'+columnindex);
			node6.setAttribute('name','clear_text_ext'+columnindex);
			node6.setAttribute('class','icon-homeimg icon-clear inpb-advSearchreset marL5');
			node6.setAttribute('style','display:none;');
			node6.style.cursor = "pointer";
			node6.onclick = function() {
				var popupobj=CrmPopup.getPopupObj('last');
				ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val('');
				ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").val('');
				return false;
			}
			parentObj.appendChild(node6);
		}
		ld('#'+popupobj.divid+" [name=clear_text_ext"+columnindex+"]").css("display",'');
	}
}

function New_clearKeywordsinput(columnIndex) {
	var popupobj = CrmPopup.getPopupObj("last");
	if(popupobj!=undefined&&popupobj.searchtype == 'advance') {
		ld('#'+popupobj.divid).find("#fval"+columnIndex).val('');
		if(ld('#'+popupobj.divid).find("#fval_ext"+columnIndex).length>0){
			ld('#'+popupobj.divid).find("#fval_ext"+columnIndex).val('');
		}
	}
}

function New_defaultRequiredElements(columnindex) {
    var popupobj=CrmPopup.getPopupObj('last');
    
    if(ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval"+columnindex+"]").length>0) removeElement('jscal_trigger_fval'+columnindex);
    if(ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").length>0) removeElement('fval_ext'+columnindex);
    if(ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval_ext"+columnindex+"]").length>0) removeElement('jscal_trigger_fval_ext'+columnindex);
    if(ld("#"+popupobj.advanceSearchDivid+" [name=clear_text_ext"+columnindex+"]").length>0) removeElement('clear_text_ext'+columnindex);
                                
    
}
function New_checkAdvancedFilter() {
	var escapedOptions = new Array('account_id','contactid','contact_id','product_id','parent_id','campaignid','potential_id','assigned_user_id1','quote_id','accountname','salesorder_id','vendor_id','time_start','time_end','lastname','accountid');
	var popupobj=CrmPopup.getPopupObj('last');
	var conditionColumns = New_vt_getElementsByName('tr', "conditionColumn");
	var criteriaConditions = [];
  
	for(var i=0;i < conditionColumns.length ; i++) {
		
		var columnRowId = conditionColumns[i].getAttribute("id");
		var columnRowInfo = columnRowId.split("_");
		var columnGroupId = columnRowInfo[1];
		var columnIndex = columnRowInfo[2];
		
		var columnId = "fcol"+columnIndex;
		var columnObject =ld("#"+popupobj.advanceSearchDivid+" [name="+columnId+"]").get(0);;// getObj(columnId);
		var selectedColumn = trim(columnObject.value);
		var selectedColumnIndex = columnObject.selectedIndex;

		var selectedColumnLabel = '';
		if(selectedColumnIndex != ''){
			var selectedColumnLabel = columnObject.options[selectedColumnIndex].text;
		}
		var comparatorId = "fop"+columnIndex;
		var comparatorObject =ld("#"+popupobj.advanceSearchDivid+" [name="+comparatorId+"]").get(0);// getObj(comparatorId);
		var comparatorValue = trim(comparatorObject.value);
		
		var valueId = "fval"+columnIndex;
		var valueObject =ld("#"+popupobj.advanceSearchDivid+" [name="+valueId+"]").get(0);;// getObj(valueId);
		var specifiedValue = trim(valueObject.value);
        //alert(specifiedValue);
        if(specifiedValue=='' && comparatorValue!=""&& comparatorValue != 'isnull' && comparatorValue != 'isnotnull'&& comparatorValue != 'curuser')
        {//32089: 单据序时簿界面：高级查找弹出层中，选择字段和条件后，不输入关键字立即查找，结果没有提示请输入查找关键字
            var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
          
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
		
		var extValueId = "fval_ext"+columnIndex;
		var extValueObject =ld("#"+popupobj.advanceSearchDivid+" [name="+extValueId+"]").get(0);// getObj(extValueId);
		if(extValueObject) {
			extendedValue = trim(extValueObject.value);
            if(extendedValue=='' && comparatorValue != 'isnull' && comparatorValue != 'isnotnull' && comparatorValue != 'curuser')
            {//32089: 单据序时簿界面：高级查找弹出层中，选择字段和条件后，不输入关键字立即查找，结果没有提示请输入查找关键字
				var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
		}
		
		var glueConditionId = "fcon"+columnIndex;
		var glueConditionObject =ld("#"+popupobj.advanceSearchDivid+" [name="+glueConditionId+"]").get(0);// getObj(glueConditionId);
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
		//if (!emptyCheck(comparatorId,selectedColumnLabel+" Option","text"))
      
        if (!emptyCheck(comparatorId,selectedColumnLabel+' '+arrJsPopLabel['OPTIONS']+' ',"text"))
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
					if(extValueObject) {
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
   var prevpopupobj=CrmPopup.getPopupObj('lastprev');
   
    ld("#"+prevpopupobj.divd+" [name=advft_criteria]").val(JSON.stringify(popupobj.criteriaConditions));
  //  document.getElementById('advft_criteria').value = JSON.stringify(criteriaConditions);
	//$('advft_criteria').value = JSON.stringify(criteriaConditions);
	
	var conditionGroups = New_vt_getElementsByName('div', "conditionGroup");
	var criteriaGroups = [];
   //var popupobj=CrmPopup.getPopupObj('last');
	for(var i=0;i < conditionGroups.length ; i++) {
		var groupTableId = conditionGroups[i].getAttribute("id");
		var groupTableInfo = groupTableId.split("_");
		var groupIndex = groupTableInfo[1];
		
		var groupConditionId = "gpcon"+groupIndex;
		var groupConditionObject = ld("#"+popupobj.advanceSearchDivid+" [name="+groupConditionId+"]").get(0);
		var groupCondition = '';
		if(groupConditionObject) {
			groupCondition = trim(groupConditionObject.value);
		}
		criteriaGroups[groupIndex] = {"groupcondition":groupCondition};
		
	}
    popupobj.advft_criteria_groups=JSON.stringify(criteriaGroups);
    popupobj.advft_criteria=JSON.stringify(criteriaConditions);
   
	return true;
}

/**
 * IE has a bug where document.getElementsByName doesnt include result of dynamically created 
 * elements
 */
function New_vt_getElementsByName(tagName, elementName) {
    var popupobj=CrmPopup.getPopupObj('last');
	var inputs = ld("#"+popupobj.advanceSearchDivid+" "+tagName);
    
	var selectedElements = [];
   
    ld.each(inputs,function(){
        if(ld(this).attr("tag")==elementName)
        {
            selectedElements.push( ld(this).get(0) );
        }
    });

	return selectedElements;
}

/*
editer:ljj
time:20231110
reason:XUQIU1000542
content:选择源单、选择产品、基本查找和高级查找增加“搜索历史”功能（参考单据列表高级查找搜索历史功能）
note:新增参数searchfrom 列表：listpage 选择原单：selectsearchdetail
 */
function advanceFilterSearch(){
	var that=this;

//选择源单版getUrlString，显示历史搜索记录
	this.show_history_new=function (popupobj){
		var prevpopupobj=CrmPopup.getPopupObj('lastprev');
		var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SearchHistory&mode='+popupobj.searchmode;
		url += '&searchtype='+popupobj.searchtype+'&divid='+popupobj.divid;

		if (prevpopupobj.type == 'selectsearchdetail' && popupobj.searchtype == 'advance'){
			var searchfrom=prevpopupobj.type;
		}else {
			var searchfrom=popupobj.type;
		}
		url += '&searchfrom='+searchfrom;

		if(popupobj.advancefiltersearch == 'yes' && popupobj.searchtype == 'advance'){
			url += '&advancefiltersearch=yes';
		}
		//zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
		// if(popupobj.module == 'Approve'){
		// 	var prevpopupobj = CrmPopup.getPopupObj('lastprev');
		// 	if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
		// 		url += '&searchmodule='+prevpopupobj.module;
		// 	}
		// }
		ldAjax(url,"",function(data){
			DelProgressObjs();
			if(data.code == 1){
				if (popupobj.searchtype == 'advance'){//选择源单高级查找新建了弹出层
					var tmppopupobj=CrmPopup.getPopupObj('last');
				}else {
					var tmppopupobj=popupobj;
				}
				if(data.result.num_rows >0){
					ld('#'+tmppopupobj.divid+' [name=SearchHistory]').html(data.result.content);
				}else{
					ld('#'+tmppopupobj.divid+' [name=SearchHistory]').html(data.result.emptycontent);
				}
			}
		});
	}
	/*
    editer:ljj
    time:20231110
    reason:XUQIU1000542
    content:选择源单、选择产品、基本查找和高级查找增加“搜索历史”功能（参考单据列表高级查找搜索历史功能）
    note:
    1.参数searchfrom 列表：listpage 选择原单：selectsearchdetail
    2.功能：清除历史搜索记录
    */
	this.clearhistoryNew=function (obj){
		var searchtype = ld(obj).attr('searchtype');
		var popupobj=CrmPopup.getPopupObj("last");
		popupobj.searchtype = searchtype;
		popupobj.searchmode = 'clearhistory';
		advanceFilterSearch.getInstance().show_history_new(popupobj);
	}

	/*
    editer:ljj
    time:20231110
    reason:XUQIU1000542
    content:选择源单、选择产品、基本查找和高级查找增加“搜索历史”功能（参考单据列表高级查找搜索历史功能）
    note:
    1.参数searchfrom 列表：listpage 选择原单：selectsearchdetail
    2.功能：基本查找点击获取历史搜索记录
     */
	this.getBasicFieldSearchHistoryNew=function (obj){
		//显示清除按钮\
		var popupobj=CrmPopup.getPopupObj('last');

		if (popupobj.type=='selectsearchdetail'){
			var selectmodule=popupobj.module;
		}else if (popupobj.type == 'relatelistpage' && popupobj.headermodule == 'PriceBooks' && popupobj.module == 'Products'){
			selectmodule = popupobj.module;
		}else {
			var selectmodule=module;
		}
		var url = 'index.php?module='+selectmodule+'&action='+selectmodule+'Ajax&file=SearchHistory&mode=showhistory&newbasicsearch=yes';
		url += '&searchtype=BasicSearch';
		if (popupobj.type == 'relatelistpage' && popupobj.headermodule == 'PriceBooks' && popupobj.module == 'Products'){
			url += '&searchfrom=selectsearchdetail';
		}else {
			url += '&searchfrom='+popupobj.type;
		}
		//zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
		if(selectmodule == 'Approve'){
			url += '&searchmodule='+selectmodule;
		}
		if(selectmodule == 'RecycleBin'){
			return false;
		}

		if (obj.tagName.toLowerCase() === 'input') {
			var optionvalues = ld(obj).parent().prev(' #basicsearchcolumns_real').find('select#bas_searchfield option').map(function() {
				return ld(this).val();
			}).get();
		} else if (obj.tagName.toLowerCase() === 'select') {
			var optionvalues = ld(obj).find(' option').map(function() {
				return ld(this).val();
			}).get();
		}

		ldAjax(url,"",function(data){
			DelProgressObjs();
			if(data.code == 1){
				var searchvalue_arr = data.result.searchvalue_arr;
				var clearlabel = data.result.clearlabel;
				var html = '';
				ld.each(searchvalue_arr,function(i,item){
					if (optionvalues.includes(item.searchvalue.search_field)) {
						html += '<li class="active-result" name="BasicSearch_result_'+i+'"  onclick="selectThisHistoryLine(this);return false;">'+
							'<a class="overflow-space" optionvalue="'+item.searchvalue.search_field+'" searchtext="'+item.searchvalue.search_text+'" title="'+item.label+'">'+item.label+'</a>'+
							'</li>';
					}
				});
				if (popupobj.type == 'selectsearchdetail'){
					html += '<li name="clear_BasicSearch" searchtype="BasicSearch" onclick="advanceFilterSearch.getInstance().clearhistoryNew(this)" onmouseover="cmb_limouseover(event,\'BasicSearch\',\'\')"><a class="overflow-space blueFont">'+clearlabel+'</a></li>';
				}else {
					html += '<li name="clear_BasicSearch" searchtype="BasicSearch" onclick="clearhistory(this)" onmouseover="cmb_limouseover(event,\'BasicSearch\',\'\')"><a class="overflow-space blueFont">'+clearlabel+'</a></li>';
				}
				ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html(html);
				ld('body').unbind('click').bind('click',function(){
					ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html('');
				});
			}else{
				ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html('');
			}
			var liobj=ld('#basicSearchNewDiv #basicSearchList').find('li');
			ld(liobj).unbind('mouseover').mouseover(function (){

				ld(liobj).attr("class","");
				ld(this).addClass('result_li');

			});
		});
	}
	/*
    editer:ljj
    time:20231110
    reason:XUQIU1000542
    content:选择源单、选择产品、基本查找和高级查找增加“搜索历史”功能（参考单据列表高级查找搜索历史功能）
    note:
    1.参数searchfrom 列表：listpage 选择原单：selectsearchdetail
    2.功能：选择历史搜索记录 点击事件
     */
	this.searchhistory_change_new=function (obj){
		var optionvalue = ld(obj).attr('optionvalue');
		var fldname = ld(obj).attr('fldname');
		var parentdivid = ld(obj).attr('divid');
		cmb_liclick(optionvalue,fldname,parentdivid);
		var popupobj=CrmPopup.getPopupObj("last");
		if(popupobj.searchtype == 'BasicSearch'){
			//为基本查询框赋值
			var searchtext = ld(obj).attr('searchtext');
			//因为存在不同数据分类的下拉框value值不同的情况，所以这里根据columnname判断
			var optionvalue_arr = optionvalue.split(':');
			if(optionvalue_arr.length<=1){
				ld('#'+popupobj.divid+' select[name=search_field]').val(optionvalue);
			}else{
				var columnname = optionvalue_arr[2];
				var checkinfoobj = CrmPopup.findHtmlobj(popupobj.divid,'search_field');
				var optionsobjs = checkinfoobj.find("option");
				var tmp_optionvalue = "";
				ld.each(optionsobjs,function(){
					tmp_optionvalue = ld(this).val();
					if(tmp_optionvalue == optionvalue){
						ld('#'+popupobj.divid+' select[name=search_field]').val(tmp_optionvalue);
						return false;
					}else{
						var tmp_optionvalue_arr = tmp_optionvalue.split(':');
						if(optionvalue_arr.length<=1){
							var tmp_columnname = tmp_optionvalue;
						}else{
							var tmp_columnname = tmp_optionvalue_arr[2];
						}
						if(tmp_columnname == columnname){
							ld('#'+popupobj.divid+' select[name=search_field]').val(tmp_optionvalue);
							return false;
						}
					}
				});
			}
			ld('#'+popupobj.divid+' input[name=search_text]').val(searchtext);
		}else if(popupobj.searchtype == 'advance'){
			//为高级查询框赋值
			var searchid = ld(obj).attr('searchid');
			popupobj.searchmode = 'choosehistory';
			var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SearchHistory&mode='+popupobj.searchmode;
			url += '&searchtype='+popupobj.searchtype+'&divid='+popupobj.divid+'&id='+searchid;
			//zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
			if(module == 'Approve'){
				var prevpopupobj = CrmPopup.getPopupObj('lastprev');
				if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
					url += '&searchmodule='+prevpopupobj.module;
				}
			}
			ldAjax(url,"",function(data){
				DelProgressObjs();
				if(data.code == 1){
					var popupobj=CrmPopup.getPopupObj("last");
					that.changeAdvanceCondition(popupobj,data.result.criteria_groups);
				}
			});
		}
	}

	this.changeAdvanceCondition=function (popupobj,criteria_groups){
		var groupid; //查询组编号
		var groups_criteria; //查询组信息
		var group_columns; //组内查询字段信息
		var column_index; //每行的编号
		var column_criteria; //每行查询条件信息
		var columnvalue; //查询内容
		var fori = 0; //'且'、'或'条件编号
		var conditionColumnRowElement; //每行对象
		//清空原有条件
		ld('#'+popupobj.divid+' [tag=conditionGroup]').remove();
		//重置已有查询条件数量
		popupobj.advft_column_index_count = -1;
		popupobj.advft_group_index_count = 0;
		popupobj.column_index_array = [];
		popupobj.group_index_array = [];
		//遍历所有查询条件
		for(groupid in criteria_groups){
			groups_criteria = criteria_groups[groupid];
			group_columns = groups_criteria['columns'];
			New_addConditionGroup('pop_adv_filter_div');//添加查询组
			for(column_index=0;column_index < group_columns.length;column_index++){ //这里直接用遍历会有问题(循环长度为2的数组，会出现第三个参数‘each’)
				column_criteria = group_columns[column_index];
				New_addConditionRow(groupid);//添加查询行
				conditionColumnRowElement = ld('#'+popupobj.divid+' #fcol'+popupobj.advft_column_index_count); //获取行对象
				conditionColumnRowElement.val(column_criteria['columnname']); //为查询字段赋值
				var text = ld('#'+popupobj.divid+" #fcol" + popupobj.advft_column_index_count +" option:selected").text();
				if(ld("#"+popupobj.divid+" #cmb_span_optiontext_fcol"+popupobj.advft_column_index_count)){
					ld("#"+popupobj.divid+" #cmb_span_optiontext_fcol"+popupobj.advft_column_index_count).val(text);
				}
				New_updatefOptions(conditionColumnRowElement.get(0), 'fop'+popupobj.advft_column_index_count); //控制'且'、'或'条件显示
				ld('#'+popupobj.divid+" #fop"+popupobj.advft_column_index_count).val(column_criteria['search_comparator']);
				New_addRequiredElements(popupobj.advft_column_index_count); //特殊查询类型控制，如日期等;
				//设置关键字
				columnvalue = column_criteria['value'];
				if(column_criteria['comparator'] == 'bw' && columnvalue != '') { //特殊类型：日期
					var values = columnvalue.split(",");
					ld('#'+popupobj.divid+" #fval"+popupobj.advft_column_index_count).val(values[0]);
					if(values.length == 2 && ld('#'+popupobj.divid+" #fval_ext"+popupobj.advft_column_index_count))
						ld('#'+popupobj.divid+" #fval_ext"+popupobj.advft_column_index_count).val(values[1]);
				}else{
					//特殊翻译
					if(columnvalue =='Accepted'){
						ld('#'+popupobj.divid+" #fval"+popupobj.advft_column_index_count).val(alert_arr.Accepted);
					}
					else if(columnvalue =='Rejected'){
						ld('#'+popupobj.divid+" #fval"+popupobj.advft_column_index_count).val(alert_arr.Accepted);
					}
					else{
						var values = columnvalue.split(",");
						ld('#'+popupobj.divid+" #fval"+popupobj.advft_column_index_count).val(values[0]);
					}
				}
			}
			//设置每行的'且'、'或'条件
			for(column_index=0;column_index < group_columns.length;column_index++){//直接用遍历会有问题
				column_criteria = group_columns[column_index];
				if(ld('#'+popupobj.divid+" #fcon"+fori))
				{
					ld('#'+popupobj.divid+" [name=fcon"+fori).val(column_criteria['column_condition']);
				}
				fori += 1;
			}
		}
		//设置查询组之间的'且'、'或'条件
		for(groupid in criteria_groups){
			groups_criteria = criteria_groups[groupid];
			if(ld('#'+popupobj.divid+" #gpcon"+groupid))
				ld('#'+popupobj.divid+" #gpcon"+groupid).val(groups_criteria['condition']);
		}
	}
}
advanceFilterSearch.getInstance=function(){
	if (advanceFilterSearch.cur_obj == null ){
		advanceFilterSearch.cur_obj = new advanceFilterSearch();
	}
	return advanceFilterSearch.cur_obj;
}

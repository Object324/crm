 /*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

function verify_data() {
	var isError = false;
	var errorMessage = "";
	if (trim(document.CustomView.viewName.value) == "") {
		isError = true;
		errorMessage += "\nView Name";
	}
	// Here we decide whether to submit the form.
	if (isError == true) {
		alert(alert_arr.MISSING_REQUIRED_FIELDS + errorMessage);
		return false;
	}
	//return true;
}


function CancelForm()
{
var cvmodule = document.templatecreate.cvmodule.value;
var viewid = document.templatecreate.cvid.value;
document.location.href = "index.php?module="+cvmodule+"&action=index&viewname="+viewid;
}


function check4null(form)
{
        var isError = false;
        var errorMessage = "";
        // Here we decide whether to submit the form.
        if (trim(form.subject.value) =='') {
                isError = true;
                errorMessage += "\n subject";
                form.subject.focus();
        }

        // Here we decide whether to submit the form.
        if (isError == true) {
                alert(alert_arr.MISSING_REQUIRED_FIELDS + errorMessage);
                return false;
        }
 return true;
}

//added to hide date selection option, if a user doesn't have permission for not permitter standard filter column
//added to fix the ticket #5117
function standardFilterDisplay()
{
	if(getObj("stdDateFilterField"))
	{
		if(document.CustomView.stdDateFilterField.selectedIndex > -1 && document.CustomView.stdDateFilterField.options[document.CustomView.stdDateFilterField.selectedIndex].value == "not_accessible")
		{
			getObj('stdDateFilter').disabled = true;
			getObj('startdate').disabled = true;                                                                                         getObj('enddate').disabled = true;
			//getObj('jscal_trigger_date_start').style.visibility="hidden";
			//getObj('jscal_trigger_date_end').style.visibility="hidden";
		}
		else
		{
			getObj('stdDateFilter').disabled = false;
			getObj('startdate').disabled = false;
			getObj('enddate').disabled = false;
			//getObj('jscal_trigger_date_start').style.visibility="visible";
			//getObj('jscal_trigger_date_end').style.visibility="visible";
		}
	}
}
function ProductDetailmoveUp()
{
var elem = document.getElementById('selectedAssmablyColumns');
    if(elem.options.selectedIndex>=0){
    	for (var i=1;i<elem.options.length;i++){
    		if(elem.options[i].selected == true){
    			//swap with one up
    			var first = elem.options[i-1];
    			var second = elem.options[i];
    			var temp = new Array();
    
    			temp.value = first.value;
    			temp.innerHTML = first.innerHTML;
    
    			first.value = second.value;
    			first.innerHTML = second.innerHTML;
    
    			second.value = temp.value;
    			second.innerHTML = temp.innerHTML;
    
    			first.selected = true;
    			second.selected = false;
    		}
    	}
    }
}
//上移 XUQIU1001802 xxy 2023-8-17 序时簿列表--查询分类--增加多选、多选上下移动
function ProductDetailCheckBoxmoveUp(){
	var elem = document.getElementById('selectedAssmablyColumns');
	var options = elem.getElementsByClassName('commonSelect');
	
	var selectedOptions = [];// 存储所有选中的元素
	for (var i = 0; i < options.length; i++) {
		var inputElem = options[i].getElementsByTagName('input')[0];
		if (inputElem.checked == true) {
			selectedOptions.push(options[i]);
		}
	}
	//检查是否选中的元素中首个已经是第一个，如果是则不进行上移操作
	if (selectedOptions.length == 0 || selectedOptions[0] == options[0]) {
		return;
	}
	for (var i = 0; i < selectedOptions.length; i++) {
		var current = selectedOptions[i];
		var previous = current.previousElementSibling;

		if (previous) {
			elem.insertBefore(current, previous);
			current.getElementsByTagName("input")[0].checked = true;
			previous.getElementsByTagName("input")[0].checked = false;
		}
	}
}
//下移
function ProductDetailCheckBoxmoveDown(){
	var elem = document.getElementById('selectedAssmablyColumns');
	var options = elem.getElementsByClassName('commonSelect');

	var selectedOptions = [];
	for (var i = 0; i < options.length; i++) {
		var inputElem = options[i].getElementsByTagName('input')[0];
		if (inputElem.checked == true) {
			selectedOptions.push(options[i]);
		}
	}
	
	// 检查是否选中的元素已经是最后一个，如果是则不进行下移操作
	if (selectedOptions.length === 0 || selectedOptions[selectedOptions.length - 1] === options[options.length - 1]) {
		return;
	}

	// 从底部开始遍历选中的元素，并一一下移
	for (var i = selectedOptions.length - 1; i >= 0; i--) {
		var current = selectedOptions[i];
		var next = current.nextElementSibling;
		elem.insertBefore(next, current);
		current.getElementsByTagName('input')[0].checked = true;
		next.getElementsByTagName('input')[0].checked = false;
	}
}
function SaveProductListView(obj,module)
{
    var productinfo = '';
    var selobj=document.getElementById('selectedAssmablyColumns');
    var pagewidth = document.getElementById('PageWidthPercent').value;
    if(pagewidth == "" || pagewidth == null)
    {
        //页面宽度百分比不能为空！
        alert(arrJsPopLabel['PERCENTAGEWIDTHCANOTEMPTY']);
        return false;
    }
    if(isNaN(pagewidth))
    {
        //页面宽度百分比只能为数字！
        alert(arrJsPopLabel['PERCENTAGEONLYDIGITAL']);
        return false;
    }
    if(selobj.options.length == 0)
    {
        //至少选择一项！
        alert(arrJsPopLabel['SELECTATLEASTONE']);
        return false;
    }
    
    for (var i=0;i<selobj.options.length;i++)
    {
        productinfo+=selobj.options[i].value+",";
    }
    //alert('action=ListView&ajax=true&module='+module+'&submode=SaveProductView&PageWidthPercent='+pagewidth+'&searchtype=advSearch&ProductListViewString='+productinfo);
    new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: 'action=ListView&ajax=true&module='+module+'&submode=SaveProductView&PageWidthPercent='+pagewidth+'&searchtype=advSearch&ProductListViewString='+productinfo,
                    onComplete: function(response) {
					   var results=response.responseText.split("###SUCCESS###");
                        //$("UseReportList").innerHTML=results[1];
						puyoungJS_DialogBox.unblock();
                        fninvsh('productlistview');
                        window.location.href="index.php?module="+module+"&action=index&parenttab=Sales";
                    }
            }
    );
    
}
//40386: 系统设置->单据分录定制->排序，下移功能无法使用
//function ProductDetailmoveDown()
//{
//var elem = document.getElementById('selectedAssmablyColumns');
//	if(elem.options.selectedIndex>=0){
//		for (var i=elem.options.length-2;i>=0;i--){
//			if(elem.options[i].selected == true){
//				//swap with one down
//				var first = elem.options[i+1];
//				var second = elem.options[i];
//				var temp = new Array();
//
//				temp.value = first.value;
//				temp.innerHTML = first.innerHTML;
//
//				first.value = second.value;
//				first.innerHTML = second.innerHTML;
//
//				second.value = temp.value;
//				second.innerHTML = temp.innerHTML;
//
//				first.selected = true;
//				second.selected = false;
//			}
//		}
//	}
//}

/**
 *@edit:andy 
 *@date:20140909
 *@reason:左右选择项改进
 *@version:
 */
 if (document.all)

	var browser_ie=true

else if (document.layers)

	var browser_nn4=true

else if (document.layers || (!document.all && document.getElementById))

	var browser_nn6=true
function copySelectedOptionsCustomviewModule(source, destination) {

    var srcObj =document.getElementById(source);// $(source);
	var destObj =document.getElementById(destination);// $(destination);
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
		if (srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,               
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}
			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie) 
                    newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6) 
                    newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)//右键
				srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null) 
                    existingObj.selected=true
			}
		}
	}
}
//2023-7-11 xxy option全换成checkbox和label XUQIU1001609 PC端-数据分类，选择显示字段优化（需求）
function copySelectedCheckboxCustomviewModule(source, destination, moveaction) {
    var srcObj = ld("#"+source);// $(source);
	var destObj =ld("#"+destination);// $(destination);
	srcObj_len = srcObj.children().length;
	destObj_len = destObj.children().length;
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj_len;i++){
		destObj.find("input").prop("checked", false);
		destObj.prev().find("input").prop("checked", false);
    }
    ld.each(srcObj.children(),function(){
		if (ld(this).find("input").is(":checked")==true) {
			var rowFound=false;
			var existingObj=null;
			var that = this;
			ld.each(destObj.children(),function(){
				if (ld(this).find("label").attr('value')==ld(that).find("label").attr('value')) {
                    ld(that).children().remove();//无论默认有无，都去掉该备选项 ,               
					rowFound=true;
					existingObj=ld(this).find("input");
					return false;
				}
			})
			if (rowFound!=true) {
				newColObj_value=ld(this).find("label").attr('value');
				if (browser_ie) {
                    newColObj_text=ld(this).find("label").text();
				}
				else if (browser_nn4 || browser_nn6) {
					newColObj_text=ld(this).find("label").text();
				}
				if(moveaction == 'moveright'){ //右移
					newColObj_html='<div class="ld-category-draggable commonSelect">'
									+'<input id="'+newColObj_text+'" type="checkbox">'
									+'<label value="'+newColObj_value+'" style="margin-left: 8px;" for="'+newColObj_text+'">'+newColObj_text+'</label>'
									+'<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="'+arrJsPopLabel["DRAGTOSORT"]+'"  data-direction="top" data-type="position" style="float: right;margin-top: -26px;cursor: move;display:none;"></a></div>'
									+'</div>';
				}else if(moveaction == 'moveleft'){ //左移
					newColObj_html='<div class="ld-category-draggable commonSelect">'
									+'<input id="'+newColObj_text+'" type="checkbox">'
									+'<label value="'+newColObj_value+'" style="margin-left: 8px;" for="'+newColObj_text+'">'+newColObj_text+'</label>'
									+'<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="'+arrJsPopLabel["MoveRightToDisplay"]+'"  data-direction="top" data-type="position" style="float: right;margin-top: -26px;cursor: move;display:none;"></a></div>'
									+'</div>';
				}
				ld(destObj).append(newColObj_html)//右键
				ld("table[class='settingPopTable lasttdbordernon']").find("div[name='selectedAssmablyColumns'],div[name='AssmablyList']").children().hover(function() {//重新绑定拖动图标的hover
					ld('.ld-dragicon').hide();
					ld(this).find('.ld-dragicon').show();
				});
				ld("table[class='settingPopTable lasttdbordernon']").find("div[name='selectedAssmablyColumns'],div[name='AssmablyList']").children().mouseleave(function(){
					ld(this).find('.ld-dragicon').hide();
				});
				ld(this).find("input").prop("checked", false);
                ld(this).remove();
                i=-1;
				ld(destObj).find('label:last').focus();
				ld(destObj).find('input:last').prop("checked",true);
				// newColObj.selected=true
				rowFound=false;
                DataCategoryListPopup.MultipleSelectionFields();
				tooltip('.sort-tip-items', {transition: true, time: 200});
			} else {
				if(existingObj != null) 
                    existingObj.prop("checked",true);
			}
		}
	})
}
//全选
function selectallcheckboxCustomviewModule(obj){
	if(ld(obj).is(":checked")==true){
		ld.each(ld(obj).parent().next(),function(index,allobj){
			ld(allobj).find("input").prop("checked",true);
		})
	}else{
		ld(obj).parent().next().find("input").prop("checked",false);
	}
}
//双击移动点击事件
function addColumnCheckBoxCustomview(source,destination,event) 
{
	var tmp_destination = destination;
    var source = document.getElementById(source);
    var destination = document.getElementById(destination);
    // 获取source div
    var availListObj = source.getElementsByClassName("commonSelect");
    for (var i = 0; i < availListObj.length; i++) {
        // 被选中元素的父级div
        if (event.target.parentNode == availListObj[i]) {
			targetObj = availListObj[i];
			source.removeChild(targetObj);
			destination.appendChild(targetObj);
			break;
        }
    }
	ld(destination).find('label:last').focus();
	ld(destination).find('input:last').prop("checked",true);
	if(tmp_destination == 'selectedAssmablyColumns'){
		ld(targetObj).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['DRAGTOSORT'])
	}else{
		ld(targetObj).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['MoveRightToDisplay'])
	}
}


/**
 *@edit:andy 
 *@date:
 *@reason:左右结构点击事件
 *@version:
 */
function addColumnCustomviewModule(source, destination) 
{
    var availListObj=getObj(source)
    var selectedColumnsObj=getObj(destination)


    for (i=0;i<availListObj.length;i++) 
    {
        if (availListObj.options[i].selected==true) 
        {            	
        	var rowFound=false;
        	var existingObj=null;
            for (j=0;j<selectedColumnsObj.length;j++) 
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                {
                    rowFound=true
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true) 
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                newColObj.selected=true
                availListObj.remove(i);//20140902，diony，右移时删除左边信息
                rowFound=false
            } 
            else 
            {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
}
//Function to Set the status as Approve/Deny for Public access by Admin
function ChangeCustomViewStatus(viewid,now_status,changed_status,module,parenttab)
{
	$('status').style.display = 'block';
	new Ajax.Request(
       		'index.php',
               	{queue: {position: 'end', scope: 'command'},
               		method: 'post',
                    postBody:'module=CustomView&action=CustomViewAjax&file=ChangeStatus&dmodule='+module+'&record='+viewid+'&status='+changed_status,
					onComplete: function(response) 
					{
			        	var responseVal=response.responseText;
						if(responseVal.indexOf(':#:FAILURE') > -1) {
							alert('Failed');
						} else if(responseVal.indexOf(':#:SUCCESS') > -1) {
							var values = responseVal.split(':#:');
							var module_name = values[2];
							var customview_ele = $('viewname');
							showDefaultCustomView(customview_ele, module_name, parenttab,customview_ele.value);
						} else {
							$('ListViewContents').innerHTML = responseVal;
						}
						$('status').style.display = 'none';
					} 
				}
	);
}


//高级查询

function HigherSearchGroup(parentNodeName)
{
    this.parentNodeName=parentNodeName;
    this.btn_addnewcondtiontext='添加条件';//新条件
    this.btn_addnewcombinationtext="添加组合条件";
    
    this.searchandlabel=arrJsPopLabel['SEARCHAND'];
    this.searchorlabel=arrJsPopLabel['OR'];
    this.columns_block="";//查询字段下拉框
    this.source='customview';//
    this.foption="";//查询条件
    this.advft_column_index_count = -1;
    this.advft_group_index_count=0;
    this.advft_group_index_num=0; //统计查询条件数量
    this.column_index_array=[];
    this.group_index_array = [];
    this.from_searchtype; //判断是否为自动提醒的高级查询
    this.fLabels=[];
    this.first=0;
}
HigherSearchGroup.prototype.addConditionGroup=function() {

    var popupobj=CrmPopup.getPopupObj("last");
    
	for(var i=this.group_index_array.length - 1; i>=0; --i) {
		var prevGroupIndex =this.group_index_array[i];
		if(CrmPopup.isExistsObj(popupobj.divid,'conditiongroup_'+prevGroupIndex)) {
			this.addGroupConditionGlue(prevGroupIndex);
			break;
		}
	}

	var groupIndex = this.advft_group_index_count+1;
	var parentNode = ld("#"+popupobj.divid+" [name='"+this.parentNodeName+"']");
  
	var newNode = document.createElement('div');
	newNodeId = 'conditiongroup_'+groupIndex;
  	//newNode.setAttribute('id',newNodeId);
  	newNode.setAttribute('name',newNodeId);

  	newNode.innerHTML = "<table class='settingPopTable' border='0' cellpadding='0' cellspacing='1' width='100%' name='conditiongrouptable_"+groupIndex+"'>"+
							"<tr name='groupheader_"+groupIndex+"'>"+
								"<td colspan='5' align='right' style='height:24px;'>"+
									"<a class='icon-homeimg icon-close' href='javascript:void(0);' title='"+arrJsPopLabel['DELETECOMBINATION']+"' onclick='CrmPopup.getPopupObj(\"last\").highersearchobj.deleteGroup(\""+groupIndex+"\");'></a>"+
								"</td>"+
							"</tr>"+
							"<tr name='groupfooter_"+groupIndex+"'>"+
								"<td colspan='5' align='left'>"+
									"<a href='javascript:void(0);' onclick='CrmPopup.getPopupObj(\"last\").highersearchobj.addConditionRow(\""+groupIndex+"\")'>"+this.btn_addnewcondtiontext+"</a>"+
								"</td>"+
							"</tr>"+
						"</table>"+
						
						"<table class='settingPopTable' border='0' cellpadding='0' cellspacing='0' width='100%'>"+
							"<tr><td align='center' name='groupconditionglue_"+groupIndex+"'>"+
							"</td></tr>"+
						"</table>";
						

	parentNode.append(newNode);

	this.group_index_array.push(groupIndex);
	this.advft_group_index_count++;
}

HigherSearchGroup.prototype.addGroupConditionGlue=function(groupIndex) {

    var popupobj=CrmPopup.getPopupObj("last");

	var groupConditionGlueElement = ld("#"+popupobj.divid+" [name='groupconditionglue_"+groupIndex+"']");
   //添加组合
	if(groupConditionGlueElement) {
		groupConditionGlueElement.html( "<select name='gpcon"+groupIndex+"' id='gpcon"+groupIndex+"' class='ld-select-inner width60'>"+
												"<option value='and'>"+this.searchandlabel+"</option>"+
												"<option value='or'>"+this.searchorlabel+"</option>"+
											"</select>");
	}
}


HigherSearchGroup.prototype.addConditionRow=function(groupIndex) {
	let that = this;
    var popupobj=CrmPopup.getPopupObj("last");
	var groupColumns = this.column_index_array[groupIndex];

	if(typeof(groupColumns) != 'undefined') {
		for(var i=groupColumns.length - 1; i>=0; --i) {
			var prevColumnIndex = groupColumns[i];
           
			if(CrmPopup.isExistsObj(popupobj.divid,'conditioncolumn_'+groupIndex+'_'+prevColumnIndex)) {
				this.addColumnConditionGlue(prevColumnIndex);
				break;
			}
		}
	}

	var columnIndex = this.advft_column_index_count+1;
    this.advft_group_index_num++;
	var nextNode = CrmPopup.findHtmlobj(popupobj.divid,'groupfooter_'+groupIndex) ;

	var newNode = document.createElement('tr');
	newNodeId = 'conditioncolumn_'+groupIndex+'_'+columnIndex;
  	//newNode.setAttribute('id',newNodeId);
  	newNode.setAttribute('name',newNodeId);

    nextNode.before(newNode);

	if(that.source === "PricePolicy_RoleModule") {
		let popObj = CrmPopup.getPopupObj('lastprev'),
			editObj = PricePolicy.getInstance(popObj).getEditInstance();
		ld(newNode).append(editObj.getModuleScopeFirstTd(that.moduleList,columnIndex))
	}

	node1 = document.createElement('td');
	// node1.setAttribute('class', 'dvtCellLabel noborder a');
    node1.setAttribute('align', 'left');
	node1.setAttribute('width', '25%');
	
	if (this.source == 'reports' || this.source == 'usereports')
		node1.innerHTML = '<select name="fcol'+columnIndex+'" id="fcol'+columnIndex+'" onchange="CrmPopup.getPopupObj(\"last\").highersearchobj.updatefOptions(this, \'fop'+columnIndex+'\');CrmPopup.getPopupObj(\"last\").highersearchobj.addRequiredElements('+columnIndex+');CrmPopup.getPopupObj(\"last\").highersearchobj.clearKeywordsinput('+columnIndex+');CrmPopup.getPopupObj(\"last\").highersearchobj.updateRelFieldOptions(this, \'fval_'+columnIndex+'\');" class="ld-select-inner gwidth100">'+
							'<option value="">--'+jsnone+'--</option>'+
	        				this.columns_block+
						'</select>';
	else
		node1.innerHTML = "<select name='fcol"+columnIndex+"'  id='fcol"+columnIndex+"' onchange='CrmPopup.getPopupObj(\"last\").highersearchobj.updatefOptions(CrmPopup.findHtmlobj(CrmPopup.getPopupObj(\"last\").divid,\"fcol"+columnIndex+"\"), \"fop"+columnIndex+"\");CrmPopup.getPopupObj(\"last\").highersearchobj.addRequiredElements("+columnIndex+");CrmPopup.getPopupObj(\"last\").highersearchobj.clearKeywordsinput("+columnIndex+");' class='ld-select-inner gwidth100'>"+
							"<option value=''>--"+jsnone+"--</option>"+
	        				this.columns_block+
						"</select>";

	newNode.appendChild(node1);

	node2 = document.createElement('td');
	// node2.setAttribute('class', 'dvtCellLabel noborder b');
    node2.setAttribute('align', 'left');
	node2.setAttribute('width', '20%');
	newNode.appendChild(node2);
    //查询条件下拉框
	node2.innerHTML = '<select name="fop'+columnIndex+'" id="fop'+columnIndex+'" class="width100 ld-select-inner" onchange="CrmPopup.getPopupObj(\'last\').highersearchobj.addRequiredElements('+columnIndex+');">'+
							'<option value="">--'+jsnone+'--</option>'+
						    this.foption+
						'</select>';

	node3 = document.createElement('td');
	// node3.setAttribute('class', 'dvtCellLabel noborder c');
    node3.setAttribute('align', 'left');
	newNode.appendChild(node3);

	if (this.source == 'reports' )
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="">'+
						'<img height=20 width=20 style="cursor: pointer;" title="'+arrJsPopLabel['FIELDCOMPARE']+'" alt="'+arrJsPopLabel['FIELDCOMPARE']+'" src="themes/images/terms.png" onClick="hideAllElementsByName(\'relFieldsPopupDiv\'); fnvshobj(this,\'show_val'+columnIndex+'\');"/>'+
						'<input style="display:none;" class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="CrmPopup.findHtmlObj(CrmPopup.getPopupObj(\"last\").divid,\'fval'+columnIndex+'\').val();return false;" title="'+arrJsPopLabel['CLEAR']+'"/>'+
						'<div class="full-menu" name="show_val'+columnIndex+'" style="position: absolute; width:300px; z-index: 50; display: none;">'+
                        '<table width="300" cellspacing="0" cellpadding="0" border="0" class="full-menu-table-wrapper">'+
                        	'<tbody><tr><td>'+
                                '<table width="100%" align="center" cellspacing="0" cellpadding="0" border="0" class="full-menu-table">'+
                                    '<thead>'+
                                    '<tr>'+
                                        '<td colspan="5" class="divPeople-HeadBg">'+
                                        '<div>'+
                                            '<div style="float:left;">'+
                                                '<span class="divPeople-Imgico">'+
                                                    '<img src="themes/softed/tier/logo.png" >'+
                                                '</span>'+
                                                '<span class="divPeople-Head">'+arrJsPopLabel['USINGFIELD']+'</span>'+
                                            '</div>'+
                                            '<div class="divPeople-ImgClose">'+
                                                '<a onclick="hideAllElementsByName(\'relFieldsPopupDiv\');">'+
                                                    '<img src="themes/softed/tier/close.png">'+
                                                '</a>'+
                                            '</div>'+
                                        '</div>'+
                                        '</td>'+
                                    '</tr>'+
                                    '</thead>'+
                                '<tbody align="center">'+
										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="small">'+
											'<tr>'+
												'<td>'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" bgcolor="white" class="small">'+
														'<tr>'+
															'<td width="30%" align="left" class="cellLabel small">'+arrJsPopLabel['ATTRIBUTEFIELD']+'</td>'+
															'<td width="30%" align="left" class="cellText">'+
																'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" class="ld-select-inner">'+
																	'<option value="">--'+jsnone+'--</option>'+
													        		this.rel_fields+
												        		'</select>'+
															'</td>'+
														'</tr>'+
													'</table>'+
												'</td>'+
											'</tr>'+
										'</table>'+
                                        '<tr>'+
                                            '<td class="divStorey-Bottom">'+
                                                '<a class="Save-button" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');">'+arrJsPopLabel['Execution']+'</a>'+
                                            '</td>'+
                                        '</tr>'+
                                        '</tbody>'+
                                '</table>'+
                                '</td></tr></tbody></table>'+
									'</td>'+
								'</tr>'+
							'</table>'+
						'</div>';
    else if (this.source == 'usereports')
    node3.innerHTML = '<input name="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="">'+
						
						'<input style="display:none;" class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="document.getElementById(\'fval'+columnIndex+'\').value=\'\';return false;" title="'+arrJsPopLabel['CLEAR']+'"/>'+
						'<div class="layerPopup" id="show_val'+columnIndex+'" name="relFieldsPopupDiv" style="border:0; position: absolute; width:300px; z-index: 50; display: none;">'+
							'<table width="100%" cellspacing="0" cellpadding="0" border="0" align="center" class="mailClient mailClientBg">'+
								'<tr>'+
									'<td>'+
										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="layerHeadingULine">'+
											'<tr background="themes/images/qcBg.gif" class="mailSubHeader">'+
												'<td width=90% class="genHeaderSmall"><b>'+arrJsPopLabel['USINGFIELD']+'</b></td>'+
												'<td align=right>'+
													'<img border="0" align="absmiddle" src="themes/images/Close.png" style="cursor: pointer;diplay:none" alt="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');"/>'+
	          									'</td>'+
											'</tr>'+
										'</table>'+

										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="small">'+
											'<tr>'+
												'<td>'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" bgcolor="white" class="small">'+
														'<tr>'+
															'<td width="30%" align="left" class="cellLabel small">'+arrJsPopLabel['ATTRIBUTEFIELD']+'</td>'+
															'<td width="30%" align="left" class="cellText">'+
																'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" class="ld-select-inner">'+
																	'<option value="">--'+jsnone+'--</option>'+
													        		this.rel_fields+
												        		'</select>'+
															'</td>'+
														'</tr>'+
													'</table>'+
													'<!-- save cancel buttons -->'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" class="layerPopupTransport">'+
														'<tr>'+
															'<td width="50%" align="center">'+
																'<input type="button" style="width: 70px;" value="--'+arrJsPopLabel['NONE']+'--" name="button" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');" class="create" accesskey="X" title="--'+arrJsPopLabel['NONE']+'--"/>'+
															'</td>'+
														'</tr>'+
													'</table>'+
												'</td>'+
											'</tr>'+
										'</table>'+
									'</td>'+
								'</tr>'+
							'</table>'+
						'</div>';
	else
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="width150 commonTextBoxPop" type="text" value="">'+
						'<input style="display:none;" name="clearfval_'+columnIndex+'" class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="CrmPopup.findHtmlobj(CrmPoup.getPopupObj(\"last\").divid,\'fval'+columnIndex+'\').val();return false;" title="'+arrJsPopLabel['CLEAR']+'"/>';
	

    
	node4 = document.createElement('td');
	// node4.setAttribute('class', 'dvtCellLabel noborder d');
    node4.setAttribute('align', 'left');
	//node4.setAttribute('id', 'columnconditionglue_'+columnIndex);
    node4.setAttribute('name', 'columnconditionglue_'+columnIndex);
	node4.setAttribute('width', '60px');
	newNode.appendChild(node4);

	node5 = document.createElement('td');
	// node5.setAttribute('class', 'dvtCellLabel noborder e');
    node5.setAttribute('align', 'left');
	node5.setAttribute('width', '30px');
	newNode.appendChild(node5);
	node5.innerHTML = '<a  href="javascript:;" onclick="CrmPopup.getPopupObj(\'last\').highersearchobj.deleteColumnRow('+groupIndex+','+columnIndex+');" title="'+arrJsPopLabel['DELETE']+'" >'+arrJsPopLabel['DELETE']
						'</a>';

	//edit: xll 20/11/14 BUG0074940 企业微信移动端，报表->测试单折线图 点击“筛选”操作按钮没有反应
	var select_width = 180;
	var window_width = CrmPopup.getClientWidth();
	if(window_width < 800){
		var td_width = (window_width - 40) / 3;
		node1.setAttribute('width', td_width+'px');
		node2.setAttribute('width', td_width+'px');
		node3.setAttribute('width', td_width+'px');
		node4.setAttribute('width', '10px');
		node5.setAttribute('width', '30px');
		select_width = parseInt(td_width - 15);
	}

	//wym 230505 高级查找添加搜索功能
	var popupobj = CrmPopup.getPopupObj("last");
	var selectname = 'fcol'+columnIndex;
	if(ld("#"+popupobj.divid + ' #'+selectname).length>0){
		var selObj = ld("#"+popupobj.divid + ' #'+selectname);
		var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
		cls_resetComboxHtmlobj.setPopupObj(popupobj);
		cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,selObj.parents('td').first().width() - 15);
	}
  
	if(CrmPopup.isExistsObj(popupobj.divid,'fcol'+columnIndex)) 
            this.updatefOptions(CrmPopup.findHtmlobj(popupobj.divid,'fcol'+columnIndex), 'fop'+columnIndex);
	if(typeof(this.column_index_array[groupIndex]) == 'undefined') 
        this.column_index_array[groupIndex] = [];
	this.column_index_array[groupIndex].push(columnIndex);
	this.advft_column_index_count++;
    this.showhidetabletitle();

}

var jsnone='无';
HigherSearchGroup.prototype.addColumnConditionGlue=function(columnIndex) {
    var popupobj=CrmPopup.getPopupObj("last");
    
	var columnConditionGlueElement = CrmPopup.findHtmlobj(popupobj.divid,'columnconditionglue_'+columnIndex);

	if(columnConditionGlueElement) {
		columnConditionGlueElement.html("<select name='fcon"+columnIndex+"' class='ld-select-inner'>"+
													"<option value='and'>"+this.searchandlabel+"</option>"+
													"<option value='or'>"+this.searchorlabel+"</option>"+
												"</select>");
	}
}
HigherSearchGroup.prototype.showhidetabletitle=function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    
    var conditiongroups=ld("#"+popupobj.divid).find("div[name^='conditiongroup']");
   var show='no';
    conditiongroups.each(function(){
        var tableobj=ld(this).find("table[name^='conditiongrouptable']");
       
        if(tableobj.find("tr").length>=4)
        {
            CrmPopup.findHtmlobj(popupobj.divid,"datacategory_tabletitle").find("li:last").css("display","");
            show='yes';
            return false;
        }
    });
    if(show=='no')
    {
        CrmPopup.findHtmlobj(popupobj.divid,"datacategory_tabletitle").find("li:last").css("display","none");
    }
}

HigherSearchGroup.prototype.deleteColumnRow=function(groupIndex, columnIndex) {
	this.removeElement('conditioncolumn_'+groupIndex+'_'+columnIndex);
	var groupColumns = this.column_index_array[groupIndex];
	var keyOfTheColumn = groupColumns.indexOf(columnIndex);
	var isLastElement = true;
	var popupobj=CrmPopup.getPopupObj("last");
    
	for(var i=keyOfTheColumn; i<groupColumns.length; ++i) {
		var nextColumnIndex = groupColumns[i];
		var nextColumnRowId = 'conditioncolumn_'+groupIndex+'_'+nextColumnIndex;
		if(CrmPopup.isExistsObj(popupobj.divid,nextColumnRowId)) {
			isLastElement = false;
			if(ld("#"+popupobj.divid).find("select[name^='fcon']").length < 1){
				ld('#advfiltershow').css('display','none');
			}
			break;
		}
	}
    
    
	if(isLastElement) {
		for(var i=keyOfTheColumn-1; i>=0; --i) {
			var prevColumnIndex = groupColumns[i];
			var prevColumnGlueId = "fcon"+prevColumnIndex;
			if(CrmPopup.isExistsObj(popupobj.divid,prevColumnGlueId)) {
				this.removeElement(prevColumnGlueId);
				if(ld("#"+popupobj.divid).find("select[id^='fcon']").length < 1){
					ld('#advfiltershow').css('display','none');
				}
				break;
			}
		}
	}
   //edit:duan  如果总条件数量为0,且类型为自动提醒，则新增空条件，避免查询区块消失
   this.advft_group_index_num--;
   if(this.advft_group_index_num==0 && this.from_searchtype!=undefined && this.from_searchtype=='AutomaticReminds')
       this.addConditionRow(groupIndex);
    //ld("#conditiongrouptable_"+groupIndex+" .deleteauto").click();
   // alert(ld("#conditiongrouptable_"+groupIndex+" tr").length);
   //高级查询>添加新组合：填写数据，当第一行的内容删除时第一行下面的下拉框中的内容也清除。
   if( ld("#"+popupobj.divid +" [name=conditiongrouptable_"+groupIndex+"] tr").length<=2)
       this.deleteGroup(groupIndex);
   this.showhidetabletitle();
}

HigherSearchGroup.prototype.removeElement=function(elementId) {
    var popupobj=CrmPopup.getPopupObj("last");
    
	var element = CrmPopup.findHtmlobj(popupobj.divid,elementId);
	if(element) {
		element.remove();
	}
}
HigherSearchGroup.prototype.deleteGroup=function(groupIndex) {
	this.removeElement('conditiongroup_'+groupIndex);
	var popupobj=CrmPopup.getPopupObj("last");
    
	var keyOfTheGroup = this.group_index_array.indexOf(groupIndex);
	var isLastElement = true;
	
	for(var i=keyOfTheGroup; i<this.group_index_array.length; ++i) {
		var nextGroupIndex = this.group_index_array[i];
		var nextGroupBlockId = "conditiongroup_"+nextGroupIndex;
		if(CrmPopup.isExistsObj(popupobj.divid,nextGroupBlockId)) {
			isLastElement = false;
			break;
		}
	}
	
	
	if(isLastElement) {
		for(var i=keyOfTheGroup-1; i>=0; --i) {
			var prevGroupIndex = this.group_index_array[i];
			var prevGroupGlueId = "gpcon"+prevGroupIndex;
			if(CrmPopup.isExistsObj(popupobj.divid,prevGroupGlueId)) {
				this.removeElement(prevGroupGlueId);
				break;
			}
		}
	}	
}
HigherSearchGroup.prototype.updateRelFieldOptions=function(sel, opSelName) {
    var popupobj=CrmPopup.getPopupObj("last");
    
    var selObj = CrmPopup.findHtmlobj(popupobj.divid,opSelName);//下拉框
    var fieldtype = null ;

    var currOptionvalue = selObj.val();
    var currFieldvalue = sel.val();

    if(currFieldvalue != null && currOptionvalue.length != 0)
    {
    	fieldtype = trimfValues(currOptionvalue);
    	 var ops = this.rel_fields[fieldtype];
    
    	var off = 0;
    	if(ops != null)
    	{
    		var nMaxVal = selObj.find("option").length;
    		
            selObj.empty();
    		selObj.append("<option>"+alert_arr.LBL_NONE+"</option>");
            
    		if (currFieldvalue == '') {
    		   selObj.val("");
    		}
    		off = 1;
    		for (var i = 0; i < ops.length; i++)
    		{
    			var field_array = ops[i].split("::");
    			var label = field_array[1];
    			var field = field_array[0];
    			if (label == null) continue;
              
    	           	selObj.append("<option value='"+label+"'>"+label+"</option>");
    		    	//selObj.options[i + off] = option;
    			if (currOptionvalue != null && currOptionvalue == label)
    			{
    			     selObj.val(currOptionvalue);
    				//option.selected = true;
    			}
    		}
    	}
    }
    else
    {
        selObj.empty();
    	var nMaxVal = selObj.length;
    	 selObj.append("<option>"+alert_arr.LBL_NONE+"</option>");
          selObj.val("");
    		
    }

}
HigherSearchGroup.prototype.isExistsDateTimeStr=function(value)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var isexists='no';
    ld.each(popupobj.datetimestr,function(key,resultobj){
            if(value==key)
            {
                isexists='yes';
                return false ;
            }
    });
    
    return isexists;
}
HigherSearchGroup.prototype.setSearchValue=function(searchvalue)
{
    this.searchvalue=searchvalue;
}
HigherSearchGroup.prototype.addRequiredElements=function(columnindex) {
    var popupobj=CrmPopup.getPopupObj("last");
	var colObj = CrmPopup.findHtmlobj(popupobj.divid,'fcol'+columnindex);//下拉框字段
	var opObj =  CrmPopup.findHtmlobj(popupobj.divid,'fop'+columnindex); //查询条件下拉框
    var valObj =CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex);   //查询内容
	//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
	var value = valObj.val();
    if(colObj==undefined ||colObj==null ||opObj==undefined || opObj==null) {
         return;
	}
    // hzx 2023/10/31 BUG0072295 kfbcrm-工作流程定制-当选择触发条件为“是空值”“不是空值”“有改变”时，去掉后边的关键字输入框
	// wym 2023/11/10 BUG0075323 kfbcrm-客户-工作流程定制-设置触发条件为“客户来源 有改变”时，应不显示关键字输入框
    if(opObj.val() == 'isnull' || opObj.val() == 'isnotnull'|| opObj.val() == 'has_changed' || opObj.val() == 'curuser'){
		valObj.css('display','none');
		valObj.siblings('.icon-clear').css('display','none');
		valObj.siblings('.Wdate').css('display','none');
		return;
	}else{
		valObj.css('display','');
		valObj.siblings('.icon-clear').css('display','');
	}
	if(!colObj.is(":checked") ) {
		//return ;
	}
	var currFieldvalue = colObj.val();
    var currOpvalue = opObj.val();
    var fieldtype = null ;
    if(currFieldvalue != null && currFieldvalue.length != 0) {
		var fieldInfo = currFieldvalue.split(":");
		var tableName = fieldInfo[0];
		var fieldName = fieldInfo[2];
		fieldtype = fieldInfo[4];
		//如果选择的是不日期和时间移除日期显示格式
        if(fieldtype!='D'&&fieldtype!='DT'&&fieldtype!='T'){
            var parentObj = valObj.parent();
			parentObj.html("");
           	var node5 = document.createElement('input');
        	node5.setAttribute('type', 'text');
        	node5.setAttribute('class', 'width150 commonTextBoxPop');
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
                if(e.keyCode==13) {
                    if(gVTModule=='OftenUseReport')
						generateReport(node5);
                    return false;
                }
            }
            parentObj.append(node5);
        }else{
            //直接删除onclick事件，时间和日期切换的时候，控件无法自动切换，先删除橡皮擦，新增个时间或日期输入框，再删除老的输入框
            if(CrmPopup.isExistsObj(popupobj.divid,'fval_ext'+columnindex)) {
				//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
				var fval_ext_value = CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).val();
				this.removeElement('fval_ext'+columnindex);
			}
            if(CrmPopup.isExistsObj(popupobj.divid,'clear_text_ext'+columnindex)) //清除查询内容文本框
                this.removeElement('clear_text_ext'+columnindex);
            var timeformat = " %H:%M:%S";
            var showtime = ' HH:mm:ss';
            if(fieldtype == 'D' || (tableName == 'ld_activity' && fieldName == 'date_start')) {
                timeformat = '';
                showtime = '';
            }
			valObj = CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex);//查询内容
			var parentObj = valObj.parent();
			if(CrmPopup.isExistsObj(popupobj.divid,'fval'+columnindex))
                this.removeElement('fval'+columnindex);
			if(CrmPopup.isExistsObj(popupobj.divid,'clearfval_'+columnindex)) //清除查询内容文本框
                this.removeElement('clearfval_'+columnindex);
          	var node5 = document.createElement('input');
            node5.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'",alwaysUseStartDate:true})');
        	node5.setAttribute('class', 'Wdate btn-radius-system WdateImage maxWidth160');
        	node5.setAttribute('type', 'text');
        	//node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
			node5.setAttribute('style','height:30px;margin-right: 10px;');
			//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
			if(value!=undefined){
				node5.setAttribute('value',value);
			}
			parentObj.append(node5);
        }
		switch(fieldtype) {
			case 'D':
			case 'DT':
			case 'T':
				if(fieldtype=='T' && tableName.indexOf('ld_crmentity')<0){
					this.defaultRequiredElements(columnindex);
					break;
				}
                //edit:can 2020-11-17 43325: （https://61mis.com/kfbtest [^]）客户问题（王杰），自动提醒设置，客户新增界面，数据范围设置“下次回访日期”，比较关系选择“今天”，没有自动带出日期（需要补丁）
				var dateformat ="YYYY-mm-dd";// $('jscal_dateformat').value;
				var timeformat = " %H:%M:%S";
				var showtime = ' HH:mm:ss';
				if(fieldtype == 'D' || (tableName == 'ld_activity' && (fieldName == 'date_start' || fieldName == 'due_date'))) {
					timeformat = '';
					showtime = '';
				}
				var isexistsdatestr=this.isExistsDateTimeStr(currOpvalue);
				if(currOpvalue == 'bw'||isexistsdatestr=='yes' ) {
					if(!CrmPopup.isExistsObj(popupobj.divid,'fval_ext'+columnindex)) {
						//var fillernode = document.createElement('br');
						var node1 = document.createElement('input');
						node1.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'",alwaysUseStartDate:true})');
						node1.setAttribute('class', 'Wdate btn-radius-system WdateImage maxWidth160');
						node1.setAttribute('type', 'text');
						node1.setAttribute('id','fval_ext'+columnindex);
						node1.setAttribute('name','fval_ext'+columnindex);
						node1.setAttribute('style','height:30px;');
						//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
						if(fval_ext_value!=undefined){
							node1.setAttribute('value',fval_ext_value);
						}
						//parentObj.appendChild(fillernode);
						parentObj.append(node1);
					}
					if(isexistsdatestr=='yes') {
						var resultobj=popupobj.datetimestr;//eval('.popupobj.datatimestr.');
						//本年，明年，n天后，n天前等
						CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).attr("disabled","true");
						CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).attr("disabled",'true');
						for(var timekey in popupobj.datetimestr) {
							if(timekey==currOpvalue){
								if(fieldtype=='DT') {
									 CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val( resultobj[timekey][0]+" 00:00:00");
									 CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).val(resultobj[timekey][1]+" 23:59:59");
								} else {
									CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val( resultobj[timekey][0]);
									 CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).val(resultobj[timekey][1]);
								}
							   break;
							}
						}
					} else {
						CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).removeAttr("readonly");
						CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).removeAttr("readonly");
					}
				} else {
					if(CrmPopup.isExistsObj(popupobj.divid,'fval_ext'+columnindex)) removeElement('fval_ext'+columnindex);
					if(CrmPopup.isExistsObj(popupobj.divid,'jscal_trigger_fval_ext'+columnindex)) removeElement('jscal_trigger_fval_ext'+columnindex);
					if(CrmPopup.isExistsObj(popupobj.divid,'clear_text_ext'+columnindex)) removeElement('clear_text_ext'+columnindex);
				}
				break;
			default	:this.defaultRequiredElements(columnindex);
		}

		if(isexistsdatestr!='yes') {
			//如果日期查询 不是本年，明年等，则显示清除按钮
			var node6 = document.createElement('input');
			node6.setAttribute('type','button');
			node6.setAttribute('align','absmiddle');
			node6.setAttribute('name','clear_text_ext'+columnindex);
			node6.setAttribute('style','display:none');
			node6.setAttribute('class','icon-homeimg icon-clear inpb-advSearchreset');
			node6.style.cursor = "pointer";
			node6.onclick = function() {
				CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val("");
				CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).val("");
				return false;
			}
			parentObj.append(node6);
			//edit: 68631 can 自动提醒设置问题
			if(this.searchvalue!=undefined){ //wym XUQIU1002478 不加这个判断，每次给关键字赋的值都会被覆盖为空
				CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val(this.searchvalue);
			}
		}
		//wym BUG0075492 kfbcrm-首页-报表组件穿透弹出层中，高级查找，关键字后没有橡皮擦
		CrmPopup.findHtmlobj(popupobj.divid,'clear_text_ext'+columnindex).show();
	}
}

HigherSearchGroup.prototype.clearKeywordsinput=function(columnindex) {//wym XUQIU1002478 高级查找条件--切换选择条件时，关键字填写的值不清空
	var popupobj = CrmPopup.getPopupObj("last");
	if(popupobj!=undefined) {
		ld('#'+popupobj.divid).find("#fval"+columnindex).val('');
		if(ld('#'+popupobj.divid).find("#fval_ext"+columnindex).length>0){
			ld('#'+popupobj.divid).find("#fval_ext"+columnindex).val('');
		}
	}
}

HigherSearchGroup.prototype.defaultRequiredElements=function(columnindex) {
    var popupobj=CrmPopup.getPopupObj("last");
    
    if(CrmPopup.isExistsObj(popupobj.divid,'jscal_trigger_fval'+columnindex)) 
        this.removeElement('jscal_trigger_fval'+columnindex);
	if(CrmPopup.isExistsObj(popupobj.divid,'fval_ext'+columnindex)) 
        this.removeElement('fval_ext'+columnindex);
	if(CrmPopup.isExistsObj(popupobj.divid,'jscal_trigger_fval_ext'+columnindex)) 
        this.removeElement('jscal_trigger_fval_ext'+columnindex);
	if(CrmPopup.isExistsObj(popupobj.divid,'clear_text_ext'+columnindex)) 
        this.removeElement('clear_text_ext'+columnindex);
}
/**
添加等于，小于，区间，包含等查询下拉框
**/
HigherSearchGroup.prototype.updatefOptions=function(sel, opSelName) {

    var popupobj=CrmPopup.getPopupObj("last");
   
    var selObj = CrmPopup.findHtmlobj(popupobj.divid,opSelName);
    var fieldtype = null ;
    
	if(selObj==undefined ||selObj==null ||sel==undefined || sel==null)
	{
		return;
	}
	if(!selObj.is(":checked") )
	{
		//return ;
	}
    var currOptionvalue = selObj.val();
    var currFieldvalue = sel.val();    
   
    if(currFieldvalue != null && currFieldvalue.length != 0) {
		fieldtype = trimfValues(currFieldvalue);
		AjaxJSPage('cls_advanceFilter_js','include/js/cls_advanceFilter.js');
		var cls_advanceFilterObj = new cls_advanceFilter();
		var ops = cls_advanceFilterObj.getOptionByType(fieldtype);

		var off = 0;
        
		if(ops != null) {
	
			var nMaxVal = selObj.find("option").length;
            /*
			for(nLoop = 0; nLoop < nMaxVal; nLoop++) {
				selObj.remove(0);
			}*/
            selObj.empty();
           //by LD Can 20121130 none修改为无
			//selObj.options[0] = new Option (jsnone, '');
            selObj.append("<option>"+jsnone+"</option>");
            
			if (currFieldvalue == '') {
				//selObj.options[0].selected = true;
                selObj.val("");
			}
			off = 1;
            var k=0;
           
			for (var i = 0; i < ops.length; i++) {
			 
				var label = this.fLabels[ops[i]];
           
				if (label == null) continue;
               
                if(currFieldvalue.indexOf('publicaccount:publicaccount:Accounts')>0||currFieldvalue.indexOf('currency_id')>0)//客户模块中是否公海字段
                {
                     if(ops[i]!='e'&& ops[i]!='n')
                     {
                        continue;
                     }
                }
                if(currFieldvalue.indexOf('content:content:PublicAnnouncement')>0)//客户模块中是否公海字段
                {
                     if(ops[i]!='c')
                     {
                        continue;
                     }
                }
                if(currFieldvalue.indexOf("conversion_rate")>0)
                {
                     
                     if(ops[i]=='isnull'|| ops[i]=='isnotnull')
                     {
                        continue;
                     }
                }
                
				//var option = new Option (fLabels[ops[i]], ops[i]);
				//selObj.options[k + off] = option;
                selObj.append("<option value='"+ops[i]+"'>"+this.fLabels[ops[i]]+"</option>");
                k++;
				if (currOptionvalue != null && currOptionvalue == ops[i]) {
					//option.selected = true;
                    selObj.val(ops[i]);
				}
			}
			if(fieldtype=='D'||fieldtype=='DT')
           {
                var resultobj=popupobj.datetimestr;//eval('.popupobj.datatimestr.');  
             
                ld.each(popupobj.datetimestr,function(value,resultobj){
                         
                     selObj.append("<option value='"+value+"'>"+resultobj[2]+"</option>");
                    
                                     
                } );
                 
           }
           //zkt 20220518 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
           //获取字段信息
            var popupobj = CrmPopup.getPopupObj("last");
            var fieldsinfo = [];
            if(CrmPopup.global_listPopupObj.length>0){
                for(var i=CrmPopup.global_listPopupObj.length-1;i>=0;i--)
                {

					if (CrmPopup.global_listPopupObj[i].module == popupobj.module && CrmPopup.global_listPopupObj[i].fields != undefined) {
						fieldsinfo = CrmPopup.global_listPopupObj[i].fields;
						break;
					}
					else if(CrmPopup.global_listPopupObj[i].module == popupobj.module && CrmPopup.global_listPopupObj[i].fieldinfo != undefined) {
						fieldsinfo = CrmPopup.global_listPopupObj[i].fieldinfo;
						break;
					}
                }
            }
            if(fieldsinfo.length>0){
                //判断字段类型，若为用户字段类型则条件下拉框增加当前用户
                var string_array = currFieldvalue.split(":");
                var fieldname = string_array[2];
                var tablename = string_array[0];
                ld.each(fieldsinfo,function(index,tmpfieldinfo){
					//231207 wym BUG0076816 “查询分类”-“新建分类”-“设置条件”处，选择“团队成员”字段后，右侧条件下拉框内，不显示“包含当前操作员”
                    var fieldinfo = tmpfieldinfo;
					if(fieldinfo['fieldname']){
						var tmpfieldname=fieldinfo['fieldname'];
					}else{
						var tmpfieldname=fieldinfo['fieldName'];
					}
					if(tmpfieldname==fieldname){
						if(global_multiuser_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
							selObj.append("<option value='curuser'>"+fLabels['includeuser']+"</option>");
						}
						else if(global_user_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
							selObj.append("<option value='curuser'>"+fLabels['curuser']+"</option>");
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
		}
    }
	else {
		if (currFieldvalue == '') {
			//zkt 20240201 BUG20240201-32 kfbcrm-联系人-新建查询分类-不选择字段时 选择条件的下拉框内应只显示“--无--”
			selObj.empty();
			selObj.append("<option>"+jsnone+"</option>");
		}
    }
}

HigherSearchGroup.prototype.addNewConditionGroup=function() {

   var popupobj=CrmPopup.getPopupObj("last");
	this.addConditionGroup();	
	this.addConditionRow(this.advft_group_index_count);
    //zkt 20220830 BUG0054711在金融行业的演示账套中，在销售机会模块--数据分类，添加组合条件的时候，高度增加，为了显示保存会增加一个滑动条。但是滑动条直接滑到最低端。能否在添加组合条件之后界面不会调到最低端，跳转到附件图（BUG0054711、BUG0055777、BUG0055064）
	if(this.first>0&&ld('#'+popupobj.divid).find(' [name=adv_filter_div]')!=undefined && ld('#'+popupobj.divid).find(' [name=adv_filter_div]').length>0)
    {
        var adv_filter_divobj = ld('#'+popupobj.divid).find(' [name=adv_filter_div]');
        var newconditiongroupobj = ld(adv_filter_divobj).find(' div[name=conditiongroup_'+this.advft_group_index_count+']');
        var top = ld(newconditiongroupobj).get(0).offsetTop;
        ld("#"+popupobj.divid+"_scroll").scrollTop(top-10);
    }
    else{
        if(this.first>0)
            ld("#"+popupobj.divid+"_scroll").scrollTop(document.getElementById(popupobj.divid+"_scroll").scrollHeight-400);
    }
    this.first++;
 
}
HigherSearchGroup.prototype.checkAdvancedFilter=function() {

    var popupobj=CrmPopup.getPopupObj("last");
	var escapedOptions = new Array('account_id','contactid','contact_id','product_id','parent_id','campaignid','potential_id','assigned_user_id1','quote_id','accountname','salesorder_id','vendor_id','time_start','time_end','lastname','accountid');
	var conditionColumns=ld("#"+popupobj.divid).find("tr[name^='conditioncolumn']")
	//var conditionColumns = vt_getElementsByName('tr', "conditionColumn");
	var criteriaConditions = [];
    var returnValue=true;
    conditionColumns.each(function(){
        
       	var columnRowId = ld(this).attr("name");
		var columnRowInfo = columnRowId.split("_");
		var columnGroupId = columnRowInfo[1];
		var columnIndex = columnRowInfo[2];
		
		var columnId = "fcol"+columnIndex;//查询字段的下拉框
		var columnObject = CrmPopup.findHtmlobj(popupobj.divid,columnId);
		var selectedColumn = trim(columnObject.val());
		var selectedColumnIndex = columnObject.get(0).selectedIndex;	
		var selectedColumnLabel = columnObject.find("option:selected").text();
		
		var comparatorId = "fop"+columnIndex;//条件下拉框
		var comparatorObject = CrmPopup.findHtmlobj(popupobj.divid,comparatorId);
		var comparatorValue = trim(comparatorObject.val());
		
		var valueId = "fval"+columnIndex;
		var valueObject =  CrmPopup.findHtmlobj(popupobj.divid,valueId);
		var specifiedValue = trim(valueObject.val());
        //alert(specifiedValue);
		
		var extValueId = "fval_ext"+columnIndex;
        if(CrmPopup.isExistsObj(popupobj.divid,extValueId))
		{
		  var extValueObject = CrmPopup.findHtmlobj(popupobj.divid,extValueId);
    		if(extValueObject) {
    			extendedValue = trim(extValueObject.val());
    		}
		}

		//zkt 20231212 BUG0077040 kfbcrm-工作流程定制-触发条件 选择条件为“有改变”，保存会提示输入关键字（需要补丁）
		if(specifiedValue=='' && comparatorValue!=""&&comparatorValue!="无"&&comparatorValue != 'isnull' && comparatorValue != 'isnotnull' && comparatorValue != 'curuser'&& comparatorValue != 'has_changed')
        {
            var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];

			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			returnValue= false;
			return false;
        }
		var glueConditionId = "fcon"+columnIndex;//且或
		var glueConditionObject = CrmPopup.findHtmlobj(popupobj.divid,glueConditionId);
		var glueCondition = '';
		if(glueConditionObject) {
			glueCondition = trim(glueConditionObject.val());
		}
		
		// If only the default row for the condition exists without user selecting any advanced criteria, then skip the validation and return.
		if(conditionColumns.length == 1 && selectedColumn == '' && comparatorValue == '' && specifiedValue == '')
			return true;

		//if (!emptyCheck(columnId," Column ","text"))
      
        if(ld("#"+popupobj.divid+" [name="+columnId+"]").val()!="")
       {
           
      
             if (ld("#"+popupobj.divid+" [name="+comparatorId+"]").val()=="无")
    		{
				 var confirm_str = arrJsPopLabel['CONDITION']+arrJsPopLabel['CANOTEMPTY'];
				 RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

    		     returnValue= false;
                 return false;
    		}
       }
        
		

		var col = selectedColumn.split(":");
		
			if(escapedOptions.indexOf(col[3]) == -1) {
				if(col[4] == 'T' || col[4] == 'DT') {
					var datime = specifiedValue.split(" ");
					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"){
						if(datime.length > 1) {
							if(!re_dateValidate(datime[0],selectedColumnLabel,"OTH")) {
								
                        		  returnValue= false;
                                  return false;
		
							}
							if(!re_patternValidate(datime[1],selectedColumnLabel,"TIMESECONDS")) {
								 returnValue= false;
                                  return false;
							}
						} else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
							if(CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'has_changed'){
								if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
								{
								     returnValue= false;
                                    return false;
								}
							}
						}else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
							if(CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'has_changed'){

								if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
								{
								     returnValue= false;
                                    return false;
								}
							}
						}else if(CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull'&& CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'has_changed'){
						  
							if(!re_patternValidate(datime[0],selectedColumnLabel,"TIMESECONDS")) {
								returnValue= false;
                                return false;
							}
						}
					}

					if(extValueObject) {
						var datime = extendedValue.split(" ");
						if (extendedValue.charAt(0) != "$" && extendedValue.charAt(extendedValue.length-1) != "$"){
							if(datime.length > 1) {
								if(!re_dateValidate(datime[0],selectedColumnLabel,"OTH")) {
									returnValue= false;
                                    return false;
								}
								if(!re_patternValidate(datime[1],selectedColumnLabel,"TIMESECONDS")) {
									returnValue= false;
                                    return false;
								}
							} else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
								if(!dateValidate(extValueId,selectedColumnLabel,"OTH"))
									{
									   returnValue= false;
                                        return false;
									}
							} else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
								if(!dateValidate(extValueId,selectedColumnLabel,"OTH"))
									{
									   returnValue= false;
                                        return false;
									}
							}else {
								if(comparatorValue!='isnull'&&!re_patternValidate(datime[0],selectedColumnLabel,"TIMESECONDS")) {
									returnValue= false;
                                    return false;
								}
							}
						}
					}
				}
				else if(col[4] == 'D')
				{
					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"&& CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'has_changed'){
						if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
						{
						    returnValue= false;
                            return false;
						}
					}
					if(extValueObject) {
						if(!dateValidate(extValueId,selectedColumnLabel,"OTH"))
						{
						    returnValue= false;
                            return false;
						}
					}
				}else if(col[4] == 'I')
				{
					//if(!intValidate(valueId,selectedColumnLabel+i))
					//	{
						    //returnValue= false;
                            return false;
					//	}
				}else if(col[4] == 'N')
				{
					if (!numValidate(valueId,selectedColumnLabel,"any",true))
						{
						    returnValue= false;
                            return false;
						}
				}
			
			}
       
		//Added to handle yes or no for checkbox fields in reports advance filters. 
		if(col[4] == "C") {
			if(specifiedValue == "1")
				specifiedValue = CrmPopup.findHtmlobj(popupobj.divid,valueId).val('yes') ;
			else if(specifiedValue =="0")
				specifiedValue = CrmPopup.findHtmlobj(popupobj.divid,valueId).val('no') ;
		}
		if (extValueObject && extendedValue != null && extendedValue != '') specifiedValue = specifiedValue +','+ extendedValue;
		
		criteriaConditions[columnIndex] = {"groupid":columnGroupId, 
											"columnname":selectedColumn,
											"comparator":comparatorValue,
											"value":specifiedValue,
											"columncondition":glueCondition
										};
        
    });
   
     if(!returnValue)
     {
            return returnValue;
     }
    CrmPopup.findHtmlobj(popupobj.divid,'advft_criteria').val(JSON.stringify(criteriaConditions));
    //document.getElementById('advft_criteria').value = JSON.stringify(criteriaConditions);
	//$('advft_criteria').value = JSON.stringify(criteriaConditions);
	var conditionGroups=ld("#"+popupobj.divid).find("div[name^='conditiongroup']");
	//var conditionGroups = vt_getElementsByName('div', "conditionGroup");
	var criteriaGroups = [];
    conditionColumns.each(function(){
        	var groupTableId = ld(this).attr("name");
            
		var groupTableInfo = groupTableId.split("_");
		var groupIndex = groupTableInfo[1];
		
		var groupConditionId = "gpcon"+groupIndex;
		var groupConditionObject = CrmPopup.findHtmlobj(popupobj.divid,groupConditionId);
		var groupCondition = '';
		if(groupConditionObject) {
			groupCondition = trim(groupConditionObject.val());
		}
		criteriaGroups[groupIndex] = {"groupcondition":groupCondition};
		
    })

    CrmPopup.findHtmlobj(popupobj.divid,'advft_criteria_groups').val(JSON.stringify(criteriaGroups));
    //document.getElementById('advft_criteria_groups').value = JSON.stringify(criteriaGroups);
	//$('advft_criteria_groups').value = JSON.stringify(criteriaGroups);
	return true;
}
//基本查询
function showDateRange( type ) {
    var popupobj=CrmPopup.getPopupObj("last");
    
				if (type!="custom") {
					CrmPopup.findHtmlobj(popupobj.divid,'startdate').attr('readOnly',true);
                    CrmPopup.findHtmlobj(popupobj.divid,'enddate').attr('readOnly',true);
								
				} else {
					CrmPopup.findHtmlobj(popupobj.divid,'startdate').attr('readOnly',false);
                    CrmPopup.findHtmlobj(popupobj.divid,'enddate').attr('readOnly',false);
                    CrmPopup.findHtmlobj(popupobj.divid,'startdate').val("");
                    CrmPopup.findHtmlobj(popupobj.divid,'enddate').val("");
	
				}                
                var resultobj=popupobj.datetimestr;//eval('.popupobj.datatimestr.');  
             
                for(var i in resultobj)
                {          
                    
                    if(type==i){                        
                            CrmPopup.findHtmlobj(popupobj.divid,'startdate').val( resultobj[i][0]);
                            CrmPopup.findHtmlobj(popupobj.divid,'enddate').val(resultobj[i][1]);
    					  
                        }                       
                }              
 			}
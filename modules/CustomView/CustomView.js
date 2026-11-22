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
						lingdangJS_DialogBox.unblock();
                        fninvsh('productlistview');
                        window.location.href="index.php?module="+module+"&action=index&parenttab=Sales";
                    }
            }
    );
    
}
function ProductDetailmoveDown()
{
var elem = document.getElementById('selectedAssmablyColumns');
	if(elem.options.selectedIndex>=0){
		for (var i=elem.options.length-2;i>=0;i--){
			if(elem.options[i].selected == true){
				//swap with one down
				var first = elem.options[i+1];
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
    this.column_index_array=[];
    this.group_index_array = [];
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

  	newNode.innerHTML = "<table class='small crmTable' border='0' cellpadding='5' cellspacing='1' width='100%' valign='top' name='conditiongrouptable_"+groupIndex+"'>"+
							"<tr name='groupheader_"+groupIndex+"'>"+
								"<td colspan='5' align='right'>"+
									"<a class='icon-homeimg icon-close' href='javascript:void(0);' title='删除组合' onclick='CrmPopup.getPopupObj(\"last\").highersearchobj.deleteGroup(\""+groupIndex+"\");'></a>"+
								"</td>"+
							"</tr>"+
							"<tr name='groupfooter_"+groupIndex+"'>"+
								"<td colspan='5' align='left'>"+
									"<input type='button' class='editauto addConditionRow' value='"+this.btn_addnewcondtiontext+"' onclick='CrmPopup.getPopupObj(\"last\").highersearchobj.addConditionRow(\""+groupIndex+"\")' />"+
								"</td>"+
							"</tr>"+
						"</table>"+
						
						"<table class='small' border='0' cellpadding='5' cellspacing='1' width='100%' valign='top'>"+
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
		groupConditionGlueElement.html( "<select name='gpcon"+groupIndex+"' id='gpcon"+groupIndex+"' class='small'>"+
												"<option value='and'>"+this.searchandlabel+"</option>"+
												"<option value='or'>"+this.searchorlabel+"</option>"+
											"</select>");
	}
}


HigherSearchGroup.prototype.addConditionRow=function(groupIndex) {

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
  
	var nextNode = CrmPopup.findHtmlobj(popupobj.divid,'groupfooter_'+groupIndex) ;

	var newNode = document.createElement('tr');
	newNodeId = 'conditioncolumn_'+groupIndex+'_'+columnIndex;
  	//newNode.setAttribute('id',newNodeId);
  	newNode.setAttribute('name',newNodeId);

    nextNode.before(newNode);
	node1 = document.createElement('td');
	node1.setAttribute('class', 'dvtCellLabel noborder');
    node1.setAttribute('align', 'left');
	node1.setAttribute('width', '25%');
	
	if (this.source == 'reports' || this.source == 'usereports')
		node1.innerHTML = '<select name="fcol'+columnIndex+'" id="fcol'+columnIndex+'" onchange="CrmPopup.getPopupObj(\"last\").highersearchobj.updatefOptions(this, \'fop'+columnIndex+'\');CrmPopup.getPopupObj(\"last\").highersearchobj.addRequiredElements('+columnIndex+');CrmPopup.getPopupObj(\"last\").highersearchobj.updateRelFieldOptions(this, \'fval_'+columnIndex+'\');" class="commonSelectPop">'+
							'<option value="">--'+jsnone+'--</option>'+
	        				this.columns_block+
						'</select>';
	else
		node1.innerHTML = "<select name='fcol"+columnIndex+"' onchange='CrmPopup.getPopupObj(\"last\").highersearchobj.updatefOptions(CrmPopup.findHtmlobj(CrmPopup.getPopupObj(\"last\").divid,\"fcol"+columnIndex+"\"), \"fop"+columnIndex+"\");CrmPopup.getPopupObj(\"last\").highersearchobj.addRequiredElements("+columnIndex+");' class='commonSelectPop'>"+
							"<option value=''>--"+jsnone+"--</option>"+
	        				this.columns_block+
						"</select>";
   
	newNode.appendChild(node1);
	node2 = document.createElement('td');
	node2.setAttribute('class', 'dvtCellLabel noborder');
    node2.setAttribute('align', 'left');
	node2.setAttribute('width', '20%');
	newNode.appendChild(node2);
    //查询条件下拉框
	node2.innerHTML = '<select name="fop'+columnIndex+'" id="fop'+columnIndex+'" class="toWidth100 commonSelectPop" onchange="CrmPopup.getPopupObj(\'last\').highersearchobj.addRequiredElements('+columnIndex+');">'+
							'<option value="">--'+jsnone+'--</option>'+
						    this.foption+
						'</select>';

	node3 = document.createElement('td');
	node3.setAttribute('class', 'dvtCellLabel noborder');
    node3.setAttribute('align', 'left');
	newNode.appendChild(node3);
    
	if (this.source == 'reports' )
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="toWidth150 commonTextBoxPop" type="text" value="">'+
						'<img height=20 width=20 style="cursor: pointer;" title="字段比较" alt="字段比较" src="themes/images/terms.png" onClick="hideAllElementsByName(\'relFieldsPopupDiv\'); fnvshobj(this,\'show_val'+columnIndex+'\');"/>'+
						'<input style="display:none;" class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="CrmPopup.findHtmlObj(CrmPopup.getPopupObj(\"last\").divid,\'fval'+columnIndex+'\').val();return false;" title="清除"/>'+
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
                                                '<span class="divPeople-Head">'+
                                                    "选择字段"+
                                                '</span>'+                                                    
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
															'<td width="30%" align="left" class="cellLabel small">相关字段</td>'+
															'<td width="30%" align="left" class="cellText">'+
																'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" class="commonSelectPop">'+
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
                                                '<a class="Save-button" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');">执行</a>'+
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
    node3.innerHTML = '<input name="fval'+columnIndex+'" class="toWidth150 commonTextBoxPop" type="text" value="">'+
						
						'<input style="display:none;" class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="document.getElementById(\'fval'+columnIndex+'\').value=\'\';return false;" title="清除"/>'+
						'<div class="layerPopup" id="show_val'+columnIndex+'" name="relFieldsPopupDiv" style="border:0; position: absolute; width:300px; z-index: 50; display: none;">'+
							'<table width="100%" cellspacing="0" cellpadding="0" border="0" align="center" class="mailClient mailClientBg">'+
								'<tr>'+
									'<td>'+
										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="layerHeadingULine">'+
											'<tr background="themes/images/qcBg.gif" class="mailSubHeader">'+
												'<td width=90% class="genHeaderSmall"><b>选择字段</b></td>'+
												'<td align=right>'+
													'<img border="0" align="absmiddle" src="themes/images/Close.png" style="cursor: pointer;diplay:none" alt="关闭" title="关闭 onclick="hideAllElementsByName(\'relFieldsPopupDiv\');"/>'+
	          	'</td>'+
											'</tr>'+
										'</table>'+

										'<table width="100%" cellspacing="0" cellpadding="0" border="0" class="small">'+
											'<tr>'+
												'<td>'+
													'<table width="100%" cellspacing="0" cellpadding="5" border="0" bgcolor="white" class="small">'+
														'<tr>'+
															'<td width="30%" align="left" class="cellLabel small">相关字段</td>'+
															'<td width="30%" align="left" class="cellText">'+
																'<select name="fval_'+columnIndex+'" id="fval_'+columnIndex+'" onChange="AddFieldToFilter('+columnIndex+',this);" class="commonSelectPop">'+
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
																'<input type="button" style="width: 70px;" value="--无--" name="button" onclick="hideAllElementsByName(\'relFieldsPopupDiv\');" class="create" accesskey="X" title="--无"/>'+
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
		node3.innerHTML = '<input name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="toWidth150 commonTextBoxPop" type="text" value="">'+
						'<input style="display:none;" name="clearfval_'+columnIndex+'" class="icon-homeimg icon-clear inpb-advSearchreset" type="button" onclick="CrmPopup.findHtmlobj(CrmPoup.getPopupObj(\"last\").divid,\'fval'+columnIndex+'\').val();return false;" title="清除"/>';
	

    
	node4 = document.createElement('td');
	node4.setAttribute('class', 'dvtCellLabel noborder');
    node4.setAttribute('align', 'left');
	//node4.setAttribute('id', 'columnconditionglue_'+columnIndex);
    node4.setAttribute('name', 'columnconditionglue_'+columnIndex);
	node4.setAttribute('width', '60px');
	newNode.appendChild(node4);

	node5 = document.createElement('td');
	node5.setAttribute('class', 'dvtCellLabel noborder');
    node5.setAttribute('align', 'left');
	node5.setAttribute('width', '30px');
	newNode.appendChild(node5);
	node5.innerHTML = '<a  href="javascript:;" onclick="CrmPopup.getPopupObj(\'last\').highersearchobj.deleteColumnRow('+groupIndex+','+columnIndex+');" title="'+arrJsPopLabel['DELETE']+'" >'+arrJsPopLabel['DELETE']
						'</a>';
  
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
		columnConditionGlueElement.html("<select name='fcon"+columnIndex+"'  class='commonSelectPop'>"+
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
HigherSearchGroup.prototype.addRequiredElements=function(columnindex) {

    var popupobj=CrmPopup.getPopupObj("last");
	var colObj = CrmPopup.findHtmlobj(popupobj.divid,'fcol'+columnindex);//下拉框字段
	var opObj =  CrmPopup.findHtmlobj(popupobj.divid,'fop'+columnindex); //查询条件下拉框
    var valObj =CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex);   //查询内容
    if(colObj==undefined ||colObj==null ||opObj==undefined || opObj==null)
     {
         return;
     }
  if(!colObj.is(":checked") )
  {
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
        	node5.setAttribute('class', 'toWidth150 commonTextBoxPop');
        	node5.setAttribute('style', 'width:150px');
        	node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
            //18763: 常用报表>销售预测分析表：转到高级查询，录入查找关键字后，按键盘上的Enter键，结果：页面跳转到了首页。
            node5.onkeypress=function(event){
                var e=event||window.event;
              
                if(e.keyCode==13)
                {
                    if(gVTModule=='OftenUseReport')
                            generateReport(node5);
                    return false;
                }
            }
            parentObj.append(node5);

        }else{
            //直接删除onclick事件，时间和日期切换的时候，控件无法自动切换，先删除橡皮擦，新增个时间或日期输入框，再删除老的输入框
            if(CrmPopup.isExistsObj(popupobj.divid,'fval_ext'+columnindex)) 
                this.removeElement('fval_ext'+columnindex);

            if(CrmPopup.isExistsObj(popupobj.divid,'clear_text_ext'+columnindex)) //清除查询内容文本框
                this.removeElement('clear_text_ext'+columnindex);
                
            var timeformat = " %H:%M:%S";
            var showtime = ' HH:mm:ss';
            if(fieldtype == 'D' || (tableName == 'ld_activity' && fieldName == 'date_start')) 
            {
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
        	node5.setAttribute('class', 'Wdate btn-radius-system');
        	node5.setAttribute('type', 'text');
        	//node5.setAttribute('id','fval'+columnindex);
        	node5.setAttribute('name','fval'+columnindex);
			node5.setAttribute('style','width:150px;margin-right: 10px;');
            
			
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
				var dateformat = $('jscal_dateformat').value;
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
	                        	node1.setAttribute('class', 'Wdate btn-radius-system');
	                        	node1.setAttribute('type', 'text');
	                        	node1.setAttribute('id','fval_ext'+columnindex);
	                        	node1.setAttribute('name','fval_ext'+columnindex);
								node1.setAttribute('style','width:150px');
								//parentObj.appendChild(fillernode);
								parentObj.append(node1);
							}
							
							if(isexistsdatestr=='yes')
                            {
                                var resultobj=popupobj.datetimestr;//eval('.popupobj.datatimestr.');  
                                //本年，明年，n天后，n天前等
                                CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).attr("disabled","true");
                                CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).attr("disabled",'true');
                               
                                 for(var timekey in popupobj.datetimestr)
                                    {          
                                        
                                        if(timekey==currOpvalue){  
                                                if(fieldtype=='DT')
                                                {
                                                     CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val( resultobj[timekey][0]+" 00:00:00");
                                                     CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).val(resultobj[timekey][1]+" 23:59:59");
                                                }
                                                else
                                                {
                                                    CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val( resultobj[timekey][0]);
                                                     CrmPopup.findHtmlobj(popupobj.divid,'fval_ext'+columnindex).val(resultobj[timekey][1]);
                                                }
                        					   break;
                                            }                       
                                    }   

                            }
                            else
                            {
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
		if(isexistsdatestr!='yes')
		{
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
		}
       
        if(currOpvalue == 'isnull'||currOpvalue == 'isnotnull'){
            CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).val();
            CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).attr("readonly",true);
        } else{
           CrmPopup.findHtmlobj(popupobj.divid,'fval'+columnindex).attr("readonly",false);
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
       
		var ops = typeofdata[fieldtype];
        //alert(fieldtype);
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
		}
    } else {
		if (currFieldvalue == '') {
			selObj.val("");
		}
    }
}

HigherSearchGroup.prototype.addNewConditionGroup=function() {
   
   var popupobj=CrmPopup.getPopupObj("last");
	this.addConditionGroup();	
	this.addConditionRow(this.advft_group_index_count);
    if(this.first>0)
        ld("#"+popupobj.divid+"_scroll").scrollTop(document.getElementById(popupobj.divid+"_scroll").scrollHeight+10);
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
							if(CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull'){
								if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
								{
								     returnValue= false;
                                    return false;
								}
							}
						}else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
							if(CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull'){

								if(!dateValidate(valueId,selectedColumnLabel,"OTH"))
								{
								     returnValue= false;
                                    return false;
								}
							}
						}else if(CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull'){
						  
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
					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"&& CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnull' && CrmPopup.findHtmlobj(popupobj.divid,comparatorId).val() != 'isnotnull'){
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
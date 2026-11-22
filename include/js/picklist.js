/**
 * this function is used to get the picklist values using ajax
 * it does not accept any parameters but calculates the modulename and roleid from the document
 */
function changeModule(){
	var oModulePick = $('pickmodule')
	var module=oModulePick.options[oModulePick.selectedIndex].value;
	var oRolePick = $('pickid');
	//var role=oRolePick.options[oRolePick.selectedIndex].value;
	var urlstring = 'action=PickListAjax&module=PickList&directmode=ajax&file=PickList&moduleName='+encodeURIComponent(module);
	ldAjaxHtml('index.php',urlstring,function (ajaxhtml) {
		DelProgressObjs();
		$("picklist_datas").innerHTML=ajaxhtml;
		fnhide('actiondiv');
		puyoungJS_DialogBox.unblock();
	});
	//fnhide('actiondiv');
}

/**
 * this function is used to assign picklist values to role
 * @param string module - the module name
 * @param string fieldname - the name of the field
 * @param string fieldlabel - the label for the field
 */
function assignPicklistValues(module,fieldname,fieldlabel){
	var elem = $('pickid');
	var role=elem.options[elem.selectedIndex].value;

	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&file=AssignValues&moduleName='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldname)+'&fieldlabel='+encodeURIComponent(fieldlabel)+'&roleid='+role,
			onComplete: function(response) {
			 
			     puyoungJS_DialogBox.block();
                $("status").style.display="none";
				$("actiondiv").style.display="none";
                $("actiondiv").style.zindex=10000000;
				$("actiondiv").innerHTML=response.responseText;
                fnvshobj('','actiondiv');
				//placeAtCenter($('actiondiv'));
               // Drag.init(document.getElementById("assignPickListHeading"), document.getElementById("actiondiv"));
			}
		}
		);
}

/**
 * this function is used to select the value from select box of picklist to the edit box
 */
function selectForEdit(){
	var node = document.getElementById('edit_availPickList');
	if(node.selectedIndex >=0){
		var value = node.options[node.selectedIndex].text;
		document.getElementById('replaceVal').value = value;
		$('replaceVal').focus();
	}
}

/**
 * this function checks if the edited value already exists; 
 * if not it pushes the edited value back to the picklist
 */
function pushEditedValue(e){
	var node = document.getElementById('edit_availPickList');
	if(typeof e.keyCode != 'undefined'){
		var keyCode = e.keyCode;
		//check if escape key is being pressed:: if yes then substitue the original value
		if(keyCode == 27){
			node.options[node.selectedIndex].text = node.options[node.selectedIndex].value;
			$('replaceVal').value = node.options[node.selectedIndex].value;
			return;
		}
	}
	
	var newVal = trim(document.getElementById('replaceVal').value);
	for(var i=0;i<node.length;i++){
		if(node[i].text.toLowerCase() == newVal.toLowerCase() && node.options[node.selectedIndex].text.toLowerCase() != newVal.toLowerCase()){
			var confirm_str = arrJsPopLabel['THEREAREDUPLICATEVALUES'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
	}
	
	var nonEdit = document.getElementsByClassName('nonEditablePicklistValues');
	if(nonEdit){
		for(var i=0;i<nonEdit.length;i++){
			var val = trim(nonEdit[i].innerHTML);
			if(val.toLowerCase() == newVal.toLowerCase()){
				var confirm_str = arrJsPopLabel['THEREAREDUPLICATEVALUES'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}
	
	if(node.selectedIndex >=0){
		node.options[node.selectedIndex].text = newVal;
	}
}

/**
 * this function is used to show the delete div for a picklist
 */
function showDeleteDiv(){
	var moduleElem = $('pickmodule');
	var module = moduleElem.options[moduleElem.selectedIndex].value;
	
	var oModPick = $('allpick');
	var fieldName=oModPick.options[oModPick.selectedIndex].value;
	var fieldLabel=oModPick.options[oModPick.selectedIndex].text;
	
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&mode=delete&file=ShowActionDivs&moduleName='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldName)+'&fieldlabel='+encodeURIComponent(fieldLabel),
			onComplete: function(response) {
			     puyoungJS_DialogBox.block();
				$("status").style.display="none";
				$("actiondiv").style.display ='none';
                $("actiondiv").style.zIndex='9999999999';
				$("actiondiv").innerHTML=response.responseText;
                fnvshobj('','actiondiv');
				//placeAtCenter($('actiondiv'));
                
                // Drag.init(document.getElementById("deletePickListHeading"), document.getElementById("actiondiv"));
			}
		}
		);
}

/**
 * this function is used to show the add div for a picklist
 */
function showAddDiv(){
	var moduleElem = $('pickmodule');
	var module = moduleElem.options[moduleElem.selectedIndex].value;
	
	var oModPick = $('allpick');
	var fieldName=oModPick.options[oModPick.selectedIndex].value;
	var fieldLabel=oModPick.options[oModPick.selectedIndex].text;
	
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&mode=add&file=ShowActionDivs&moduleName='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldName)+'&fieldlabel='+encodeURIComponent(fieldLabel),
			onComplete: function(response) {
    			$("status").style.display="none";
    			$("actiondiv").style.display ='none';
                $("actiondiv").style.zIndex='9999';
    			$("actiondiv").innerHTML=response.responseText;
                fnvshobj('','actiondiv');
			}
		}
		);
}

/**
 * this function is used to show the edit div for a picklist
 */
function showEditDiv(){
	var moduleElem = $('pickmodule');
	var module = moduleElem.options[moduleElem.selectedIndex].value;
	
	var oModPick = $('allpick');
	var fieldName=oModPick.options[oModPick.selectedIndex].value;
	var fieldLabel=oModPick.options[oModPick.selectedIndex].text;
	
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&mode=edit&file=ShowActionDivs&moduleName='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldName)+'&fieldlabel='+encodeURIComponent(fieldLabel),
			onComplete: function(response) {
			puyoungJS_DialogBox.block();
				$("status").style.display="none";
				$("actiondiv").style.display ='none';
                $("actiondiv").style.zIndex='9999999999';
				$("actiondiv").innerHTML=response.responseText;
                fnvshobj('','actiondiv');
				//placeAtCenter($('actiondiv'));
                 
                // Drag.init(document.getElementById("editPickListHeading"), document.getElementById("actiondiv"));
			}
		}
		);
}

/**
 * this function validates the add action
 * @param string fieldname - the name of the picklist field
 * @param string module - the name of the module
 */
function validateAdd(fieldname, module){
	var pickArr=new Array();
	var pick_options = document.getElementsByClassName('picklist_existing_options');
	for(var i=0;i<pick_options.length;i++){
		if(pick_options[i].value != ''){
			pickArr[i]=(pick_options[i].innerHTML).replace(/&amp;/i,'&');
		}
	}
   
	var new_vals = new Array();
	new_vals=trim($("add_picklist_values").value).split('\n');		
	if(new_vals == '' || new_vals.length == 0) {    
		var confirm_str = arrJsPopLabel['PLEASEADDLEASTONEVALUE'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	for(i=0;i<new_vals.length;i++){
		if (trim(new_vals[i]).search(/(\<|\>|\\|\/)/gi)!=-1) {
			var confirm_str = arrJsPopLabel['SPECIALCHARACTERS']+'"<" ">" "\\" "/"'+arrJsPopLabel['PLEASETRYOTHERVALUES'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false
		}
	}
	
	var node = document.getElementsByClassName('picklist_noneditable_options');
	var nonEdit = new Array();
	for(var i=0;i<node.length;i++){
		nonEdit[i] = trim(node[i].innerHTML);
	}

    
	pickArr = pickArr.concat(new_vals);
	pickArr = pickArr.concat(nonEdit);
	if(checkDuplicatePicklistValues(pickArr) == true){
		pickAdd(module,fieldname);
	}
}

/**
 * this function is used to check duplicate values in a given picklist values arrays
 * @param array arr - the picklist values array
 * @return boolean - true if no duplicates :: false otherwise
 */
function checkDuplicatePicklistValues(arr){
	var len=arr.length;
    	return true;
	for(i=0;i<len;i++){
		for(j=i+1;j<len;j++){
			if(trim(arr[i]).toLowerCase() == trim(arr[j]).toLowerCase()){
				var confirm_str = arrJsPopLabel['DROPDOWNBOXVALUEREPEAT']+"'"+trim(arr[i])+"'";
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}

}

/**
 * this function adds a new value to the given picklist
 * @param string module - the module name
 * @param string fieldname - the picklist field name
 */
function pickAdd(module, fieldname){
	var arr = new Array();
	arr = $("add_picklist_values").value.split("\n");
	var trimmedArr = new Array();
	for(var i=0,j=0;i<arr.length;i++){
		if(trim(arr[i]) != ''){
			trimmedArr[j++] = trim(arr[i]);
		}
	}
	var newValues = JSON.stringify(trimmedArr);
	arr = new Array();
	
	var roles = $("add_availRoles").options;
	var roleValues = '';
	if(roles.selectedIndex > -1){
		for (var i=0,j=0;i<roles.length;i++){
			if(roles[i].selected == true){
				arr[j++] = roles[i].value;
			}
		}
		roleValues = JSON.stringify(arr);
	}
	//edit:can reason:9076: 控制面板 > 下拉框编辑界面：去掉角色权限功能
	/*if(trim(roleValues) == '') {
		if(!confirm(arrJsPopLabel['NOCHOICEROLESSURE'])){
			return false;
		}
	}
	*/
	var node = document.getElementById('saveAddButton');
	node.disabled = true;
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&mode=add&file=PickListAction&fld_module='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldname)+'&newValues='+encodeURIComponent(newValues)+'&selectedRoles='+encodeURIComponent(roleValues),
			onComplete: function(response) {
				var str = response.responseText;
				changeModule();
				//$("status").style.display="none";
			}
		}
		);
}

/**
 * this function validates the edit action for a picklist
 * @param string fieldname - the fieldname of the picklist
 * @param string module - the module name
 */
function validateEdit(fieldname, module){
	var newVal = Array();
	var oldVal = Array();
	
	var node = document.getElementById('edit_availPickList');
	for(var i=0;i<node.length;i++){
		newVal[i] = node[i].text;
		if(trim(newVal[i]) == ''){
			var confirm_str = arrJsPopLabel['CANOTREPLACENULLVALUE'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		if (trim(newVal[i]).search(/(\<|\>|\\|\/)/gi)!=-1) {
			var confirm_str = arrJsPopLabel['SPECIALCHARACTERS']+'"<" ">" "\\" "/"'+arrJsPopLabel['PLEASETRYOTHERVALUES'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false
		}
		oldVal[i] = node[i].value;
	}
	pickReplace(module, fieldname, JSON.stringify(newVal), JSON.stringify(oldVal));
}

/**
 * this function is used to modify the picklist values
 * @param string module - the module name
 * @param string fieldname - the field name
 * @param array newVal - the new values for the picklist in json encoded string format
 * @param array oldVal - the old values for the picklist in json encoded string format
 */
function pickReplace(module, fieldname, newVal, oldVal){
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&mode=edit&file=PickListAction&fld_module='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldname)+'&newValues='+encodeURIComponent(newVal)+'&oldValues='+encodeURIComponent(oldVal),
			onComplete: function(response) {
				var str = response.responseText;
				changeModule();
				//$("status").style.display="none";
			}
		}
	);
}

/**
 * this function validates the delete action
 * @param string fieldname - the name of the picklist field
 * @param string module - the name of the module
 */
function validateDelete(fieldname, module){
	var node = $('replace_picklistval');
	var replaceVal = node.options[node.selectedIndex].value;
	if(trim(replaceVal) == ''){
		var confirm_str = arrJsPopLabel['CANREPLACEDWITHNULLVALUE'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	
    var objdiv_title = 	arrJsPopLabel['WARMPROMPT'];//标题
	var confirm_str = arrJsPopLabel['ALLROLESREMOVESELECTOPTION'];

	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //确定按钮
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
    	node = document.getElementById('delete_availPickList');
    	var arr = new Array();
        var valarr = new Array();
    	for(var i=0;i<node.length;i++){
    		if(node.selectedIndex == -1){
    			var confirm_str = arrJsPopLabel['NOVALUECANDELETED'];
    			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    			return false;
    		}else{
    			for(var j=0, k=0; j<node.length; j++){
    				if(node.options[j].selected == true){
    					arr[k] = encodeURIComponent((node.options[j].text).replace(/(")/ig,"\\$1"));
                        valarr[k] = node.options[j].value;
                        k++;
    				}
    			}
    		}
    	}
    
    	//check if replacement value is not equal to any deleted value
    	for(var i=0; i<arr.length; i++){
    		if(replaceVal == arr[i]){
    			var confirm_str = arrJsPopLabel['PLEASECHANGEVALUEREPLACEMENT'];
    			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    			return false;
    		}
    	}
    	
    	var nonEditableLength = 0;
    	var nonEditable = $('nonEditablePicklistVal');
    	if(typeof nonEditable != 'undefined'){
    		nonEditableLength = nonEditable.options.length;
    	}
    
    	if(arr.length == (node.length+nonEditableLength)){
    		var confirm_str = arrJsPopLabel['DROPDOWNBOXMUSTLEASTONEOPTION'];
    		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    		return false;
    	}
        //alert(document.getElementById('delete_availPickList').value)
        //alert(document.getElementById('replace_picklistval').value)
        /**
         *@edit:andy 
         *@date:20140919
         *@reason:0011541: 下拉框编辑中删除替代不合理
         *@version:
         */
        if(document.getElementById('delete_availPickList').value == document.getElementById('replace_picklistval').value){
            var confirm_str = arrJsPopLabel['ITSERREPLACEABLE'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;           
        }
    	pickDelete(module,fieldname,arr,replaceVal,valarr);
        var popupobj=CrmPopup.getPopupObj("last");
        
        ComboxPopup.popupobj;
       
	}); 
}
validateDelete.funname='validateDelete';

/**
 * this function deletes the given picklist values
 * @param string module - the module name
 * @param string fieldname - the field name of the picklist
 * @param array arr - the picklist values to delete
 * @param array replaceVal - the replacement value for the deleted value(s)
 */
function pickDelete(module, fieldname,arr,replaceVal,valarr){
	var otherurl = '';
	var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
	if ((module == 'CashBill' || module == 'SendCashBill') && ld("#"+detailviewpopupobj.divid+" [name='selectsource']").length>0) {
		var otherurl = "&selectsourcetype="+ld("#"+detailviewpopupobj.divid+" [name='selectsource']").val();
	}
    var selectvalue = ld(":input[name='"+fieldname+"']").val();
    ld.ajax({
        url: 'index.php?action=PickListAjax&module=PickList&mode=delete&file=PickListActions&fld_module='+encodeURIComponent(module)+'&fieldname='+encodeURIComponent(fieldname)+'&values='+JSON.stringify(arr)+'&replaceVal='+encodeURIComponent(replaceVal)+'&selectvalue='+selectvalue+otherurl,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            if(data.code==1)
            {
				var popupobj=CrmPopup.getPopupObj("last");
				popupobj.CancelEvent();
				var popupobj=CrmPopup.getPopupObj("last");
				if(popupobj!=undefined)//控制面板(级联字段)
				{
					popupobj.delElements=new Array();
					popupobj.delElements.push({"oldtext":decodeURIComponent(arr[0]),'replacevalue':(replaceVal)});
				}
                delComboxTr(valarr);
                var fieldname = ComboxPopup.popupobj.fieldname;
                coverComboxContent(data.result,fieldname);

				//BUG0067065 20230609 liushuai kfbcrm-市场活动-编辑预期反应下拉框字段，删除一个字段后，输入框内的内容没有替代(编辑弹出层保存时afterOkComboxSave()，参数selectvalue会读取当前页面的值，因此删除后要修改页面值)
				var inputobjs = ld(":input[name='"+fieldname+"']");
				ld.each(inputobjs, function (index, obj) {
					if(arr.indexOf(ld(this).val()) != -1){
						ld(this).val(replaceVal);
					}
				});
				var inputobjs_2 = ld("#"+detailviewpopupobj.divid).find(" [name=cmb_span_optiontext_"+fieldname+"]")
				ld.each(inputobjs_2, function (index, obj) {
					if(arr.indexOf(ld(this).val()) != -1){
						ld(this).val(replaceVal);
					}
				});
				// ld(":input[name='"+fieldname+"']").val(replaceVal);
				// ld("#"+detailviewpopupobj.divid+" [name=cmb_span_optiontext_"+fieldname+"]").val(replaceVal);
            }
        }
    });
}

/**
 * this function is used to assign the available picklist values to the assigend picklist values section
 */
function moveRight(){
	var rightElem = $('selectedColumns');
	for (var i=0;i<rightElem.length;i++){
		rightElem.options[i].selected=false;
	}
	
	var leftElem = $('availList');
	
	for (var i=0;i<leftElem.length;i++){
		if(leftElem.options[i].selected==true){            	
			var rowFound=false;
			//check if the value already exists
			for(var j=0;j<rightElem.length;j++){
				if(rightElem.options[j].value==leftElem.options[i].value){
					rowFound=true;
					rightElem.options[j].selected=true;
					break;
				}
			}
			
			//if the value does not exist then create it and set it as selected
			if(rowFound!=true){
				var newColObj=document.createElement("OPTION");
				newColObj.value=leftElem.options[i].value;
				newColObj.innerHTML=leftElem.options[i].innerHTML;
				
				rightElem.appendChild(newColObj);
				leftElem.options[i].selected=false;
				newColObj.selected=true;
			}
		}
	}
}

/**
 * this function is used to remove values from the assigned picklist values section
 */
function removeValue(){
	var elem = $('selectedColumns');
	if(elem.options.selectedIndex>=0){
		for (var i=0;i<elem.options.length;i++){ 
			if(elem.options[i].selected == true){
				elem.removeChild(elem.options[i--]);
			}
		}
	}
}

/**
 * this function is used to move the selected option up in the assigned picklist
 */
function moveUp(){
	var elem = document.getElementById('selectedColumns');
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

/**
 * this function is used to move the selected option down in the assigned picklist
 */
function moveDown(){
	var elem = document.getElementById('selectedColumns');
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
 * this function is used to move the selected option up in the assigned picklist
 */
function popup_moveUp(moveid){
	var popupobj=CrmPopup.getPopupObj("last");
	var elem =CrmPopup.findHtmlobj(popupobj.divid,moveid);
	if(elem[0].options.selectedIndex>=0){
		for (var i=1;i<elem[0].options.length;i++){
			if(elem[0].options[i].selected == true){
				//swap with one up
				var first = elem[0].options[i-1];
				var second = elem[0].options[i];
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
	//0043936: (61mis.com/kfbcrm)首页-组件模板定制；在组件模板编辑界面，选择模块后，调整模块“上移”或“下移”，右侧进度条跟随移动的模块移动，而不是固定不动的形式
	ld(elem).animate({ scrollTop: "-=22" });
}

/**
 * this function is used to move the selected option down in the assigned picklist
 */
function popup_moveDown(moveid){
	var popupobj=CrmPopup.getPopupObj("last");
	var elem =CrmPopup.findHtmlobj(popupobj.divid,moveid);
	if(elem[0].options.selectedIndex>=0){
		for (var i=elem[0].options.length-2;i>=0;i--){
			if(elem[0].options[i].selected == true){
				//swap with one down
				var first = elem[0].options[i+1];
				var second = elem[0].options[i];
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
	//0043936: (61mis.com/kfbcrm)首页-组件模板定制；在组件模板编辑界面，选择模块后，调整模块“上移”或“下移”，右侧进度条跟随移动的模块移动，而不是固定不动的形式
	ld(elem).animate({ scrollTop: "+=22" });
}

/**
 * this function is used to save the assigned picklist values for a given role
 * @param string moduleName - the name of the module
 * @param string fieldName - the name of the field
 * @param string roleid - the id of the given role
 */
function saveAssignedValues(moduleName, fieldName, roleid){
	var node = document.getElementById('selectedColumns');
	if(node.length == 0){
		var confirm_str = arrJsPopLabel['DROPDOWNBOXMUSTLEASTONEOPTION'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	var arr = new Array();
	for(var i=0;i<node.length;i++){
		arr[i] = node[i].value;
	}
	
	node = document.getElementById('roleselect');
	var otherRoles = new Array();
	if(node != null){
		if(node.selectedIndex > -1){
			for(var i=0,j=0; i<node.options.length; i++){
				if(node.options[i].selected == true){
					otherRoles[j++] = node.options[i].value;
				}
			}
		}
	}
	otherRoles = JSON.stringify(otherRoles);
	
	var values = JSON.stringify(arr);
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&file=SaveAssignedValues&moduleName='+encodeURIComponent(moduleName)+'&fieldname='+encodeURIComponent(fieldName)+'&roleid='+roleid+'&values='+encodeURIComponent(values)+'&otherRoles='+encodeURIComponent(otherRoles),
			onComplete: function(response) {
				if(response.responseText == "SUCCESS"){
					$("status").style.display="none";
					$("actiondiv").style.display="none";
					showPicklistEntries();
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","",response.responseText);
				}
			}
		}
	);
}

/**
 * this function is used to display the picklist entries for a given module for a given field for a given roleid
 * it accepts the module name as parameter while retrieves other values from DOM
 * @param string module - the module name 
 */
function showPicklistEntries(){
	var moduleNode = $('pickmodule');
	var moduleName = moduleNode.options[moduleNode.selectedIndex].value;
	
	var node = $('pickid');
	var roleid = node.options[node.selectedIndex].value;
	
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&file=PickList&moduleName='+encodeURIComponent(moduleName)+'&roleid='+roleid+'&directmode=ajax',
			onComplete: function(response) {
				if(response.responseText){
					$("status").style.display="none";
					$('pickListContents').innerHTML = response.responseText;
				}
			}
		}
	);
}

/**
 * this function is used to display the select role div
 * @param string roleid - the roleid of the current role
 */
function showRoleSelectDiv(roleid){
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&file=ShowRoleSelect&roleid='+roleid,
			onComplete: function(response) {
				if(response.responseText){
					$("status").style.display="none";
					var node = $('assignPicklistTable');
					var tr = document.createElement('tr');
					var td = document.createElement('td');
					td.innerHTML = response.responseText;
					tr.appendChild(td);
					$('addRolesLink').style.display = "none";
					
					var tbody = getChildByTagName(node,'tbody');
					var sibling = getChildByTagName(tbody, "tr");
					sibling = getSiblingByTagName(sibling, "tr");
					tbody.insertBefore(tr,sibling);
					placeAtCenter($('actiondiv'));
				}
			}
		}
	);
	
}

/**
 *
 */
function getSiblingByTagName(elem,tagName){
	var sibling = elem.nextSibling;
	while(sibling.nodeName.toLowerCase()!=tagName.toLowerCase()){
		sibling = sibling.nextSibling;
	}
	return sibling;
}

/**
 *
 */
function getChildByTagName(elem,tagName){
	for(var i=0;elem.childNodes.length;++i){
		if(elem.childNodes[i].nodeName.toLowerCase()==tagName.toLowerCase()){
			break;
		}
	}
	if(i >= elem.childNodes.length){
		return null;
	}
	return elem.childNodes[i];
}


/**下拉查询*************/
/**
图片按钮事件
*/
var cmb_fldname='';
var is_leave=false;
var  fielddepend=undefined;
var picklist=false;
var cmb_parentdivid='';

function com_img_change(event,fldname,parentdivid)
{
    if(parentdivid==''||parentdivid==undefined)
   {
     var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
 
   }
   else
   {
    divid=parentdivid;
   }
   cmb_parentdivid=divid;
 	window.event? window.event.cancelBubble = true : e.stopPropagation();
     picklist=true;
     if(cmb_fldname!=''&&fldname!=cmb_fldname&&CrmPopup.isExistsObj(divid,"dv_drop_"+cmb_fldname)){ 
         CrmPopup.findHtmlobj(divid,"dv_drop_"+cmb_fldname).css("left","-9000px");
         CrmPopup.findHtmlobj(divid,"cmb_a_"+cmb_fldname).attr("class","");
         CrmPopup.findHtmlobj(divid,"cmb_a_"+cmb_fldname).addClass('chzn-single');
         CrmPopup.findHtmlobj(divid,'dv_chzn_'+cmb_fldname).attr("class","");
         
        CrmPopup.findHtmlobj(divid,'dv_chzn_'+cmb_fldname).removeClass().addClass('chzn-container');
        CrmPopup.findHtmlobj(divid,'dv_chzn_'+cmb_fldname).addClass('chzn-container-single');
        
         cmb_fldname='';
         is_leave=false;
      }
      cmb_fldname=fldname;

    var fromobj=CrmPopup.findHtmlobj(divid,"cmb_a_"+cmb_fldname);//获取点击按钮元素
    var dvdrop= CrmPopup.findHtmlobj(divid,"dv_drop_"+cmb_fldname);//获取下拉框内内容
    //edit:duan 增加事件监测输入法当前输入状态
    fromobj.unbind('compositionstart').bind('compositionstart',function(){ //开始输入
        ld(this).attr('inputtype','start');
    })
    fromobj.unbind('compositionend').bind('compositionend',function(){ //结束输入
        ld(this).attr('inputtype','finish');
    })
    
    var j=1;
    var obj= CrmPopup.findHtmlobj(divid,fldname);
    CrmPopup.findHtmlobj(divid,"cmb_span_optiontext_"+fldname).attr('cur_input_select',"yes");
	ld("#"+divid+" [name=dv_chzn_"+fldname+"]").find(".chzn-results").find("li").attr("class","active-result");
    if(fromobj.attr("class")=='chzn-single')
    {   
        ld("#"+divid+" [name=dv_chzn_"+fldname+"]").find(" .chzn-drop").css("display",'');
        
        fromobj.addClass('chzn-single-with-drop') ;
        CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).attr("class","");
         CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container");
         CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container-single");
        // CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container-active");
        
       dvdrop.css("left","0");
       dvdrop.css("display","");
         CrmPopup.findHtmlobj(divid,'txt_search_'+fldname).val('');
         CrmPopup.findHtmlobj(divid,'txt_search_'+fldname).focus();
         
         if(cmb_parentdivid == 'listeditpagepopup')
         {
                
                //下拉框内容重新定位
                var fromobj=CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_a_"+fldname);//获取点击按钮元素
                var dvdrop= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_drop_"+fldname);//获取下拉框内内容
                
                if(fromobj.hasClass('chzn-single-with-drop'))
                {
                    //zkt 20221122 BUG0059003通用问题请提供补丁，供应商列表-单选用户字段在列表中编辑，弹框位置有问题，应该在该字段下面显示
                    var dvfluobj= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_cmb_"+fldname);//
                    var newpicklistleft = ld(dvfluobj).offset().left;//left
                    var dvfluobjtop = ld(dvfluobj).offset().top;
                    var dvfluobjheight = ld(dvfluobj).height();
                    var dvchzncontentobj= CrmPopup.findHtmlobj(cmb_parentdivid,"dv_chzn_"+fldname);//
                    var dvchzncontentheight = ld(dvchzncontentobj).height();
                    dvfluobjheight = dvfluobjheight>0?dvfluobjheight:dvchzncontentheight;
                    var picklisttop = ld(dvdrop).offset().top;
                    var picklistheight = ld(dvdrop).height();
                    var displaynoneheight = picklistheight<=26?0:26;
                    var newpicklisttop = dvfluobjtop+dvfluobjheight;
                    var windowHeight =CrmPopup.getClientHeight();
                    newpicklisttop = (newpicklisttop+picklistheight)>windowHeight?(dvfluobjtop+displaynoneheight-picklistheight-5):newpicklisttop;
                    dvdrop.css("left",newpicklistleft);
                    dvdrop.css("top",newpicklisttop);
                }
         }
      

    }
    else
    {
        CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).attr("class","");
        
        CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container");
         CrmPopup.findHtmlobj(divid,'dv_chzn_'+fldname).addClass("chzn-container-single");
         fromobj.attr("class","");
         fromobj.addClass('chzn-single');
       // dvdrop.style.left='-9000px';
        dvdrop.css("left","-9000px");
    }
	if(ld('#'+divid+' ul[name=cmb_ul_'+cmb_fldname+'] li').length == 1){
		ld('#'+divid+' ul[name=cmb_ul_'+cmb_fldname+'] li[name=li_chzn_'+cmb_fldname+']').css('display','block');
	}else{
		ld('#'+divid+' ul[name=cmb_ul_'+cmb_fldname+'] li[name=li_chzn_'+cmb_fldname+']').css('display','hidden');
	}
	//wym BUG20240523-41 单选用户小编辑的时候，下拉框挡了一小部分输入框了
	/*ld("#"+divid+" [name=dv_drop_"+cmb_fldname+"]").css('width',ld("#"+divid+" [name=dv_drop_"+cmb_fldname+"]").prev().get(0).offsetWidth+'px');
	ld("#"+divid+" [name=dv_drop_"+cmb_fldname+"]").css('top','');*/
	CrmPopup.findHtmlobj(divid,'li_chzn_'+fldname).attr("class","");
}
/**
下拉框字符查找事件
**/
function makePys(event,fldname,parentdivid){

     if(parentdivid==''||parentdivid==undefined)
       {
         var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
       }
       else
       {
        divid=parentdivid;
       }
      
    var e=event||window.event;
    var searchobj=e.srcElement||e.target;//查询文本框
    if(searchobj==undefined)
    {
        return false;
    }
    var picklistttype=ld(searchobj).attr("picklisttype");
    if(picklistttype=='smownerpicklist')
     {
        //负责人下拉框
        //edit:can 2021-01-03 44174: (61mis.com/kfbcrm)客户管理-客户-新增；新增客户界面选择销售负责人，中文输入时有异常，无法正常编辑输入
        var searchtext=ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html();
        var tmpvalue= Tools.DelHtmlTag(searchtext);
        tmpvalue=Tools.DelHtmlnbsp(tmpvalue);
        var searchtext=ld.trim(tmpvalue);
     }
     else
        var searchtext=searchobj.value;


    if(trim(searchtext)=='')
    {
		searchtext = '';
        //16884: 服务合同>新建：基本信息区块，产品类别的下拉框，点击下拉框的空白处，多显示了一个下拉选项【没有匹配项目】
        //18276: 所有模块>列表/明细：分配、推进、更改状态、更改创建人弹出层，模糊查询，删除关键字，下拉选项显示应该是原来的默认值。
       // return false;
    }
    //
    var uppersearch=searchtext.toLowerCase();
    var objsel=CrmPopup.findHtmlobj(divid,fldname);
    if(divid=='ImportXlsDiv')//导入特殊
            objsel=ld("#"+fldname);
    var b=false;
	var j=0;
    var pingyin=false;
    var len=objsel.find("option").length;

   var optionsobjs=objsel.find("option");
   var selected_optionname_arr = [];
	var optgroupobjs=objsel.find("optgroup");
	if(optgroupobjs.length>0){ //wym 230425 搜索功能添加是否有区块的判断
		var optgroupobjlis = ld("#"+divid).find(" [name^="+fldname+'_optgroups_'+"]");
		ld.each(optgroupobjlis,function(){ //遍历optgroup
			var optgroupbj_li = ld(this);
			var parentul = Tools.getParentobjByChild(optgroupbj_li,'ul');
			var groupindex = ld(this).data('groupindex');
			var option_li = ld(parentul).find("li[groups="+fldname+"_optgroups_"+ groupindex +"]");

			var optgroupbj_litext=ld(optgroupbj_li).text().toLowerCase();
			var arrRslt_group = makePy(optgroupbj_litext);
			if(arrRslt_group != undefined) {
				var pingyingstr_group = arrRslt_group.join("").toLowerCase();
				if (optgroupbj_litext.indexOf(uppersearch) >= 0 || pingyingstr_group.indexOf(uppersearch) >= 0) { //当区块名相符，显示该区块及其所有子元素
					b = true;
					optgroupbj_li.attr("class", "");
					optgroupbj_li.addClass('active-result');
					ld.each(option_li, function () {
						ld(this).attr("class", "");
						ld(this).addClass('active-result');
						selected_optionname_arr.push(ld(this).attr('name'));
					});
				} else {
					optgroupbj_li.attr("class", ""); //当区块名不符，隐藏该区块
					ld.each(option_li, function () {  //遍历该区块内所有option
						var text = ld(this).text().toLowerCase();
						var arrRslt = makePy(text);
						if (arrRslt != undefined) {
							var pingyingstr = arrRslt.join("").toLowerCase();
							if (text.indexOf(uppersearch) >= 0 || pingyingstr.indexOf(uppersearch) >= 0) { //当option相符，显示该option及其对应区块名
								b = true;
								optgroupbj_li.addClass('active-result');
								ld(this).attr("class", "");
								ld(this).addClass('active-result');
							} else {
								ld(this).attr("class", ""); //当option不符，不显示该option及其对应区块名
							}
							selected_optionname_arr.push(ld(this).attr('name'));
						}
					});
				}
			}
		});
	}
	var parent_divobj = ld("#"+divid);
	var child_obj = '';
	ld.each(optionsobjs,function(){
		//optgroup查询过的选项不再进行查询
		if(selected_optionname_arr.indexOf('dv_chzn_'+j+"_"+fldname)>-1){
			j++;
			return true;
		}
		var text=ld(this).text().toLowerCase();
		var arrRslt = makePy(text);

		if(arrRslt != undefined){
			var pingyingstr=arrRslt.join("").toLowerCase();

			/*
			*edit: chj
			*date: 2020/9/29
			*reason: 42809: (61mis.com/kfbcrm)系统设置-其他设置-登录日志查询；选择成员下拉框，第一个选项“无” ，不是默认“请选择”选项，且无法点击选择；成员有英文名时，输入成员大写首字母，显示没有匹配项目
			*/
			child_obj = parent_divobj.find('[name=dv_chzn_'+j+'_'+fldname+']');

			if(text.indexOf(uppersearch)>=0||pingyingstr.indexOf(uppersearch)>=0)
			{
				b=true;

				child_obj.attr("class","");
				child_obj.addClass('active-result');
				//CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+fldname).attr("class","");
				//CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+fldname).addClass('active-result');
			}

			else
			{

				child_obj.attr("class","");

				//console.log(text+'---'+searchtext);
				//CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+fldname).attr("class","");

			}
            j++;
        }
        
    })
	//objsel.val('');//ctrl+Enter
    if(b==false){
   	    CrmPopup.findHtmlobj(divid,'li_chzn_'+fldname).attr("class","");
        CrmPopup.findHtmlobj(divid,'li_chzn_'+fldname).addClass("active-result");  		
   	}
    else{
		//chj 2021/1/20 44365: （本地php72，8.3.7）客户-页面设置-布局规则；新增布局规则，触发字段编辑查找时，查找的结果显示在了界面左侧
		CrmPopup.findHtmlobj(divid,'li_chzn_'+fldname).attr("class","");
		var css_left = new Array();
		var css_left =  CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).css("left").split('px');
		if(parseInt(css_left[0]) < 0){
			CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).css("left",0);
		}
    }
    
        
	
}
function com_keyPress(event)
{
    //17129: 所有模块>列表/明细：分配弹出层，光标放在搜索栏中，按“Enter”键，结果页面显示的代码
      if(event.keyCode==13)
    {
       
        return false;
    }
     
}


function com_chosen(event,fldname,parentdivid)
{
    if(parentdivid==''||parentdivid==undefined)
	{
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
	}else{
		divid=parentdivid;
	}
	var e=event||window.event;
	var chosenobj=e.srcElement||e.target;
    var keycode= event.keyCode || event.which;
	var picklisttype= ld(chosenobj).attr("picklisttype");
    if(picklisttype=='smownerpicklist'){
        //edit:duan date:2022-1-22 reason:49661 列表页查看范围关闭下拉框后后继续输入不显示查询结果
        var fromobj = CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname);
        //监测输入法状态,如果正在输入，则不执行查询
        if(fromobj.attr('inputtype')=='start'){
            return false;
        }
        //只有增加内容的按键可以触发打开下拉框事件
        if((keycode>=48 && keycode<=57)||(keycode>=65 && keycode<=111)||(keycode==32)||(keycode==8)){
            //关闭下拉框后，如果继续输入，则重新打开下拉框
            if(CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class")=='chzn-single'){   
                com_img_change(event,fldname,parentdivid)
            }
        }else{
             return false;
        }
    }
    
    if(picklisttype=='smownerpicklist')
	{
		//负责人下拉框
		//  console.log(ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html());
		if(iskehu001=='yes')
		{
			//edit；can20210819（chrome浏览器)  47570: 阳光https://kehu001.com/weixin/kh44923/ [^])新建客户-销售负责人字段模糊搜索查找功能无效
			ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").find("[type=userName]").remove();

		}
		var tmpvalue= Tools.DelHtmlTag(ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html());
		

		if(ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html().indexOf("<br>")>=0&&(keycode==8||keycode==32))
		{
			ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html(tmpvalue);
		}
		//  ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html(tmpvalue);

		tmpvalue=Tools.DelHtmlnbsp(tmpvalue);
		if(keycode!=37&&keycode!=39)//左右方向键
		{
			if(/Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent))
			{
				//edit:can 2021-01-12 44211: （http://51mis.com.cn/XS/hzxmz/ [^]）Mac自带的Safari浏览器，客户问题（王杰），负责人和单选用户字段无法输入中文进行模糊查找（需要补丁）
			}else  if (window.getSelection) {//ie11 10 9 ff safari
				//edit:can 2020-12-03 43539: （本地php72，8.3.3版本）销售管理-合同订单-新建（需要补丁）；在订单新建时，进行编辑查找负责人，无法拼音输入汉字
				// chosenobj.focus(); //解决ff不获取焦点无法定位问题
				var range = window.getSelection();//创建range
				range.selectAllChildren(chosenobj);//range 选择obj下所有子内容
				range.collapseToEnd(true);//光标移至最后
				range = window.getSelection().getRangeAt(0);//找到焦点位置
			}else if (document.selection) {//ie10 9 8 7 6 5
				var range = document.selection.createRange();//创建选择对象
				range.moveToElementText(chosenobj);//range定位到obj
				range.collapse(true);//光标移至最后
				range.select();
				range = document.getSelection().getRangeAt(0);//找到焦点位置
			}
		}
		//  chosenobj.removeAllRanges();
		//   chosenobj.addRange(range);
		var value=ld.trim(tmpvalue);//ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html();
	}else
		var value=ld("#"+divid+" [name='txt_search_"+fldname+"']").val();
	if(picklisttype=='smownerpicklist' ){
		EmptyProgressObjs();//清空
	 	if(value==''){
            ld("#"+divid+" [name=dv_chzn_"+fldname+"]").find(".chzn-results").find("li").attr("class","active-result");
            ld("#"+divid+" [name=li_chzn_"+fldname+"]").attr("class","");
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
            {
            	//通讯录(pc端企业微信)
				cls_wxOpenDataobj.bindAllOpenData();
            }
            return ;
	 	}
	 	ld("#"+divid+" [name=cmb_ul_"+fldname+"]").find('.active-result').removeClass("active-result");
		ld("#"+divid+" [name=dv_drop_"+fldname+"]").find('.active-result').removeClass("active-result");
	 	ld("#"+divid+" #cmb_ul_"+fldname).find('.active-result').removeClass("active-result");

	 	ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=searchUserByKehu001&iskehu001="+iskehu001,{'searchvalue':value},function(data){
	 		if(data.result.list.length>0){
	 			ld.each(data.result.list,function(tmpindex,tmpuserid){
	 				//zxm	0048427: （81mis.com/kfbcrm）系统设置》成员管理》删除成员时，关键字搜索不到成员
					ld("#"+divid+" [name=dv_chzn_"+fldname+"]").find("[userid="+tmpuserid+"]").addClass('active-result');
	 			});
	 		}else{
	 			ld("#"+divid+" [name=li_chzn_"+fldname+"]").attr("class","");
                ld("#"+divid+" [name=li_chzn_"+fldname+"]").addClass("active-result");
	 		}
	 		if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
	 		{
	 			//通讯录(pc端企业微信)
				cls_wxOpenDataobj.bindAllOpenData();
	 		}
	 	});
   }
   else{
		getJsScript('include/js/multipingyin.js',function(){
			makePys(event,fldname,parentdivid);
		});
   }
}
/**
edit:can
reason:鼠标离开当前下拉框事件
**/
function cmb_mouseleave(event,fldname)
{
  
     return;
     
    
}
/**
edit:chj
reason:点击下拉框时，鼠标停留在内容的最后
**/
function cmb_picklist_end_foucs(event,fieldname){
	var popupobj=undefined;
	popupobj=CrmPopup.getPopupObj("last");
	if(popupobj != undefined && popupobj != 'undefined' && popupobj.divid != ''){
		ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fieldname+"]").select();
	}else{
		ld(" [name=cmb_span_optiontext_"+fieldname+"]").select();
	}
	 
}
/**
 edit:liushuai
 reason:单击默认值单选框
 **/
// @edit:liushuai,2021-05-19,reason:【ID1001646】页面设置，字段属性设置“默认”值后，则默认值前面的“复选框”自动勾选并生效(取消勾选清空)
function cmb_defaultvalue_check(obj,fldid,fldname){
	if (ld(obj).is(":checked") === false){ //取消选中 //BUG0069226 xxy 2023-7-20 后台设置模块页面设置中，设置默认值，取消默认时，取消默认前复选框的勾选状态再保存无效果 
		var popupobj = CrmPopup.getPopupObj("last");

		//文本
		ld("#"+popupobj.divid+" [name=defaultvalue_"+fldid+"_name]").val('');

		//下拉框
		ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").val('');
		ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fldname+"]").attr('cur_input_select',"yes");

		//日期
		ld("#"+popupobj.divid+" [name=cmb_span_optiontext_defaultvalue_"+fldid+"_name]").val('');
		ld("#"+popupobj.divid+" [name=cmb_span_optiontext_defaultvalue_"+fldid+"_name]").attr('cur_input_select',"yes");

		//复选框
		ld("#defaultvalue_"+fldid+"_name").prop("checked",false);

		//多选框
		ld("#"+popupobj.divid+" .select2-selection__choice").remove();

		//关联单据
		ld("#"+popupobj.divid+" [name=defaultvalue_"+fldid+"]").val('');//BUG0069226 xxy 2023-7-20 清除关联单据所用到的隐藏域 
		ld("#"+popupobj.divid+" [name=referencemodule_"+fldid+"]").val('');
	}

}
// @edit:liushuai,2021-05-19,reason:【ID1001646】页面设置，字段属性设置“默认”值后，则默认值前面的“复选框”自动勾选并生效(操作列时判断默认值是否勾选)
//edit:can 46335: （http://akjykj.vicp.cc:85/ [^]）客户问题（AK金蝶软件李），在电话管家上服务->服务合同，新建"服务合同",编辑“合同类型”、“发票类型”和“负责人”后不能保存。（备注：在其他浏览器上可以正常保存）;

function cmb_defaultvalue_checked(obj,type,fldid,fldname){//默认值操作列
	switch(type) {
		case 'select':  //下拉框 不同于日期下拉框一样有value属性
			if (empty(ld(obj).text())){
				ld("#defaultvalue_check_"+fldid).prop('checked',false);
			}else{
				ld("#defaultvalue_check_"+fldid).prop('checked',true);
			}
			break;
		case 'date':  //日期
		case 'text':  //数字 QQ Email Skype 百分比 货币 网址 单选用户 多选用户
		case 'textarea':
			if (empty(ld(obj).val())){
				ld("#defaultvalue_check_"+fldid).prop('checked',false);
			}else{
				ld("#defaultvalue_check_"+fldid).prop('checked',true);
			}
			break;
		case 'onecheckbox': //复选框(单选)
			if (ld(obj).prop("checked") === true){
				ld("#defaultvalue_check_"+fldid).prop('checked',true);
			}else{
				ld("#defaultvalue_check_"+fldid).prop('checked',false);
			}
			break;
		case 'morecheckbox': //多选框
			if (ld(obj).val() !== null && ld(obj).val().length !== 0) {
				ld("#defaultvalue_check_"+fldid).prop('checked',true);
			}else{
				ld("#defaultvalue_check_"+fldid).prop('checked',false);
			}
			break;
		default:

	}
}
/**
edit:can
reason:单击下拉框
**/

function cmb_liclick(optionvalue,fldname,parentdivid)
{
	var popupobj=undefined;
 	var event = window.event || arguments[3];
 	if(event==undefined){
        return false;
 	}

    var li_srcElement=event.srcElement||event.target;
  
    while(li_srcElement!=undefined&&li_srcElement.tagName!='LI'){
        li_srcElement=li_srcElement.parentNode;
      
    }
    
	var MassEditPopup = undefined;
    var divid="";
 
     if(parentdivid==''||parentdivid==undefined)
   {
      popupobj=CrmPopup.getPopupObj("last");
     
    divid=popupobj.divid;
   }
   else
   {
    popupobj=CrmPopup.getPopupObj("last");
    //42505: 收款单关联预收单的时候，先选合同，再选账户不能触发带出预收信息
    divid=parentdivid;
   }
   
   
    //edit:can 2020--10-09 42849: 合同订单->新增了单选用户字段->查看界面小编辑，不显示任何用户信息
    var  picklisttype=ld(li_srcElement).attr("picklisttype");

     
    if(picklisttype=='smownerpicklist'||fldname=='HomeSmOwnerSearchScope'||fldname=='ChuantouSmOwnerSearchScope')
    {
         
        ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").html(ld(li_srcElement).html());

		//BUG0075470 lius 20231114 客户模块，批量编辑界面，选择内容后，前面的框没有自动勾选上。
		//批量编辑的单选用户类型的下拉框不是标准的,用的div而不是input,导致绑定事件massedit_initOnChangeHandlers()无法绑定change事件
		var checkbox = ld("#"+divid+' input[name="'+fldname+'_mass_edit_check"]');
		if(checkbox) checkbox.prop("checked",true);
    }
    else{
		var tmplicolor = ld(li_srcElement).css('color'); //BUG0067582 xxy 2023-6-13 页面设置中下拉框选中字段没有颜色样式，此处为其颜色赋值
		if(!empty(tmplicolor)){
			CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).css('color',tmplicolor);
		}
		ld("#"+divid+" [name=cmb_span_optiontext_"+fldname+"]").val(ld(li_srcElement).html());
	}
 

	// ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）(单选用户选择空时，关联带出的值也应该为空)
	if (picklisttype=='smownerpicklist' && optionvalue == ''){
		var tmpfieldinfo=popupobj.fieldname_fields[fldname];
		if(tmpfieldinfo.bigtype=="selectoneuser")//153
		{
			tmpclear_relatefielddatas(tmpfieldinfo.referencemodule,ld("#"+popupobj.divid+" [name="+fldname+"]").val(),'',fldname,popupobj.module,'select');
		}
	}
   
    var objoption=CrmPopup.findHtmlobj(divid,fldname);
 	objoption.val(optionvalue);
   
    
    if(divid=='ImportXlsDiv')//导入特殊
            objoption=ld("#"+fldname);
    var optiontext='';
    picklist=true;
    if(typeof objoption.change=='function')
        objoption.change();
    if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
    {
   	    var sourcename = objoption.name;
        var sourcevalue = objoption.value;	
       
        fielddepend.fieldValueChange(sourcename, sourcevalue);
    }
   
    /*for(var i=0;i<objoption.find("option").length;i++)
    {
        if(objoption.find("option")[i].value==optionvalue)
        {
             
            objoption.find("option")[i].selected=true;
            optiontext=objoption.find("option")[i].text;
            objoption.find("option")[i].selected=true;
         
           objoption.find("option")[i].selectedIndex=i;
            objoption.find("option")[i].value=optionvalue;

             if(typeof objoption.change=='function')
                objoption.change();
            if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
            {
           	    var sourcename = objoption.name;
                var sourcevalue = objoption.value;	
               
                fielddepend.fieldValueChange(sourcename, sourcevalue);
            }
            break;
        }
    }*/
    
    var usersApprovestatus=ld("#approvestatus").attr("key");//Liver 20161223，bug0024252: 控制面板>用户管理：审批委托选择启用，增加提示信息【审批委托启用时，审批单据将不会流转到该用户，直接流转到审批委托人，是否继续？】
        //029246: 用户管理：审批委托选择“停用”时，不应该弹出提示信息。
    if(usersApprovestatus != undefined && usersApprovestatus=='users' && objoption[objoption.selectedIndex].text=='启用'){
        if(!confirm(arrJsPopLabel['USERAPPROVESREMINDS'])){
            
              CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class","");
                CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class",'chzn-single');
              
                
                CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).css("left","-9000px");//隐藏下拉框
                
                
            return false;
        }
    }
     
     if(MassEditPopup!=undefined && popupobj!=undefined&&popupobj.type!=MassEditPopup.type)
     {
      
         setCodeNumPrefix(fldname,optionvalue,'actions');//设置编号
     }
   
    CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class","");
    CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class",'chzn-single');

	//ls 2022-02-17 0049994: （奥德）合同订单提交审批时，选择‘合同订单审批流程（苏奥二部---制热&制冷）’这个审批流程，&符号被转义显示成&amp;(.html()方法默认会转义，用.text()就不会转义)
   
    if(CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).attr("picklisttype")=='smownerpicklist')
         CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).html(ld(li_srcElement).html());
    else
         CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(ld(li_srcElement).text());
	CrmPopup.findHtmlobj(divid,"cmb_span_optiontext_"+fldname).attr('cur_input_select',"no");

	//默认值选择后  input框也要选中
	var fldid = ld("#"+divid).attr("fieldid");
	ld("#defaultvalue_check_"+fldid).prop('checked',true);
    if(typeof cls_wxOpenDataobj!="undefined"&&typeof cls_wxOpenDataobj!=undefined){
        if(popupobj==undefined)
                cls_wxOpenDataobj.bindAllOpenData();
        else
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                        
    }
                
  //  CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(optiontext);
    CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).css("left","-9000px");//隐藏下拉框
	//选择字段带出关联信息
    //edit:can 20211220 49326: （81mis.com/kfbtest/index.php）客户列表》查找历史，输入关键字2次后，再选择查找历史时，关键字带不出
    if(popupobj != undefined&&popupobj.type!='ListBasicSearchPopup'&&popupobj.type!='ListHigherSearchPopup')
    	if(popupobj != undefined&&popupobj.type!=RelateListPage.type){
    		getJsScript('include/js/relatedfield.js',function(){
    			getRelatedFieldData(popupobj.module,optionvalue,'',fldname,popupobj.module,'select');
                //edit:can 2021-12-14 049252: (https://www.51mis.com/hy/liuyishou/ [^])客户-页面设置-布局规则-设置了销售负责人如果属于招商部则电话号码必填，结果无效
                // popupobj.fieldruleobj.CheckReLoadPopup();//是否重新加载界面
    		});
    	}
 
}
/*
edit:andy
reason:系统编号改进,增加省份、城市拼音首字母前缀
date:20140804
*/
function setCodeNumPrefix(fldname,optionvalue,action)
{
 
    popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.module!='Accounts')
    {
        return false;
    }
    var divid=popupobj.divid;
    if(action == 'action' && CrmPopup.getHtmlobjval(divid,'mode') == 'edit')
        return;
    if((fldname =="bill_city"  || fldname=="bill_state") ){ 
        if(document.forms['QcEditView'] != undefined){
            if(document.getElementById("hiddenprefix") != undefined){
                var hiddenprefix =document.getElementById("hiddenprefix").value;
                var systemnum=document.getElementById(hiddenprefix);
                var fieldvalue=systemnum.value;
            }   
            var module=CrmPopup.getHtmlobjval(divid,'module');
        }
      
        else if(document.forms['EditView'] != undefined)
        {
            //if(document.forms['EditView'].mode.value == 'edit')
                //return; //单据编辑，编号经页面加载完成后，编号改变
            if(document.getElementById("hiddenprefix") != undefined){
                var hiddenprefix =document.getElementById("hiddenprefix").value;
                var systemnum=document.getElementById(hiddenprefix);
                var fieldvalue=systemnum.value;
            }
            var module=CrmPopup.getHtmlobjval(divid,'module');
        }        
            
        if (typeof(systemnum) != "undefined"){
           //alert('module=Settings&action=SettingsAjax&file=Controllsystemnum&mode='+module+'&ajax='+'true'+'&type='+'1'+'&fldname='+fldname+'&optionvalue='+optionvalue)
            new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Home&action=HomeAjax&file=Controllsystemnum&mode='+module+'&ajax='+'true'+'&type='+'1'+'&fldname='+fldname+'&optionvalue='+encodeURIComponent(optionvalue)+'&fieldvalue='+fieldvalue,
                onComplete: function(response) {
                    //alert(response)        
                    if(response.responseText.indexOf('SUCCESS')>-1){
                        var results=response.responseText.split("###SUCCESS###");
                        //alert(results[1])
                            systemnum.value=results[1];
                            
     
                    }
                }
            }); 
        }
        
    }
}

/**
edit:can
reason:鼠标在下拉框内容上移动事件
**/

function cmb_limouseover(event,fldname,parentdivid)
{
     if(parentdivid==''||parentdivid==undefined)
   {
   
     var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
   }
   else
   {
    divid=parentdivid;
   }

    var e=event||window.event;
    var cur_liobj=e.srcElement||e.target;
   while(cur_liobj!=undefined&&cur_liobj.tagName!='LI'){
        cur_liobj=cur_liobj.parentNode;
      
    }
	cur_liobj.className="active-result highlighted";
	var liid=cur_liobj.getAttribute("name");
	var objoption=CrmPopup.findHtmlobj(divid,fldname);
   // alert( CrmPopup.findHtmlobj(divid,'cmb_ul_'+fldname).find('li').length);
   //edit:can 2020-11-20 43358: （61mis.com/kfbcrm)合同订单模块>新建单据界面：选择“单选用户”字段，会自动全选
   
    CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).find('li').each(function() {
		if(ld(this).attr('name') != liid){
			if(ld(this).attr("class")!='')
             {
               
                 ld(this).attr("class","");
                ld(this).attr("class","active-result");
               
             }
		}
	})
    


}


document.onclick = function(event){ 

      var e=event||window.event;
      var obj=e.srcElement||e.target;

    
      if(obj!=undefined&&(obj.getAttribute("name")=='txt_search_'+cmb_fldname||obj.getAttribute("name")==cmb_fldname))
      {
       
        is_leave=false;
        
      }
     else
     {
        
         while(obj!=undefined)
         {
           
            
            if(obj.tagName=='BODY'||obj.tagName=='TD'||obj.tagName=="HTML")
            {
                is_leave=true;
                break;
            }
           if(obj.getAttribute("name")=="dv_cmb_"+cmb_fldname)
           {
            
              is_leave=true;
              break;
           }
            if(obj.getAttribute("name")=="dv_chzn_"+cmb_fldname|| obj.getAttribute("name")=="dv_drop_"+cmb_fldname||obj.getAttribute("name")=="dv_cmb_"+cmb_fldname)
            {
                is_leave=false;
                break;
            }
            obj=obj.parentNode||obj.parentElement ;
         }
     }
    
      if(cmb_fldname!=''&&is_leave==true&&CrmPopup.isExistsObj(cmb_parentdivid,"dv_drop_"+cmb_fldname)){   
			//alert(CrmPopup.findHtmlobj(cmb_parentdivid,cmb_fldname).val());
			CrmPopup.findHtmlobj(cmb_parentdivid,"dv_drop_"+cmb_fldname).css("left","-9000px");
			CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_span_optiontext_"+cmb_fldname).attr('cur_input_select',"no");
			// CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_a_"+cmb_fldname).attr("class","");
			// CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_a_"+cmb_fldname).attr("class","chzn-single");
			// diony 2021-06-22 增加红色边框提醒，这里需要更改
			CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_a_"+cmb_fldname).removeClass("chzn-single").removeClass("chzn-single-with-drop");
			CrmPopup.findHtmlobj(cmb_parentdivid,"cmb_a_"+cmb_fldname).addClass("chzn-single");
			CrmPopup.findHtmlobj(cmb_parentdivid,'dv_chzn_'+cmb_fldname).attr("class","");
			CrmPopup.findHtmlobj(cmb_parentdivid,'dv_chzn_'+cmb_fldname).addClass("chzn-container");
			CrmPopup.findHtmlobj(cmb_parentdivid,'dv_chzn_'+cmb_fldname).addClass("chzn-container-single");
         
         cmb_fldname='';
         is_leave=false;
      }
      
      //合同订单产品明细录入下拉框
       if( typeof(dropselectField) !='undefined' && obj!=undefined&&obj.id != dropselectField && dropselectField != '')
        {
            if(obj.id != 'selectRow' && document.getElementById(dropselectField) != undefined && document.getElementById(dropselectField).disabled == false &&  document.getElementById(dropselectField).value == '')
            {
                //document.getElementById(dropselectField).value = arrJsPopLabel['INPUTAKEYWORDSQUERY'];
                
                //document.getElementById(selectField).style.color='#999';
            }
			if(document.getElementById('search_'+dropselectField) != undefined)
				document.getElementById('search_'+dropselectField).style.display = 'none';
            dropselectField = '';
        }
		//表单，快速创建选择模块
        if( typeof(search_obj) !='undefined' && obj!=undefined&&obj.id != search_obj && search_obj != '')
		{
			search_obj.style.display = 'none';
		}
      //用户管理模块,职位级别下拉框
	var dv_userlevelobj = document.getElementById('dv_userlevel');
	if(dv_userlevelobj != undefined){
		if(e.target != dv_userlevelobj){
			dv_userlevelobj.style.display = 'none';
			show_related_picklist_content('userlevel','yes');
		}
	}

 }

/**
 * Enter事件
 * @author Tujt 2015-07-24
 */
function editpick_keyup(obj,event){
	if(empty(ld(obj).val())) return false;
	var e = event || window.event;
	if(e.keyCode == 13){
		pushEditedValue(event);
		ld('#actiondiv div.D_pbtn input.D_pbtnok').click();
	}else{
	       pushEditedValue(event);
		//ld('#actiondiv div.D_pbtn input.D_pbtnok').click();
	}
}

function approve_change(optionvalue,fldname,parentdivid,display,require,showurgent)//提交意见是否显示和必填
{
    var popupobj=CrmPopup.getPopupObj("last");
    var submittext = ld("#"+popupobj.divid+" [name=showsubmitremark]");
    var submitlabel = ld("#"+popupobj.divid+" [name=submitremarkrequire]");
    var showurgentobj = ld("#"+popupobj.divid+" [name=showurgent]");//是否显示需要加急审批
    if(require=="yes")
    {
        ld(submitlabel).css("display",'inline');
    }else
    {
        ld(submitlabel).css("display",'none');
    }
    if(display =="yes")
    {
        ld(submittext).css("display",'');
    }else
    {
        ld(submittext).css("display",'none');
        ld(submitlabel).css("display",'none');
    }
    if (showurgent == "yes")
		ld(showurgentobj).css("display",'');
    else
		ld(showurgentobj).css("display",'none');
    cmb_liclick(optionvalue,fldname,parentdivid);
}
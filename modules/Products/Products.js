/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
document.write("<script type='text/javascript' src='"+global_js_url+"include/js/modules/Products/multifile.js'></script>");

function updateListPrice(unitprice,fieldname, oSelect)
{
	if(oSelect.checked == true)
	{
		document.getElementById(fieldname).style.visibility = 'visible';
		document.getElementById(fieldname).value = unitprice;
	}else
	{
		document.getElementById(fieldname).style.visibility = 'hidden';
	}
}

function check4null(form)
{
  var isError = false;
  var errorMessage = "";
  if (trim(form.productname.value) =='') {
			 isError = true;
			 errorMessage += "\n Product Name";
			 form.productname.focus();
  }

  if (isError == true) {
			 alert(alert_arr.MISSING_REQUIRED_FIELDS + errorMessage);
			 return false;
  }
  return true;
}

function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}
function set_return_specific(product_id, product_name) {

    if(document.getElementById('from_link').value != '')
	{
		var fldName = window.document.QcEditView.products_name;
		var fldId = window.document.QcEditView.product_id;
	}else if(typeof(window.document.DetailView) != 'undefined')
	{
	   var fldName = window.document.DetailView.product_name;
	   var fldId = window.document.DetailView.product_id;
	}
     
	else if(typeof(window.document.EditView) != 'undefined')
	{
	 
     
		if(typeof(window.document.EditView.related_to) != 'undefined'){//提醒，选择产品
			var fldName = window.document.EditView.related_to_name;
			var fldId = window.document.EditView.related_to;
		}else{
		 
			var fldName = window.document.EditView.products_name;
			var fldId = window.document.EditView.product_id;
		}
	}
	if(fldName != undefined){
		fldName.value = product_name;
	}
	if(fldId != undefined){
		fldId.value = product_id;
	}
    
}

function set_return_formname_specific(formname,product_id, product_name) {
        window.document.EditView1.products_name.value = product_name;
        window.document.EditView1.product_id.value = product_id;
}
function add_data_to_relatedlist(entity_id,recordid,destination_module) 
{
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:"module=Potentials&action=updateRelations&destination_module="+destination_module+"&entityid="+entity_id+"&parentid="+recordid,
		onComplete: function(response) {
			var popupobj=CrmPopup.getPopupObj('lastprev');
			var divid = popupobj.divid;
			var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_'+destination_module).val();
			var viewid = CrmPopup.findHtmlobj(divid,'viewname_'+destination_module).val();
			cancelCrmPopup();
			showRelatedCustomView(related_id,viewid);
			setRelatedResizeTable_Init(destination_module);
			set_rel_count();
		}
	}
	);
}



var isgrandbind = 1;


// <<<<<<<<<<<<<<<<<<<<<  合同订单录入明细，增加含税单价列 end  >>>>>>>>>>>>>>>>>>>


function set_return_product(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.document.QcEditView.parent_name.value = product_name;
        window.document.QcEditView.parent_id.value = product_id;
	} else {
		window.document.EditView.product_name.value = product_name;
		window.document.EditView.product_id.value = product_id;
	}
}
function getImageListBody() {
	if (browser_ie) {
		var ImageListBody=getObj("ImageList")
	} else if (browser_nn4 || browser_nn6) {
		if (getObj("ImageList").childNodes.item(0).tagName=="TABLE") {
			var ImageListBody=getObj("ImageList")
		} else {
			var ImageListBody=getObj("ImageList")
		}
	}
	return ImageListBody;
}

// Function to Round off the Price Value
function roundPriceValue(val) {
   val = parseFloat(val);
   val = Math.round(val*100)/100;
   val = val.toString();
   
   if (val.indexOf(".")<0) {
      val+=".00"
   } else {
      var dec=val.substring(val.indexOf(".")+1,val.length)
      if (dec.length>2)
         val=val.substring(0,val.indexOf("."))+"."+dec.substring(0,2)
      else if (dec.length==1)
         val=val+"0"
   }
   
   return val;
} 
// End

// <<<<<<<<<<<<<<<<<<<<<  奥特林：产品明细录入改进 begin  >>>>>>>>>>>>>>>>>>>
/**
 * 判断当前标题录入样式，是否为RMB产品录入样式
 * @project PROT99 奥特林：产品明细录入改进
 * @author Tujt 2014-10-16
 */
function rmb_checkRMBProduct(){
	var parentwindow = window;
	if(parentwindow.document.getElementById('bomproduct') != undefined){//判断产品套餐
		return 'bom';
	}else if(parentwindow.document.getElementById('rmbproduct') != undefined){
		return 'rmb';
	}
	return 'list';
}
/**
 * 给当前行文本框绑定事件
 * @project PROT99 奥特林：产品明细录入改进
 * @author Tujt 2014-10-16
 */
function rmb_productEventBind(curr_row){
    var tableobj=document.getElementById("proTab");
	//var trobj = document.getElementById('row'+curr_row);
    var trobj=tableobj.rows[curr_row+1];
   
	var inputs = trobj.getElementsByTagName('input');
	var inputlen = inputs.length;var b = false;var oldvalue = '';var oldkeyval = 0;
	for(var i=0; i<inputlen; i++){
		if(inputs[i].type == 'text'){
			inputs[i].title = inputs[i].value;
			if('comment' == inputs[i].id.substring(0,7)) continue;
			if(!b && 'qua' == inputs[i].id.substring(0,3)) b = true;//数量是放在本行需要计算的文本框最前列，所以当获取到数量文本框，
                                                               //就可以给剩下文本库事件了
			if(b){
				//if('tax_profit' == inputs[i].id.substring(0,10)) b = false;
				inputs[i].autocomplete = 'off';
				inputs[i].maxLength = 28;
				inputs[i].onfocus = function(event){//光标移入事件
					var e = event||window.event;
					var obj = e.srcElement||e.target;
					oldvalue = obj.value;
				}
				inputs[i].onkeydown = function(event){//键盘按下事件
					var e = event||window.event;
					var obj = e.srcElement||e.target;
					oldkeyval = obj.value;
					var key = e.keyCode || e.which;
					var updown = '';
					if(key == 40){//方向下键
						updown = 'down';
					}else if(key == 38){//方向上键
						updown = 'up';
					}
					if(updown != ''){
						var parentid = obj.parentNode.parentNode.id;
						if('row' == parentid.substring(0,3)){
							var rowi = parentid.substring(3,parentid.length);
							var max_row_count = document.getElementById("rowcnt").value;
							var thisid = obj.id.replace(rowi,'');
							var uindex = rowi;
							if(rowi == 1 && updown == 'up'){
								uindex = max_row_count;
							}else if(rowi == max_row_count && updown == 'down'){
								uindex = 1;
							}else{
								if(updown == 'up'){
									uindex --;
								}else{
									uindex ++;
								}
							}
							if(document.getElementById(thisid+uindex) != ''){
								document.getElementById(thisid+uindex).focus();
								document.getElementById(thisid+uindex).select();
							}
						}
					}

					if(e.ctrlKey && key == 86){//拷贝
						return true;
					}

					if (!e.shiftKey && !e.altKey && !e.ctrlKey &&// Backspace, Tab, Enter
						key ==  8  || key == 9 || key == 13 ||// Home, End
						key == 35  || key == 36 ||// <-, -> 方向键
						key == 37  || key == 39 ||// Del, Ins
						key == 46  || key == 45 ||
						key == 190 || key == 188 ||
						key == 109 || key == 110) {
							return;
					}
					if((key > 47 && key < 58) || (key > 95 && key < 106))
						return;//数字
					return false;
				}
				inputs[i].onkeyup = function (event){
					var e = event||window.event;
					var obj = e.srcElement||e.target;
					var reg = /^([\d]+|([\d]+[.]?|[\d]+[.]?[\d]+))$/;
					if(obj.value.replace(reg,'0') != 0){//非数字，则还原回按键按下前的值
						obj.value = oldkeyval;
					}
				}
				inputs[i].onblur = function(event){//光标移出事件
					var e = event||window.event;
					var obj = e.srcElement||e.target;
                   
					if(obj.value != oldvalue){
						rmb_countProductTotal(curr_row);//计算单价和价格
						fieldformulaobj.CountsubTotal();//
						
					}
				}
			}
		}
	}
	rmb_countProductTotal(curr_row);//计算数据
	calcTotal();
}
/**
 * 获取decimal类型的金额、价格值
 * @project PROT99 奥特林：产品明细录入改进
 * @author Tujt 2014-10-17
 */
function rmb_getdecimal(idstr,setype){
	var decimal = 0;
	if(setype == 'html'){
		if(document.getElementById(idstr) != undefined && document.getElementById(idstr).innerHTML != '')
			decimal = parseFloat(document.getElementById(idstr).innerHTML);
	}else{
		if(document.getElementById(idstr) != undefined && document.getElementById(idstr).value != '')
			decimal = parseFloat(document.getElementById(idstr).value);
	}
	decimal = parseFloat(decimal) + 0;
	return decimal;
}
/**
 * 计算RMB含税单价、总价、欧元单价等休息
 * @project PROT99 奥特林：产品明细录入改进
 * @author Tujt 2014-10-16
 */
function rmb_countProductTotal(curr_row){
	//1、计算欧元单价
	var rmbprice = rmb_getdecimal('rmbprice'+curr_row);//欧元标准单价
	if(rmbprice > 0){
		document.getElementById('eur_price'+curr_row).innerHTML = rmbprice.toFixed(2);
	}else{
		document.getElementById('eur_price'+curr_row).innerHTML = rmbprice;
	}
	//2、计算RMB含税单价
	var tax_rate = rmb_getdecimal('tax_rate'+curr_row);//汇率
	var tax_customs = rmb_getdecimal('tax_customs'+curr_row);//关税
	var tax_freight = rmb_getdecimal('tax_freight'+curr_row);//运费系数
	var tax_profit = rmb_getdecimal('tax_profit'+curr_row);//利润率
	var tax_added = rmb_getdecimal('tax_added'+curr_row);//增值税
	var discount_amount = rmb_getdecimal('discount_amount'+curr_row);//RMB折扣额
	var rmbtaxprice = 0;//RMB含税单价
	if(tax_rate > 0){
		rmbtaxprice = rmbprice * tax_rate;//RMB含税单价 = 欧元标准单价*汇率
	}
	if(tax_customs > 0){
		if(rmbtaxprice > 0) rmbtaxprice = rmbtaxprice * tax_customs;
		else rmbtaxprice = rmbprice * tax_customs;
	}
	if(tax_added > 0){
		if(rmbtaxprice > 0) rmbtaxprice = rmbtaxprice * tax_added;
		else rmbtaxprice = rmbprice * tax_added;
	}
	if(tax_freight > 0){
		if(rmbtaxprice > 0) rmbtaxprice = rmbtaxprice * tax_freight;
		else rmbtaxprice = rmbprice * tax_freight;
	}
	if(tax_profit > 0){
		if(rmbtaxprice > 0) rmbtaxprice = rmbtaxprice * tax_profit;
		else rmbtaxprice = rmbprice * tax_profit;
	}
	//人民币含税单价
	if(discount_amount > 0) rmbtaxprice = rmbtaxprice - discount_amount;
	document.getElementById('rmb_taxprice'+curr_row).value = rmbtaxprice.toFixed(2);
	document.getElementById('span_rmb_taxprice'+curr_row).innerHTML = rmbtaxprice.toFixed(2);
	//3、计算RMB含税总价
	var qty = document.getElementById('quantity'+curr_row).value;//产品数量
	document.getElementById('rmb_taxamount'+curr_row).value = (qty * rmbtaxprice).toFixed(2);
	document.getElementById('span_rmb_taxamount'+curr_row).innerHTML = (qty * rmbtaxprice).toFixed(2);
	document.getElementById('subtotal').value = (qty * rmbtaxprice).toFixed(2);
	document.getElementById('span_subtotal').innerHTML = (qty * rmbtaxprice).toFixed(2);
}
// <<<<<<<<<<<<<<<<<<<<<  奥特林：产品明细录入改进 end    >>>>>>>>>>>>>>>>>>>
function ProductListCopy(record)
{
    var objparams=new CreatePagePopup.params();
     objparams.params['isduplicate']='yes';
     CreatePagePopup.showpage(module,"&record="+record+"&isDuplicate=true",objparams);
}
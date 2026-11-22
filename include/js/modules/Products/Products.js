/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//document.write("<script type='text/javascript' src='"+global_js_url+"include/js/modules/Products/multifile.js'></script>");

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
     var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:"module="+detailviewpopupobj.module+"&action="+detailviewpopupobj.module+"Ajax&file=updateRelations&destination_module="+destination_module+"&entityid="+entity_id+"&parentid="+recordid,
		onComplete: function(response) {
			var popupobj=CrmPopup.getPopupObj('lastprev');
			var divid = popupobj.divid;
			var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_'+destination_module).val();
			var viewid = CrmPopup.findHtmlobj(divid,'viewname_'+destination_module).val();
			cancelCrmPopup();
			//showRelatedCustomView(related_id,viewid);
//			popupobj.relatelistsizeobj.setRelatedResizeTable_Init(destination_module);
//			set_rel_count();
                    var tmparra=new Array();
                          tmparra.push(popupobj.record);
                          
                        var tmpobj= new AfterUpdatePrevPopupObjContent('Products',getEmptyValueInfo(),tmparra);
                        tmparra=['Products'];
                        tmpobj.eachrefreshlistbyModules(tmparra);
                        delete tmpobj;
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
    if(	document.getElementById('rmb_taxprice'+curr_row)==undefined)
    {
        return ;
    }
	document.getElementById('rmb_taxprice'+curr_row).value = rmbtaxprice.toFixed(2);
    if(document.getElementById('span_rmb_taxprice'+curr_row)==undefined)
    {
        return ;
    }
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
//editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 16:59
function product_detail_qtyinstock(id,type){
	//zkt 20231010 XUQIU1001341 SQL注入
	var param = {record : id ,module:"Products",file:"product_detail_qtyinstock",'action':'ProductsAjax','type':type};
	var tmpurl = cls_encryptyurl.Puyoung_Encryptyurl("index.php?",param);
    ld.post(tmpurl,param,function(response) {
        var data = ld.parseJSON(response);
        var crmPopupobj = CrmPopup.load(data.result.title, '', "", "LdPopWidth800px", '', '', '', "", '');

        crmPopupobj.show(data.result.content);

        crmPopupobj.center();
        //zkt 20221011 0051704(https://61mis.com/order/index.php) （自用order）充值合同》订货折扣，即时库存查询功能界面， 当鼠标移出子窗口， 有任何一个点击事件， 这个窗口应该消失
        crmPopupobj.isclicklayerclose='yes';
    });
}

function prdt_sys(obj,module){
	var table_html = '';
	var myDate = new Date();
	var m = myDate.getMonth() + 1;
	var d = myDate.getDate();
	if(m < 10){
		m = '0'+m;
	}
	if(d < 10){
		d = '0'+d;
	}
	var _date = myDate.getFullYear() + "-" + m + "-" + d;
	var start_date = _date +' 00:00:00';
	var end_date = _date + ' 23:59:59';
	var divid = 'prdt_sys_div';var isinit = 0;
	table_html +='<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">';
	table_html +='<tbody>';
	table_html += '<tr><td class="DetailedTd1Label" align="left" width="10%">产品名称：<input type="text" size="20" name="prdt_name" value="" id="prdt_name"/></td><td class="DetailedTd1Label" align="left" width="10%">产品编号：<input type="text" size="20" name="prdt_no" value="" id="prdt_no"/></td></tr>';
	table_html += '<tr><td class="DetailedTd1Label" align="left" width="10%" colspan="2">规格型号：<input type="text" size="20" name="prdt_spc" value="" id="prdt_spc"/></td></tr>';
	table_html += '<tr><td class="DetailedTd1Label" align="left" width="10%">'+arrJsPopLabel['STARTTIME']+'：<input type="text" onClick="WdatePicker({startDate:\'%y-%M-%d %H:%M:%S\',dateFmt:\'yyyy-MM-dd HH:mm:ss\',alwaysUseStartDate:true})" class="Wdate" size="20" readonly="true" name="prdt_startdate" value="" id="prdt_startdate"/></td><td class="DetailedTd2Info" align="left" width="40%">'+arrJsPopLabel['ENDTIME']+'：<input type="text" onClick="WdatePicker({startDate:\'%y-%M-%d %H:%M:%S\',dateFmt:\'yyyy-MM-dd HH:mm:ss\',alwaysUseStartDate:true})" class="Wdate" size="20" readonly="true" name="prdt_enddate" value="" id="prdt_enddate"/></td></tr>';
	table_html +='</tbody>';
	table_html +='</table>';
	if(0 == ld('#'+divid).length){//当层未创建时，创建层
		var divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'D_pop_box LdPopWidth500px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		divObj.style.display = "none";
		divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="D_pop_tit">'+
								'<strong class="D_ptita" id="titlename">产品同步</strong>'+
								'<a href="javascript:fninvshnew(\''+divid+'\');" class="D_ptitc">'+
									'<img style="margin:5px 0px 0px 4px;padding:0px;" src="themes/icon/pop_close.png" '+
									'alt="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'">'+
								'</a>'+
							'</div>'+
							'<div id="'+divid+'content" >'+
								'&nbsp;'+
							'</div>'+
							'<div class="D_pbtn"><input class="D_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+
							'<input class="D_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button" onclick="fninvshnew(\''+divid+'\');"></div>';
	}else{
		isinit = 1;
	}
	ld('#'+divid+'content').html(table_html);
	fnvshobj(obj, divid);
	ld('#'+divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
		var prdt_startdate = ld('#prdt_startdate').val();
		var prdt_enddate = ld('#prdt_enddate').val();
		var prdt_name = ld('#prdt_name').val();
		var prdt_no = ld('#prdt_no').val();
		var prdt_spc = ld('#prdt_spc').val();
		if(empty(prdt_startdate) && !empty(prdt_enddate)){
			var tips = arrJsPopLabel['STARTTIME']+arrJsPopLabel['CANOTEMPTY']+'！';
			RemindsMsg("","LdPopWidth400px","","yes","",tips);
			return false;
		}
		if(empty(prdt_enddate) && !empty(prdt_startdate)){
			var tips = arrJsPopLabel['ENDTIME']+arrJsPopLabel['CANOTEMPTY']+'！';
			RemindsMsg("","LdPopWidth400px","","yes","",tips);
			return false;
		}
		if(!empty(prdt_enddate) && !empty(prdt_startdate)){
			if(prdt_startdate > prdt_enddate){
				var tips = arrJsPopLabel['THESTARTTIME']+'！';
				//THESTARTTIME
				RemindsMsg("","LdPopWidth400px","","yes","",tips);
				return false;
			}
		}
		fninvshnew(divid);
		if(ld('#bw_sync_helpdesk_div') != undefined){
			ld('#bw_sync_helpdesk_div').html('<div id="cell" style="text-align:center;"><p>正在同步更新产品，请稍候......</p></div>')
		}
		fnvshobj(obj,'bw_sync_helpdesk_div');
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: "module=Products&action=ProductsAjax&frommodule=Products&Ajax=true&file=prdt_sys&startdate="+prdt_startdate+'&enddate='+prdt_enddate+'&prdt_name='+prdt_name+'&prdt_no='+prdt_no+'&prdt_spc='+prdt_spc,
				onComplete: function(response) {
					
					fninvshnew('bw_sync_helpdesk_div');
					alert(arrJsPopLabel['Synchronizedsuccess']);//同步成功
					getListViewEntries_js('Products','start=1');//刷新页面
				}
			}
		);
	});

}




/**
 * @edit:ls
 * @date:2020-7-6
 * @reason:
 * @description:义文机电一键检测需求
 */
function showproductlist(module, popuptype){
    var popupobj=CrmPopup.getPopupObj("last"); // console.log(CrmPopup.getPopupObjByDivId(divid));
    // console.log(popupobj);
    var divid=popupobj.divid;
    //可查询的字段数组
	//@edit:liushuai,2020-11-03,reason:【ID1001067】上海义文一键检测个性化开发(检测字段改变)
	var products_column = [
		'cf_3606',      //物料名称
		'customform08_id_name',//选择标准/品牌
		'cf_2726',      //品牌名称
		'cf_2908',      //供应商料号
		'cf_2780',      //头型
		'cf_2781',      //驱动槽
		'cf_4429',      //牙距类型
		'cf_4430',      //杆型
		'cf_4431',      //螺纹长度类型
		'cf_4432',      //螺纹旋向
		'customform48_id_name',      //选择牌号
		'cf_2794',      //材质总类
		'cf_2791',      //性能等级
		'cf_2734',      //表面处理
		'cf_4443',      //镀层要求
		'cf_2848',      //直径(毫米)
		'cf_2849',      //长度(毫米)
		'cf_4315',      //规格
		'cf_4724',      //材质
		'cf_4725',      //材料
		'cf_4726',      //镀层
		'cf_4718',      //尺寸
		'cf_4727',      //非标等级
		'cf_4558',      //参考标准
		'cf_4686',      //性能要求
		'cf_2743',      //组合件构成
		'cf_4793',      //报价信息补充
	];
	var customform02_column = [
		'ld_customform02scf:cf_2650:cf_2650:CustomForm02_物料名称:V',
		'ld_customform02:customform08_id:customform08_id:CustomForm02_选择标准/品牌:V',
		'ld_customform02scf:cf_2851:cf_2851:CustomForm02_品牌名称:V',
		'ld_customform02scf:cf_2854:cf_2854:CustomForm02_供应商料号:V',
		'ld_customform02scf:cf_2819:cf_2819:CustomForm02_头型:V',
		'ld_customform02scf:cf_2820:cf_2820:CustomForm02_驱动槽:V',
		'ld_customform02scf:cf_4410:cf_4410:CustomForm02_牙距类型:V',
		'ld_customform02scf:cf_4411:cf_4411:CustomForm02_杆型:V',
		'ld_customform02scf:cf_4412:cf_4412:CustomForm02_螺纹长度类型:V',
		'ld_customform02scf:cf_4413:cf_4413:CustomForm02_螺纹旋向:V',
		'ld_customform02:customform48_id:customform48_id:CustomForm02_选择牌号:V',
		'ld_customform02scf:cf_2828:cf_2828:CustomForm02_材质总类:V',
		'ld_customform02scf:cf_2829:cf_2829:CustomForm02_性能等级:V',
		'ld_customform02scf:cf_2830:cf_2830:CustomForm02_表面处理:V',
		'ld_customform02scf:cf_4438:cf_4438:CustomForm02_镀层要求:V',
		'ld_customform02scf:cf_2852:cf_2852:CustomForm02_直径(毫米):V',
		'ld_customform02scf:cf_2853:cf_2853:CustomForm02_长度(毫米):V',
		'ld_customform02scf:cf_3301:cf_3301:CustomForm02_规格:V',
		'ld_customform02scf:cf_4712:cf_4712:CustomForm02_材质:V',
		'ld_customform02scf:cf_4719:cf_4719:CustomForm02_材料:V',
		'ld_customform02scf:cf_4720:cf_4720:CustomForm02_镀层:V',
		'ld_customform02scf:cf_4711:cf_4711:CustomForm02_尺寸:V',
		'ld_customform02scf:cf_4721:cf_4721:CustomForm02_非标等级:V',
		'ld_customform02scf:cf_4549:cf_4549:CustomForm02_参考标准:V',
		'ld_customform02scf:cf_2835:cf_2835:CustomForm02_性能要求:V',
		'ld_customform02scf:cf_4427:cf_4427:CustomForm02_组合件构成:V',
		'ld_customform02scf:cf_2841:cf_2841:CustomForm02_报价信息补充:V',
	];

    //拼接高级查询立即查找按钮的请求值
    var advft_criteria = '[null';
    ld.each(products_column, function(tmpindex,tmpcolumnname){
        var tmpvalue = CrmPopup.findHtmlobj(divid,tmpcolumnname).val();
        if(tmpvalue != '' && tmpvalue != undefined && tmpvalue != 'tmpvalue'){
            advft_criteria += ',{"groupid":"1","columnname":"' + customform02_column[tmpindex] + '","comparator":"e","value":"' + tmpvalue + '","columncondition":"and"}';
        }
    });
    advft_criteria += ']';
    // console.log(ld('#'+popupobj.divid+' [name="cf_3282"]').val());  //取单个值
    // var parent_type = 'Products';
    var parent_type = 'CustomForm02'; //物料主数据表

    var tmp_advft_criteria = JSON.parse(advft_criteria);
	if (tmp_advft_criteria.length > 1) {  // 表示有查询条件（页面字段有值）
		tmp_advft_criteria[tmp_advft_criteria.length-1].columncondition = ''; //将最后一个条件的columncondition置空
		advft_criteria = JSON.stringify(tmp_advft_criteria);
	}else{
		advft_criteria = '[null]';
	}
    popupobj.advft_criteria = advft_criteria; //将查询数据保存到弹框对象里（高级查找自动填充数据）
    // console.log(advft_criteria);

    var advft_criteria_groups = '[null,{"groupcondition":""}]';

    // onecheck=yes  表示一键检测    advft_criteria、advft_criteria_groups一键检测页面的数据
    var surl = "module="+parent_type+"&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype="+popuptype;
    surl+="&popup=yes&page_popup=yes&onecheck=yes&advft_criteria="+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups;
    surl+="&searchtype=advance&query=true&account="+account_version;
    CrmPopupWindow(module,surl,parent_type);

}

//产品禁用

function discontinued()
{

    var select_options = document.getElementById('allselectedboxes').value;
    var count=select_options.split(";").length-1;
    if(select_options=='all')
    {
        count=$('numOfRows').value;
    }
    if(count <= 0){
        RemindsMsg("","LdPopWidth400px","","yes","","");
        return false;
    }

    if(count > getMaxMassOperationLimit()) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		//确定按钮
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			confirmDiscontinued(select_options);
		})
		return false;
    } else {
        confirmDiscontinued(select_options);
    }
}
//确认禁用
function confirmDiscontinued(select_options){
    var  accounttype=document.massdelete.publicaccounttype.value;
    var gstart='';
    if(document.forms['massdelete'].pagenum!=undefined)
    {
        gstart="&start="+document.forms['massdelete'].pagenum.value;
    }
    else
    {
        gstart="&start="+document.forms['massdelete'].pagenum[0].value;
    }
    var viewname=document.getElementById("viewname").value;
    var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var excludedRecords = $('excludedRecords').value;
	ld("#DiscontinuedDiv").css('display','none');

	var url ="index.php?module=Products&action=ProductsAjax&file=Discontinued"+gstart;
	//zkt 树结构显示增加条件，获取树结构点击条件
	if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
		url += '&isshowModuleListTree=yes';
	}
	var params = {parenttab:'Parent Products',idstring:select_options,pagepublicaccounttype:accounttype,
		SearchScope:searchScope,viewname:viewname,excludedRecords:excludedRecords};
	ldAjax(url,params,function (restobj) {
		ld('#rptContentLoading').hide();
		if(empty(restobj)) return false;
		var discontinuedConvert_html = '<div id="discontinuedConvertcontent" class="pop_remind_content">'+ restobj.log.value +'</div>';
		var discontinuedConvert_popupobj = CrmPopup.load(restobj.title.value,'','','LdPopWidth600px','Products','',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL'])
		discontinuedConvert_popupobj.show(discontinuedConvert_html);

		ld('#'+discontinuedConvert_popupobj.divid+'_btncancel').unbind('click').bind('click',function() {
			ld('#current_page_boxes').val('');//清空所选单据checkbox
			ld('#allselectedboxes').val('');//清空选择全部参数
			ld('#selectedboxes').val('');
			getListViewEntries_js('Products', restobj.start.value);//刷新页面
		});
		ld('#'+discontinuedConvert_popupobj.divid+'_btnok').unbind('click').bind('click',function() {
			discontinuedConvert_popupobj.CancelEvent();
			ld('#current_page_boxes').val('');//清空所选单据checkbox
			ld('#allselectedboxes').val('');//清空选择全部参数
			ld('#selectedboxes').val('');
			getListViewEntries_js('Products', restobj.start.value);//刷新页面
		});

	});
}

function addtocart(record)
{
    getJsScript('include/js/modules/Products/shopcart.js',function(){
        addtocarts(record);
    });
}

//“批量上架”“批量下架”
function Batchoperateshelves(module,operatetype)
{
    var select_options = document.getElementById('allselectedboxes').value;
    var count=select_options.split(";").length-1;
    if(select_options=='all')
    {
        count=$('numOfRows').value;
    }
    if(count <= 0){
        RemindsMsg("","LdPopWidth400px","","yes","","");
        return false;
    }

    if(count > getMaxMassOperationLimit()) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		//确定按钮
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			comfirmBatchoperateshelves(module,select_options,operatetype);
		})
		return false;
    } else {
        comfirmBatchoperateshelves(module,select_options,operatetype);
    }
}
//“批量上架”“批量下架”确认
function comfirmBatchoperateshelves(module,select_options,operatetype)
{
    
    var gstart='';
    if(document.forms['massdelete'].pagenum!=undefined)
    {
        gstart="&start="+document.forms['massdelete'].pagenum.value;
    }
    else
    {
        gstart="&start="+document.forms['massdelete'].pagenum[0].value;
    }
    var viewname=document.getElementById("viewname").value;
    var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var excludedRecords = $('excludedRecords').value;
	ld("#BathoperatefillDiv").css('display','none');
	var url = "index.php?module=Products&action=ProductsAjax&file=BatchONorOFFShelves&frommodule="+module+gstart+"&operate="+operatetype;
	//zkt 树结构显示增加条件，获取树结构点击条件
	if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
		url += '&isshowModuleListTree=yes';
	}
	var params = {idstring:select_options,
		SearchScope:searchScope,viewname:viewname,excludedRecords:excludedRecords};
	ldAjax(url,params,function(restobj){
		ld('#rptContentLoading').hide();
		if(empty(restobj)) return false;
		var BathoperatefillConvert_html = '<div id="BathoperatefillConvertcontent" class="pop_remind_content">'+ restobj.log.value +'</div>';
		var BathoperatefillConvert_popupobj = CrmPopup.load(restobj.title.value,'','','LdPopWidth600px',module,'',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL'])
		BathoperatefillConvert_popupobj.show(BathoperatefillConvert_html);
		ld('#'+BathoperatefillConvert_popupobj.divid+'_btncancel').unbind('click').bind('click',function() {
			ld('#current_page_boxes').val('');//清空所选单据checkbox
			ld('#allselectedboxes').val('');//清空选择全部参数
			ld('#selectedboxes').val('');
			getListViewEntries_js(module, restobj.start.value);//刷新页面
		});
		ld('#'+BathoperatefillConvert_popupobj.divid+'_btnok').unbind('click').bind('click',function() {
			BathoperatefillConvert_popupobj.CancelEvent();
			ld('#current_page_boxes').val('');//清空所选单据checkbox
			ld('#allselectedboxes').val('');//清空选择全部参数
			ld('#selectedboxes').val('');
			getListViewEntries_js(module, restobj.start.value);//刷新页面
		});

	});
}
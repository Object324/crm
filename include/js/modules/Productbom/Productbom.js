/*********************************************************************************
**{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

var bom_edit_qty = 0;
/**
 * 添加产品信息
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_setProduct(product_id,product_name,unitprice,desc,subprod_id,pro_all,curr_row){
	var parentwindow = window;var qty = 1;
	if(bom_edit_qty && bom_edit_qty > 0){//产品弹出框快速创建，编辑产品套餐时，产品数量赋值
		qty = bom_edit_qty;
	}
	if(window.opener != undefined && document.getElementById('proTab') == undefined)
		parentwindow = window.opener;
	var subpro = pro_all.split(",");

	var inputs = getBomFormObj(parentwindow);

	inputs.elements["productname"+curr_row].value = product_name;
    //设置产品名称为不可输入
    document.getElementById("productname"+curr_row).style.cursor = 'not-allowed';
	document.getElementById("productname"+curr_row).disabled  = true;
	
	inputs.elements["hdnProductId"+curr_row].value = product_id;
	//inputs.elements["comment"+curr_row].value = desc;
	inputs.elements["quantity"+curr_row].value = qty;
	//inputs.elements["listprice"+curr_row].value = unitprice;
	//inputs.elements["unitprice"+curr_row].value = unitprice;
	var bomtotal = qty * unitprice;
	//parentwindow.document.getElementById("bomtotal"+curr_row).innerHTML = bomtotal.toFixed(2);
	var subprolen = subpro.length;
	for(var i=0;i<subprolen; i++){//自定义产品字段
		spanname = subpro[i].split(":");
		if(parentwindow.document.getElementById(spanname[0]+curr_row) != undefined){
			if(spanname[0] == 'costprice')
				parentwindow.document.getElementById(spanname[0]+curr_row).value = spanname[1];   
			else
				parentwindow.document.getElementById(spanname[0]+curr_row).innerHTML = spanname[1];   
		}
	}
	bom_productEventBind(curr_row);//绑定事件
}

var istotal = 1;//是否计算套餐售价、商品总价（手动输入套餐售价后，不再再次计算套餐售价）

/**
 * 获取form表单对象
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-27
 */
function getBomFormObj(parentwindow){
    var inputs;
	if(!parentwindow) parentwindow = window;
	if(typeof(parentwindow.document.EditView) != 'undefined')
		inputs = parentwindow.document.EditView;
	else if(typeof(parentwindow.document.QcbomEditView) != 'undefined')
		inputs = parentwindow.document.QcbomEditView;
	return inputs;
}
/**
 * 计算产品条数
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-27
 */
function bom_totalnoofrows(){
    var max_row_count = document.getElementById('proTab').rows.length;
        max_row_count = eval(max_row_count)-2;
	//set the total number of products
	var inputs = getBomFormObj();
	//inputs.totalProductCount.value = max_row_count;	
}

/**
 * 绑定套餐售价事件
 * @@project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_init(setype){
    var oldtotal = 0;
  

}

// /**************		产品选择框		**************/
/**
 * 产品套餐操作类
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-27
 */
this.ProductBomEvent = function(){
	this.mode;// 状态
	var bomisinit = 0;//是否已经初始化
	var isbomsubmit = 1;//是否提交
	var bom_userid = 0;//用户初始ID
	this.bom_id = 0;
    var that=this;

	this.selectProductList = function(){//选择产品套餐
		if(isbomsubmit == 2) return false;//防止重复点击
		isbomsubmit = 2;
		var bomid = ld('#numberCopies_bomid').val();
		var productid = ld('#numberCopies_prodid').val();
		if(productid != ''){//传入产品ID，单选产品套餐模式
			var nc_number = ld('#numberCopies_number').val();
			if(nc_number == ''){
				RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
				ld('#numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			nc_number = parseFloat(nc_number);
			if(nc_number <= 0){
				RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
				ld('#numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
			urlstr += '&setype=product&productid='+productid;
		
			this.Ajax(urlstr,function(rest){
				if(rest != ''){
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					y = 0;var checkproduct = window.opener.rmb_checkRMBProduct();
					var mod = window.opener.document.EditView.module.value;
					var bomselectproduct = 1;var bomprod = ld('#numberCopies_bomprod').val();
					var bomprodobj = eval('('+ bomprod +')')?eval('('+ bomprod +')'):JSON.parse(bomprod);
					var nc_number = ld('#numberCopies_number').val();
					var bom_name = ld('[name=QcbomEditView] [name=subject]').val();
					var packageTotal = ld('[name=QcbomEditView] [name=packageTotal]').val();
					ld.each(restobj,function(entityid,entityobj){//循环产品信息，并添加到页面上
						var prod_array = entityobj.vt_prod_arr;
						if(y>0) {
							var row_id = window.opener.fnAddProductRow(mod);
						} else {
							var row_id = ld('#bom_curr_row').val();
						}
						for (var columnname in prod_array) {
							if(window.opener.document.getElementById(columnname+row_id) != undefined){
								if(columnname == 'quantity'){
									if(nc_number > 0 && prod_array['quantity'] > 0){
										prod_array['quantity'] = nc_number * prod_array['quantity'];
									}
								}
								if(window.opener.document.getElementById('span_'+columnname+row_id) != undefined){
									window.opener.document.getElementById('span_'+columnname+row_id).innerHTML = prod_array[columnname];
								}
								window.opener.document.getElementById(columnname+row_id).value = prod_array[columnname];
							}
							if(columnname == 'productname'){
								window.opener.document.getElementById('productname'+row_id).disabled  = true;
								window.opener.document.getElementById('productname'+row_id).style.cursor = 'not-allowed';
							}
						}
						y=y+1;
					});
				}
				window.close();
			});
		}else if(bomid != ''){//产品套餐多选
			var bomqty = {};var bom_bool = 0;var numcopies = 0;
			if(ld('#numberCopies_radio_1').attr('checked')){//相同份数
				var nc_number = ld('#numberCopies_number').val();
				if(nc_number == ''){
					RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
					ld('#numberCopies_number').focus();
					isbomsubmit = 1;
					return false;
				}
				nc_number = parseFloat(nc_number);
				if(nc_number <= 0){
					RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
					ld('#numberCopies_number').focus();
					isbomsubmit = 1;
					return false;
				}
				numcopies = 1;
			}else{
				ld('#'+divid+'  [name=numberCopies_bomnamenum]').each(function(){
					if(ld(this).val() == ''){
						RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
						ld(this).focus();bom_bool = 1;
						return false;//跳出本次循环，类似于break
					}else if(ld(this).val() > 0)//数量必须大于0
						bomqty[ld(this).attr('bomid')] = ld(this).val();
					else{
						RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
						ld(this).focus();bom_bool = 1;
						return false;//跳出本次循环，类似于break
					}
				});
				if(bom_bool == 1){
					isbomsubmit = 1;
					return false;
				}
				numcopies = 2;
			}
			if(numcopies == 0) return false;
			var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
			urlstr += '&setype=bomproduct&bomid='+bomid;
			if(document.getElementById('returnmodule')){
				urlstr += '&returnmodule='+document.getElementById('returnmodule').value;
			}
			if(document.getElementById('curr_row')){
				urlstr += '&curr_row='+document.getElementById('curr_row').value;
			}
			if(document.getElementById('currencyid')){
				urlstr += '&currencyid='+document.getElementById('currencyid').value;
			}
			if(document.getElementById('warehouse')){
				urlstr += '&wareid='+document.getElementById('warehouse').value;
			}
			//alert(urlstr);
			this.Ajax(urlstr,function(rest){//获取bom对应的产品信息
				if(rest != ''){
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					y = 0;var checkproduct = window.opener.rmb_checkRMBProduct();
					var mod = window.opener.document.EditView.module.value;
					var nc_number =ld('#numberCopies_number').val();
					ld.each(restobj,function(entityid,entityobj){//循环产品信息，并添加到页面上
						var prod_array = entityobj.vt_prod_arr;
						if(y>0) {
							var row_id = window.opener.fnAddProductRow(mod);
						} else {
							var row_id = ld('#curr_row').val();//#bom_curr_row
						}
						for (var columnname in prod_array) {
							if(window.opener.document.getElementById(columnname+row_id) != undefined){
								if(columnname == 'quantity'){
									if(numcopies == 1){//相同份数
										if(nc_number > 0 && prod_array['quantity'] > 0){
											prod_array['quantity'] = nc_number * prod_array['quantity'];
										}
									}else{//不同份数
										if(bomqty[prod_array['bom_id']] > 0 && prod_array['quantity'] > 0){
											prod_array['quantity'] = bomqty[prod_array['bom_id']] * prod_array['quantity'];
										}
									}
								}
								if(window.opener.document.getElementById('span_'+columnname+row_id) != undefined){
									window.opener.document.getElementById('span_'+columnname+row_id).innerHTML = prod_array[columnname];
								}
								window.opener.document.getElementById(columnname+row_id).value = prod_array[columnname];
							}
							if(columnname == 'productname'){
								window.opener.document.getElementById('productname'+row_id).disabled  = true;
								window.opener.document.getElementById('productname'+row_id).style.cursor = 'not-allowed';
							}
						}
						y=y+1;
					});
					
				}
				window.close();
			});
		}
	}
	this.selectcancel = function(){//填写套餐份数界面，取消按钮事件
		this.clearhtml();
		//getListViewEntries_js('Productbom','parenttab=Tools&start=1');
		//fninvshnew('qcbomnumberDiv');
		cancelCrmPopup();
		isbomsubmit = 1;
	}
/*	this.copy = function(entityid){//赋值
		this.mode = 'copy';
		this.initBom(entityid);
	}
	this.update = function(entityid){//临时调整
		this.mode = 'update';
		this.initBom(entityid);
	}*/
    
	this.trim = function(string){//去除空格
		return string.replace(/\s/g,"");
	}
	this.clearhtml = function(){//清空
		if(bom_userid > 0){
			ld('[name=QcbomEditView] [name=bomsmownerid]').val(bom_userid);
			var defaultval = j("[name=QcbomEditView] [name=bomsmownerid]").find("option:selected").text()
			ld('[name=QcbomEditView] #cmb_span_optiontext_bomsmownerid').val(defaultval);
			ld('#productbom_no').val('');
			var inputs = getBomFormObj();
			var productcount = inputs.totalProductCount.value;
			ld('#row1 img[clearimg=clear]').click();
			if(productcount > 1){
				for(var i=2;i<=productcount;i++){
					deleteRow('ProductBom',i);
				}
			}
			document.getElementById('commodityTotal_td').innerHTML = '';
			document.getElementById('commodityTotal').value = 0;
			document.getElementById('packageTotal').value = 0;
		}
	}
	this.selectBom = function(){//多选产品套餐方法
		var bomidstr = '';var rowid = '';
		var bomobj = this;
		var parnetobj;
		var selected_i = 0;
		ld('[name=selected_id]:checked').each(function(){
			//获取多选框上级td的上级tr的ID，并把当前产品套餐ID取出来
			//rowid = ld(this).parent('td').parent('tr').attr('id');
			parnetobj = bomobj.getParentTag(this,'tr');
			rowid = ld(parnetobj).attr('id');
			rowid = rowid.split(',');
			rowid = rowid[0];
			rowid = rowid.split('_');
			rowid = rowid[1];
			bomidstr += rowid+',';
			selected_i++;
		});
        if(bomidstr == ''){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
		}
        bomidstr=bomidstr.substr(0,bomidstr.length-1);//删除逗号
        
	   that.popupSelectNum(bomidstr)

	}
    this.popupSelectNum=function(bomidstr){
        
        var strarr=bomidstr.split(",");
        
       	var selected_i=strarr.length;
		var crmPopupobj = CrmPopup.load(arrJsPopLabel['NUMBEROFCOPIES'],"", "", "LdPopWidth500px",'Productbom', '', "", "", "");
		var _divs = "<div id='qcbomnumberDiv'><div id='qcbomnumber'><table class='ld-pop-container' border='0' cellpadding='0' cellspacing='0' width='100%'><tbody>";
		if(selected_i > 1){//选择了两个或者两个以上的套餐
			_divs += "<tr align='left' style='display:;' id='numberCopies_radiotr' name='numberCopies_radiotr'>";
			_divs += "<td class='padB20'>";
			_divs += "<input class='input-btn-align cursorPointer' type='radio' id='numberCopies_radio_1' name='numberCopies_radio_1' value='1' onclick='bom.copiesRadio(1,\"\");' />&nbsp;";
            _divs += "<label class='cursorPointer' for='numberCopies_radio_1' onclick='bom.copiesRadio(1,\"\");'>"+arrJsPopLabel['SAMENUMBEROFCOPIES']+'</label>';
			_divs += "&nbsp;&nbsp;<input class='input-btn-align cursorPointer' type='radio' id='numberCopies_radio_2' name='numberCopies_radio_2' value='0' onclick='bom.copiesRadio(0,\""+bomidstr+"\");' />&nbsp;";
            _divs += "<label class='cursorPointer' for='numberCopies_radio_2' onclick='bom.copiesRadio(0,\""+bomidstr+"\");'>"+arrJsPopLabel['NUMBEROFDIFFERENT']+'</label>';
			_divs += "</td>";
			_divs += "</tr>";
		}
        else
        {
            _divs += "<input style='display:none' class='input-btn-align' checked  type='radio' id='numberCopies_radio_1' name='numberCopies_radio_1' value='1' onclick='bom.copiesRadio(1,\"\");' />";
        }
		_divs += "<tr>";
		_divs += "<td>";
		_divs += "<div id='numberCopies_div_1' name='numberCopies_div_1'>";
		_divs += "<font color='red'>*</font>"+arrJsPopLabel['NUMBEROFCOPIES']+':';
		if(language=='zh-cn'){
            _divs += "<input type='text' id='numberCopies_number' name='numberCopies_number' autocomplete='off' value=1 class='ld-input-inner' style='width: 83%;margin-left: 2%;' onkeyup='this.value=this.value.replace(/\D/g,\"\");' maxlength='11'>";
        }
        else{
            _divs += "<input type='text' id='numberCopies_number' name='numberCopies_number' autocomplete='off' value=1 class='ld-input-inner' style='width: 66%;margin-left: 2%;' onkeyup='this.value=this.value.replace(/\D/g,\"\");' maxlength='11'>";
        }
		_divs += "</div>";
		_divs += "</td>";
		_divs += "</tr>";
		_divs += "</tbody>";
		_divs += "</table>";
		_divs += "<div id='numberCopies_div_2' name='numberCopies_div_2' style='display:none;max-height:250px;overflow-y:auto;margin-top: -30px;'>";
		_divs += "<table class='ld-public-content' style='padding: 0 12px 10px;' cellspacing='0' cellpadding='0' border='0' width='100%' name='numberCopies_div_2_table'>";
		_divs += "<tr>";
		_divs += "<td class='ld-form-item-label'>"+arrJsPopLabel['PRODUCTPACKAGE']+"</td>";
		_divs += "<td class='ld-form-item-content'><font color='red'>*</font>&nbsp;"+arrJsPopLabel['NUMBEROFCOPIES']+"</td>";
		_divs += "</tr>";
		_divs += "</table>";
		_divs += "</div>";
        _divs += "</div></div>";
		_divs += "<div class='E_pbtn'>";
		_divs += "<input name='button' class='E_pbtnok' value='"+arrJsPopLabel['CONFIRMED']+"' onclick='bom_selectProductList();' type='button'/>";
		_divs += "<span>&nbsp;</span>";
		_divs += "<input name='button' class='E_pbtncancel' value='"+arrJsPopLabel['CANCEL']+"' onclick='bom.selectcancel();' type='button'/>";
		_divs += "<input type='hidden' id='numberCopies_bomid' name='numberCopies_bomid'/>";
		_divs += "<input type='hidden' id='numberCopies_prodid' name='numberCopies_prodid'/>";
		_divs += "<input type='hidden' id='numberCopies_bomprod' name='numberCopies_bomprod'/>";
		_divs += "</div>";
		crmPopupobj.show(_divs);
		var prevdivid = crmPopupobj.divid;
		this.initNumberCopies(2);
		CrmPopup.findHtmlobj(prevdivid,'numberCopies_bomid').val(bomidstr);
		CrmPopup.findHtmlobj(prevdivid,'numberCopies_prodid').val('');
        
    }
	this.copiesRadio = function(setype,bomidstr){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		if(setype == 1){
			CrmPopup.findHtmlobj(divid,'numberCopies_div_1').css('display','');
			CrmPopup.findHtmlobj(divid,'numberCopies_div_2').css('display','none');
			CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').prop('checked','checked');
			CrmPopup.findHtmlobj(divid,'numberCopies_radio_2').prop('checked',false);
		}else{
			var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
			urlstr += '&setype=bomname&bomid='+bomidstr;
			this.Ajax(urlstr,function(rest){
				if(rest != ''){
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					//ld("#numberCopies_div_2_table tr:not(:first)").remove();//删除除第一行外所有行
					CrmPopup.findHtmlobj(divid,'numberCopies_div_2_table').find('tr:not(:first)').remove();
					var tabletr = '';var restindex = 0;
					ld.each(restobj.bom,function(entityid,entityname){
						tabletr = '<tr bgcolor="white"><td class="ld-form-item-label">'+entityname+'</td>'+
									'<td class="ld-form-item-content"><input class="ld-input-inner" type="text" name="numberCopies_bomnamenum" '+
									'autocomplete="off" maxlength="11" bomid="'+entityid+'" '+
									'onkeyup="this.value=this.value.replace(/\\D/g,\'\');" ></td></tr>';
						CrmPopup.findHtmlobj(divid,'numberCopies_div_2_table').append(tabletr);
						++ restindex;
						
						if(restindex == restobj.row){
							CrmPopup.findHtmlobj(divid,'numberCopies_div_1').css('display','none');
							CrmPopup.findHtmlobj(divid,'numberCopies_div_2').css('display','');
							CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').prop('checked',false);
							CrmPopup.findHtmlobj(divid,'numberCopies_radio_2').prop('checked','checked');
						}
					});
				}
			});
		}
	}
	this.initNumberCopies = function(setype){//初始化套餐份数界面
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		CrmPopup.findHtmlobj(divid,'numberCopies_div_1').css('display','');
		CrmPopup.findHtmlobj(divid,'numberCopies_div_2').css('display','none');
		CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').attr('checked',true);
		CrmPopup.findHtmlobj(divid,'numberCopies_radio_2').attr('checked',false);
        
		CrmPopup.findHtmlobj(divid,'numberCopies_number').val('1');//35438: 合同订单新增界面>选择产品弹出层>选择产品套餐>选择产品套餐份数弹出层：套餐份数应该默认为“1”
		if(setype == '1'){//非选择产品套餐状态
			CrmPopup.findHtmlobj(divid,'numberCopies_radiotr').css('display','none');
		}else{//
			CrmPopup.findHtmlobj(divid,'numberCopies_radiotr').css('display','');
		}
	}
	this.getParentTag = function(obj,tag){//传入对象和tag标签名，递归回去对象上级（或上上级）的tag标签
		var els = '';var tagname = '';
		els = ld(obj).parent();
		tagname = ld(els).get(0).tagName;
		if(tagname.toLowerCase() != tag.toLowerCase()){
			els = this.getParentTag(els,tag);
		}
		return els;
	}
	/**
	 * Ajax封装方法，callback为回掉方法
	 * @author Tujt 2014-11-27
	 */
	this.Ajax = function(data,callback){
		// ld("#status").css("display","inline");
		ldAjaxHtml('index.php?',data,function(rest){
			DelProgressObjs();
			// ld("#status").css("display","none");
			callback(rest);
		});
	}
}
var bom = new ProductBomEvent();
function bom_updatesave()
{
    //调整保存
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.after_save=function(){
        bom.popupSelectNum(popupobj.record+"");
    }
    SaveDataRecord.save();
}
function bom_edit(entityid,mode)
{
    var entityarr = [];
	var bom_id;
	var curr_row = 0;
	var frommdoule = '';
    
	if(entityid != '')
		entityarr = entityid.split(',');
	var record = parseInt(entityarr[0],10);
	if(record > 0){//获取对应的产品套餐ID
		bom_id = record;
	}else{
		bom_id = '';
	}
    if(mode=='edit')//编辑
   {
     var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",'Productbom',"","","","",bom_id);
    Popupobj.prevshow();
    PageRecordPopup.showpage("Productbom",bom_id,"&refreshmodule=Productbom",PageRecordPopup.params);
   }
   else if(mode=='update'){
             var paramobj=new PageRecordPopup.fun_params();
             paramobj.save_funname=bom_updatesave;
             var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",'Productbom',"","","","",bom_id);
            Popupobj.prevshow();
            PageRecordPopup.showpage("Productbom",bom_id,"&refreshmodule=Productbom&adjustselectquantity=yes",paramobj);
   }
   else if(mode=='copy'){
        
         var objparams=new CreatePagePopup.params();
            objparams.params['isduplicate']='yes';
      CreatePagePopup.showpage("Productbom","&refreshmodule=Productbom&record="+bom_id+"&isDuplicate=true",objparams);
   }
   
    
}

/**
 * 
 * @param
 * @returns
 * @author Tujt 
 */	
var isbomsubmit = 1;
function bom_selectProductList(){
	if(isbomsubmit == 2) return false;//防止重复点击
	isbomsubmit = 2;
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var createpopupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var prevdivid=prevpopupobj.divid;
	var bomid = CrmPopup.findHtmlobj(divid,'numberCopies_bomid').val();
	var productid = CrmPopup.findHtmlobj(divid,'numberCopies_prodid').val();
    var edit_createPopupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    
	//alert(bomid);
	if(bomid != ''){//传入产品ID，单选产品套餐模式
		var bomqty = {};var bom_bool = 0;var numcopies = 0;
       
		if(CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').is(":checked")){//相同份数
			var nc_number = CrmPopup.findHtmlobj(divid,'numberCopies_number').val();
			if(nc_number == ''){
				RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
				CrmPopup.findHtmlobj(divid,'numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			nc_number = parseFloat(nc_number);
			if(nc_number <= 0){
				RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
				ld('#numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			numcopies = 1;
		}else{
			ld('#'+divid+' [name=numberCopies_bomnamenum]').each(function(){
				if(ld(this).val() == ''){
					RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
					ld(this).focus();bom_bool = 1;
					return false;//跳出本次循环，类似于break
				}else if(ld(this).val() > 0)//数量必须大于0
					bomqty[ld(this).attr('bomid')] = ld(this).val();
				else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
					ld(this).focus();bom_bool = 1;
					return false;//跳出本次循环，类似于break
				}
			});
			if(bom_bool == 1){
				isbomsubmit = 1;
				return false;
			}
			numcopies = 2;
		}
      
		if(numcopies == 0) return false;
		var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
		urlstr += '&setype=bomproduct&bomid='+bomid;
		//alert(urlstr);
		//alert(CrmPopup.findHtmlobj(prevdivid,'returnmodule').val());
		if(CrmPopup.findHtmlobj(prevdivid,'return_module').val() != undefined && !empty(CrmPopup.findHtmlobj(prevdivid,'return_module').val()) ){
			urlstr += '&returnmodule='+CrmPopup.findHtmlobj(prevdivid,'return_module').val();
		}else if (prevpopupobj.popuptype == 'inventory_prod'){
			urlstr += '&returnmodule='+ prevpopupobj.currentmodule;
		}
		
		if(CrmPopup.findHtmlobj(prevdivid,'curr_row').val() != undefined){
			urlstr += '&curr_row='+CrmPopup.findHtmlobj(prevdivid,'curr_row').val();
		}
		var bom_total = 0;//套餐售价
		var total = 0;
		if(CrmPopup.findHtmlobj(prevdivid,'total').val() != undefined){
			total = CrmPopup.findHtmlobj('div_pagerecord','total').val();
		}
       	var tableobj=edit_createPopupobj.getDetailTableObj();
		var emptyrows = [];
		var startemptyrowindex = 0;
		var trlen = edit_createPopupobj.detaildatavalue_arr.length;
		for (var tmpi =0; tmpi <=trlen-1; tmpi++) {
			if (edit_createPopupobj.detaildatavalue_arr[tmpi].productid==undefined|| edit_createPopupobj.detaildatavalue_arr[tmpi].productid == ''
				|| edit_createPopupobj.detaildatavalue_arr[tmpi].productid == 0) {
				if (edit_createPopupobj.detaildatavalue_arr[tmpi].databind == undefined ||
					edit_createPopupobj.detaildatavalue_arr[tmpi].databind == 'no') {
					var tmprowobj = ld(tableobj).find("tr[rowindex=" + tmpi + "]");//赋值的行对象
					edit_createPopupobj.selectproductobj.setDataBind(tmprowobj);
				}
				emptyrows.push(tmpi+1)
			}
		}
		var entmprowslen = emptyrows.length;
		//zkt 20231013 XUQIU1001341 SQL注入
		ldAjaxHtmlNoProgress('index.php?',urlstr,function(response) {

			if(response != ''){
				var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
				y = 0;
				var mod =  CrmPopup.findHtmlobj('div_pagerecord','module').val();

				ld.each(restobj,function(entityid,entityobj){//循环产品信息，并添加到页面上

					var prod_array = entityobj.vt_prod_arr;
					if(y>0) {
						//添加行
						if (startemptyrowindex < entmprowslen)
							row_id = emptyrows[startemptyrowindex];
						if (empty(row_id)) {
							row_id = edit_createPopupobj.selectproductobj.fnaddProductRow();
						}
						startemptyrowindex++;
					} else {
						var row_id =edit_createPopupobj.selectproductobj.chooseProductRowindex;//#bom_curr_row
						row_id = parseInt(row_id);
						if(emptyrows.indexOf(row_id)>-1){
							startemptyrowindex++;
						}
					}
					var intproductid=prod_array["hdnProductId"];
					var rowobj=ld(tableobj).find("tr[rowindex="+row_id+"]");
					for (var columnname in prod_array) {
						if(ld(rowobj).find(" [detailcolumnname="+columnname+"]").val() != undefined && columnname != 'comment'){
							if(columnname == 'quantity'){
								if(numcopies == 1){//相同份数
									var nc_number = CrmPopup.findHtmlobj(divid,'numberCopies_number').val();//份数
									if(nc_number > 0 && prod_array['quantity'] > 0){
										prod_array['quantity'] = nc_number * prod_array['quantity'];
									}
								}else{//不同份数

									if(bomqty[prod_array['bom_id']] > 0 && prod_array['quantity'] > 0){
										prod_array['quantity'] = bomqty[prod_array['bom_id']] * prod_array['quantity'];
										nc_number= bomqty[prod_array['bom_id']];
									}else{
										prod_array['quantity'] = nc_number * prod_array['quantity'];
									}
								}
							}
							if(ld(rowobj).find(" [detailcolumnname=span_"+columnname+"]").html() != undefined){
								ld(rowobj).find(" [detailcolumnname=span_"+columnname+"]").html(decodeURIComponent(prod_array[columnname]));
							}

							ld(rowobj).find(" [detailcolumnname="+columnname+"]").val(decodeURIComponent(prod_array[columnname]));

							edit_createPopupobj.detaildatavalue_arr[row_id-1][columnname] = decodeURIComponent(prod_array[columnname]);

						}
						if(columnname == 'productname'){
							ld(rowobj).find(" [detailcolumnname=productname]").attr("disabled",true);
							ld(rowobj).find(" [detailcolumnname=productname]").css("cursor",'not-allowed');
						}
						//chj 2021/5/19 45960: （http://51mis.com/hy/demo20210518 [^]）客户问题（谢彦涛），出库单选择“产品套餐”，仓库默认“总仓”，保存时提示仓库不能为空，无法保存
						if(columnname == 'wareid_rawvalue' && !empty(prod_array[columnname])){
							ld(rowobj).find("#wareid").val(prod_array[columnname]);
						}
						if(columnname == 'wareid' && empty(prod_array[columnname])){
							ld(rowobj).find("#wareid").val(2);
						}

						if(columnname == 'product_desc'){

							//edit：can 20200730 套餐名称


							ld(rowobj).find("[tag=dv_productbominfo]").css("display",'');
							ld(rowobj).find("[tag=productbomname]").html(prod_array['bom_name']);//套餐名称（用于界面显示）
							ld(rowobj).find("[tag=productbomquantity]").html(nc_number);
							//ld(rowobj).find("[name=productbomid]").val(prod_array['bom_id']);//套餐id(用于保存)
							ld(rowobj).find("[name=productbomquantity]").val(nc_number);
							prod_array['productbomquantity']=nc_number;

							edit_createPopupobj.detaildatavalue_arr[row_id-1]['productbomname'] = prod_array['productbomname'];

							edit_createPopupobj.detaildatavalue_arr[row_id-1]['productbomquantity'] = prod_array['productbomquantity'];
							edit_createPopupobj.detaildatavalue_arr[row_id-1]['productbomid'] = prod_array['bom_id'];
							//var product_desc = prod_array['bom_name'] +'('+ prod_array['bom_total'] +'*'+ prod_array['quantity']+')';
							//	CrmPopup.findHtmlobj(edit_createPopupobj.divid,'comment'+row_id).html(decodeURIComponent(product_desc));
						}
						if(columnname == 'bom_total'){

							if(numcopies == 1){//相同份数
								bom_total = prod_array[columnname] * nc_number;
							}else{

								bom_total = prod_array[columnname] * bomqty[prod_array['bom_id']];
							}

						}

						//ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示
						if(ld.inArray(columnname,edit_createPopupobj.allproductimagefieldname) >= 0){
							getproductImageName(prod_array['hdnProductId'],row_id,columnname);
						}

					}
					edit_createPopupobj.selectproductobj.setValue(intproductid,prod_array,row_id);
					//@edit:liushuai,2020-09-18,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格（选择多个产品时，在插入行之后并赋完值再调用）
					createpopupobj.RelatedProductToolFieldtriggcols=[];	//chj 2022/7/12 报价单选择“产品套餐”时没有没有根据开发公式计算出对应金属的基础价
					getRelatedProductToolFieldPriceCallBack(createpopupobj,row_id);
					y=y+1;
				});
				var pageRecordPopupobj =CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
				var fieldformulaobj=pageRecordPopupobj.fieldformulaobj;

				fieldformulaobj.changetaxprice();
				//edit:can 20210925 47942: （81mis.com/kfbcrm）销售管理》合同订单》新建，分录中选择产品套餐不会自动计算，修改分录中字段内容后才计算
				fieldformulaobj.CountsubTotal();


			}
			popupobj.CancelEvent();
			prevpopupobj.CancelEvent();
			// edit_createPopupobj.selectproductobj.setScrollMoveEvent(prod_array,9);
		});

	}
}

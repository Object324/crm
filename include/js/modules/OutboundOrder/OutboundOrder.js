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
var OutboundOrderForApprove = function(persence,stockid,stype){
	var isinit = 0;
	ld.ajax("index.php?action=OutboundOrderAjax&module=OutboundOrder&file=OutboundOrderForApprove&persence="+persence+"&record="+stockid+"&stype="+stype)
	.done(function(results){
		var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
		if(restobj.code == 1){
			if(stype == 'check'){
				if(persence ==2){
					window.location.href="index.php?action=DetailView&module=OutboundOrder&record="+stockid+"&salestype=yes";
				}else{
					window.location.href="index.php?action=DetailView&module=OutboundOrder&record="+stockid+"&salestype=yes&sendtype=yes";
				}
			}else{
				var obj = new SaveApproveOperation();
				ld_defer.then(obj.saveApproveBefore()).then(obj.saveApprove()).then(obj.saveApproveAfter());
				return true;
			}
		}else if(restobj.code == -2){
			//chj 2020/12/25 43323: 系统参数设置为不允许负库存出库，审核时提示信息样式不对
			var info = '<b>'+restobj.err_subject+'</b><a class=\'icon-mediumimg_1\' href=\'javascript:;\' style=\'position:absolute;right:0.7%;margin: -3px 5px 0 0;\' onclick="getLinksUrl(\'OutboundOrder\',\'Module\',\'toexamine\');" ></a><br />';
			info += restobj.err_info;
			RemindsMsg("","width450",popupobj.module,"","",info);
			/*
			if(ld('#findproductqtyinstock_div').length == 1){
				if(0 == isinit) isinit = 1;
			}
			fninvshnew('ApproveBlocks');
          
			var divobj = createElementDivs('findproductqtyinstock_div');
			ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['Savefailed']);
			ld(divobj).css('max-height','500px');
			ld('#findproductqtyinstock_divcontent').html(info);
			ld('#findproductqtyinstock_divcontent').css('max-height','300px');
			ld('#findproductqtyinstock_divcontent').css('border','none');
			ld('#findproductqtyinstock_div .D_pbtn .D_pbtncancel').css('display','none');
			if(0 == isinit){//初次加载的时候才显示
				ld('#fieldmap_div').css('top','28%');
			}
			//确认事件
			ld('#findproductqtyinstock_div .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
				fninvshnew('findproductqtyinstock_div');
				return false;
			});*/
			return false;
		}
        else if(restobj.code==-3)
        {
            alert(restobj.msg);
            return false;
        }
        else{
             
			fninvshnew('ApproveBlocks');
			var opertion;
			if(stype == 'check'){
				opertion = arrJsPopLabel['CHECKFAIL'];
			}else{
				opertion = arrJsPopLabel['APPROVEFAIL'];
			}
			var prod_data = restobj.err_info;
			var _error = '<div style="width:97%;max-height:400px;overflow-y:auto;margin-top:10px;margin-bottom:10px;line-height:22px;padding-left:10px;font-weight:normal;"><b>'+arrJsPopLabel['THETOTALOUTBOUNDQUANTITY'] + ',' + opertion+'!'+ '</b><a class=\'icon-mediumimg_1\' href=\'javascript:;\' style=\'position:absolute;right:0.7%;margin: -3px 5px 0 0;\' onclick="getLinksUrl(\'OutboundOrder\',\'Module\',\'toexamine\');" ></a><br />';
			var num = 1;
			for(var lineitem_id in prod_data){
				_error += num + '、 '+prod_data[lineitem_id].productname + ' '+ arrJsPopLabel['THECUMULATIVEQUANTITY'] + ':'+prod_data[lineitem_id].haveoutproductcount + ',' +
					arrJsPopLabel['BUTTHENUMBEROFTHEOUT'] + ':' + prod_data[lineitem_id].balanceoutproductcount + '<br />';
				num++;
			}
			_error += '</div>';
			var divobj = createElementDivs('out_message');
            //edit:can 2020-10-29 43062: （https://61mis.com/kfbcrm [^]）设置不允许负库存出库，更新库存数量的触发点为审批通过，出库单（出库单编号：CK151）审批失败弹出层标签没有显示，显示为空
			ld(divobj).find('.E_pop_tit .E_ptita').html(opertion);
			ld('#out_messagecontent').html(_error);
			ld(divobj).css('max-height','500px');
			ld('#out_messagecontent').css('max-height','400px');
			ld('#out_messagecontent').css('border','none');
			ld(divobj).find('.D_pbtn .D_pbtncancel').css('display','none');
			ld(divobj).find('div.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
				fninvshnew('out_message');puyoungJS_DialogBox.unblock();
			});
			return false;
		}
	})
}
//出库单 - 审核、反审核
function set_stock_presence(stockid,persence,type)
{
	//persence 1:审核  2反审核
    if(persence == 1){
    	var message = arrJsPopLabel['DETERMINELIBRARYYET'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",message);
    	//点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        	OutboundOrderForApprove(persence,stockid,'check');
        });
        return false;
	}else{
		var message = arrJsPopLabel['SUREWANTREVOKESECRETARY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",message);
		//点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        	OutboundOrderForApprove(persence,stockid,'check');
        });
        return false;
	}
}

function set_stock_smsSend(stockid)
{
    window.location.href="index.php?action=DetailView&module=OutboundOrder&parenttab=Stock&record="+stockid+"&salestype=yes&sendtype=yes";
}


function getWarehouse(warehouseid,obj,type){
        if(document.getElementById("selectwareid") != undefined)
        {
            var select_id = document.getElementById("selectwareid").value;
            if(select_id > 0)
            {
                $('morewarehouseid').className='';
                document.getElementById("selectwareid").value = '';
            } 
        }
    	if(obj!=null){
        var classmethods = ld('.on');
        for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
        }
        obj.className='on On';

        }
		$('wareid').value=warehouseid; 
        getListViewEntries_js('OutboundOrder');
		 if(document.getElementById('morewarehouseid')!=undefined)
		{
			ld('morewarehouseid').className='';   
		}
		if(ld('#ware_select_more') != undefined){
			ld('#ware_select_more').removeClass('On');
			ld('#cmb_span_optiontext_selectwareid').val('');
		}
        
}
function getMoreWarehouse(obj,id){
	var classmethods = $$('.on');
    var warehouseid=obj.value;
   
    if(warehouseid==''){
        //您没有这个仓库的权限！
        //window.location.href='index.php?module=OutboundOrder&action=index&parenttab=Stock';
        //	0019330: 库存>出库单列表界面：全部仓库切换到更多选择“仓库数量”，然后在选择空白的，界面会闪下undefind
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
    }
    $(id).className='On';
	$('wareid').value=warehouseid; 
    getListViewEntries_js('OutboundOrder','start=1');
	ld('#ware_select_more').addClass('On');
   
}

/*
edit:can
date:20130814
reason:新增和编辑模板中选择模块事件
*/
function moduleSel(obj)
{
    	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			//postBody: 'module=Settings&action=TemplatePrintField&printtabid='+obj.value,
            postBody: 'module=Settings&action=TemplatePrintField&printtabid='+obj,
			onComplete: function(response) {
				if(response.responseText.indexOf("SUCCESS")>-1)
                {
                    var results=response.responseText.split("##SUCCESS##");
                    document.getElementById("tabField").innerHTML=results[1];
                }
				    
				else
					alert(alert_arr.ERROR_WHILE_EDITING);
			}
		}
		);

}
/*
edit:can
date:20130815
reason:打印模板新增和编辑界面字段选择
*/
function fieldSel(obj)
{
    document.getElementById("selField").value="[var."+obj.value+"]";
    
}
/*
edit:can
date:20130815
reason:打印模板中插入模板
*/

function	InsertTemplate(obj)
{
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        alert(arrJsPopLabel['PLEASESELECTFIELD']);
        return false;
    }
    var txtvalue=document.forms['frmsendInfoContent'].SelectField.options[document.forms['frmsendInfoContent'].SelectField.selectedIndex].text;
    //document.getElementById('CKcontent').value += document.getElementById("selField").value;
    //insertText(CKcontent,document.getElementById("selField").value);
	/**
	 * 用jquery重写该事件，实现在textarea光标处插入代码
	 * @reason 0014906: 出库单> 明细,关于发送短信中的"插入到内容模板"按钮点不动问题
	 * @author Tujt 2015-05-13
	 */
	(function($){
	 $.fn.extend({
	  insertAtCaret: function(myValue){
	   var $t=$(this)[0];
	   if (document.selection) {
		this.focus();
		sel = document.selection.createRange();
		sel.text = myValue;
		this.focus();
	   }
	   else 
		if ($t.selectionStart || $t.selectionStart == '0') {
		 var startPos = $t.selectionStart;
		 var endPos = $t.selectionEnd;
		 var scrollTop = $t.scrollTop;
		 $t.value = $t.value.substring(0, startPos) + myValue + $t.value.substring(endPos, $t.value.length);
		 this.focus();
		 $t.selectionStart = startPos + myValue.length;
		 $t.selectionEnd = startPos + myValue.length;
		 $t.scrollTop = scrollTop;
		}
		else {
		 this.value += myValue;
		 this.focus();
		}
	  }
	 }) 
	})(ld);
	ld('#CKcontent').insertAtCaret(ld('#selField').val());
}


function insertText(obj,str) {
    if (document.selection) {
        var sel = document.selection.createRange();
        sel.text = str;
    } else if (typeof obj.selectionStart === 'number' && typeof obj.selectionEnd === 'number') {
        var startPos = obj.selectionStart,
            endPos = obj.selectionEnd,
            cursorPos = startPos,
            tmpStr = obj.value;
        obj.value = tmpStr.substring(0, startPos) + str + tmpStr.substring(endPos, tmpStr.length);
        cursorPos += str.length;
        obj.selectionStart = obj.selectionEnd = cursorPos;
    } else {
        obj.value += str;
    }
}


//V6.5:财务和库存单据选择源单  使用橡皮擦，清除客户或者清除源单之后，分录中的产品信息应该清空，源单信息区块内容也应该清空。
clearAccountsContactsInfo.other_clear=function()
{
  clearModuleProduct("",'OutboundOrder','');
}

//出库单
function saveApproveLog(){
	var popupobj=CrmPopup.getPopupObj("last");
	var record = ld("#"+popupobj.divid+" [name=record]").val();
	var approveid = ld("#"+popupobj.divid+" [name=approveid]").val();
	var stepid = ld("#"+popupobj.divid+" [name=stepid]").val();
    var approvestatus = 0;
	if(document.frmapproveblock.approvestatus != undefined){
		approvestatus = document.frmapproveblock.approvestatus.value;
	}else if(ld("#"+popupobj.divid+" [name=approveoperate]").length>0){
        approvestatus = ld("#"+popupobj.divid+" [name=approveoperate]").val();
	}else{
	   return false;
	}
    
    if(approvestatus == 2){//审批成功操作
		OutboundOrderForApprove(1,record,'approve')
	}else{
		var obj = new SaveApproveOperation();
		ld_defer.then(obj.saveApproveBefore()).then(obj.saveApprove()).then(obj.saveApproveAfter());
	}
	
}

function jsQualifyDate(){
    this.form= document.forms['EditView']; 
    this.form.action.value='Save';
    var topBtn = ld('input[name="button"][class="save"]')[0];
    var cur_this=this;
    topBtn.onclick =function(){
         cur_this.saveOutboundOrderOrderDetail();
    }
    var botBtn = ld('input[name="button"][class="save"]')[1];
    botBtn.onclick =function(){
        cur_this.saveOutboundOrderOrderDetail();
    }
}

jsQualifyDate.prototype.saveOutboundOrderOrderDetail = function(){
    var cur_this=this;
	if(validateInventory('OutboundOrder')){
		var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
		var account_id = 0;
		if(!empty(divid)){
			account_id = CrmPopup.findHtmlobj(divid,"account_id").val();
		}
		//if(document.getElementById('hidden_rowid_'+i))
		var max_row_count = document.getElementById('rowcnt').value;
		var productinfo = [];
		var k = 0;
		for (var i=1;i<=max_row_count;i++) 
		{
			if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('quantity'+i) != undefined && document.getElementById('quantity'+i).value != ''){
				var productid = document.getElementById('hdnProductId'+i).value;
				var quantity = document.getElementById('quantity'+i).value;
				if(productid > 0){
					productinfo[k] = productid +'|'+quantity;
					k++;
				}
			}
		}
		//功能1 判断产品负库存	功能2 限制出货控制
		if(productinfo.length >= 1){
			var mode = document.EditView.mode.value;
			var record = document.EditView.record.value;
			var url = 'module=Products&action=ProductsAjax&file=CheckProductQtyinstock&persence=1&frommodule=OutboundOrder&type=save&account_id='+account_id+'&mode='+mode+'&record='+record+'&productinfo='+productinfo.join(',');
			new Ajax.Request(
				'index.php',
				{
					queue: {position: 'end', scope: 'command'},
					method: 'post',
					postBody:url,
					onComplete: function(response) {
						var isinit = 0;
						var results=trim(response.responseText);
						var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
						if(restobj.code == -1){
							var info = '<b>'+restobj.err_subject+'</b><a class=\'icon-mediumimg_1\' href=\'javascript:;\' style=\'position:absolute;right:0.7%;margin: -3px 5px 0 0;\' onclick="getLinksUrl(\'OutboundOrder\',\'Module\',\'toexamine\');" ></a><br />';
							info += restobj.err_info;
							if(ld('#findproductqtyinstock_div').length == 1){
								if(0 == isinit) isinit = 1;
							}
							var divobj = createElementDivs('findproductqtyinstock_div');
							ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['Savefailed']);
							ld(divobj).css('max-height','500px');
							ld('#findproductqtyinstock_divcontent').html(info);
							ld('#findproductqtyinstock_divcontent').css('max-height','300px');
							ld('#findproductqtyinstock_divcontent').css('border','none');
							ld('#findproductqtyinstock_div .D_pbtn .D_pbtncancel').css('display','none');
							if(0 == isinit){//初次加载的时候才显示
								ld('#fieldmap_div').css('top','28%');
							}
							//确认事件
							ld('#findproductqtyinstock_div .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
								fninvshnew('findproductqtyinstock_div');
                                //FieldDuplicateValidate('OutboundOrder',cur_this.form);
								return false;
							});
						}else if(restobj.code == -2){
							var divobj = createElementDivs('accountallowdeliverydate');
							ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['Reminder1']);
							var content_html = '';
							content_html += '<div class="qui_dialog_body ww_dialog_body" id="wechat_showTips">'
							content_html += '<div class="msgDlg">';
							content_html += '<div class="msgDlg_left">';
							content_html += '<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>';
							content_html += '</div>';
							content_html += '<div class="msgDlg_right">';
							content_html += '<div class="msgDlg_right_text">'+restobj.err_info+'</div>';
							content_html += '</div></div></div>';
							ld('#accountallowdeliverydatecontent').html(content_html);
							ld(divobj).css('max-height','500px');
							ld(divobj).css('width','450px');
							ld(divobj).css('background','#FDFDFD');
							ld('#accountallowdeliverydatecontent').css('max-height','400px');
							ld('#accountallowdeliverydatecontent').css('border','none');
							fnvshobj('', 'accountallowdeliverydate');
							ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
							ld(divobj).find('div.D_pbtn .D_pbtncancel').hide();
							ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
								fninvshnew('accountallowdeliverydate');puyoungJS_DialogBox.unblock();
							});
						}else{
							FieldDuplicateValidate('OutboundOrder',cur_this.form);
							return true;
						}
					}
				}
			); 
		}
        else
        {
            FieldDuplicateValidate('OutboundOrder',cur_this.form);
        }
        
		
		return true;
    }else{
        return false;
    }
}

//弹出短信弹出层
function SMSSendPopup()
{
    
    var parentshow=this.show;
    this.createBottomHtml=function()
    {
       
        
         
              this.popupbottomhtml='<div class="D_pbtn"> ';
              
              this.popupbottomhtml+=' <span>&nbsp;<input name="button" id="'+this.divid+'_btnok" class="D_pbtnok" value="'+this.OkText+'" tagClick="'+this.Okfun.funname+'"  type="button">';
              this.popupbottomhtml+='<span>&nbsp;</span><input name="button" class="D_pbtncancel" value="'+this.CancelText+'" id="'+this.divid+'_btncancel" type="button">'
             
              this.popupbottomhtml+=' </div>';
          
           this.btnokid=this.divid+"_btnok";
          this.btncancelid=this.divid+"_btncancel";
       
    }
    
   
}
SMSSendPopup.type='helpdesksms';
SMSSendPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,createNewText)
{
     SMSSendPopup.prototype=new CrmPopup();  
     SMSSendPopup.prototype.constructor=SMSSendPopup;  
   
     
     SMSSendPopup.prototype.type=SMSSendPopup.type;
    SMSSendPopup.prototype.createNewText=createNewText;
    

     var  QcPopupobj=new SMSSendPopup();
     QcPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return QcPopupobj;
    
}
 
 
 //弹出层的单例
SMSSendPopup.getInstance=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,createNewText)
{
     for(var i=0;i<CrmPopup.global_signleInstance.length;i++)
     {
        if(CrmPopup.global_signleInstance[i].type==SMSSendPopup.type)
        {
            return CrmPopup.global_signleInstance[i];
        }
     }

      var crmpopupobj=SMSSendPopup.load(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,createNewText);
     CrmPopup.global_signleInstance.push(crmpopupobj);
    return crmpopupobj;

}

var Settlement = function(){
	var searchurl = $('search_url').value;
	var viewid = getviewId();
	var idstring = "";
	List_CheckBox_Ids.getIds('OutboundOrder');
	var  select_options=List_CheckBox_Ids.ids;
	idstring=select_options;
	count= List_CheckBox_Ids.num_rows;
	var excludedRecords = $('excludedRecords').value;
	var numOfRows = List_CheckBox_Ids.num_rows;

	if(count<=0)
	{   
		RemindsMsg("","LdPopWidth400px",module,"yes","","");return false;
	}
	var table_html = '';
	//Complexform_Div0
	table_html += '<div class="" style="">';
	table_html +='<table class="DetailContentTable" cellspacing="1" cellpadding="0" border="0" width="100%">';
	table_html +='<tbody>';
	table_html += '<tr><td class="DetailedTd1Label" align="right" width="10%">结算日期</td><td class="DetailedTd2Info" align="left" width="40%"><input type="hidden" name="s_record" value="'+idstring+'"><input class="Wdate" name="settlement_date" tabindex="c" style="border:1px solid #dbdbdb;" fieldlabel="结算日期" fieldonly="0" size="20" maxlength="10" value="" onclick="WdatePicker()" type="text"></td></tr>';
	table_html += '<tr><td class="DetailedTd1Label" align="right" width="10%">结算状态</td><td class="DetailedTd2Info" align="left" width="40%"><select name="settlement_status" style="width:150px;"><option values=" 未结"> 未结</option><option values="已结">已结</option><option values="不满足结算条件">不满足结算条件</option></select></td></tr>';
	table_html +='</tbody>';
	table_html +='</table></div>';
	var crmPopupobj=CreatePagePopup.load("","","","LdPopWidth450px",'OutboundOrder',"",'none',"","");
	crmPopupobj.prevshow();
	crmPopupobj.setParams('结算',SettlementOk,'',"LdPopWidth450px",'OutboundOrder',"","确认","","取消");  
	crmPopupobj.quickcreatehtml=table_html;
	crmPopupobj.show(table_html);

}

var SettlementOk = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var _date =  CrmPopup.findHtmlobj(divid,'settlement_date').val();
	var _status =  CrmPopup.findHtmlobj(divid,'settlement_status').val();
	var s_record =  CrmPopup.findHtmlobj(divid,'s_record').val();
	if(empty(_date)){
		 RemindsMsg("","LdPopWidth400px","","yes","",'结算日期不能为空！');return false;
	}
	if(empty(_status)){
		 RemindsMsg("","LdPopWidth400px","","yes","",'结算状态不能为空！');return false;
	}
	ld.ajax("index.php?module=Customreport&action=EveryMonthBlock&s_record="+s_record+"&s_date="+_date+"&s_status="+_status)
	.done(function(){
		var popupobj=CrmPopup.getPopupObj("last");
		popupobj.CancelEvent();  
		RemindsMsg("","LdPopWidth400px","","yes","",'结算成功！');
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			getListViewEntries_js('OutboundOrder',1);//刷新页面
		});
		return false;
	})
}
//edit:can 2020-08-27 中孚修改发货单的签回
function Changezh_cf_2444()
{
    var that=this;
    that.popupobj=CrmPopup.getPopupObj('last');//查看界面
    that.showpopup=function(){
        var popupobj=that.popupobj;
        var record=popupobj.record;
     
              
        ldAjax("index.php?module=OutboundOrder&action=OutboundOrderAjax&file=Changezh_cf_2444&operatetype=showpopup",{},function(ajaxdata){
            var crmpopupobj= CrmPopup.load(ajaxdata.result.title,that.save,"",450,'OutboundOrder','',ajaxdata.result.oktext,'',ajaxdata.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmpopupobj,ajaxdata.result.content);
            DelProgressObjs();
        })
    }
    that.save=function()
    {
        var record=that.popupobj.record;
        var lastpopupobj=CrmPopup.getPopupObj("last");
        var cf_2444=ld("#"+lastpopupobj.divid+" [name=statusname]").val();
      
        ldAjax("index.php?module=OutboundOrder&action=OutboundOrderAjax&file=Changezh_cf_2444&out_id="+record+"&operatetype=save",{'cf_2444':cf_2444},function(ajaxdata){
               var valueinfo=getEmptyValueInfo();
              
              valueinfo={'result':''};
              valueinfo['result']={'datainfo':''};
             
              valueinfo['result']['datainfo']={'cf_2444':''};
                
              valueinfo['result']['datainfo']['cf_2444']={'fieldname':"cf_2444",'value':cf_2444};
               var tmparra=new Array();
               tmparra.push(that.popupobj.record);  
              var tmpobj= new AfterUpdatePrevPopupObjContent(that.popupobj.module,valueinfo,tmparra);
             tmpobj.eachrefreshDetailViewByModules(new Array(that.popupobj.module));//刷新查看界面
             tmpobj.update();//更新列表界面
            
            lastpopupobj.CancelEvent();
            DelProgressObjs();
        })
    }
    
}
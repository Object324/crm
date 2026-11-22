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

//document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");


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
        
        var fldName = getOpenerObj("quotes_name");
        var fldId = getOpenerObj("quote_id");
        fldName.value = product_name;
        fldId.value = product_id;
        window.opener.document.EditView.action.value = 'EditView';
        window.opener.document.EditView.convertmode.value = 'update_quote_val';
	window.opener.document.EditView.submit();
	
}
function add_data_to_relatedlist(entity_id,recordid) {

        opener.document.location.href="index.php?module=Emails&action=updateRelations&destination_module=Accounts&entityid="+entity_id+"&parentid="+recordid;
}
function set_return_formname_specific(formname,product_id, product_name) {
        window.opener.document.EditView1.quotes_name.value = product_name;
        window.opener.document.EditView1.quote_id.value = product_id;
}
function set_return_todo(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.task_parent_name.value = product_name;
        window.opener.document.QcEditView.task_parent_id.value = product_id;
	} else {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
	}
}


//报价单选择客户，如果客户有扣率则直接在产品明细中带出
function getAccountForDiscountRate(account_id,rowid){
    
	url = 'module=Accounts&action=AccountsAjax&file=getAccountForDiscountRate&accountid='+account_id;
	/*var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}*/
 
    var popupobj=CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
	new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:url,
			onComplete: function(response) {		    
				var result=response.responseText;
              
				var rowcnt =ld("#"+popupobj.divid+" [name=rowcnt]").val();// parentwindow.document.getElementById('rowcnt').value;
				for(var i = 1; i<=rowcnt; i++){
					if(ld("#"+popupobj.divid+" [name=discount_percent"+i+"]").length>0){
					  
					//	if(parentwindow.document.getElementById('discount_percent'+i).value <= 0 || parentwindow.document.getElementById('discount_percent'+i).value == ''){
						ld("#"+popupobj.divid+" [name=discount_percent"+i+"]").val(result);
                        	//parentwindow.document.getElementById('discount_percent'+i).value =result;
					//	}
					}
				}
				//新增行时，不需要进行计划，只在切换客户时，进行赋值重新计算
				if(rowid <= 0){
				    
					popupobj.fieldformulaobj.changediscountpercent();
				}
			}
		}
	);
}


function HaigeControlTrElement()
{
    var popupobj=CrmPopup.getPopupObj('last');
    if((popupobj.record>0|| popupobj.paramsobj.params.isduplicate=='yes')&&account_version=='haige')
    {
        var trobjs=popupobj.getTrObjsByDelType('no');//获取没有删除的行
        ld.each(ld(trobjs),function(){
             var rowindex=ld(this).attr("rowindex");
             if(ld(this).find("[name=hdnProductId"+rowindex+"]").val()>0)
             {
                 var haveordercount=ld(this).find("[name=haveordercount"+rowindex+"]").val();
                 if(haveordercount!=""&&parseInt(haveordercount)>0)
                 {
                    ld(this).find(" .icon-sdel2").css('display','none');//隐藏删除行阿牛
                    ld(this).find(" .icon-select").css('display','none');//隐藏选择产品的按钮
                    ld(this).find(" .icon-clear").css('display','none');//隐藏清除产品的按钮
                 }
                    
                    
             }
        })
        
    }
}
//海格报价单保存事件重写
function savehaigequote()
{
    var popupobj = CrmPopup.getPopupObj("last");
    if(account_version!='haige'&&popupobj.module == 'Quotes')
    {
        return false;
    }
    var btnobj = popupobj.getbtnOkobj();
    btnobj.disabled = true;
    

    if (SaveDataRecord.validate()) {
       
        if (SaveDataRecord.duplicate()) {
            
               //保存判断（特价单是否重复，数量等信息是否为空，数量是否小于已出货数量）及特殊物料清单判断，
                 var popupobj = CrmPopup.getPopupObj('last');
                var divid=popupobj.divid;
                var potentialid=CrmPopup.getHtmlobjval(divid,'potential_id');//特价申请单编号
                var dataurl = "&module=Quotes&file=HaigeQuoteSpecialSavejudge&action=QuotesAjax&haigesave=true";
                dataurl+='&potentialid='+potentialid;
               
                var trobjs=popupobj.getTrObjsByDelType("no");
                var rowcnt =ld(trobjs).length;
                dataurl += '&rowcnt='+rowcnt;
                ld.each(ld(trobjs),function(){
                    var rowindex=ld(this).attr("rowindex");
                    var rowobj=ld(this);
                    var productname = ld(rowobj).find(' [name=productname]').val();
                    var hdnProductId = ld(rowobj).find(' [name=hdnProductId]').val();
                    if(productname == '' || hdnProductId == '') return true;
                    var standardprice = ld(rowobj).find(' [name=standardprice]').val();
                    var quantity = ld(rowobj).find(' [name=quantity]').val();
                    if(ld(rowobj).find(' [name=discount_percent]').length>0&&ld(rowobj).find(' [name=discount_percent]').parent().css('display')!='none'){
                        var discount_percent = ld(rowobj).find(' [name=discount_percent]').val();
                        dataurl += '&discount_percent'+rowindex+'='+discount_percent;
                    }
                    if(ld(rowobj).find(' [name=agent_discount]').length>0&&ld(rowobj).find(' [name=agent_discount]').parent().css('display')!='none'){
                        var agent_discount = ld(rowobj).find(' [name=agent_discount]').val();
                        dataurl += '&agent_discount'+rowindex+'='+agent_discount;
                    }
                    
                    var hidden_rowid = ld(rowobj).find(' [name=hidden_rowid]').val();
                    dataurl += '&hdnProductId'+rowindex+'='+hdnProductId+'&productname'+rowindex+'='+productname;
                    dataurl += '&standardprice'+rowindex+'='+standardprice+'&quantity'+rowindex+'='+quantity
                        +'&hidden_rowid_'+rowindex+'='+hidden_rowid;
                })
                if (popupobj.type == PageRecordPopup.type) {
                    dataurl += "&record=" + popupobj.record + "&mode=edit";
                }
                else if(popupobj.type==CreatePagePopup.type){
                     dataurl += "&mode=create&Create=yes";
                }
                if(popupobj.relatedcreate == 'yes'){
            		
            	}else{
            		if(popupobj.lasturl!=undefined)
            			dataurl+=popupobj.lasturl;
            	}
                var ret = true;
                ld.ajax({
                    type : "post",
                    url : "index.php",
                    data : dataurl,
                    async:false,
                    dataType:"json",
                    timeout:10000,
                    success : function(data) {
                      
                        if (data.code==1 ) {
                           //保存判断完成，存在可替换物料时给出提示信息
                          if(data.result.repacehtml != undefined && data.result.repacehtml != ''){
                                var crmPopupobj=CrmPopup.load("","","","LdPopWidth900px","Quotes","","","","");
	                            crmPopupobj.prevshow();
                                crmPopupobj.setParams(data.result.title,"","","LdPopWidth900px","Quotes","",data.result.oktext,"","");
                                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.repacehtml);
                                //特殊物料信息给出提示信息，点击后继续保存
                                ld("#"+crmPopupobj.divid+"_btnok").unbind('click').on('click',function() {
                                    crmPopupobj.CancelEvent();
                                    SaveDataRecord.ajaxsave();
                                });
                                //ld("#"+crmPopupobj.divid+"_btncancel").unbind('click').on('click',function() {
//                                    SaveDataRecord.ajaxsave();
//                                });
                                ld("#"+crmPopupobj.divid+"_imgclose").unbind('click').on('click',function() {
                                    SaveDataRecord.ajaxsave();
                                }); 
                          }
                          else{
                            SaveDataRecord.ajaxsave();
                          }
                           
                        }
                        else if(data.code==-1){
                            var btnobj = popupobj.getbtnOkobj();
                            btnobj.disabled = false;
                      
                            ld('#rptContentLoading').hide();
                            var Popupobj = CrmPopup.load("","","","LdPopWidth400px", module,"","","","");
                            Popupobj.prevshow();
                            Popupobj.setParams(arrJsPopLabel['WARMPROMPT'],"",'',"LdPopWidth400px",module,"",arrJsPopLabel['CONFIRMED'],"","");
                            Popupobj.Okfun=function(){
                                var popupobj = CrmPopup.getPopupObj('last');
                                popupobj.CancelEvent();
                            }
                            CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);
                            
                        }
                    }
                });
              
            }
            else {
                btnobj.disabled = false;
                popupobj.issavesubmit='no';
            }
        }
        else {
            popupobj.issavesubmit='no';
            
            btnobj.disabled = false;
        }
    
}

//浩辰特殊开发  chj  20220530 合同生成 模块详情页面增加作废按钮
function Haochen_VoidOrder(obj,record){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
	var order_no = CrmPopup.findHtmlobj(divid,'selectlistval_name').val();
	var msgConfirm = arrJsPopLabel['Confirmtovoidthecontract'];
	msgConfirm = msgConfirm.replace("{Var}",order_no);
	//alert(order_no);
	RemindsMsg("","LdPopWidth400px","","yes","yes",msgConfirm);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var surl = 'index.php?module=CustomForm14&action=CustomForm14Ajax&file=Haochen_VoidOrder&ajax=yes&record=' + record+'&frommodule='+popupobj.module;
		//alert(surl);
		ldAjax(surl, "", function (data) {
			if (data.code == 1) {
				DelProgressObjs();
				var tmparra=new Array();
				tmparra.push(record);
				var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,"",tmparra);
				var refreshdetailmodules = new Array(popupobj.module);
				tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
				tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);
				tmpobj.update();//更新界面字段
				return false;
			}
		})
	});
}
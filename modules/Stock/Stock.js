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

document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");
var StockForApprove = function(persence,stockid,stype){
	ld.ajax("index.php?action=StockAjax&module=Stock&file=StockForApprove&persence="+persence+"&record="+stockid+"&stype="+stype)
	.done(function(results){
		if(results.indexOf('success') > -1 ){
			if(stype == 'check'){
				window.location.href="index.php?action=DetailView&module=Stock&parenttab=Stock&record="+stockid+"&salestype=yes"; 
			}else{
				//审批
				var obj = new SaveApproveOperation();
				ld_defer.then(obj.saveApproveBefore()).then(obj.saveApprove()).then(obj.saveApproveAfter());
				return true;
			}
		}else{
			fninvshnew('ApproveBlocks');
			var opertion;
			if(stype == 'check'){
				opertion = arrJsPopLabel['CHECKFAIL'];
			}else{
				opertion = arrJsPopLabel['APPROVEFAIL'];
			}
			var prod_data = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
			var _error = '<div style="width:97%;max-height:400px;overflow-y:auto;margin-top:10px;margin-bottom:10px;line-height:22px;padding-left:10px;font-weight:normal;"><b>'+arrJsPopLabel['THETOTALSTOCKQUANTITY'] + ',' + opertion+'!'+ '</b><br />';
			var num = 1;
			for(var lineitem_id in prod_data){
				_error += num + '、 '+prod_data[lineitem_id].productname + ' '+ arrJsPopLabel['THECUMULATIVEQUANTITYSTOCK'] + ':'+prod_data[lineitem_id].havepurchasecount + ',' +
					arrJsPopLabel['BUTTHENUMBEROFTHESTOCK'] + ':' + prod_data[lineitem_id].balancepurchasecount + '<br />';
				num++;
			}
			_error += '</div>';
			var divobj = createElementDivs('out_message');
			ld(divobj).find('.D_pop_tit .D_ptita').html(opertion);
			ld('#out_messagecontent').html(_error);
			ld(divobj).css('max-height','500px');
			ld('#out_messagecontent').css('max-height','400px');
			ld('#out_messagecontent').css('border','none');
			ld(divobj).find('.D_pbtn .D_pbtncancel').css('display','none');
			ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
				fninvshnew('out_message');lingdangJS_DialogBox.unblock();
			});
			return false;
		}
	})
}
function set_stock_presence(stockid,persence,type)
{

	getJsScript('include/js/ListViewButton.js',function(){
		if(type == 0 && persence != 2)
	    {
	        window.location.href="index.php?action=DetailView&module=OutboundOrder&parenttab=OutboundOrder&power=false"; 
	        return false;
	    }
		if(persence == 1)
	    {
	        //var message = window.confirm("确定入库吗？");
			var confirm_str = arrJsPopLabel['OKWAREHOUSINGIT'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	       	//点击确认
	       	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
	       		StockForApprove(persence,stockid,'check');
	       	});
	        return false;
	    }
	    else{
	    	var confirm_str = arrJsPopLabel['INVENTORYQUANTITIESRESTORED'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	       	//点击确认
	       	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
	       		StockForApprove(persence,stockid,'check');
	       	});
	        return false;	
	    }
	});  
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
        var classmethods = $$('.on');
        for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
        }
        obj.className='on On';
        }
		$('wareid').value=warehouseid; 
        getListViewEntries_js('Stock');
		if(document.getElementById('morewarehouseid')!=undefined)
		{
			ld('morewarehouseid').className='';   
		}
		if(ld('#ware_select_more') != undefined){
			ld('#ware_select_more').removeClass('On');
			ld('#cmb_span_optiontext_selectwareid').html('');
		}
        
}
function getMoreWarehouse(obj,id){
    var classmethods = $$('.on');
    var warehouseid=obj.value;
    if(warehouseid==''){
        //您没有这个仓库的权限！
       // alert(arrJsPopLabel['NOHAVEPERMISSIONWAREHOUSE']);  
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
    }
    $(id).className='On';
	$('wareid').value=warehouseid; 
    getListViewEntries_js('Stock','start=1');   
	ld('#ware_select_more').addClass('On');
    
}

//V6.5:财务和库存单据选择源单  使用橡皮擦，清除供应商或者清除源单之后，分录中的产品信息应该清空，源单信息区块内容也应该清空。
clearVendors.other_clear=function()
{
    clearModuleProduct(this,'Stock',''); 
}

//入库单
function saveApproveLog(obj,record,approveid,stepid){
	obj.disabled=true;
	if(document.frmapproveblock.approvestatus != undefined){
		var approvestatus = document.frmapproveblock.approvestatus.value;
		if(approvestatus == 2){//审批成功操作
			StockForApprove(1,record,'approve')
		}else{
			var obj = new SaveApproveOperation();
			ld_defer.then(obj.saveApproveBefore()).then(obj.saveApprove()).then(obj.saveApproveAfter());
		}
	}
	return false;
}
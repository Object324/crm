/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

//出库确认
function instockroomOperation(record)
{
    //退货出库操作不可逆，请仔细确认单据信息。是否确认退货出库？
    //alert("module=PurchaseBack&action=PurchaseBackOperation&parenttab=Purchase&record="+record+"&type=outstock");
    var confirm_str = arrJsPopLabel['RETURNOPERATIONREVERSIBLEPURCHASE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){                 
        new Ajax.Request(
                'index.php',
                {
                    queue: {
                        position: 'end',
                        scope: 'command'
                    },
                    method: 'post',
                    postBody:"module=PurchaseBack&file=PurchaseBackOperation&action=PurchaseBackAjax&record="+record+"&type=outstock",
                    onComplete: function(response) 
                    {
                        var result = response.responseText.split('###ERROR###');
                        //当前产品的数量不能超过产品的已退货数量
                        if(result[1] == 2)
                        {
                            var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS1'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            return false;
                        }
                        if(response.responseText.indexOf('#####SUCCESS#####')>=0)
                        {
							 var tmparra=new Array();
							  tmparra.push(record);
							  var tmpobj= new AfterUpdatePrevPopupObjContent('PurchaseBack',getEmptyValueInfo(),tmparra);
							  var refreshlistmodules = new Array('PurchaseBack');
							  tmpobj.eachrefreshlistbyModules(refreshlistmodules);
							  //服务单保存后刷新服务单的历史记录(查看界面)
							   tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
							   if(record>0)
							   {
									tmpobj.update();//更新界面字段
									
							  }
                           // window.location.href="index.php?module=PurchaseBack&action=DetailView&parenttab=Purchase&record="+record;
                        }
                    }
                }
        );
    });
}
/**
 * @edit:chj
 * @date:2014-10-9
 * @reason:销售退货 回撤
 * @description:
 */
function retracementOperation(obj,record,message)
{
    var confirm_str = arrJsPopLabel['AFTEREXCYTIONTHESTATUSWILLBERESTOREDOUT'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){      
        new Ajax.Request(
                'index.php',
                {
                    queue: {
                        position: 'end',
                        scope: 'command'
                    },
                    method: 'post',
                    postBody:"module=PurchaseBack&action=PurchaseBackAjax&file=PurchaseBackOperation&parenttab=Purchase&record="+record+"&type=cancelstock",
                    onComplete: function(response) 
                    {
                        //zkt 20220530 52285（https://81mis.com/kfbtest）采购管理》采购退货单》任意点击一条采购退货单编号》回撤（浏览器：火狐、Google），状态不刷新，需要手动刷新页面查看
                        if(response.responseText.indexOf('#####SUCCESS#####')>=0)
                        {
                            var tmparra=new Array();
							  tmparra.push(record);
							  var tmpobj= new AfterUpdatePrevPopupObjContent('PurchaseBack',getEmptyValueInfo(),tmparra);
							  var refreshlistmodules = new Array('PurchaseBack');
							  tmpobj.eachrefreshlistbyModules(refreshlistmodules);
							  //服务单保存后刷新服务单的历史记录(查看界面)
							   tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
							   if(record>0)
							   {
									tmpobj.update();//更新界面字段
									
							  }
							//window.location.href="index.php?module=PurchaseBack&action=DetailView&parenttab=Purchase&record="+record;
                        }
                    }
                }
        );  
    });
}
//结束退货弹出层
function instockroomEndOperation(obj,record,message)
{
	var surl = "index.php?module=PurchaseBack&action=PurchaseBackAjax&file=PurchaseBackEndOperation&parenttab=Purchase&record="+record;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",'PurchaseBack',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,instockroomEndOperationButton,"","LdPopWidth400px",'PurchaseBack',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
		}
	})
}

//结束退货确认
function instockroomEndOperationButton()
{
    var end ='';
    var popupobj=CrmPopup.getPopupObj("last");
	var message = ld("#"+popupobj.divid+" [name=status]").val();
	var record = ld("#"+popupobj.divid+" [name=record]").val();
	if(message=='已出库')
    {
        end = 'out';
    }
    else
    {
        end = 'notout';
    }
	var surl = "index.php?module=PurchaseBack&action=PurchaseBackAjax&file=PurchaseBackOperation&parenttab=Purchase&record="+record+"&type=endstock&end="+end;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			popupobj.CancelEvent();
			 var tmparra=new Array();
			  tmparra.push(record);
			  var tmpobj= new AfterUpdatePrevPopupObjContent('PurchaseBack',getEmptyValueInfo(),tmparra);
             
			  var refreshlistmodules = new Array('PurchaseBack');
			  tmpobj.eachrefreshlistbyModules(refreshlistmodules);
			  //服务单保存后刷新服务单的历史记录(查看界面)
			   tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
			   if(record>0)
			   {
					tmpobj.update();//更新界面字段
					
			  }
		}
        DelProgressObjs();
	})
}
    /*
    *新增操作 by andy
    *退款单带出退货单
    *date:20140120
    */
    function set_return_specific(help_id, help_name) {
            
    	//getOpenerObj used for DetailView 
            var fldName = getOpenerObj("salesback_name");
            var fldId = getOpenerObj("salesbackid");
            fldName.value = help_name;
            fldId.value = help_id;
    }


/*
edit:diony
date:20140717
reason:采购退货单、采购退款单判断金额是否超过 
*/
function validatePurchaseTotal(module)
{
    var vstring = new Array();
    var max_row_count = document.getElementById('rowcnt').value;
    for(var i = 1; i<=max_row_count; i++)
    {
        vstring[i-1] = document.getElementById('hdnProductId'+i).value +'-'+ document.getElementById('quantity'+i).value +'-'+ document.getElementById('listprice'+i).value;
        if(document.getElementById('lineitem_id'+i)!=undefined)
        {
           vstring[i-1]+='-'+document.getElementById('lineitem_id'+i).value
        }
    }
   
        var record = document.getElementById('purchaseorder_id').value;
        var purchasebackid = document.getElementById('purchaseback_id').value;
        if(purchasebackid.length==0)
        { 
            purchasebackid = 0;
        }
        url = "index.php?module=PurchaseBack&action=PurchaseBackAjax&file=PurchaseBackOperation&parenttab=Purchase&record="+record+"&purchasebackid="+purchasebackid+"&idstring="+vstring+"&type=savecheck";
    
    
    http_reqfield=createfieldXMLHTTP();
    http_reqfield.open("POST",url,false);
    isDuplicate=false;
    http_reqfield.onreadystatechange=RequestPurchaseBack;
    http_reqfield.setRequestHeader("If-Modified-Since","0");
    http_reqfield.send();
    if(isDuplicate == false)
    {
        return true;
    }
    return false;
}


function RequestPurchaseBack()
{
    if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
    {
        var str=http_reqfield.responseText;
    	if(str.indexOf('###SUCCESS###') >= 0)
        {
           isDuplicate=false;
        }
        else
        {
            var results=str.split('###ERROR###');
            puyoungJS_DialogBox.unblock();
            if(results[1] == 2)
            {
                var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS1'];
            }
            else if(results[1] == 3)
            {
                var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS2'];
            }
            else if(results[1]==50)
            {
                var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS50'];
                
            }
            else if(results[1] == 4)
            {
                var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS3'];
            }
            else if(results[1] == 5)
            {
                var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS4'];
            }
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);	
            isDuplicate=true;
        }
    }
}

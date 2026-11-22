/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

//出库确认
function instockroomOperation(record)
{
    //var message = window.confirm("退货入库操作不可逆，请仔细确认单据信息。是否确认退货入库？");    
    //退货入库操作不可逆，请仔细确认单据信息。是否确认退货入库？
    var message = window.confirm(arrJsPopLabel['RETURNSWAREHOUSINGOPERATIONNOTREVERSIBLE']);
    if(message==true)
    {
        new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=PurchaseBack&action=PurchaseBackOperation&parenttab=Purchase&record="+record+"&type=outstock",
					onComplete: function(response) 
                    {
                        if(response.responseText.indexOf('#####SUCCESS#####')>0)
                        {
                            window.location.href="index.php?module=PurchaseBack&action=DetailView&parenttab=Purchase&record="+record;
                        }
                    }
                }
        );
    }
}

//结束退货弹出层
function instockroomEndOperation(obj,record,message)
{
    new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:"module=PurchaseBack&action=PurchaseBackEndOperation&parenttab=Purchase&record="+record,
				onComplete: function(response) 
                {
                    if(response.responseText.indexOf('#####SUCCESS#####')>0)
                    {
                        result = response.responseText.split('#####SUCCESS#####');
                        if(message=='已出库')
                        {
                            document.getElementById("instockroomEndOperation_Out_div").innerHTML = result[1];
                            fnvshobj(obj,'instockroomEndOperation_Out');
                        }
                        else
                        {
                            document.getElementById("instockroomEndOperation_NotOut_div").innerHTML = result[1];
                            fnvshobj(obj,'instockroomEndOperation_NotOut');
                        }
                    }
                }
            }
    );
}

//结束退货确认
function instockroomEndOperationButton(record,message)
{
    var end ='';
    if(message=='已出库')
    {
        end = 'out';
    }
    else
    {
        end = 'notout';
    }
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=PurchaseBack&action=PurchaseBackOperation&parenttab=Purchase&record="+record+"&type=endstock&end="+end,
					onComplete: function(response) 
                    {
                        if(response.responseText.indexOf('#####SUCCESS#####')>0)
                        {
                            window.location.href="index.php?module=PurchaseBack&action=DetailView&parenttab=Purchase&record="+record;
                        }
                    }
                }
    );
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
        vstring[i-1] = document.getElementById('hdnProductId'+i).value +'-'+ document.getElementById('quantity'+i).value +'-'+ document.getElementById('listprice'+i).value+'-'+document.getElementById('lineitem_id'+i).value;
    }
 
        var record = document.EditView.purchaseback_id.value;
        var purchasecashbackid = document.getElementById('purchasecashback_id').value;
        if(purchasecashbackid.length==0)
        { 
            purchasecashbackid = 0;
        }
        url = "index.php?module=PurchaseBack&action=PurchaseBackAjax&file=PurchaseBackOperation&parenttab=Purchase&record="+record+"&purchasecashbackid="+purchasecashbackid+"&idstring="+vstring+"&type=savecashcheck";
    
   
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
                alert(arrJsPopLabel['THENUMBEROFRETURNS1']);
            }
            else if(results[1] == 3)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS2']);
            }
            else if(results[1]==50)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS50']);
                
            }
            else if(results[1] == 4)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS3']);
            }
            else if(results[1] == 5)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS4']);
            }	
            isDuplicate=true;
        }
    }
}
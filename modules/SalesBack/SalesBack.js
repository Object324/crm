/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

//入库确认
function instockroomOperation(record,message)
{
    //退货入库操作不可逆，请仔细确认单据信息。是否确认退货入库？
    var message = arrJsPopLabel['RETURNSWAREHOUSINGOPERATIONNOTREVERSIBLE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",message);

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
                    postBody:"module=SalesBack&file=SalesBackOperation&action=SalesBackAjax&record="+record+"&type=instock",
                    onComplete: function(response) 
                    {
                        var result = response.responseText.split('###ERROR###');
                        //当前产品的数量不能超过产品的已退货数量
                        if(result[1] == 2)
                        {
                            var confirm_str = arrJsPopLabel['THENUMBEROFRETURNS1'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            return false;
                        }
                        if(response.responseText.indexOf('#####SUCCESS#####')> -1)
                        {
                            window.location.href="index.php?module=SalesBack&action=DetailView&parenttab=Sales&record="+record;
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
    var message = arrJsPopLabel['AFTEREXCYTIONTHESTATUSWILLBERESTORED'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",message);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){   
        new Ajax.Request(
                'index.php',
                {
                    queue: {
                        position: 'end',
                        scope: 'command'
                    },
                    method: 'post',
                    postBody:"module=SalesBack&file=SalesBackOperation&action=SalesBackAjax&record="+record+"&type=cancelstock",
                    onComplete: function(response) 
                    {
                        if(response.responseText.indexOf('#####SUCCESS#####')> -1)
                        {
                            window.location.href="index.php?module=SalesBack&action=DetailView&parenttab=Sales&record="+record;
                        }
                    }
                }
        );
    });
}
//结束退货弹出层
function instockroomEndOperation(obj,record,message)
{
	if(empty(message) && !empty(salesbackstatus)){
		message = salesbackstatus;
	}
    new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:"module=SalesBack&action=SalesBackEndOperation&parenttab=Sales&record="+record,
				onComplete: function(response) 
                {
                    if(response.responseText.indexOf('#####SUCCESS#####')>0)
                    {
                        result = response.responseText.split('#####SUCCESS#####');
                        if(message=='已入库')
                        {
                            document.getElementById("instockroomEndOperation_In_div").innerHTML = result[1];
                            fnvshobj(obj,'instockroomEndOperation_In');
                        }
                        else
                        {
                            document.getElementById("instockroomEndOperation_NotIn_div").innerHTML = result[1];
                            fnvshobj(obj,'instockroomEndOperation_NotIn');
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
    if(message=='已入库')
    {
        end = 'in';
    }
    else
    {
        end = 'notin';
    }
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=SalesBack&action=SalesBackOperation&parenttab=Sales&record="+record+"&type=endstock&end="+end,
					onComplete: function(response) 
                    {
                        if(response.responseText.indexOf('#####SUCCESS#####')>0)
                        {
                            window.location.href="index.php?module=SalesBack&action=DetailView&parenttab=Sales&record="+record+"&sendtype=yes";
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

/**
edit:
time:2015-01-12
reason:销售退货单发送短信
**/
function sendSMSSalesBack(obj,divid,recordid,accountid,productsid)
{
    $("status").style.display="inline";
     
    //弹出框的设计
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=MassSMS&action=SendSMSSalesBack&record=" +recordid+"&accountid="+accountid+"&productsid="+productsid,
		onComplete:function (response) {
		    $("status").style.display="none";
            if(response.responseText.indexOf("####:###")>-1)
            {
                var results=response.responseText.split("####:###");
                $("divSendSMSSalesBack_Content").innerHTML=results[1];
                fnvshobj(obj,divid);
                $("status").style.display="none";
            }
		}
	}); 
}
/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，各种判断
**/
function SaveSendSMSSalesBack(obj)
{    
    if(!document.getElementById("smsFirst").checked&&!document.getElementById("smsSecond").checked)
    {
        var confirm_str = arrJsPopLabel['MESSAGESNOTCHECKED'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    
    if(document.getElementById("smsFirst").checked)
    {
        var textRecipientFirst=document.getElementById("textRecipientFirst").value.trim();
        
        if(textRecipientFirst==''||textRecipientFirst == null){
            //接收人信息为空！
            var confirm_str = arrJsPopLabel['SMS1RECIPIENTISEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        var textContextFirst=document.getElementById("textContextFirst").value;
        if(textContextFirst==''){
            //接收内容为空！
            var confirm_str = arrJsPopLabel['SMS1RECEPTIONCONTENTEMPTYs'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    
    if(document.getElementById("smsSecond").checked)
    {
        var textRecipientSecond=document.getElementById("textRecipientSecond").value.trim();
        if(textRecipientSecond==''){
            //接收人信息为空！
            var confirm_str = arrJsPopLabel['SMS2RECIPIENTISEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        var textContextSecond=document.getElementById("textContextSecond").value;
        if(textContextSecond==''){
            //接收内容为空！
            var confirm_str = arrJsPopLabel['SMS2RECEPTIONCONTENTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    
    var form=document.forms['sendSalesBackForm'];
    form.submit();
}

/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，选择需发送短信执行
**/
function chooseSalesBackSMS(type)
{
    if(type=='smsFirst'){
        
    }else if(type=='smsSecond'){
        
    }
}
/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，设置接收人手机字段 
**/
function chooseSalesBackSMSPhone(obj,divid,divold,salesbackid,type)
{
    $("status").style.display="inline";
         
    var senddiv=document.getElementById(divold);
    senddiv.style.display="none"; 
    
    //弹出框的设计
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=MassSMS&action=SendSMSSalesBackContent&contenttype=phone&smstype="+type+"&salesbackid="+salesbackid,
		onComplete:function (response) {
		 
         $("status").style.display="none";
         if(response.responseText.indexOf("####:###")>-1)
         {
            var results=response.responseText.split("####:###");
            $("divSendSMSSalesBack_Phone_Content").innerHTML=results[1];
            fnvshobj(obj,divid);
         }
		}
	}); 
}
/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，设置短信内容格式模板   
**/
function chooseSalesBackSMSContent(obj,divid,divold,salesbackid,type)
{
    $("status").style.display="inline";
         
    var senddiv=document.getElementById(divold);
    senddiv.style.display="none"; 
    
    //弹出框的设计
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=MassSMS&action=SendSMSSalesBackContent&contenttype=content&smstype="+type+"&salesbackid="+salesbackid,
		onComplete:function (response) {
		 
         $("status").style.display="none";
         if(response.responseText.indexOf("####:###")>-1)
         {
            var results=response.responseText.split("####:###");
            $("divSendSMSSalesBack_SMSContent_Content").innerHTML=results[1];
            salesBackModuleSel();
            fnvshobj(obj,divid);
         }
		}
	}); 
}
/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，设置短信内容 
**/
function salesBackModuleSel()
{
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody: 'module=SalesBack&action=SMSContent&printtabid=14',
		onComplete: function(response) {
			if(response.responseText.indexOf("SUCCESS")>-1)
            {
                var results=response.responseText.split("##SUCCESS##");
                document.getElementById("tabField").innerHTML=results[1];
            }
		}
	}
	);
}
/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，设置接收人手机字段，判断至少要选择一个 
**/
function SaveSalesBackSMSPhone(obj)
{
    checkFlg = 0;
    var checkfieldids = '';
    var inputs = document.getElementsByName('phoneSMS');
    for(var i = 0; i < inputs.length; i++) {
		if(inputs[i].checked == true) {
			checkFlg++;
            checkfieldids += inputs[i].id+",";
            
		}
	}
    if(checkFlg == 0) {
		var confirm_str = arrJsPopLabel['PLEASESELECTANITEM'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    else
    {
        document.getElementById("checkfieldids").value=checkfieldids;
        var form=document.forms['sendInfoPhoneForm'];
        form.submit();
    }
}
/**
edit:
time:2015-01-12
reason:销售退货单发送短信时，设置短信内容，判断 
**/
function SaveSalesBackSMSContent(obj)
{
    var textRecipient=document.getElementById("CKcontent").value;
    if(textRecipient==''){
        //内容模板为空！
        var confirm_str = arrJsPopLabel['CONTENTTEMPLATEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    
    var form=document.forms['sendInfoSMSContentForm'];
    form.submit();
    
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
		postBody: 'module=SalesBack&action=SMSContent&printtabid='+obj.value,
		onComplete: function(response) {
			if(response.responseText.indexOf("SUCCESS")>-1)
            {
                var results=response.responseText.split("##SUCCESS##");
                document.getElementById("tabField").innerHTML=results[1];
            }
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

function InsertTemplate(obj)
{
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    var txtvalue=document.forms['frmsendInfoContent'].SelectField.options[document.forms['frmsendInfoContent'].SelectField.selectedIndex].text;
	document.getElementById('CKcontent').value += document.getElementById("selField").value;
    //insertText(CKcontent,document.getElementById("selField").value);
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




/*
edit:diony
date:20140717
reason:采购退货单、采购退款单判断金额是否超过 
*/
function validatePurchaseTotal(module)
{
    var vstring = new Array();
	var currency_id = '';
    var max_row_count = document.getElementById('rowcnt').value;
    
    for(var i = 1; i<=max_row_count; i++)
    {
        if(document.getElementById('hidden_rowid_'+i).value == 0){
            vstring[i-1] = document.getElementById('hdnProductId'+i).value +'-'+ document.getElementById('quantity'+i).value +'-'+ document.getElementById('listprice'+i).value;
            if(document.getElementById('lineitem_id'+i)!=undefined)
            {
               vstring[i-1]+='-'+document.getElementById('lineitem_id'+i).value
            }
        }
    }
  
        var record = document.EditView.salesorder_id.value;
        var salesbackid = document.EditView.record.value;
        if(salesbackid.length==0)
        { 
            salesbackid = 0;
        }
		if(document.getElementById('inventory_currency') != undefined)
		{
			currency_id = document.getElementById('inventory_currency').value; 
		}
        url = "index.php?module=SalesBack&action=SalesBackAjax&file=SalesBackOperation&record="+record+"&salesbackid="+salesbackid+"&idstring="+vstring+"&type=savecheck&currency_id="+currency_id+"";
    
   
    http_reqfield=createfieldXMLHTTP();
    http_reqfield.open("POST",url,false);
    isDuplicate=false;
    http_reqfield.onreadystatechange=RequestPurchaseBack;
    http_reqfield.setRequestHeader("If-Modified-Since","0");
    http_reqfield.send(null);
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
            lingdangJS_DialogBox.unblock();
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
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            isDuplicate=true;
        }
    }
}
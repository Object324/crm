/*
{*修改编码格式:统一编码：UTF-8*}
*/
calendarParentid="PaymentMassCashBill";//批量收款
/*
更新操作
edit:can
date:20131202
reason:5954: 批量收款改进：批量收款时可选择设定“收款日期”（皓星）
*/

function ChangeCashBilldate(obj)
{
    if(obj.options[obj.selectedIndex].value=='customdate')
    {
        document.getElementById('cashdate').style.display='inline';
        document.getElementById('cashdateimg').style.display='inline';
    }
    else
    {
         document.getElementById('cashdate').style.display='none';
        document.getElementById('cashdateimg').style.display='none';
    }
}
/*
edit:can
date:20130524
reason:回款计划的批量删除
*/
function massDelPaymentPlan(alert_str,module,gstart,viewid,idlist,searchscope)
{   
  
   
      new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=PaymentPlan&action=DeleteAjax&idlist="+idlist+"&SearchScope="+searchscope,
					onComplete: function(response) {
					  
					        if(response.responseText.indexOf("#####:error")==-1)
                            {
                               
                                 if(confirm(alert_str))
                                {    
                                     new Ajax.Request(
                            				'index.php',
                            				{
                            					queue: {
                            						position: 'end',
                            						scope: 'command'
                            					},
                            					method: 'post',
                            					postBody:"module=Users&action=massdelete&return_module="+module+"&"+gstart+"&viewname="+viewid+"&idlist="+idlist+"&SearchScope="+searchscope,
                            					onComplete: function(response) {
                            						$("status").style.display="none";
                                                  
                            						result = response.responseText.split('&#&#&#');
                                                    if(result[2]!="undefined")
                                                    {
                                                        $("ListViewContents").innerHTML= result[2];
                                                    }
                                                    else 
                                                    {
                                                        $("ListViewContents").innerHTML= "数据错误!";
                                                    }
                            					}
                            				}
                            				);
                            		}
                            }
                            else 
                            {
                                //您选择的记录有已收款或者部分已收款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['SELECTHASRECEIVINGDELETINGFAILED'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                $("status").style.display="none";
                            }
					}
				}
				);
                return false;
}

function PaymentPlanDetialDel(confirmationMsg,formName,action)
{
    $("status").style.display="inline";

    var delrecord=document.getElementById("recordid").value;

    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=PaymentPlan&action=DeleteAjax&delrecord="+delrecord,
					onComplete: function(response) {
						$("status").style.display="none";
                       
                        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirmationMsg);
                                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                  submitFormForAction(formName,action);
                                })
                            }
                            else 
                            {
                                //您选择的记录有已收款或者部分已收款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['SELECTHASRECEIVINGDELETINGFAILED'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            }
					}
				}
				);
}
function chkAllPayment(obj)
{
    var tabcashBill=document.getElementById("MMassCashBill");
   
    for(var i=1;i<tabcashBill.rows.length;i++)
    {
        document.getElementById("chkPayment"+i).checked=obj.checked;
        if(obj.checked)
        {
            document.getElementById("chkPayment"+i).value=0;
        }
        else 
        {
            document.getElementById("chkPayment"+i).value=1;
        }
    }
}

/*
edit:can
date:20130524
reason:回款计划删除
*/
function PaymentplanDel(alert_str,url)
{
    $("status").style.display="inline";
   
    
   
    var delrecord=url.split("&")[url.split("&").length-1]
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=PaymentPlan&action=DeleteAjax&"+delrecord,
					onComplete: function(response) {
						$("status").style.display="none";
                       //alert(response.responseText);
                        if(response.responseText.indexOf("#####:error")==-1)
                            {                    
                                RemindsMsg("","LdPopWidth400px","","yes","yes",alert_str);
                                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                  document.location.href=url;
                                })
                            }
                            else 
                            {
                                //您选择的记录有已收款或者部分已收款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['SELECTHASRECEIVINGDELETINGFAILED'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            }
					}
				}
				);
}
function chkamount(obj)
{
   var tableElements = document.getElementById('massCashBill_form_div');    
   var inputElements = tableElements.getElementsByTagName("input");
   var groupElements = []
   for(var i=0;i<inputElements.length;i++){
       var obj = inputElements[i];
       if(obj.type=='checkbox'){
          groupElements.push(obj);
       }
   }
    
   var all_state = true;
   for (var i=1;i<groupElements.length;i++) {
		var state=groupElements[i].checked;
		if (state == false)
		{
			all_state=false;
			break;
		}
   }
   groupElements[0].checked = all_state;      
}
/*
edit:Can
reason:批量收款
*/
function SaveMassCashBill(frmname)
{
   
    //var confirm_str="请确认，是否收款？";
    var popupobj=CrmPopup.getPopupObj("last");
    var obj=document.getElementById(popupobj.divid);
    
    var confirm_str=arrJsPopLabel['PLEASECONFIRMWHETHERCOLLECTION'];
    var confir=false;
    var tabcashbill=document.getElementById("MMassCashBill");
    var rowcount=tabcashbill.rows.length;
	var bankaccountConfir=false;
    
    for(var i=1;i<rowcount;i++)
    {
        if(document.getElementById("chkPayment"+i).checked)
        {
            confir=true;
            break;
        }
    }
	//判断账户是否为空
	for(var i=1;i<rowcount;i++)
    {
		if(document.getElementById("bankaccountsetid"+i).value == '')
		{
			bankaccountConfir=true;
			break;
		}
	}
	if(bankaccountConfir)
	{
		//银行账户不能为空！
        var confirm_str = arrJsPopLabel['BANKACCOUNTCANNOTBEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
	}
    if(!confir)
    {
        //请至少选中一条记录！
        var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONERECORD'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return ;
    }
   // 
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
      document.forms[frmname].submit();
    });    
}

SaveMassCashBill.funname='SaveMassCashBill';
function  CreateCashBill(obj,paymentplanid,accountid)
{
    var w = window.open();//发请求之前打开一个空页面
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
                    async:false,
					method: 'post',
					postBody:"module=PaymentPlan&action=CashBillPaymentStatus&record="+paymentplanid,
					onComplete: function(response) {
						$("status").style.display="none";
                       
                        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                 w.location="index.php?module=CashBill&action=EditView&Create=yes&return_action=DetailView&&frommodule=PaymentPlan&relatedcreate=yes&PaymentPlan="+paymentplanid+"&account_id="+accountid+'&fromid='+paymentplanid;
                                 //window.open("index.php?module=CashBill&action=EditView&Create=yes&return_action=DetailView&parenttab=Finacial&PaymentPlan="+paymentplanid);
                            }
                            else 
                            {
                                w.close();
                                //当前单据已收款，不允创建收款单！
                                alert(arrJsPopLabel['RECEIVINGNOTALLOWSINGLE']);
                            }
					}
				}
				);
}
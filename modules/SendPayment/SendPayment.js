calendarParentid="PaymentMassCashBill";//批量收款
/*
更新操作
edit:can
date:20131202
reason:5954: 批量收款改进：批量收款时可选择设定“收款日期”（皓星）
*/

function ChangeSendCashBilldate(obj)
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
edit:Can
reason:批量付款
*/
function SaveMassSendCashBill(frmname)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var obj=document.getElementById(popupobj.divid);
    var confirm_str=arrJsPopLabel['PLEASECONFIRMWHETHERPAYMENT'];
    var confir=false;
    var tabcashbill=document.getElementById("MMassSendCashBill");
    var rowcount=tabcashbill.rows.length;
    
    for(var i=1;i<rowcount;i++)
    {
        if(document.getElementById("chkPayment"+i).checked)
        {
            confir=true;
            break;
        }
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
SaveMassSendCashBill.funname='SaveMassSendCashBill';
function chkAllSendPayment(obj)
{
    var tabcashBill=document.getElementById("MMassSendCashBill");
   
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
date:20140106
reason:付款计划的批量删除（V3.2)
*/
function massDelSendPayment(alert_str,module,gstart,viewid,idlist,searchscope)
{   
  
   
      new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=SendPayment&action=DeleteAjax&idlist="+idlist+"&SearchScope="+searchscope,
					onComplete: function(response) {
					  
					        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                RemindsMsg("","LdPopWidth400px","","yes","yes",alert_str);
                                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){                                      
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
                                });
                            }
                            else 
                            {
                                //您选择的记录有已付款或者部分已付款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['PAYMENTRECORDPARITIALLYDELETEFAILED'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                $("status").style.display="none";
                            }
					}
				}
				);
                return false;
}

function SendPaymentDetialDel(confirmationMsg,formName,action)
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
					postBody:"module=SendPayment&action=DeleteAjax&delrecord="+delrecord,
					onComplete: function(response) {
						$("status").style.display="none";
                       
                        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirmationMsg);
                                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                  submitFormForAction(formName,action);
                                });
                            }
                            else 
                            {
                                //您选择的记录有已付款或者部分已付款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['PAYMENTRECORDPARITIALLYDELETEFAILED'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);   
                            }
					}
				}
				);
}


/*
edit:can
date:20140106
reason:付款计划删除
*/
function SendPaymentDel(alert_str,url)
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
					postBody:"module=SendPayment&action=DeleteAjax&"+delrecord,
					onComplete: function(response) {
						$("status").style.display="none";
                        if(response.responseText.indexOf("#####:error")==-1)
                            {  
                              RemindsMsg("","LdPopWidth400px","","yes","yes",alert_str);
                              ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                document.location.href=url;
                              });
                            }
                            else 
                            {
                                //您选择的记录有已付款或者部分已付款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['PAYMENTRECORDPARITIALLYDELETEFAILED'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str); 
                            }
					}
				}
				);
}



function  CreateSendCashBill(obj,paymentplanid,vendor_id)
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
					postBody:"module=SendPayment&action=SendCashBillPaymentStatus&record="+paymentplanid,
					onComplete: function(response) {
						$("status").style.display="none";
                       
                        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                 w.location="index.php?module=SendCashBill&action=EditView&relatedcreate=yes&return_action=DetailView&parenttab=Finacial&frommodule=SendPayment&fromid="+paymentplanid+"&SendPayment="+paymentplanid+"&vendor_id="+vendor_id;
                                 //window.open("index.php?module=CashBill&action=EditView&Create=yes&return_action=DetailView&parenttab=Finacial&PaymentPlan="+paymentplanid);
                            }
                            else 
                            {
                                w.close();
                                //当前单据已付款，不允创建付款单！
                                var confirm_str = arrJsPopLabel['CURRENTHASPAIDNOTALLOWSINGLE'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);  
                            }
					}
				}
				);
}

function chkamount(obj)
{
   var tableElements = document.getElementById('massSendCashBill_form_div');    
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

//批量审核
function masscheckCashBill(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status){
	//var url = 'module=CashBill&type=check&action=CashBillAjax&file=BankConfirm&idlist='+idlist;
	//RequestAjax(url,function(rest){
		//if(rest.indexOf('#####:success') > -1){
            if(confirm_status){
                confirm_massCheck(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status);
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",alert_str);
                //点击确认
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    confirm_massCheck(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status);
                }); 
            }
}

function confirm_massCheck(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status){
    var url = 'module=CashBill&action=CashBillAjax&file=BankConfirm&type=checklist&return_module='+module;
    url += '&'+gstart+'&viewname='+viewid+'&idlist='+idlist+'&SearchScope='+searchscope;
    RequestAjax(url,function(rest){
        if(empty(rest)) return false;
        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
        var divobj = createElementDivs('massApproveCashBill');
        ld(divobj).css('max-height','350px');
        ld('#massApproveCashBillcontent').css('max-height','250px');
        ld('#massApproveCashBillcontent').css('overflow-y','auto');
        var submitlog = '<div style="width:97%;line-height:22px;padding-left:10px;">';
        submitlog += restobj.log.value;//批量提交失败日志
        submitlog += '</div>';
        ld(divobj).find('div.D_pop_tit .D_ptita').html(restobj.title.value);
        ld('#massApproveCashBillcontent').html(submitlog);
        fnvshobj('', 'massApproveCashBill');
        ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
            fninvshnew('massApproveCashBill');puyoungJS_DialogBox.unblock();
            getId('allselectedboxes').value = '';
            getListViewEntries_js(module,'start='+restobj.start.value);//刷新页面
        });
		DelProgressObjs();
    });
}
/*
edit:Can
date:20130606
reason:无回款计划金额
*/
function nopayment(obj)
{
    var ret=true;
    var popupobj=CrmPopup.getPopupObj("last");

    if(obj == 'select')
        obj = ld('#'+popupobj.divid+' [name="nopaymentplan"]').get(0);
    var otherselect = ld('#'+popupobj.divid+' [name="otherselect"]').get(0).value;    //调整 增加 减少
     if(isNaN(obj.value)&& trim(obj.value)!="")
    {
        //无回款计划金额非法！
        var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        obj.focus();
        
        if(!document.all)
        {
             obj.select();
             window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
        }
        
        ret=false;
    }
    obj.value=trim(obj.value);
    if(obj.value=="")
    {
        obj.value=0;
    }
    var curvalue=0;
    var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]').get(0);
    var trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    
   // var rowcount=paymenttab.rows.length;//总行数
    //for(var i=1;i<rowcount-3;i++)
   // {
    ld.each(trobjs,function(){
        
        var curCashBill = ld(this).find(' [name="amount"]').get(0);
        if(isNaN(curCashBill.value) || curCashBill.value=='')
            curCashBill.value = 0;
    
            curvalue=curvalue+parseFloat(curCashBill.value);
        
    })
           
   // }
   
   
    var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    if(otherselect == 1)
        var total=curvalue+parseFloat(obj.value);
    else
        var total=curvalue-parseFloat(obj.value);
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(typeofdata_decimal);
    ld('#'+popupobj.divid+' [name="totalplayment"]').get(0).value =parseFloat(total).toFixed(typeofdata_decimal);
    return ret;
}

function deleteRowPayment(i)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]');
//  	var rowcount = paymenttab.rows.length;
	var dis_row = 0;
    /*if(ld('#'+popupobj.divid+' [name="row'+i+'"]').size() > 0){
        ld('#'+popupobj.divid+' [name="row'+i+'"]').get(0).style.display = 'none';
        ld('#'+popupobj.divid+' [name="row'+i+'"]').attr('deleted','yes');
        
        
    }
    if(ld('#'+popupobj.divid+' [name="deleterow'+i+'"]').size() > 0){
        ld('#'+popupobj.divid+' [name="deleterow'+i+'"]').get(0).value = 1;
        
    }*/
    ld(paymenttab).find("tr[rowindex="+i+"]").remove();
  
	var dis_row=paymenttab.find("[detaildeleted=no]").length;
    //没有明细行
    if(dis_row == 0){
        if(ld('#'+popupobj.divid+' [name="span_total"]').size() > 0){
            ld('#'+popupobj.divid+' [name="span_total"]').get(0).style.display = 'none';
        }
        if(ld('#'+popupobj.divid+' [name="total"]').size() > 0){
            ld('#'+popupobj.divid+' [name="total"]').get(0).style.display = '';
        }
    }else{
        if(ld('#'+popupobj.divid+' [name="span_total"]').size() > 0){
            ld('#'+popupobj.divid+' [name="span_total"]').get(0).style.display = '';
        }
        if(ld('#'+popupobj.divid+' [name="total"]').size() > 0){
            ld('#'+popupobj.divid+' [name="total"]').get(0).style.display = 'none';
        }
    }
    //选择源单字段增加保存到数据库功能
//	updateCashbillSourceNo();
    ShowSequence(popupobj);
    caltotal();//计算合计
}
function setCashBillTotal(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    if(ld('#'+popupobj.divid+' [name="span_total"]').size() > 0){
        ld('#'+popupobj.divid+' [name="span_total"]').get(0).innerHTML = obj.value;
	}
      //设置小计的金额(当没有原单就是本次收款金额)
    var popupobj=CrmPopup.getPopupObj('last');
    getChooseRelateLists.getInstance(popupobj).setsubtotalvalue();
}
//editor:gyq_161 reason:源单分录计算总金额   2019/11/25 15:05
function caltotal()
{
    //隐藏原单字段
    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    if( ld('#'+popupobj.divid+' table[name="proTab"]').length<=0){
        
        return ;
    }
    var ret=true;
    var curvalue=0;
    
    var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]').first();
    var nopaymentplan = paymenttab.find('[name="nopaymentplan"]').first().val();
    var otherselect= paymenttab.find('[name="otherselect"]').first().val();
    var trobjs = popupobj.getTrObjsByDelType("no");
    ld.each(trobjs,function(){
        var i=ld(this).attr("rowindex");
        
         curvalue=curvalue+parseFloat(ld(this).find("[name=amount]").val());   
        
    })
    //zkt 20220914 BUG0056474收款单-预收单，实际收款金额有值，但是点击编辑，就为0了
    if(trobjs.length<=0&&popupobj.cashbilltype=='debuction'){
        //预收单不需要计算
            return;
    }
    if(paymenttab.find('[name="subtotal_amount"]').size() > 0){
        //paymenttab.find('[name="subtotal_amount"]').first().html(parseFloat(curvalue).toFixed(gettypeofdata_decimal(popupobj,'amount','detail'))) ;
	}
    
 
 
 //   var paymenttr= var totalpaymenttr=ld("#"+popupobj.divid+' [tag=tr_totaltag').get(0);//paym paymenttab.find('tr').eq(rowcount-3);
//    var paymenttd=paymenttr.find('td').eq(1);
//    paymenttd.html(curvalue.toFixed(2));

    var totalpaymenttr =ld("#"+popupobj.divid+' [tag=tr_totaltag').get(0);//paym
    //var  totalpaymenttd=totalpaymenttr.find('td').eq(1);
    //var totalpaymenttr=paymenttab.rows[rowcount-1];
    //var totalpaymenttd=totalpaymenttr.cells[1];
    if(otherselect == 1)
        var total=curvalue;
    else
        var total=curvalue-parseFloat(nopaymentplan);
    var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
	if(paymenttab.find('[name="sum_total"]').size() > 0){
        paymenttab.find('[name="sum_total"]').first().html(parseFloat(total).toFixed(typeofdata_decimal)) ;
	}
    if(paymenttab.find('[name="span_total"]').size() > 0){
        paymenttab.find('[name="span_total"]').first().html(parseFloat(total).toFixed(typeofdata_decimal)) ;
	}

	if(paymenttab.find('[name="total"]').size() > 0){
        paymenttab.find('[name="total"]').first().val(parseFloat(total).toFixed(typeofdata_decimal));
	}
	if(curvalue > 0){
        paymenttab.find('[name="sum_total"]').first().show();
        paymenttab.find('[name="span_total"]').first().show();
        paymenttab.find('[name="total"]').first().hide();
        
	}else{
        paymenttab.find('[name="sum_total"]').first().hide();
        paymenttab.find('[name="span_total"]').first().hide();
        paymenttab.find('[name="total"]').first().show();
		
	}
   
   //zkt 小计
    // ld("#"+popupobj.divid+" [name=subtotal_amount]").val(parseFloat(total).toFixed(2));
   // ld("#"+popupobj.divid+" [name=span_subtotal_amountl]").html(parseFloat(total).toFixed(2));
    getChooseRelateLists.getInstance(popupobj).setsubtotaltrshow();//显示小计
    getChooseRelateLists.getInstance(popupobj).setActualTotal()//设置实际收款金额
    return ret;
}
/*
edit:chj
date:2014-4-22
reason:调整回款计划总金额(v5.3)
*/
function selpayment(obj)
{
    var ret=true;
    var curvalue=0;
    var popupobj=CrmPopup.getPopupObj("last");
    var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]').get(0);
    var rowcount=paymenttab.rows.length;//总行数
    //var nopaymentplan = document.getElementById('nopaymentplan');
    var nopaymentplan = ld('#'+popupobj.divid+' [name="nopaymentplan"]').get(0);
    var  trobjs=ld(paymenttab).find("tr[detaildeleted=no]");
    
    if(isNaN(nopaymentplan.value) || nopaymentplan.value=='')
        nopaymentplan.value = 0;
    //for(var i=1;i<rowcount-3;i++)
    //{
        //var curCashBill = document.getElementById("curCashBill"+i);
    ld.each(trobjs,function(){
         var curCashBill = ld(this).find(' [name="amount"]').get(0);
        if(isNaN(curCashBill.value) || curCashBill.value=='')
            curCashBill.value = 0;
        curvalue=curvalue+parseFloat(curCashBill.value);
    })
       
   // }
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    if(obj == 1)
        var total=curvalue+parseFloat(nopaymentplan.value);
    else
        var total=curvalue-parseFloat(nopaymentplan.value);
    var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(typeofdata_decimal);
    ld('#'+popupobj.divid+' [name="totalplayment"]').get(0).value=parseFloat(total).toFixed(typeofdata_decimal);
    return ret;
}
/*
edit:Can
date:20130606
reason:本次收款金额改变
*/
function curCashBill(obj)
{
     var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
     var rowobj=ld(obj).parent();
     while(ld(rowobj).prop("tagName")!="TR")
     {
        rowobj=ld(rowobj).parent();
     }
    obj.value=trim(obj.value);
    var ret=true;
    if(isNaN(obj.value)&& obj.value!="")
    {
        //金额非法！
        var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        obj.focus();
         if(!document.all)
        {
             obj.select();
             window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
        }

        ret= false;
    }
    if(obj.value=="")
    {       
        obj.value=0;
    }
   
    //var chkName="curCashBill";
    var chkName="amount";
    
    var rowindex=obj.name.substring(chkName.length);
    var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]').get(0);
    var tabtr=ld(rowobj).get(0);
    var tabtdamount=tabtr.cells[6];//金额
    var tabtdactualamount=tabtr.cells[7];//实收金额
    var tabtdCashBill=tabtr.cells[10];//本次收款
    var curvalue=0;
    var trobjs=ld("#"+popupobj.divid+" [tag=cashbillinfo][deleted=no]");
    
    var rowcount=ld("#"+popupobj.divid+" [tag=cashbillinfo][deleted=no]")
    var nowtr;
    var nowtd;
     ld.each(trobjs,function(){
       var i=ld(this).attr('rowindex');
    
       var curCashBillobj =ld(this).find("[name=amount]");
        if(isNaN(curCashBillobj.val()) || curCashBillobj.val()=='')
            curCashBillobj.val(0);
        
            curvalue=curvalue+parseFloat(curCashBillobj.val());
           
    } ) 
    
      caltotal();//计算合计
    
    return ret;
}
/*
edit:can
date:20130710
reason:收款单上合同订单清除后清除相应的回款计划列表
*/
function ClearPaymentList(module)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var tabpay = ld('#'+popupobj.divid+' table[name="proTab"]').get(0);
    if(tabpay!=undefined)
    {
        for(var i=1;i<tabpay.rows.length-3;i++)
        {
            tabpay.deleteRow(i);
        }
         tabpay.rows[tabpay.rows.length-3].cells[1].innerHTML=0.00;
        tabpay.rows[tabpay.rows.length-1].cells[1].innerHTML=ld('#'+popupobj.divid+' [name="nopaymentplan"]').get(0).value;
    }
    return false;
}

clearAccountsContactsInfo.other_clear=function()
{
  clearModuleProduct("",'CashBill','');
}

function getChooseRelateLists(popupobj){
    
  
    this.popupobj=popupobj;//新增或者编辑界面
    var that=this;
    that.first='yes';
    that.debuctionlabel='';//预收 文字
    that.list=[];
             
    that.DeductedAmountlabel='';//已抵扣金额 文字
    that.CanDeductibleAmount='';//可抵扣金额 文字
     this.setCurrencyId=function(currency_id)
    {
        this.currency_id=currency_id;
    }

    //获取收款单界面客户的预收款信息
    this.getChooseAccountRelateList=function(bankaccountsetid,accountid,cashtype){
        var popupobj=this.popupobj;
      // var bankaccountsetid=ld("#"+popupobj.divid+" [name=bankaccountsetid]").val();
      //  var accountid=ld("#"+popupobj.divid+" [name=account_id]").val();
       // var cashtype=ld("#"+popupobj.divid+" [name=cashbilltype]").val();//收款类型(cashbill:收款单,debuction:预收单)
       //if(popupobj.column_fields['accountid']==undefined){
//        return false;
//       }
        //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
        
        if(cashtype=='cashbill')
        {
           
            
            ld.ajax({
                url:"index.php?module=CashBill&action=CashBillAjax&file=getAccountDebuctionList&accountid="+accountid+"&bankaccountsetid="+bankaccountsetid+"&cashbillid="+popupobj.record+"&cashtype="+cashtype+"&currency_id="+that.currency_id,
                type:"post",
                dataType:"json",
                timeout:30000,
                async:false,
                success:function(data){
                
                   // ld(function(){
                    var list=data.result.list;
                    that.list=data.result.list;

                    that.debuctionlabel=data.result.debuctionlabel;
                           
                    that.DeductedAmountlabel=data.result.DeductedAmountlabel;
                    that.CanDeductibleAmount=data.result.CanDeductibleAmount;
                  
                    if(ld("#"+that.popupobj.divid+" [name=proTab]").length>0)
                             that.showDebuctionList();
                       
                   // })
                     
                }
            })
        }
    }
    that.showDebuctionList=function(){
         that.removeAllDebuction();

        if(that.list.length<=0){
            if(that.first=='no')
          {
                that.setActualTotal();//40809: （51mis.com/kfbtest）收款单新建界面，选择有预收单的源单客户，勾选预收单后再切换“银行账户”时，实际收款金额没有及时更新
             
            }
            return ;
        }
        var popupobj=that.popupobj;
        ld.each(that.list,function(tmpindex,value){
            if(parseInt(value.debuctionid)>0)
                that.createEditDebuction(value);
                                
        })
                           
                          
        if(popupobj.type==DetailViewPage.type)
        {
                            //隐藏查看界面预收款信息按钮
            that.hideBtnDetailViewPage();
            
        }
        else{
            ld.each(that.list,function(tmpindex,value){
                if(parseInt(value.debuctionid)<=0||parseInt(value.rawbalanceamount)>0)
                    that.createNewDebuction(value);
                                        
            })
        }

        that.setsubtotaltrshow();//是否显示小计行
        that.changetdColSpan();//在没有原单的情况下，删除客户，然后再重新选择客户
        //合同关联创建
        if(that.popupobj.type!=DetailViewPage.type)
        {
       
         //   that.setsubtotalvalue();
         //  that.setActualTotal();

          if(that.popupobj.record>0&&that.first=='no')//编辑界面第一次加载
          {
                caltotal();//40375: （http://www.51mis.com/demo/panlulu004/演示账套 [^]）编辑已有预收单做核销的收款单时，界面“小计”计算错误
             
            }
            else{
                 that.setActualTotal();//40809
            }
            
            that.first='no';
            that.setEvent();
        
        }
    }
    this.removeAllDebuction=function(){
        var popupobj=this.popupobj;
        ld("#"+popupobj.divid+ " [tag=debuction]").remove();//删除所有预收款信息
       
    }
    //创建带有删除按钮的预收看信息
    this.createEditDebuction=function(rowvalue){
        var popupobj=this.popupobj;
        var totalobj=ld("#"+popupobj.divid+" [detailfieldname=deductionreceived_amount]");//预收抵扣金额
        if(totalobj.length<=0){
            totalobj=ld("#"+popupobj.divid+" [detailfieldname=total]");//实际收款金额
            if(totalobj.length<=0){
                return ;
            }
        }
        var tr_totalobj = Tools.getParentobjByChild(totalobj,'tr');//有预收抵扣金额行则为预收抵扣金额行,没有则为实际收款金额行
       
        var cashbillid=rowvalue.cashbillid;
        that.currency_symbol=rowvalue.currency_symbol;//币种符号
        var trhtml="<tr tag='debuction' deleted='no' debuctionid='"+cashbillid+"' detailid='"+rowvalue.detailid+"' trtype='edit' >";
      
            //当前界面是编辑界面
        trhtml+='<td class="ld-form-item-content-entrytotal" align="right"><a class="icon-homeimg icon-sdel" title="'+arrJsPopLabel['DELETE']+'" name="delrow"  href="javascript:;" style="cursor:pointer;"></a>';
        trhtml+='<span style="padding-left:5px;padding-right:5px">' +that.debuctionlabel+"</span>";
        trhtml+="<span style='padding-right:5px'><a href='index.php?pageto_module=CashBill&pageto_action=index&pageto_record="+rowvalue.cashbillid+"' target='_blank'>"+rowvalue.cashbillno+"</a></span><span style='padding-right:5px'>"+that.DeductedAmountlabel+"</span>";
      
       
        trhtml+="</td>";
        trhtml+="<td class='ld-form-item-content-entrytotal'>";
        trhtml+="<span>"+rowvalue.debuctionamount+"</span>";//已抵扣的金额
        //edit:can 2020-09-03 42574: （https://61mis.com/kfbtest [^]）收款单新建界面，选择客户后，币种选择欧元，输入本次收款金额，勾选可使用的预收单后，可使用的预收单金额被换算了。
        trhtml+=" <input type='hidden' class='ld-input-inner' name='detail_debuctionamount' value='"+rowvalue.rawdebuctionamount+"'></td>";
        trhtml+="</tr>";
     
        tr_totalobj.before(trhtml);
        //显示预收抵扣金额
        var deductionobj = ld("#"+popupobj.divid+" [detailfieldname=deductionreceived_amount]");
        if(deductionobj.length>0) {
            Tools.getParentobjByChild(deductionobj,'tr').css("display", '');
        }
    }
    //新增预收款信息
    this.createNewDebuction=function(rowvalue){
        var popupobj=this.popupobj;
        var totalobj=ld("#"+popupobj.divid+" [name=deductionreceived_amount]");//预收抵扣金额
        if(totalobj.length<=0){
            totalobj=ld("#"+popupobj.divid+" [name=total]");//实际收款金额
            if(totalobj.length<=0){
                return ;
            }
        }
        var tr_totalobj = Tools.getParentobjByChild(totalobj,'tr');//有预收抵扣金额行则为预收抵扣金额行,没有则为实际收款金额行

        var colspan=ld(tr_totalobj).eq(0).prop("colspan");//获取实际收款金额colspan
     
        
        var cashbillid=rowvalue.cashbillid;
        that.currency_symbol=rowvalue.currency_symbol;//币种符号
        
        var trhtml="<tr tag='debuction' deleted='no' debuctionid='"+cashbillid+"' trtype='new' >";
      
           
        trhtml+='<td class="ld-form-item-content-entrytotal" align="right"><input type="checkbox" name="debuctionchkbox" style="position: relative;top: -2px;">';
        trhtml+='<span style="padding-left:5px;padding-right:5px">' +that.debuctionlabel+"</span><span style='padding-right:5px'><a href='index.php?pageto_module=CashBill&pageto_action=index&pageto_record="+rowvalue.cashbillid+"' target='_blank'>"+rowvalue.cashbillno+"</a></span>";
        //剩余可抵扣金额
        trhtml+="<span style='padding-right:5px'>"+that.CanDeductibleAmount+"</span>";
       
        trhtml+="<span name='span_balanceamount' value='"+rowvalue.rawbalanceamount+"'>"+rowvalue.balanceamount+"</span>";
       
        trhtml+="</td>";
        //剩余可抵扣金额
        // alert(rowvalue.rawbalanceamount);
        trhtml+="<td class='ld-form-item-content-entrytotal'><span name='last_span_balanceamount' >"+rowvalue.rawbalanceamount+"</span> <input type='text' class='ld-input-inner' style='display:none' name='detail_debuctionamount' value='"+rowvalue.rawbalanceamount+"'></td>";
        trhtml+="</tr>";
        tr_totalobj.before(trhtml);

        //显示预收抵扣金额
        var deductionobj = ld("#"+popupobj.divid+" [detailfieldname=deductionreceived_amount]");
        if(deductionobj.length>0) {
            Tools.getParentobjByChild(deductionobj,'tr').css("display", '');
        }
    }

    //checkbox勾选（选中）
    this.DebuctionChkBoxEvent=function(jqueryobj){
        var trobj=jqueryobj;
        while(ld(trobj).get(0).tagName.toLowerCase()!='tr'){
            trobj=ld(trobj).parent();
        }
        ld(trobj).find("[name=last_span_balanceamount]").css('display','none');
        ld(trobj).find("[name=detail_debuctionamount]").css("display",'none');
       // ld(trobj).find("[name=chkbox]").css("display",'no');
        if(ld(jqueryobj).prop("checked")){
            ld(trobj).find("[name=detail_debuctionamount]").css("display",'');
           // ld(trobj).find("[name=chkbox]").css("display",'yes');
        }
        else{
            ld(trobj).find("[name=last_span_balanceamount]").css('display','');
        }
        var debuctionamount=ld(trobj).find("[name=detail_debuctionamount]").val();

        //设置实际金额
        that.setActualTotal();
        var total=parseFloat(ld("#"+popupobj.divid+ " [name=total]").val());
       
        if(total<0){//复选框勾选后，如果实际收款金额小于0，则反算复选框所在行抵扣金额
            ld("#"+popupobj.divid+ " [name=total]").val(0);
            ld("#"+popupobj.divid+" [name=sum_total]").html(0);
            ld("#"+popupobj.divid+" [name=span_total]").html(0);
            var tmpvalue=that.compute(debuctionamount,total,'add');
           
            ld(trobj).find("[name=detail_debuctionamount]").val(tmpvalue);
            that.setActualTotal();
        }
        
    }
    //删除预收款
    this.DeleteDebuctionEvent=function(jqueryobj){
        var trobj=jqueryobj;
        while(ld(trobj).get(0).tagName.toLowerCase()!='tr')
        {
            trobj=ld(trobj).parent();
        }
        trobj.attr('deleted','yes');
        trobj.css("display",'none');
        
        var debuctionid=ld(trobj).attr('debuctionid');
        var debuctionamount=ld(trobj).find("[name=detail_debuctionamount]").val();//获取该行已抵扣的金额
        //查询该预收款是否还有剩余的预收款
         var balancetrobj=ld("#"+popupobj.divid+" [debuctionid="+debuctionid+"][trtype=new]");
         if(balancetrobj.length>0){
           var balanceamount= ld(balancetrobj).find("[name=span_balanceamount]").attr('value');
           var tmpvalue= that.compute(balanceamount,debuctionamount,'add');// eval(balanceamount+debuctionamount)//获取总可抵扣金额
          
           ld(balancetrobj).find("[name=span_balanceamount]").html(that.currency_symbol+toThousands(Tools.Number.toDecimal(tmpvalue,2)));
           if(!ld(balancetrobj).find("[name=debuctionchkbox]").prop("checked")){
              ld(balancetrobj).find("[name=detail_debuctionamount]").val(tmpvalue);
               ld(balancetrobj).find("[name=last_span_balanceamount]").html(tmpvalue); 
           }
            
         }
         else{
            //var tmpvalue=ld(trobj).find("[name=debuctionamount]").val();
           // var rawvalue={'currency_symbol':that.currency_sysmbol,'cashbillid':debuctionid,'rawbalanceamount':tmpvalue,"balanceamount":toThousands(Tools.Number.toDecimal(tmpvalue,2))};
            var detailid=ld(trobj).attr("detailid");
            var rowvalue=[]
            ld.each(that.list,function(tmpindex,tmpinfo){
                if(tmpinfo.detailid==detailid){
                   rowvalue=tmpinfo;
                    return true;
                }
            })
            rowvalue.rawbalanceamount=rowvalue.rawdebuctionamount;
            rowvalue.balanceamount=rowvalue.debuctionamount;
            rowvalue.detailid=0;
           // console.log(rowvalue);
            that.createNewDebuction(rowvalue);
         }
         that.setEvent();
         that.setsubtotaltrshow();//显示或者隐藏小计行
         that.setActualTotal();//设置实际收款金额
         
    }
    //显示或者隐藏小计行
    this.setsubtotaltrshow=function(){
        var popupobj=this.popupobj;
        if(ld("#"+popupobj.divid+ " [tag=debuction][deleted=no]").length>0){
            ld("#"+popupobj.divid+" [tag=tr_subtotaltag]").css("display",'');
            ld("#"+popupobj.divid+" [name=subtotal]").css("display",'none');
            ld("#"+popupobj.divid+" [name=span_subtotal]").css("display",'none');
            if(popupobj.pagetype==PageRecordPopup.pagetype)
            {
                if(ld("#"+popupobj.divid+" [tag=cashbillinfo][deleted=no]").length<=0){//如果没有原单的收款信息
                    
                    ld("#"+popupobj.divid+" [name=subtotal]").css("display",'');
                }
                else{
                    ld("#"+popupobj.divid+" [name=span_subtotal]").css("display",'');
                    //ld("#"+popupobj.divid+" [name=subtotal]").css("display",'none');
                }
            }
            else{
                 ld("#"+popupobj.divid+" [name=span_subtotal]").css("display",'');
            }
        }
        else{
            ld("#"+popupobj.divid+" [tag=tr_subtotaltag]").css("display",'none');
        }
    }
    this.getTotalDebuction=function(){
         var popupobj=this.popupobj;
        var trobjs=ld("#"+popupobj.divid+' [tag=debuction][deleted=no]');
        var totaldebuction=0;
       
        if(trobjs.length<=0){
        
            return totaldebuction;
        }
        
        ld.each(trobjs,function(){
            var trtype=ld(this).attr("trtype");
            var debuctionamount=ld(this).find("[name=detail_debuctionamount]").val();
            if(ld.trim(debuctionamount)=='')
            {
                debuctionamount=0;
            }
            if(trtype=='new'){
                if(ld(this).find("[name=debuctionchkbox]").prop("checked")){
                    
                    totaldebuction=that.compute(totaldebuction,debuctionamount,'add');
                }
            }
            else
            totaldebuction=that.compute(totaldebuction,debuctionamount,'add');
            
        })
        return totaldebuction;
    }
    //设置实际收款金额
    this.setActualTotal=function(){
        //小计
        var popupobj=this.popupobj;

        var subtotal=0;//ld("#"+popupobj.divid+' [name=subtotal]').val();
        var trobjs=this.popupobj.getTrObjsByDelType("no");
        if(trobjs.length>0){
            subtotal = 0;
            ld.each(trobjs,function(tmprowindex,tmprowobj){
                var amountobj = ld(tmprowobj).find(' [name=amount]');
                var amount = ld(amountobj).val();
                if(ld.trim(amount+"")=='')
                    amount=0;
                subtotal+=eval(amount);
            })
        }
        else{
            subtotal = ld("#"+popupobj.divid+' [name=subtotal]').val();
        }
        if(subtotal==''){
            subtotal=0;
        }
      
        var totaldebuction=that.getTotalDebuction();

        //设置预收抵扣总额
        var typeofdata_decimal = gettypeofdata_decimal(popupobj,'deductionreceived_amount','main');
        var deductionamountobj=ld("#"+popupobj.divid+" [name=deductionreceived_amount]");
        if(deductionamountobj.length>0){
            ld("#"+popupobj.divid+' [name=deductionreceived_amount]').val(parseFloat(totaldebuction).toFixed(typeofdata_decimal));
            ld("#"+popupobj.divid+' [name=span_deductionreceived_amount]').html(parseFloat(totaldebuction).toFixed(typeofdata_decimal));
            ld("#"+popupobj.divid+' [name=sum_deductionreceived_amount]').html(parseFloat(totaldebuction).toFixed(typeofdata_decimal));
        }

        //获取实际收款金额
        var actualamount=that.compute(subtotal,totaldebuction,'minus');// eval(subtotal-totaldebuction);

         var  totalobj=ld("#"+popupobj.divid+" [name=total]");///实际收款金额
         //zkt 20220915 BUG0056512修改收款单无法保存，收款单编号GR22750：客户：苏州金螳螂建筑装饰股份有限公司，选出库单：CK2022082968187，见附图，然后点保存无效。
         if(totalobj.length<=0){
            return ;
        }
       var tr_totalobj = Tools.getParentobjByChild(totalobj,'tr');///实际收款金额行

         ld("#"+popupobj.divid+' [name=sum_total]').html(actualamount);
         ld("#"+popupobj.divid+' [name=span_total]').html(actualamount);
         
        ld("#"+popupobj.divid+' [name=total]').val(actualamount);

        if(popupobj.mainfieldformulaobj!=undefined&&popupobj.mainfieldformulaobj.maincolumninfo['total']!=undefined)
        {
             var  param=[];
           
             param['data']={'formulafieldname':popupobj.mainfieldformulaobj.maincolumninfo['total'].fieldname};
             popupobj.mainfieldformulaobj.startComputer(param);
        }
        //popupobj.mainfieldformulaobj.startComputer setvaluebyformula(popupobj.mainfieldformulaobj.maincolumninfo['total'].fieldname);
        
       // ld(tr_totalobj).find("[tag=money]").html(actualamount);
    }
    this.setEvent=function(){
        var popupobj=that.popupobj;

        var trobjs=ld("#"+popupobj.divid+" [tag=debuction][deleted=no]");
        ld.each(trobjs,function(){
            var trtype=ld(this).attr('trtype');
           // var jqueryobj=ld(this);
           var trobj=ld(this);
           
            if(trtype=='edit'){
                 var jqueryobj=ld(this).find("[name=delrow]");
                ld(jqueryobj).unbind("click").bind('click',function(){
                    
                    that.DeleteDebuctionEvent(jqueryobj);//行删除事件
                })
                
            }
            else
            {
                 var jqueryobj=ld(this).find("[name=debuctionchkbox]");
                 
                ld(jqueryobj).unbind("click").bind('click',function(){
                  
                    that.DebuctionChkBoxEvent(jqueryobj);
                })
            }
            ld(this).find("[name=detail_debuctionamount]").unbind("change").bind("change",function(){
               if(ld(this).val()==''||isNaN(ld(this).val())){
                    ld(this).val(0);
               }
                
                if(parseInt(ld(this).val())>parseInt(ld(trobj).find("[name=last_span_balanceamount]").html())){
                    //5)预收的抵扣金额不能超过可用金额，若超过光标离开后自动变为可用金额
                    ld(this).val(ld(trobj).find("[name=last_span_balanceamount]").html());
                    
                }
                //抵扣金额值改变，修改实际收款金额
                that.setActualTotal();//
            })
            
        })
        
        ld("#"+popupobj.divid+" [name=subtotal]").unbind("change").bind("change",function(){
               
                //小计金额值改变，修改实际收款金额
                that.setActualTotal();//
            })
        //ld("#"+popupobj.divid+" [name")
    }
    //当本次收款金额改变时，修改小计
    this.setsubtotalvalue=function(){
        var popupobj=this.popupobj;
        
         var  totalobj=ld("#"+popupobj.divid+" [name=total]");///实际收款金额
         if(totalobj.length<=0){
            return ;
        }
       var tr_totalobj = Tools.getParentobjByChild(totalobj,'tr');///实际收款金额行
        var totalvalue=ld(totalobj).val();
        
        if(ld.trim(totalvalue)==''){
            totalvalue=0;
        }
       var totaldebuction= that.getTotalDebuction();
        var subtotal=that.compute(totalvalue,totaldebuction,'minus');
        var typeofdata_decimal = gettypeofdata_decimal(popupobj,'subtotal','main');
        ld("#"+popupobj.divid+" [name=subtotal]").val(parseFloat(subtotal).toFixed(typeofdata_decimal));
       ld("#"+popupobj.divid+" [name=span_subtotal]").html(parseFloat(subtotal).toFixed(typeofdata_decimal));
        
    }
    this.compute=function(one,two, type){
        var typeofdata_decimal = gettypeofdata_decimal(popupobj,'total','main');
        if(type=='add'){
            return (parseFloat(one)+parseFloat(two)).toFixed(typeofdata_decimal);
        }
        else if(type=='minus'){
             return (parseFloat(one)- parseFloat(two)).toFixed(typeofdata_decimal);
        }
    }
    /**
    检查判断抵扣金额要小于等于可抵扣金额或者是否允许修改客户名称和账户
    **/
    this.verfifybalanceamount=function(){
        var popupobj=this.popupobj;
        var trobjs=ld("#"+popupobj.divid+" [tag=debuction]");
      
        if(ld("#"+popupobj.divid+' [name=account_id]').length<=0)
        {
            return true;
        }
        var cashtype=popupobj.cashbilltype;
      
        if(cashtype=='debuction'){//预收款保存
            return that.verifyCheckDebuctionNotEdit();
        }
        var accountid=ld("#"+popupobj.divid+' [name=account_id]').val();
        var bankaccountsetid=0;
        if(ld("#"+popupobj.divid+' [name=bankaccountsetid]').length>0){
            
            var bankaccountsetid=ld("#"+popupobj.divid+' [name=bankaccountsetid]').val();
            
        }
        var currency_id=0;
         if(ld("#"+popupobj.divid+' [name=currency_id]').length>0){
            
            var currency_id=ld("#"+popupobj.divid+' [name=currency_id]').val();
            
        }
        var debuctioninfo={};
        var save_debuctioninfo=[];
        
        var deleteds=[];
        if(trobjs.length<=0){
            return true;
        }
        var isedit='no';
        ld.each(trobjs,function(){
            var trtype=ld(this).attr('trtype');
            var deleted=ld(this).attr("deleted");
            if(deleted=='yes')
            {
                var detailid=ld(this).attr("detailid");
                deleteds.push(detailid);
                return true;
            }
            var debuctionid=ld(this).attr("debuctionid");
            var debuctionamount=ld(this).find("[name=detail_debuctionamount]").val();
            if(trtype=='edit'){
                    
                    debuctioninfo[debuctionid]=debuctionamount;
                    var tmpobj={"type":'edit','amount':debuctionamount,'debuctionid':debuctionamount};
                    isedit='yes';
                    
            }
            else {
                 var chkboxobj=ld(this).find("[name=debuctionchkbox]");
                 if(!ld(chkboxobj).prop("checked")){
                    return true;
                 }
                if(debuctioninfo[debuctionid]==undefined){
                     debuctioninfo[debuctionid]=debuctionamount;
                    
                     
                }
                else{
                    debuctioninfo[debuctionid]=that.compute(debuctioninfo[debuctionid],debuctionamount,'add');
                }
                  var tmpobj={"type":'new','amount':debuctionamount,'debuctionid':debuctionid};
                
            }
            save_debuctioninfo.push(tmpobj);
        })
        var jsstr=JSON.stringify(debuctioninfo);
        popupobj.save_debuctioninfo=JSON.stringify(save_debuctioninfo);
        popupobj.deleted_debuctioninfodetailid=deleteds.join(",");
      //  ld("#"+popupobj.divid+" [name=save_debuctioninfo]").val(JSON.stringify(save_debuctioninfo));
        //删除预收款明细
        //ld("#"+popupobj.divid+" [name=deleted_debuctioninfodetailid]").val(deleteds.join(","));
        var urlstring="index.php?module=CashBill&action=CashBillAjax&file=CheckDebuctionAmount&jsstr="+jsstr;
        if(popupobj.record>0){
            urlstring+='&record='+popupobj.record;
            //收款单判断控制客户名称和账户不能修改
            urlstring+="&accountid="+accountid+"&bankaccountsetid="+bankaccountsetid+"&currency_id="+currency_id;
        }
        
            
       
        var tmpbol=false;
        ld.ajax({
            url:urlstring,
            async:false,
            type:"post",
            dataType:"json",
            timeout:30000,
            success:function(data){
               
                if(data.code==1){
                  
                    tmpbol= true;
                }
                else{
                    RemindsMsg("","LdPopWidth400px",popupobj.module,"yes","",data.msg);
                    tmpbol= false;
                }
            }
        })
        
        return tmpbol;
    }
    this.verifyCheckDebuctionNotEdit=function(){
        //判断预收款是否可以改变客户和账户
        var popupobj=this.popupobj;
        if(popupobj.record<=0){
            return true;
        }
        var accountid=ld("#"+popupobj.divid+' [name=account_id]').val();
        var bankaccountsetid=0;
        var currency_id=0;
        if(ld("#"+popupobj.divid+' [name=bankaccountsetid]').length>0){
            
            var bankaccountsetid=ld("#"+popupobj.divid+' [name=bankaccountsetid]').val();
            
        }
        if(ld("#"+popupobj.divid+' [name=currency_id]').length>0){
            
            var currency_id=ld("#"+popupobj.divid+' [name=currency_id]').val();
            
        }
        
        var urlstring="index.php?module=CashBill&action=CashBillAjax&file=CheckDebuctionAmount";
        urlstring+='&record='+popupobj.record;
         urlstring+="&accountid="+accountid+"&bankaccountsetid="+bankaccountsetid;
        urlstring+="&currency_id="+currency_id;
         var tmpbol=false;
        ld.ajax({
            url:urlstring,
            async:false,
            type:"post",
            dataType:"json",
            timeout:30000,
            success:function(data){
               
                if(data.code==1){
                  
                    tmpbol= true;
                }
                else{
                    RemindsMsg("","LdPopWidth400px",popupobj.module,"yes","",data.msg);
                    tmpbol= false;
                }
            }
        })
        
        return tmpbol;
        
    }
    //隐藏查看界面预收款信息按钮
    this.hideBtnDetailViewPage=function(){
        var popupobj=this.popupobj;
       // ld("#"+popupobj.divid+" [name=debuctionchkbox]").css("display",'none');
        ld("#"+popupobj.divid+" [name=delrow]").css("display",'none');
        
    }
    /*
    列头从无到有
    */
    this.changetdColSpan=function(){
      
        var popupobj=this.popupobj;
        var tableobj=ld("#"+popupobj.divid+" [name=proTab]");
      
        if(tableobj.find("[tag=cashbillinfo][deleted=no]").length>0)
        {
            var trobj=tableobj.find("[tag=cashbillinfo][deleted=no]");
        }
        else
            var trobj=tableobj.find("tr:first-child");
        var tds=ld(trobj.get(0)).find("td");
       var length = tds.length;
       ld.each(tds,function(){
            if(ld(this).attr('head_tool')=='yes'&&ld(this).css('display')=='none'){
                length--;      
            }
       })
     
        //小计
        tableobj.find("[tag=subtotaltag]").attr("colspan",length-1);
        //合计
        tableobj.find("[tag=totaltag]").attr("colspan",length-1);
        //预收款信息
        var trobjs= tableobj.find("[tag=debuction]");
        ld.each(trobjs,function(){
            ld(this).find("td:first-child").attr("colspan",length-1);
            
        })
        //table.
    }
}

  getChooseRelateLists.getInstance=function(popupobj){
   
        if(popupobj.chooserelatelistobj==undefined){
          
            popupobj.chooserelatelistobj=new getChooseRelateLists(popupobj);
        }
        return popupobj.chooserelatelistobj;
        
    }
    
//币种切换调用事件，修改分录值 zkt 20220920
function BillChangCurrencychangeDetail(popupobj,sourcemodule,selectcurrency_rate,beforecurrency_rate){
    var sourcemodule_arr = popupobj.sourcemodule_arr;
    var withdetail = '';
    ld.each(sourcemodule_arr,function(index,sourcemoduleinfo){
        if(sourcemoduleinfo['entitytype'] == sourcemodule){
            withdetail = sourcemoduleinfo['withdetail'];
        }
    })
    var trobjs = popupobj.getTrObjsByDelType("no");
    if(withdetail == 'no'||withdetail == 'yes'){
		ld(trobjs).each(function () {
		   var tmpfieldname = 'amount';
           if(ld(this).find(' [name='+tmpfieldname+']').length>0){
                var tagMoney = ld(this).find(' [name='+tmpfieldname+']');
				var curCashBill = parseFloat(tagMoney.val());
				if(parseInt(beforecurrency_rate,10) == 1)
					curCashBill = curCashBill*selectcurrency_rate;
				else
					curCashBill = parseFloat(curCashBill/beforecurrency_rate)*selectcurrency_rate;
				curCashBill = curCashBill.toFixed(gettypeofdata_decimal(popupobj,tmpfieldname,'detail'));
                tagMoney.val(curCashBill);
                tagMoney.change();
				i++;
           }
		});
	}
                        
                       
    if(popupobj.column_fields['accountid']!=undefined){
    //选择客户
         //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
    
        //预收款信息
        if(ld("#"+popupobj.divid+" [name=bankaccountsetid]").length>0)
                var bankaccountsetid=ld("#"+popupobj.divid+" [name=bankaccountsetid]").val();
        else
                var bankaccountsetid=0;
       
         if(ld("#"+popupobj.divid+" [name=currency_id]").length>0)
                var currency_id=ld("#"+popupobj.divid+" [name=currency_id]").val();
        else
                var currency_id=0;
                
        var accountid=ld("#"+popupobj.divid+" [name=account_id]").val();
        if(popupobj.cashbilltype!=undefined)
            var cashtype=popupobj.cashbilltype;//收款类型(cashbill:收款单,debuction:预收单)
        else
            var cashtype='';
        getChooseRelateLists.getInstance(popupobj).setCurrencyId(currency_id);
        
        getChooseRelateLists.getInstance(popupobj).getChooseAccountRelateList(bankaccountsetid,accountid,cashtype);
        
    
    }
}
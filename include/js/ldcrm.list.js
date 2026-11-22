function moveUps()
{  
    if(document.getElementById('selectedColumns2')!=undefined)
    selectedColumnsObj=document.getElementById("selectedColumns2");
    else
    return;
	var currpos=selectedColumnsObj.options.selectedIndex;
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
	if (currpos>0)
	{
		var prevpos=selectedColumnsObj.options.selectedIndex-1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[prevpos].innerText
			tempdisabled = selectedColumnsObj.options[prevpos].disabled;
			selectedColumnsObj.options[prevpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[prevpos].disabled = false;
			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[prevpos].text
			tempdisabled = selectedColumnsObj.options[prevpos].disabled;
			selectedColumnsObj.options[prevpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[prevpos].disabled = false;
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[prevpos].value
		selectedColumnsObj.options[prevpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp
		selectedColumnsObj.options[prevpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}

}
function moveDowns()
{
    if(document.getElementById('selectedColumns2')!=undefined)
    selectedColumnsObj=document.getElementById('selectedColumns2');
    else
    return;
	var currpos=selectedColumnsObj.options.selectedIndex
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
    if(currpos>=0)
    {
        if (currpos<selectedColumnsObj.options.length-1)
	{
		var nextpos=selectedColumnsObj.options.selectedIndex+1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[nextpos].innerText
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];

			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[nextpos].text
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[nextpos].value
		selectedColumnsObj.options[nextpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp

		selectedColumnsObj.options[nextpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}
        
    }
	
}
function toggleSelectAlls(relCheckName,selectAllName,sel_id) {
    if (typeof(getObj(relCheckName).length)=="undefined") {
		getObj(selectAllName).checked=getObj(relCheckName).checked
	} else {
		var atleastOneFalse=false;
		for (var i=0;i<getObj(relCheckName).length;i++) {
			if (getObj(relCheckName)[i].checked==false) {
				atleastOneFalse=true
				break;
			}
		}
		getObj(selectAllName).checked=!atleastOneFalse
	}
    
}
function toggleSelect_ListViews(state,relCheckName,groupParentElementId) {
    if(state){
        ld('#selectCurrentPageRec').addClass('tb-checkbox-selected');
        ld('input[name=selected_id]').addClass('tb-checkbox-selected');
    }
    else{
        ld('#selectCurrentPageRec').removeClass('tb-checkbox-selected');
        ld('input[name=selected_id]').removeClass('tb-checkbox-selected');
    }
    var obj = document.getElementsByName(relCheckName);
    if (obj) {
		for (var i=0;i<obj.length;i++) {
			obj[i].checked=state;
			if(typeof(check_object) == 'function') {
			 
				check_object(obj[i],groupParentElementId);
                /*
                *edit:diony
                *time:2014-08-07
                *reason:取消全选，列变白色
                */
                
                if(obj[i].checked==false)
                {
                    //16811: 客户>序时簿,关于批量操作时提示单据数量不正确的问题
                    if(document.getElementById("allselectedboxes")!=undefined)
                     document.getElementById("allselectedboxes").value="";
                    /*if(document.getElementById(ListView_Page.content_tableid)==undefined)
                    {
                        var rows = "row_"+obj[i].value;
                        if((i+1)%2==1)
                        {   
                            ld("tr[id^="+rows+"]").attr('class','lvtColData'); 
                            //document.getElementById(rows).className = "lvtColData";
                           	//0026923: 回收站：列表界面全选单据，再取消全选，结果只有第一条单据取消勾选了 
                        }
                        else
                        {
                            ld("tr[id^="+rows+"]").attr('class','lvtColDataBj');
                            //document.getElementById(rows).className = "lvtColDataBj";
                        }
                        
                    }*/
                }                
			}
		}
	}

    if(document.getElementById(ListView_Page.content_tableid)!=undefined)
    {
        if(state==false)
        {
            var table = document.getElementById(ListView_Page.content_tableid);
            var trs = table.getElementsByTagName('tr');
            /*for(var i = 0; i<trs.length; i++)
            {
               var trid=trs[i].id;
               var idsplit=trid.split('row_');
               if(idsplit.length>=2)
               {
                   if((i+1)%2 == 1) {
                       document.getElementById(trs[i].id).className = "lvtColData";
                   } else {
                       document.getElementById(trs[i].id).className = "lvtColDataBj";
                   }
               }
            }*/
        }
    }

  
		if(state==true)	{
			var count = $('numOfRows').value;
       
			if($('curmodule') != undefined){
				//getNoOfRows();
			}else{
				if(count == '')	{
					getNoOfRows();
				}	
			}
            if(ld('#linkForSelectAll').length > 0){
                if(parseInt($('maxrecords').value) < parseInt(count)) {
                    $('linkForSelectAll').show();
                }
            }

		} else {
		    if(ld('#linkForSelectAll').length > 0){
                if($('allselectedboxes').value == 'all') {
                    $('linkForSelectAll').show();
                } else {
                    $('linkForSelectAll').hide();
                }
            }

		}
	//}
    
    
}
function confirmedits(url,module){
    if(module=='Accounts' || module=='SalesOrder' || module=='Invoice' || module=='Quotes' || module=='HelpDesk'
    ||module=='Expense' || module=='PurchaseOrder' || module=='Documents' || module=='Project' ||module=='Contacts' || module=='ProjectTask' ||module=='PutCash'||module=='CashDeposit' || module=='ContactRecords'  || module=='Potentials' || module=='Calendar' || module=='ServiceContracts' || module == 'PurchaseInvoice'){
        ldAjaxHtmlNoProgress('index.php?',url+"&ajax=true&ReportHeader=dheader",function(response) {
            if(response.indexOf('###SUCCESS###')>-1){
                document.location.href=cls_encryptyurl.Puyoung_Encryptyurl("index.php?"+url,'');
            }
            else{
                /*
                更新操作
                edit:can
                date:20131120
                reason:客户共享更多信息编辑(V3.1)
                */
                if(response.indexOf("###APPROVE###") > -1){
                    var result=response.split('###APPROVE###');
                    alert(result[1]);
                }else{

                    //19752: 系统右上方的快速查找，输入”客户“，点击查找按钮，点击下一页按钮，然后点击客户的编辑按钮，结果：页面跳转到首页。
                    if(url.indexOf("index.php")>=0)
                    {
                        document.location.href=cls_encryptyurl.Puyoung_Encryptyurl(url,'');
                    }
                    else
                        document.location.href=cls_encryptyurl.Puyoung_Encryptyurl("index.php?"+url,'');
                }
            }
        });
    }
    else if(module=='SendCashBill'||module=='CashBill'){ 
        var str = url.substr(0, url.indexOf('&return_module'));
        var recordid=str.split('record=')[1];
        var ucl ="module="+module+"&action=CheckDelete&parenttab=Finacial&recordid="+recordid;
        //alert(ucl)
        //return false;
        ldAjaxHtmlNoProgress('index.php?',ucl,function(response) {

            if(response.indexOf("#####:success")>-1){
                alert(arrJsPopLabel['TDHBCYCNES']);
                return false;
            }else{
                document.location.href=cls_encryptyurl.Puyoung_Encryptyurl("index.php?"+url,'');
            }
        });
    }else{
          if(url.indexOf("index.php")>=0)
          {
                document.location.href=cls_encryptyurl.Puyoung_Encryptyurl(url,'');
          }
          else
            document.location.href=cls_encryptyurl.Puyoung_Encryptyurl("index.php?"+url,'');
    }

}
function stockfirmdelete(url,module,type)
{
    if(module=='OutboundOrder' || module=='Stock' || module=='Checks')
     {
        if(type == 1)
        {
            if(module=='Checks')
            {
                //该单据盘点结束，不允许删除！
                alert(arrJsPopLabel['INVENTORYDOCUMENTSCANOTDELETED']);
                return false;
            }
            else if(module=='OutboundOrder')
            {
                //该单据已出库，不允许删除！
                alert(arrJsPopLabel['DOCUMENTHASLIBRARYCANOTDELETE']);
                return false;
            }
            else if(module=='Stock')
            {
                //该单据已入库，不允许删除！
                alert(arrJsPopLabel['DOCUMENTHASINSTORAGECANOTDELETED']);
                return false;
            }
        }
        else
        {
            alert_str=arrJsPopLabel['NOTRECYCLEBINCONFIRMDELETE'];
            if(confirm(alert_str))
        	{  
        		document.location.href=url;
        	}   
        }
     }
}
function confirmdeletes(urlpath,module)
{
    if(module=='CashBill'||module=='SendCashBill'){
        var recordid = urlpath.split('delrecord=')[1];
        var ucl ="module="+module+"&action=CheckDelete&parenttab=Finacial&recordid="+recordid;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress('index.php?',ucl,function(response) {

            if(response.indexOf("#####:success")>-1){
                alert(arrJsPopLabel['trhbccnbd']);
                return false;
            }else if(module.toLocaleLowerCase().indexOf("cashbill")!=-1||module.toLowerCase().indexOf('attachment')!=-1||module.toLowerCase().indexOf("sendcashbill")!=-1)
            {
                if(confirm(arrJsPopLabel['CANNOTBERESULSE']))
                {

                    document.location.href=urlpath;
                }
            }
        });
    }
    if(module=='Accounts' || module=='SalesOrder' || module=='Invoice' || module=='Quotes' || module=='HelpDesk' 
    || module=='Expense' || module=='PurchaseOrder' || module=='Documents' || module=='Project' ||
     module=='ProjectTask'||module=='PutCash'||module=='CashDeposit' || module=='ContactRecords'  || 
     module=='Potentials' || module=='Calendar' || module=='Commission'|| module=='ServiceContracts')
    {
        var aerrorslog;
        if(module=='Accounts'){
            aerrorslog=arrJsPopLabel['REMOVEWILLDELETEOTHER']+'?';;
        }        
        else{
            aerrorslog=arrJsPopLabel['SUREWANTDELETE'];
        }
        if(confirm(aerrorslog)){
            //zkt 20231013 XUQIU1001341 SQL注入
            ldAjaxHtmlNoProgress('index.php?',urlpath+"&ajax=true",function(response) {

                if(response.indexOf('###SUCCESS###')>-1){

                    document.location.href="index.php?"+urlpath;
                }
                else{
                    var result=response.split('###APPROVE###');
                    /*
                   更新操作
                   edit:can
                   date:20131120
                   reason:客户共享更多信息编辑(V3.1)
                   */
                    if(response.indexOf("###APPROVE###")<=0)
                    {

                        document.location.href="index.php?"+urlpath;
                    }
                    else
                        alert(result[1]);
                }
            });
        }
            
    }
    else{
            
                urlpath="index.php?"+urlpath;
                 if(module.toLocaleLowerCase().indexOf("paymentplan")!=-1)
                 {
                     PaymentplanDel(arrJsPopLabel['SUREWANTDELETE'],urlpath);
                 }
                 else if(module.toLocaleLowerCase().indexOf("sendpayment")!=-1)
                 {
                     SendPaymentDel(arrJsPopLabel['SUREWANTDELETE'],urlpath);
                 }
                 else if(module.toLocaleLowerCase().indexOf("bankaccountset")!=-1)
                 {
                     BankAccountDelete(arrJsPopLabel['tdwbddnitrbsywtd'],urlpath);
                 }
                 else if(module=='OutboundOrder' || module=='Stock' || module=='Checks')
                 {
                
                    alert_str=arrJsPopLabel['NOTRECYCLEBINCONFIRMDELETE'];
                    if(confirm(alert_str))
                	{  
                		document.location.href=cls_encryptyurl.Puyoung_Encryptyurl(urlpath,'');
                	}
                 }
                 //edit:cdw
                 //date:20130716
                 //reason:0004459: 短信作业查询、短信清单查询点击界面上的 清空，弹出的提示信息：确定要删除吗？ 应该改成：确定要清空吗？
                 else if(urlpath == 'index.php?module=CommunicationLog&action=DeleteAll&parenttab=Marketing&type=smslist' )
                 {
                    if(confirm(arrJsPopLabel['SUREWANTDELETE']))
                	{  
                		document.location.href=cls_encryptyurl.Puyoung_Encryptyurl(urlpath,'');
                	}
                 }
                 else if(module.toLocaleLowerCase().indexOf("cashbill")==-1&&module.toLocaleLowerCase().indexOf("sendcashbill")==-1)
                 {
                    if(confirm(arrJsPopLabel['SUREWANTDELETE'])){
                		document.location.href=cls_encryptyurl.Puyoung_Encryptyurl(urlpath,'');
                	}
                 }
    }

}

// @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块
// getTableViewForFenzu(this,'Emails','812','1222')
function getTableViewForFenzus(selectView,module,viewid,viewname){
    if(module=='Emails'){
        module='Accounts';
        action='getAccountToSend';
        var type=0;
        // url="module="+module+"&action="+action+"&viewname="+viewid;
        url="index.php?module="+module+"&action="+module+"Ajax&file="+action+"&viewname="+viewid+'&ajax=true';
    }
    else if(module=='MassSMS'){
        module='MassSMS';
        action='getAccepter';
        var type=1;
        url="module="+module+"&action="+action+"&viewname="+viewid;       
    }
	ld("#viewname").val(viewid);
    //数据分类添加背景色
    ld('.Category ul li.currdataClass').attr('class','divView');
    ld(selectView).attr('class','currdataClass');
	if(document.getElementById('DeleteFezu_li') != undefined){
		if(viewname != '全部'&&viewname!='All'){
			document.getElementById('DeleteFezu_li').style.display = 'block';
		}else{
			document.getElementById('DeleteFezu_li').style.display = 'none';
		}
	}
    // ld("#status").css('display','inline');
    // fnvshobj('','SMSedit');  //老版本弹窗

    ldAjax(url,"",function(data){
        if(data.code == '1'){
            var crmPopupobj=CrmPopup.load(data.result.title,New_chosebox_select_btn_MassSMS,"","300",'Emails',["Email"],data.result.oktext,"",data.result.canceltext);
            crmPopupobj.prevshow();
            crmPopupobj.show(data.result.content);

            //原来版本成功后处理逻辑
            // ld("#status").css('display','block');//老版本加载进度条  document.getElementById("status").style.display="none";
            ld("#viewname").text(viewid);//ld("#viewname").val(viewid);
            ld("#EditFezu").removeAttr('style');// document.getElementById("EditFezu").removeAttribute('style');
            ld("#EditFezu").removeAttr("disabled");
            if(viewname != '全部'&&viewname!='All'){
                ld('#DeleteFezu').parent().show();//ld('#DeleteFezu').parent().css('display','block');
            }else{
                ld('#DeleteFezu').parent().hide();
            }
            // ld("#EditFezu").attr('href',"javascript:editFenzu('Accounts','Parent Accounts',"+type+")");
        }

        DelProgressObjs();
    });
    return false;

    /*new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
        method: 'post',
        postBody:url,
        onComplete: function(response) {
        $("status").style.display="none";
        result = response.responseText.split('&#&#&#');

        $("viewname").value=viewid;

            $("#EditFezu").removeAttribute('style');
            $("#EditFezu").removeAttribute("disabled");
			if(viewname != '全部'&&viewname!='All'){
				document.getElementById('DeleteFezu').style.display = 'block';
			}else{
				document.getElementById('DeleteFezu').style.display = 'none';
			}
            $("#EditFezu").setAttribute('href',"javascript:editFenzu('Accounts','Parent Accounts',"+type+")");

        }
        }
        );*/
        /**
        更新操作
        edit:cdw
        date:20131125
        reason:营销界面群发短信修改
        **/
        //show_detailSMS(viewid);
}
//点击选择
function detailview_MassSMS_accounts()
{
    
    //获取id
    var accountid = document.getElementById('record').value;
    //获取选择的项目
    var num_rows = document.getElementById("num_rows_account_detail_sms").value;
    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {   
        var id = i+'_checkbox_account_detail';
        var id_check = document.getElementById(id);
        //选中的项目进行处理
        if(id_check.checked==true)
        {
            var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }       
    }
    ldAjaxHtmlNoProgress('index.php?',"module=Accounts&action=checkbox_check_detail_sms&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+accountid,function(response)
    {
        if(response.indexOf('#####SUCCESS#####')>0)
        {
            var result=response.split('#####SUCCESS#####');
            //zkt 20231013 XUQIU1001341 SQL注入
            var urlstring = "index.php?module=MassSMS&action=index&parenttab=Marketing&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+accountid+"&fieldid="+result[1];
            urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
            window.open(urlstring,'checkbox_MassSMS','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
        }
    });
}
//点击选择
function detailview_email_accounts()
{
    //获取id
    var accountid = document.getElementById('record').value;
    //获取选择的项目
    var num_rows = document.getElementById("num_rows_account_detail_email").value;
    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {   
        var id = i+'_checkbox_account_detail_email';
        var id_check = document.getElementById(id);
        //选中的项目进行处理
        if(id_check.checked==true)
        {
            var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }       
    }
    ldAjaxHtmlNoProgress('index.php?',"module=Accounts&action=checkbox_check_detail_email&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+accountid,function(response)
    {
        if(response.indexOf('#####SUCCESS#####')>0)
        {
            var result=response.split('#####SUCCESS#####');
            //zkt 20231013 XUQIU1001341 SQL注入
            var urlstring = "index.php?module=Emails&action=GroupEmail&parenttab=Marketing&tabid_fieldlabel_listview_email="+tabid_fieldlabel+"&accountid_listview_email="+accountid+"&account_detail="+result[1];
            urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
            //弹出窗体，并且传值
            window.open(urlstring,'checkbox_MassSMS','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
        }
    });
}
//点击选择
function detailview_email_contacts()
{
    //获取id
    var accountid = document.getElementById('record').value;
    //获取选择的项目
    var num_rows = document.getElementById("num_rows_contact_detail_email").value;
    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {   
        var id = i+'_checkbox_contact_detail_email';
        var id_check = document.getElementById(id);
        //选中的项目进行处理
        if(id_check.checked==true)
        {
            var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }       
    }
    ldAjaxHtmlNoProgress('index.php?',"module=Contacts&action=checkbox_check_detail_email&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+accountid,function(response)
    {
        if(response.indexOf('#####SUCCESS#####')>0)
        {
            var result=response.split('#####SUCCESS#####');
            //zkt 20231013 XUQIU1001341 SQL注入
            var urlsting = "index.php?module=Emails&action=GroupEmail&parenttab=Marketing&tabid_fieldlabel_listview_email="+tabid_fieldlabel+"&accountid_listview_email="+accountid+"&contact_detail="+result[1];
            urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
            window.open(urlsting,'checkbox_MassSMS','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
        }
    });
}
//点击选择
function detailview_MassSMS_contacts()
{
    //获取id
    var contactid = document.getElementById('record').value;
    //获取选择的项目
    var num_rows = document.getElementById("num_rows_contact_detail_sms").value;
    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {   
        var id = i+'_checkbox_contact_detail';
        var id_check = document.getElementById(id);
        //选中的项目进行处理
        if(id_check.checked==true)
        {
            var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }       
    }
//    alert(num_rows);
//    alert(accountid);
//    return false;
    ldAjaxHtmlNoProgress('index.php?',"module=Contacts&action=checkbox_check_detail_sms&tabid_fieldlabel="+tabid_fieldlabel+"&allids="+contactid,function(response)
    {
        if(response.indexOf('#####SUCCESS#####')>0)
        {
            var result=response.split('#####SUCCESS#####');
            //zkt 20231013 XUQIU1001341 SQL注入
            var urlsting = "index.php?module=MassSMS&action=index&parenttab=Marketing&sms_contact_listview_tabid_fieldlabel="+tabid_fieldlabel+"&contactid="+contactid+"&fieldid="+result[1];
            urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
            //  弹出窗体，并且传值
            window.open(urlsting,'checkbox_MassSMS','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
        }
    });
}
function select_moveUps(select_id)
{
	var selectedColumnsObj;
	if(document.getElementById(select_id)!=undefined)
		selectedColumnsObj=document.getElementById(select_id);
    else
    return;
	var currpos=selectedColumnsObj.options.selectedIndex;
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
	if (currpos>0)
	{
		var prevpos=selectedColumnsObj.options.selectedIndex-1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[prevpos].innerText
			tempdisabled = selectedColumnsObj.options[prevpos].disabled;
			selectedColumnsObj.options[prevpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[prevpos].disabled = false;
			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[prevpos].text
			tempdisabled = selectedColumnsObj.options[prevpos].disabled;
			selectedColumnsObj.options[prevpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[prevpos].disabled = false;
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[prevpos].value
		selectedColumnsObj.options[prevpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp
		selectedColumnsObj.options[prevpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj!=undefined&&popupobj!='undefined'){
        var elem2 =CrmPopup.findHtmlobj(popupobj.divid,select_id);
        ld(elem2).animate({ scrollTop: "-=22" });
    }
}
function select_moveDowns(select_id)
{
	var selectedColumnsObj;
    if(document.getElementById(select_id)!=undefined)
		selectedColumnsObj=document.getElementById(select_id);
    else
    return;
	var currpos=selectedColumnsObj.options.selectedIndex
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
    if(currpos>=0)
    {
        if (currpos<selectedColumnsObj.options.length-1)
	{
		var nextpos=selectedColumnsObj.options.selectedIndex+1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[nextpos].innerText
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];

			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[nextpos].text
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[nextpos].value
		selectedColumnsObj.options[nextpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp

		selectedColumnsObj.options[nextpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}
        
    }
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj!=undefined&&popupobj!='undefined'){
        var elem2 =CrmPopup.findHtmlobj(popupobj.divid,select_id);
        ld(elem2).animate({ scrollTop: "+=22" });
    }
	
}
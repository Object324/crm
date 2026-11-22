function getBankCash(bankcashid,obj){
    if(document.getElementById("selectbankid") != undefined)
    {
        var select_id = document.getElementById("selectbankid").value;
        if(select_id > 0)
        {
            $('morebankcashid').className='';
            document.getElementById("selectbankid").value = '';
        } 
    }
    if(obj!=null){
        var classmethods = $$('.on');
        for(var i=0;i<classmethods.length;i++){
            classmethods[i].className = 'on';
        }
        obj.className='on On';
     //    ld('.ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
    	// ld('#tabbank_'+bankcashid).addClass('ld-ui-tabs-active');
    }
    var leagerid = document.getElementById('hiddenledger').value;
	
	var startdate = document.getElementById('startdate').value;
    var enddate = document.getElementById('enddate').value;
	var urldata = 'ajax=yes&start=1&startdate='+startdate+'&enddate='+enddate;
	urldata += '&bankcashid='+bankcashid+'&hiddenledger='+leagerid;
	//zkt 20231122 BUG0075909 kfbcrm-现金银行流水账-切换页签 报错
	ldAjaxHtml('index.php?',"module=BankCash&action=BankCashAjax&file=ListView&bankcashid="+bankcashid+"&startdate="+startdate+"&enddate="+enddate+"&hiddenledger="+leagerid+"&ajax=yes",function(ajaxhtml){
		DelProgressObjs();
		ld("#bankcash_content").html(ajaxhtml);
	});
   // getListViewEntries_js('BankCash',urldata);
    $('bankcashid').value=bankcashid; 
}
function exportback(url){
    var select_id = document.getElementById("bankcashid").value;
    
    var startdate=document.getElementById('startdate').value;
    var enddate=document.getElementById('enddate').value;
    
     url="index.php?module=BankCash&action=BankCashAjax&file=ExportBankCash&bankid=&stdDateFilter=thismonth&startdate="+startdate+"&enddate="+enddate+"&hiddenledger=1&bankcashid="+select_id;
    url = cls_encryptyurl.Puyoung_Encryptyurl(url,'');
    document.location.href=url;
}
function getMoreBankCash(obj,id){
    var classmethods = $$('.on');
    var bankcashid=obj.value;
    if(bankcashid==''){
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
    }
    var startdate = document.getElementById('startdate').value;
    var enddate = document.getElementById('enddate').value;
    $(id).className='On';
    var leagerid = document.getElementById('hiddenledger').value;
	ldAjaxHtml('index.php?',"module=BankCash&action=BankCashAjax&file=ListView&bankcashid="+bankcashid+"&startdate="+startdate+"&enddate="+enddate+"&hiddenledger="+leagerid+"&ajax=yes",function(ajaxhtml) {
		DelProgressObjs();
		ld("#bankcash_content").html(ajaxhtml);
	})
    //getListViewEntries_js('BankCash','ajax=yes&start=1&startdate='+startdate+'&enddate='+enddate+'&bankcashid='+warehouseid+'&hiddenledger='+leagerid);       
    $('bankcashid').value=bankcashid; 
}
function showDateRangeFor(type){
	
	var popupobj=CrmPopup.getPopupObj("last");

		if (type!="custom") {
			ld('#startdate').attr('readOnly',true);
			ld('#enddate').attr('readOnly',true);		
		} else {
			ld('#startdate').attr('readOnly',false);
			ld('#enddate').attr('readOnly',false);
			ld('#startdate').val("");
			ld('#enddate').val("");

		}          
		var resultobj =  eval("("+datetimestr+")")?eval("("+datetimestr+")"):json.parse(datetimestr);
		for(var i in resultobj)
		{          
			if(type==i){                        
					ld('#startdate').val( resultobj[i][0]);
					ld('#enddate').val(resultobj[i][1]);
				  
				}                       
		}              
}

function submitfrom(){
	var startdate = ld('#startdate').val();
	var enddate = ld('#enddate').val();
	var bankcashid = ld('#bankcashid').val();
	var selectbankcashid =  ld('#selectbankcashid').val();
	if(startdate > enddate)
	{
		var confirm_str = arrJsPopLabel['OPENINGDATECANOTGREATEENDDATE'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	ldAjaxHtml('index.php?',"module=BankCash&action=BankCashAjax&file=ListView&bankcashid="+bankcashid+"&startdate="+startdate+"&enddate="+enddate+"&hiddenledger=1"+"&selectbankcashid="+selectbankcashid+"&ajax=yes",function(ajaxhtml) {
		DelProgressObjs();
		ld("#bankcash_content").html(ajaxhtml);
	});
}
/*
edit:duan
reason:中孚 商机和销售合同，列表增加“收入计划”功能
*/
function Revenueplan(module){//收入计划弹出层
    var popupobj=CrmPopup.getPopupObj('last');
    var idstring = "";
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
    var selectlen = 0;
    if (selectid != 'all') {//非全选状态，依次获取选中的单据ID

        var selectobj = document.getElementsByName("selected_id");
        var selectobjlen = selectobj.length;
        selectid = '';
        for (var i = 0; i < selectobjlen; i++) {
            if (selectobj[i].checked) {//获取选中的ID
                selectid += selectobj[i].value + ',';
                selectlen++;
            }
        }
        if (selectid == '') {//请至少选择一条记录
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
    } else {
        selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
    }
    
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",'Settings',"","","","");
	crmPopupobj.prevshow();
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Createrevenue';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,save_Revenueplan,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
            crmPopupobj.selectid=selectid;
        }
   })
   return false;
}

function save_Revenueplan(){//批量保存收入确认计划
    var popupobj=CrmPopup.getPopupObj("last");
    var revenueyear  =ld("#"+popupobj.divid+" [name=revenueyear]").val();
    var revenuemouth  =ld("#"+popupobj.divid+" [name=revenuemouth]").val();
    var revenuemoney  =ld("#"+popupobj.divid+" [name=revenuemoney]").val();
    var amount_type = ld("#"+popupobj.divid+" [name=amount]").val();
    var frommodule = ld("#"+popupobj.divid+" [name=frommodule]").val();
    if(ld.trim(revenuemouth)=="")
    {
        var confimstr = arrJsPopLabel['MONTH']+arrJsPopLabel['CANOTEMPTY'];
        audioRemindsMsg("","","","","",confimstr);
        return false;
    }
    if(amount_type == 'input_amount' && ld.trim(revenuemoney)==""){
        var confimstr = arrJsPopLabel['AMOUNT']+arrJsPopLabel['CANOTEMPTY'];
        audioRemindsMsg("","","","","",confimstr);
        return false;
    }
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    if(prevpopupobj!=undefined&&prevpopupobj.type==Listpagepopupobj.type)
    {
        record=popupobj.selectid;
    }
    var searchurl = $('search_url').value;
    var viewid = getviewId();
    var excludedRecords = $('excludedRecords').value;
    var searchScope = "";
    if (document.getElementById("SmOwnerSearchScope") != undefined)
        searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var urlstring = 'index.php?module='+frommodule+'&action='+frommodule+'Ajax&file=Saverevenue&save=true';
    urlstring += '&selectid=' + record +'&amounttype='+amount_type;
    urlstring += '&revenueyear='+revenueyear+'&revenuemouth='+encodeURIComponent(revenuemouth)+'&revenuemoney='+revenuemoney;
    urlstring += "&viewname=" + viewid + searchurl + "&SearchScope=" + searchScope+'&excludedRecords='+excludedRecords;
    //alert(urlstring);
   	ld.ajax({
			url: urlstring,
			type: 'POST',
			data: '',
			dataType: 'json',
			async: true,//
			timeout: 30000,
			success: function (data) {
			 if(data.code == 1){     
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['SUCCESSFULOPERATION']);
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    var tmparra=new Array();
                    var tmpobj= new AfterUpdatePrevPopupObjContent(frommodule,"",tmparra);
                    var refreshlistmodules = new Array(frommodule);
                    tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                     popupobj.CancelEvent();
                });
			 }
             else{
                
             }
			}
		})
   
}

function input_money(){
    var  popupobj=CrmPopup.getPopupObj('last');
    var selectobj = ld("#"+popupobj.divid+" [name=amount]");
    var inputobj = ld("#"+popupobj.divid+" [name=revenuemoney]");
    var value = ld(selectobj).val();
    if (value == 'input_amount' ) {
      ld(inputobj).css("display",'inline');
    } else {
      ld(inputobj).css("display",'none');
    }
}
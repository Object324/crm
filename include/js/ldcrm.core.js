/*
andrew
20141010
回款计划/采购计划修改金额，自动变更比例
*/
function changeratios(amountval,ratioid,amountnid,salesorderamount){
    //chj:因为金额会根据币种的改变而对应改变  回款预测，回款计划
    if(document.frmsendpayment != undefined)
    {
        salesorderamount = ld('#nopaymentamount1').html();
        salesorderamount = salesorderamount.replace(/,/gi,'');
    }
    //回款计划
    if(document.frmpaymentplan != undefined)
    {
        salesorderamount = ld('#nopaymentamount1').html();
        salesorderamount = salesorderamount.replace(/,/gi,'');
    }
    
    if(isNaN(amountval.value)){
        amountval.value=0;
    }
    if(amountval.value==0||amountval.value==0.00){
            ratioval = 0;
    }
    else if(salesorderamount<=0)//14139: 服务合同-明细界面：创建回款计划弹出层中：比例列值不正确-如图
    {
        ratioval=0;
    }
    else{
            ratioval = parseFloat(amountval.value).toFixed(2)/salesorderamount*100;
    }

    document.getElementById(amountnid).value=parseFloat(amountval.value).toFixed(2);
    document.getElementById(ratioid).value=parseFloat(ratioval).toFixed(2);
}
/*
andrew
20141010
回款计划/采购计划修改比例，自动变更jine
*/
function changeamountns(ratioval,amountnid,ratioid,salesorderamount){
    //0024226: 采购订单明细：更多-创建付款计划，弹出层中比例字段清空，点击下金额，结果清空的字段显示为NaN
    if(isNaN(ratioval.value) || ratioval.value==''){
        ratioval.value=0;
    }
    //chj:因为金额会根据币种的改变而对于改变  回款预测
    if(document.frmsendpayment != undefined)
    {
        salesorderamount = ld('#nopaymentamount1').html();
        salesorderamount = salesorderamount.replace(/,/gi,'');
    } 
    //回款计划
    if(document.frmpaymentplan != undefined)
    {
        salesorderamount = ld('#nopaymentamount1').html();
        salesorderamount = salesorderamount.replace(/,/gi,'');
    } 
    amountnval = parseFloat(ratioval.value).toFixed(2)*0.01*salesorderamount
    document.getElementById(ratioid).value=parseFloat(ratioval.value).toFixed(2);
    document.getElementById(amountnid).value=amountnval.toFixed(2);
}

function fnvshobj_backs(obj,Lay){
    var centerPixel = getViewPortCenter();
    var tagName = document.getElementById(Lay);   
    tagName.style.left=150+'px'; 
	var point = getDimension(Lay);


	var topSide = (centerPixel.y - point.y/2) ;
	var leftSide = (centerPixel.x - point.x/2);

	//to ensure that values will not be negative
	if(topSide<0) topSide = 0;
	if(leftSide < 0) leftSide = 0;  
    
	
	//var leftSide = findPosX(obj);
	//var topSide = findPosY(obj);
	var maxW = tagName.style.width;
    
	var widthM = maxW.substring(0,maxW.length-2);
    puyoungJS_DialogBox.block();
    
	if(Lay == 'editdiv')
	{
		leftSide = leftSide - 225;
		topSide = topSide - 125;
	}else if(Lay == 'transferdiv')
	{
		leftSide = leftSide - 10;
		topSide = topSide;
	}
    
    else if(Lay=="sendmail_cont")
    {
        /*
        edit:can
        date:20131012
        reason:5193: 灵当试用问题：邮件按钮无效
        */
     var pagewidth=Math.max( document.body.scrollWidth,document.body.clientWidth  );
     leftSide=(pagewidth-widthM)/2;
    }
   
	var IE = document.all?true:false;
	if(IE)
	{
		if($("repposition1"))
		{
			if(topSide > 1200)
			{
				topSide = topSide-250;
			}
		}
	}
if(topSide<80)
tagName.style.top = topSide  + "px";
else
	tagName.style.top = topSide - 80 + "px";
	tagName.style.right =leftSide + 250 + "px";
    tagName.style.zIndex=100;
	/*var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
	tagName.style.top= topSide + 'px';*/
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";
    Drag.init(document.getElementById(Lay+"heading"),tagName);
    /*if(Lay=="addblock")
    {
    Drag.init(document.getElementById("addblockheading"),document.getElementById("addblock"));
    }
    if(Lay=="orgLay")
    {
    Drag.init(document.getElementById("createfolderheading"),document.getElementById("orgLay"));
    }
    if(Lay=="emptyfolder")
    {
    Drag.init(document.getElementById("emptyfolderheading"),document.getElementById("emptyfolder"));
    }
    */
}
function posLays(obj,Lay){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 'px';
        //add by ld tifa 20130129 reason:home page quice search popup
        if(leftSide<0)tagName.style.left="0px";
	}
	else
		tagName.style.left= leftSide + 'px';
	if(document.body.clientHeight - topSide < 350){
		topSide = topSide - 350;
	}
	tagName.style.top= topSide + 'px';
}
function fninvshs(idname){
    if(idname=="ApproveBlocks" || document.getElementById("ApproveBlocks")==null)//审批->二级弹出层关闭时不关闭遮罩层
    puyoungJS_DialogBox.unblock();
    var newbox=document.getElementById(idname);
    var layer=document.getElementById('layer');
    newbox.style.display="none";
    newbox.innerHTML='';
    if(layer)
    {
    layer.style.display="none";
    document.body.removeChild(layer);
    }
}
// Drop Dwon Menu
function fnDropDowns(obj,Lay,topY){
    if(document.getElementById(Lay) !=undefined){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
        if(topY!=undefined){
        tagName.style.top= topSide + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
        }
}
function selectedRecordss(module,category)
{
 
	var allselectedboxes = document.getElementById("allselectedboxes");
	var idstring  =  (allselectedboxes == null)? '' : allselectedboxes.value;
   
   
	var viewid = getviewId();
	var url = '&viewname='+viewid;
	if(document.getElementById('excludedRecords') != null && typeof(document.getElementById('excludedRecords')) != 'undefined') {
		var excludedRecords = $('excludedRecords').value;
		var searchurl = document.getElementById('search_url').value;
		url = url+searchurl+'&excludedRecords='+excludedRecords;
	}
	var type = '';
    if(category=='Con Accounts')
    {
        type = 'Con Accounts';
        category = 'Parent Accounts';
    }
    var actiontype = 'ExportRecords';
    if(module=='SalesOrder'){
        actiontype = 'ExportproductRecords'
            
    }
    if(module == 'Stock'|| module == 'OutboundOrder' || module == 'InventoryAccount' || module == 'InventoryQuery' || module == 'Checks')
    {
        if(document.getElementById('wareid')!= null){
            var wareid = document.getElementById('wareid').value;
        }
        
    }
	if(idstring != ''){
		window.location.href=cls_encryptyurl.Puyoung_Encryptyurl("index.php?module="+module+"&action="+actiontype+"&wareid="+wareid+"&parenttab="+category+"&idstring="+idstring+url,'');
	}
	else                                                      
		window.location.href=cls_encryptyurl.Puyoung_Encryptyurl("index.php?module="+module+"&action="+actiontype+"&wareid="+wareid+"&parenttab="+category+"&type="+type,'');
	return false;
}
function expoer_accounts(module,category,exform,idstring){
    var searchType = document.getElementsByName('search_type');
	var exportData = document.getElementsByName('export_data');
	for(i=0;i<2;i++){
		if(searchType[i].checked == true)
			var sel_type = searchType[i].value;
	}
	for(i=0;i<3;i++){
		if(exportData[i].checked == true)
			var exp_type = exportData[i].value;
	}
	ldAjaxHtmlNoProgress('index.php?',"module="+module+"&action=ExportAjax&export_record=true&search_type="+sel_type+"&export_data="+exp_type+"&idstring="+idstring,function(ajaxhtml) {
		if(ajaxhtml == 'NOT_SEARCH_WITHSEARCH_ALL')
		{
			$('not_search').style.display = 'block';
			$('not_search').innerHTML="<font color='red'><b>"+arrJsPopLabel['HAVESEARCHWILLEXPORT']+" "+module+"</b></font>";
			setTimeout(hideErrorMsg1,6000);

			exform.submit();
		}
		else if(ajaxhtml == 'NOT_SEARCH_WITHSEARCH_CURRENTPAGE')
		{
			$('not_search').style.display = 'block';
			$('not_search').innerHTML="<font color='red'><b>"+arrJsPopLabel['NOHAVESEARCHBUTCHOOSE']+" "+module+"</b></font>";
			setTimeout(hideErrorMsg1,7000);

			exform.submit();
		}
		else if(ajaxhtml == 'NO_DATA_SELECTED')
		{
			$('not_search').style.display = 'block';
			$('not_search').innerHTML="<font color='red'><b>"+arrJsPopLabel['PLEASESELECTONEENTITY']+"</b></font>";
			setTimeout(hideErrorMsg1,3000);
		}
		else if(ajaxhtml == 'SEARCH_WITHOUTSEARCH_ALL')
		{
			if(confirm(arrJsPopLabel['YOUWERESEARCHNOTCHOOSE']+'\n'+arrJsPopLabel['CLICKOKCLICKCANCEL']))
			{
				exform.submit();
			}
		}
		else if(ajaxhtml == 'SEARCH_WITHOUTSEARCH_CURRENTPAGE')
		{
			if(confirm(arrJsPopLabel['YOUWERESEARCHNOTCHOOSE']))
			{
				exform.submit();
			}
		}
		else
		{
			exform.submit();
		}
	});
}
var exportcount=0;
var exportNUm=1;
function record_exports(module,category,exform,idstring)
{

    
    exform.submit();
    return false;
  
}
/**
edit:can
reason:点击产品更多币种弹出层checkbox
**/
function updateCurrencyValues(currObj,txtObj,base_curid,conv_rate) {

     var popupobj=CrmPopup.getPopupObj("last");
     var divid=popupobj.divid;
	var price_decimal = 2;
	if(CrmPopup.isExistsObj(divid,"price_decimal")){
		price_decimal = CrmPopup.findHtmlobj(divid,'price_decimal').val();
	}
   if(currObj.checked==true)
   {
     var unit_price=CrmPopup.findHtmlobj(divid,base_curid+'_curname1').val();
    
     var currenccy_id=txtObj.replace(/[^0-9]/ig,"");
     var conv_rate= CrmPopup.findHtmlobj(divid,base_curid+'_cur_conv_rate'+currenccy_id).val();
   
     var value=unit_price * conv_rate;
     CrmPopup.findHtmlobj(divid,txtObj).val(value.toFixed(price_decimal));
     
     currObj.value=1;
   }
   else
   {
     currObj.value=0;
     CrmPopup.findHtmlobj(divid,txtObj).val(0.00);
   }
}
/**
edit:can
reason:重算价格
**/
function resetCurrencyValues(currObj,txtObj,base_curid,cur_id)
{
     var popupobj=CrmPopup.getPopupObj("last");
     var divid=popupobj.divid;
     
	var radios=ld("#"+divid).find(" input[name=base_currency_input]");
    
    
	var base_currency_id=0;//基本币种
	var base_unit_price=0;//获取基本币种价格
	var base_convert_rate=0;//获取基本币种换算率
	var currency_id=0;//币种id
	var unit_price=0;//币种价格
	var conver_rate=0;//币种换算率
	cur_id=txtObj.replace(/[^0-9]/ig,"");
	var price_decimal = 2;
	if(CrmPopup.isExistsObj(divid,'price_decimal')){
		price_decimal = CrmPopup.findHtmlobj(divid,'price_decimal').val();
	}
  
    for(var i=0;i<radios.length;i++)
    {
        
        var currenccy_id=radios[i].value.replace(/[^0-9]/ig,"");
       
        if(currenccy_id==cur_id)
        {
            base_currency_id=radios[i].value.replace(/[^0-9]/ig,"") ;//获取基本币种（id)
            base_unit_price=CrmPopup.findHtmlobj(divid,base_curid+'_curname'+base_currency_id).val();
            base_conver_rate=CrmPopup.findHtmlobj(divid,base_curid+'_cur_conv_rate'+base_currency_id).val();
            break;
        }
    }
   var value=0;

       for(var i=0;i<radios.length;i++)
       {
          var   currency_id=radios[i].value.replace(/[^0-9]/ig,"");
          if(currency_id!=base_currency_id)
          {
               
                value=base_unit_price*( CrmPopup.findHtmlobj(divid,base_curid+'_cur_conv_rate'+currency_id).val()/base_conver_rate);
                CrmPopup.findHtmlobj(divid,base_curid+'_curname'+currency_id).val(value.toFixed(price_decimal));
          }
          
       }
}
// Update hidden base currency value, everytime the base currency value is changed in multi-currency UI
function updateBaseCurrencyValues() 
{
   //edit:can reason:产品参考价等于弹出层人民币(V5.8)
    var radios=document.getElementsByName('base_currency_input');
    var base_currency_id=0;//基本币种
    var base_unit_price=0;//获取基本币种价格
    var base_convert_rate=0;//获取基本币种换算率
    var currency_id=0;//币种id
    var unit_price=0;//币种价格
    var conver_rate=0;//币种换算率
    for(var i=0;i<radios.length;i++)
    {
        if(radios[i].checked)
        {
            base_currency_id=radios[i].value.replace(/[^0-9]/ig,"") ;//获取基本币种（id)
            base_unit_price=document.getElementById('curname'+base_currency_id).value;
            base_conver_rate=document.getElementById('cur_conv_rate'+base_currency_id).value;
            break;
        }
    }
    
   for(var i=0;i<radios.length;i++)
   {
        if(radios[i].checked)
        {
            continue;
        }
        currency_id=radios[i].value.replace(/[^0-9]/ig,"");
      
       document.getElementById('curname'+currency_id).value=base_unit_price*(document.getElementById('cur_conv_rate'+currency_id).value/base_conver_rate).toFixed(2);
   }
  
}
// END
function ActivityReminderPostponeCallbacks(cbmodule, cbrecord, cbreminderid) {
	if(cbmodule && cbrecord) {
		ActivityReminderProgressIndicator(true);
		ldAjaxHtmlNoProgress('index.php?',"module=Calendar&action=CalendarAjax&ajax=true&file=ActivityReminderSetupCallbackAjax&cbaction=POSTPONE&cbmodule="+
			encodeURIComponent(cbmodule) + "&cbrecord=" + encodeURIComponent(cbrecord) + "&cbreminderid=" + encodeURIComponent(cbreminderid),function (ajaxhtml) {
			ActivityReminderPostponeCallbackProcess(ajaxhtml);
		});
	}
}
function ActivityReminderCallbackProcesss(message,isReminds_popupexist='') {
    //var alert_arr;
	ActivityReminder_callback = document.getElementById("ActivityRemindercallback");
    
	if(ActivityReminder_callback == null) return;
    //by kevin don't' have activityReminder
    ActivityReminder_callback.innerHTML='';
	var winuniqueid = 'ActivityReminder_callback_win_' + (new Date()).getTime();
	if(ActivityReminder_callback_win_uniqueids[winuniqueid]) {
		winuniqueid += "-" + (new Date()).getTime();
	}
	ActivityReminder_callback_win_uniqueids[winuniqueid] = true;
    
	var ActivityReminder_callback_win = document.createElement("span");
	ActivityReminder_callback_win.id  = winuniqueid;
	ActivityReminder_callback.appendChild(ActivityReminder_callback_win);

	//wyt 221215 BUG0059939 消息提醒，点击头部弹出层中已读，右下角消息弹出层出现了，建议根据系统设置隐藏
	var url='index.php?';
	ldAjaxNoProgress(url, 'module=Reminds&action=RemindsAjax&file=RemindsPopup&ajax=true&type=getViewReminds', function (data) {
		if(data.result == 1 && (empty(isReminds_popupexist) ||isReminds_popupexist=='block')){
			ActivityReminder_callback.innerHTML = htmldecode(message);
		}
		DelProgressObjs();
		// window.location.reload();
	});

	ActivityReminder_callback.style.display = "";

	var ActivityReminder_Newdelay_response_node = '_lingdang_activityreminder_callback_interval_';
	if($(ActivityReminder_Newdelay_response_node)) {
		var ActivityReminder_Newdelay_response_value = parseInt($(ActivityReminder_Newdelay_response_node).innerHTML);
		if(ActivityReminder_Newdelay_response_value > 0) {
			ActivityReminder_callback_delay = ActivityReminder_Newdelay_response_value;
		}
		// We don't need the no any longer, it will be sent from server for next Popup
		$(ActivityReminder_Newdelay_response_node).remove();
	}
	if(message == '' || trim(message).indexOf('<script') == 0) {
		// We got only new dealay value but no popup information, let us remove the callback win created
		if($(ActivityReminder_callback_win.id))
			$(ActivityReminder_callback_win.id).remove();
		ActivityReminder_callback_win = false;
		message = '';
	}

	if(message != "") 
    {
        ActivityReminderCallbackRollout(ActivityReminder_popup_maxheight, ActivityReminder_callback_win);
    }
	else {
		ActivityReminderCallbackReset(0, ActivityReminder_callback_win);
	}
}
function ActivityReminderCallbackRollouts(z, ActivityReminder_callback_win) {
    
	ActivityReminder_callback_win = (ActivityReminder_callback_win);

	if (ActivityReminder_timer) {
		window.clearTimeout(ActivityReminder_timer);
	}
	if (ActivityReminder_callback_win && parseInt(ActivityReminder_callback_win.style.height) < z) {
	   
		ActivityReminder_callback_win.style.height = parseInt(ActivityReminder_callback_win.style.height) + ActivityReminder_progressive_height + "px";
		ActivityReminder_timer = setTimeout("ActivityReminderCallbackRollout(" + z + ",'" + ActivityReminder_callback_win.id + "')", 1);
	} else {
		ActivityReminder_callback_win.style.height = z + "px";
        
		if(ActivityReminder_autohide)
          {
           
            ActivityReminder_timer = setTimeout("ActivityReminderCallbackRollin(1,'" + ActivityReminder_callback_win.id + "')", ActivityReminder_popup_onscreen);
          }
		else ActivityReminderRegisterCallback(ActivityReminder_callback_delay);
	}
}
function ActivityReminderCallbackRollins(z, ActivityReminder_callback_win) {
	ActivityReminder_callback_win = $(ActivityReminder_callback_win);

	if (ActivityReminder_timer) {
		window.clearTimeout(ActivityReminder_timer);
	}
	if (parseInt(ActivityReminder_callback_win.style.height) > z) {
		ActivityReminder_callback_win.style.height = parseInt(ActivityReminder_callback_win.style.height) - ActivityReminder_progressive_height + "px";
		ActivityReminder_timer = setTimeout("ActivityReminderCallbackRollin(" + z + ",'" + ActivityReminder_callback_win.id + "')", 1);
	} else {
		ActivityReminderCallbackReset(z, ActivityReminder_callback_win);
	}
}
function ActivityReminderCallbackResets(z, ActivityReminder_callback_win) {
	ActivityReminder_callback_win = document.getElementById(ActivityReminder_callback_win);

	if(ActivityReminder_callback_win) {
		ActivityReminder_callback_win.style.height = z + "px";
		ActivityReminder_callback_win.style.display = "none";
	}
	if(ActivityReminder_timer) {
		window.clearTimeout(ActivityReminder_timer);
		ActivityReminder_timer = null;
	}
	ActivityReminderRegisterCallback(ActivityReminder_callback_delay);
}
function delete_fieldss(module)
{
	var select_options=document.getElementsByName('del');
	var x=select_options.length;
	var xx=0;
	url_rec="";

	for(var i=0;i<x;i++)
	{
		if(select_options[i].checked)
		{
			url_rec=url_rec+select_options[i].value +","
			xx++
		}
	}
	if($("current_action"))
		cur_action = $("current_action").innerHTML
	if (xx == 0)
	{
		var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var alert_str = arrJsPopLabel['SUREWANTDELETETHEDELECTED'] + xx +arrJsPopLabel['RECORDS'];
	if(module=="Accounts")
		alert_str = arrJsPopLabel['REMOVEWILLDELETEOTHER'] + xx +arrJsPopLabel['RECORDS'];
	if(confirm(alert_str))
	{
		$("status").style.display="inline";
		ldAjaxHtmlNoProgress('index.php?',"module="+module+"&action="+module+"Ajax&file=FindDuplicateRecords&del_rec=true&ajax=true&return_module="+module+"&idlist="+url_rec+"&current_action="+cur_action+"&"+dup_start,function(ajaxhtml) {
			$("status").style.display="none";
			$("duplicate_ajax").innerHTML= ajaxhtml;
		});
	}
	else
		return false;
}
function validate_merges(module)
{
	var check_var=false;
	var check_lead1=false;
	var check_lead2=false;

	var select_parent=document.getElementsByName('record');
	var len = select_parent.length;
	for(var i=0;i<len;i++)
	{
		if(select_parent[i].checked)
		{
			var check_parentvar=true;
		}
	}
	if (check_parentvar!=true)
	{
		var confirm_str = arrJsPopLabel['SELECTONEASSUPERIORRECORD'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	return true;
}
function select_Alls(fieldnames,cnt,module)
{
	var new_arr = Array();
	new_arr = fieldnames.split(",");
	var len=new_arr.length;
    var popupobj=CrmPopup.getPopupObj('last');
    
	for(i=0;i<len;i++)
	{
		var fld_names=new_arr[i]
		var value=ld("#"+popupobj.divid).find("[name="+fld_names+"][type=radio],[name="+fld_names+"][type=checkbox]:not(:disabled)");
        
		var fld_len=ld(value).length;;// document.getElementsByName(fld_names).length;
        
		for(j=0;j<fld_len;j++)
		{
			if(cnt == j){
				ld(value[j]).eq(0).prop('checked',true);
			}else{
				ld(value[j]).eq(0).prop('checked',false);
			}
		}
		// 新的合并需要走这个判断，更新对象里的value
		if(popupobj.listmerge_obj && !empty(popupobj.params_arr)){
			var targetvalue = ld(value[cnt]).val();
			popupobj.listmerge_obj.setValue(fld_names,targetvalue);
		}
	}
}
function selectDels(ThisName,CheckAllName)
{
	var ThisNameOptions=document.getElementsByName(ThisName);
	var CheckAllNameOptions=document.getElementsByName(CheckAllName);
	var len1=document.getElementsByName(ThisName).length;
	var flag = true;
	if (typeof(document.getElementsByName(ThisName).length)=="undefined")
	{
		flag=true;
	}
	else
	{
		for (var j=0;j<len1;j++)
		{
			if (ThisNameOptions[j].checked==false)
			{
				flag=false
				break;
			}
		}
	}
	CheckAllNameOptions[0].checked=flag
}
// Added for page navigation in duplicate-listview
var dup_start = "";
function getDuplicateListViewEntries_jss(module,url)
{
	dup_start = url;
    var popupobj=CrmPopup.getPopupObj('last');
	//ld('#rptContentLoading').show();
    
    var duplicateviewwidth = ld(popupobj).get(0).cssWidth;
    ldAjax("index.php?module="+module+"&action="+module+"Ajax&file=FindDuplicateRecords&ajax=true&duplicateviewwidth="+duplicateviewwidth+"&"+dup_start,{}
        ,function(data){
			getListViewEntries_js(module,url);//刷新页面
			$("duplicate_ajax").innerHTML = data.result.content;
            
            //zkt 20220928 XUQIU1000659  自动查重合并，合并弹出层中显示列增加拖动功能（李发林）
			//加载弹出框列表
            ListView_Page.fullwidth_divid = 'hdScrolllistentries_yy';
			ListView_Page.header_table_divid='resize_header_table_divid';//列头table所在div的id
			ListView_Page.header_tableid='resize_header_tableid';//列头所在table的id

			ListView_Page.content_tableid="resize_content_tableid";//内容所在table的id
			ListView_Page.content_table_divid="resize_content_table_divid";//内容table所在div的id
			var listresizeobj=new List_ResizeTable(popupobj);
            popupobj.listresizeobj=listresizeobj;
           	listresizeobj.setPopupResizeTable_Init(module);
			// 0038874: （kfbcrm）客户模块：自动查重合并，查找重复记录，翻页后点击【全选】复选框点不动
			mergeSelect();
            DelProgressObjs();
    })
	/*new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+module+"&action="+module+"Ajax&file=FindDuplicateRecords&ajax=true&"+dup_start,
			onComplete: function(response) {
				$("status").style.display="none";
				$("duplicate_ajax").innerHTML = response.responseText;
        // 0038874: （kfbcrm）客户模块：自动查重合并，查找重复记录，翻页后点击【全选】复选框点不动
        mergeSelect();
			}
		}
		);*/
}

function submitFormForActions(formName, action) {
   var form = document.forms[formName];
	/**
	 * 如果result_aprove=1，判断是从审批中心进入详情页，返回到审批中心
	 * @reason 0009141 审批完成后，点击返回列表按钮，建议返回到我的审批中心
	 * @author Tujt 2014-05-27
	 */
	if(formName == 'DetailView' && (action == 'index' || action == 'ListView')){//back list 返回列表
		if(form.result_aprove != undefined && form.result_aprove.value == '1'){
			window.location=cls_encryptyurl.Puyoung_Encryptyurl("index.php?module=Approve&action=index",'');
			return false;
		}
	}
	
	if (!form) return false;
    if(form.module==undefined)
    {
          var module=document.getElementById("module").value;
          var searchscope="";
          if(document.getElementById("SmOwnerSearchScope")!=undefined)
          searchscope=document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").selectedIndex].value;
          
          var record=document.getElementById("recordid").value;
          document.getElementById("action").value=action;
		  //document.getElementById("isDuplicate").value
          var isDuplicate='';
          var return_module=document.getElementById("return_module").value;

           var return_action=document.getElementById("return_action").value;
           /**
				* 查看页面返回列表时，默认增加query_session=1的参数
				* @project 序时簿查询记住搜索条件
				* @author Tujt 2014-04-24
				*/
           if(document.getElementById("SmOwnerSearchScope")!=undefined)
           
            window.location=cls_encryptyurl.Puyoung_Encryptyurl("index.php?module="+module+"&action="+action+"&record="+record+"&return_module="+return_module+"&return_action="+return_action+"&isDuplicate="+isDuplicate+"&query_session=1&SearchScope="+searchscope,'');
          else
          
            window.location=cls_encryptyurl.Puyoung_Encryptyurl("index.php?module="+module+"&action="+action+"&record="+record+"&return_module="+return_module+"&query_session=1&return_action="+return_action+"&isDuplicate="+isDuplicate,'');

    }
    else 
    {   
        form.action.value = action;
		  /**
		   * 查看页面返回列表，如果query_session变量存在，赋值为1，
			* 启用列表页面搜索session
		   * @project 序时簿查询记住搜索条件
		   * @author Tujt 2014-04-24
		   */
		  if(form.query_session != undefined){
			  form.query_session.value = '1';
		  }
		  form.submit();
    }
	return true;
}
function re_dateValidates(fldval,fldLabel,type) {
	if(re_patternValidate(fldval,fldLabel,"DATE")==false)
		return false;
	dateval=fldval.replace(/^\s+/g, '').replace(/\s+$/g, '')

	var dateelements=splitDateVal(dateval)

	dd=dateelements[0]
	mm=dateelements[1]
	yyyy=dateelements[2]

	if (dd<1 || dd>31 || mm<1 || mm>12 || yyyy<1 || yyyy<1000) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false
	}

	if ((mm==2) && (dd>29)) {//checking of no. of days in february month
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false
	}

	if ((mm==2) && (dd>28) && ((yyyy%4)!=0)) {//leap year checking
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false
	}

	switch (parseInt(mm)) {
		case 2 :
		case 4 :
		case 6 :
		case 9 :
		case 11 :
			if (dd>30) {
			var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false
		}
	}

	var currdate=new Date()
	var chkdate=new Date()

	chkdate.setYear(yyyy)
	chkdate.setMonth(mm-1)
	chkdate.setDate(dd)

	if (type!="OTH") {
		if (!compareDates(chkdate,fldLabel,currdate,arrJsPopLabel['CURRENTDATE'],type)) {
			return false
		} else return true;
	} else return true;
}
//Copied from general.js and altered some lines. becos we cant send vales to function present in general.js. it accept only field names.
function re_patternValidates(fldval,fldLabel,type) {

	if (type.toUpperCase()=="EMAIL") {
		/*changes made to fix -- ticket#3278 & ticket#3461
		  var re=new RegExp(/^.+@.+\..+$/)*/
		//Changes made to fix tickets #4633, #5111  to accomodate all possible email formats
		var re=new RegExp(/^[a-zA-Z0-9]+([\_\-\.]*[a-zA-Z0-9]+[\_\-]?)*@[a-zA-Z0-9]+([\_\-]?[a-zA-Z0-9]+)*\.+([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)*$/)
	}

	if (type.toUpperCase()=="DATE") {//DATE validation

		switch (userDateFormat) {
			case "yyyy-mm-dd" :
				var re = /^\d{4}(-)\d{1,2}\1\d{1,2}$/
				break;
			case "mm-dd-yyyy" :
			case "dd-mm-yyyy" :
				var re = /^\d{1,2}(-)\d{1,2}\1\d{4}$/
		}
	}


	if (type.toUpperCase()=="TIMESECONDS") {//TIME validation
		var re = new RegExp("^([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])$|^([0-1][0-9]|[2][0-3]):([0-5][0-9])$");
	}
	if (!re.test(fldval)) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false
	}
	else return true
}
	function copySelectedOptionss(source, destination) {

    var srcObj =document.getElementById(source);// $(source);
	var destObj =document.getElementById(destination);// $(destination);

	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    /**
    *AUTHOR:BY LD KEVIN
    *DATE:20130326
    *DESPRITION:bug3591
    */
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
		if (srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}

			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie) newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6) newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)
				srcObj.options[i].selected=false
                //srcObj.options.remove(i);//20140902，diony，右移时删除左边信息
                //i=-1;//20140902，diony，右移时删除左边信息，i=-1应该是让循环开始
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null) existingObj.selected=true
			}
		}
	}
}
function fnvshobjMores(obj,Lay,announcement){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = tagName.offsetWidth;
	if(Lay == 'editdiv') {
		leftSide = leftSide - 225;
		topSide = topSide - 225;
	} else if(Lay == 'transferdiv') {
		leftSide = leftSide - 10;
		topSide = topSide;
	}
	var IE = document.all?true:false;
	if(IE) {
		if($("repposition1")) {
			if(topSide > 1200) {
				topSide = topSide-250;
			}
		}
	}

	if((leftSide > 100) && (leftSide < 500)){
		tagName.style.left= leftSide -50 + 'px';
	} else if((leftSide >= 500) && (leftSide < 800)){
		tagName.style.left= leftSide -150 + 'px';
	} else if((leftSide >= 800) && (leftSide < 1400)){
		if((widthM > 100) && (widthM < 250)) {
			tagName.style.left= leftSide- 100  + 'px';
		} else if((widthM >= 250) && (widthM < 350)) {

			tagName.style.left= leftSide- 200  + 'px';
		}
		else if((widthM >= 350) && (widthM < 500)) {
			tagName.style.left= leftSide- 300  + 'px';
		}
		else {
			tagName.style.left= leftSide -550 + 'px';
		}
	} else {
		tagName.style.left= leftSide  + 5 +'px';
	}
	if(announcement){
		tagName.style.top = 110+'px';
	}else{
		tagName.style.top = 76+'px';
	}
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";

}
function getNoOfRowss(id){
	var module = $('curmodule').value;
	var searchurl = $('search_url').value;
	var viewid = getviewId();
	var url = "module="+module+"&action="+module+"Ajax&file=ListViewCount&viewname="+viewid+searchurl;
	if(module == 'Approve'){
		url += "&fromapprovemodule="+ld('#fromapprovemodule').val();
		url += "&approvestatus="+ld('#approvestatus').val();
	}
	/*if(module == 'Documents') {
		var folderid = $('folderid_'+id).value;
		url = url+"&folderidstring="+folderid;
	}*/
	ldAjaxHtmlNoProgress('index.php?',url,function(ajaxhtml) {
		//	if(module != 'Documents') {
		$('numOfRows').value = ajaxhtml;
		$('count').innerHTML = ajaxhtml;
		/*
        edit:can
        date:20130801
        reason:4571: 客户-->"公海未分配"、"公海已分配"页签中，将页签中所有的"客户"选中后，结果显示的是"全部客户"数量


        */
		if(ld('#linkForSelectAll').length > 0){
			if(parseInt($('maxrecords').value) < parseInt(ajaxhtml)&& module!="Accounts"){
				$('linkForSelectAll').show();
			}
		}

		/*} else {
            ld('#numOfRows_'+id).value = response.responseText;
            ld('#count_'+id).innerHTML = response.responseText;
            if(parseInt($('maxrecords').value) < parseInt(response.responseText)){
                $('linkForSelectAll_'+id).show();
            }
        }*/
	});
}
function ViewfnDropDown(obj,Lay){
    var tagName = document.getElementById(Lay);
    tagName.style.display="block";
    return false;
    if(typeof tagName == 'undefined') {
        return;
    }
    var leftSide = findPosX(obj);
    var topSide = findPosY(obj);
    var maxW = tagName.style.width;
    var widthM = maxW.substring(0,maxW.length-2);
    var getVal = eval(leftSide) + eval(widthM);
    if(getVal > document.body.clientWidth ){
    leftSide = eval(leftSide) - eval(widthM);
    //tagName.style.left = leftSide - 10 + 'px';
    }
    else
    //tagName.style.left= leftSide - 10 + 'px';
    tagName.style.display = 'block';
    //alert(tagName.offsetParent.tagName);
    /**
    *edit:can
    date:20140303
    reason:7182: 付款计划、付款单序时簿界面，先点击查找图标，再在数据分类栏，点击创建分类，弹出层严重不合理，导致无法使用，如图：
    **/
    var calendartabheight=0;
    //日程管理
    if(document.getElementById("calendartab")!=undefined)
    {
        calendartabheight=document.getElementById("calendartab").offsetHeight+10;
    }
    
    ///出入库，盘点
    if(document.getElementById("tabWareHouse")!=undefined)
    {
        calendartabheight=document.getElementById("tabWareHouse").offsetHeight+10;
    }
    if(document.getElementById("searchAcc")!=undefined&&document.getElementById("searchAcc").style.display!='none')
    {
         if(tagName.offsetHeight<100)
        {
            tagName.style.top=(tagName.offsetHeight+document.getElementById("searchAcc").offsetHeight+70+calendartabheight)+'px';
        }
        else
            tagName.style.top=(tagName.offsetHeight+document.getElementById("searchAcc").offsetHeight+20+calendartabheight)+'px';
    }
     else if(document.getElementById("advSearch")!=undefined&&document.getElementById("advSearch").style.display!='none')
       
     {
            if(tagName.offsetHeight<100)
            {
                tagName.style.top=(tagName.offsetHeight+document.getElementById("advSearch").offsetHeight+70+calendartabheight)+'px';
            }
            else
          tagName.style.top=(tagName.offsetHeight+document.getElementById("advSearch").offsetHeight+20+calendartabheight)+'px';
     }
    else
    {
     // alert(tagName.offsetParent.offsetHeight);
        if(tagName.offsetHeight<100)
        {
            tagName.style.top=(tagName.offsetHeight+70+calendartabheight)+'px';
        }
        else
        {
            tagName.style.top=(tagName.offsetHeight+10+calendartabheight)+'px';
        }
    }
        
    //alert(document.getElementById("searchAcc").offsetHeight);
}
function validateInputDatas(value, fieldLabel, typeofdata) {

	var typeinfo = typeofdata.split('~');
	var type = typeinfo[0];
  
	if(type == 'T') {
		if(!re_patternValidate(value,fieldLabel+" (Time)","TIMESECONDS"))
			return false;
	} else if(type == 'V'){
	   if(value.length>typeinfo[3]){
	          //    alert(value.length);
       var confirm_str = fieldLabel+arrJsPopLabel['INVALID']+typeinfo[3]+arrJsPopLabel['INVALID'];
       RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
       return false;
	   }
	}else if(type == 'D' || type == 'DT') {
		if(!re_dateValidate(value,fieldLabel+" (Current User Date Format)","OTH"))
			return false
	} else if(type == 'I') {
		if(isNaN(value) || value.indexOf(".")!=-1) {
			var confirm_str = arrJsPopLabel['INVALID']+fieldLabel;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false
		}
	} else if(type == 'N' || type == 'NN') {

		if(typeof(typeinfo[2]) == "undefined") {
			var numformat = "any";
		} else {
			var numformat = typeinfo[2]
		}

		if(type == 'NN') {
			var negativeallowed = true;
		} else {
			var negativeallowed = false;
		}

		if(numformat != "any") {
			if (isNaN(value)) {
				var invalid=true
			} else {
				var format = numformat.split(",")
				var splitval = value.split(".")

				if (negativeallowed == true) {
					if (splitval[0].indexOf("-") >= 0) {
						if (splitval[0].length-1 > format[0]) {
							invalid=true
						}
					} else {
						if (splitval[0].length > format[0]) {
							invalid=true
						}
					}
				} else {
					if (value < 0) {
						invalid=true
					} else if (format[0] == 2 && splitval[0] == 100 && (!splitval[1] || splitval[1]==0)) {
						invalid=false
					} else if (splitval[0].length > format[0]) {
						invalid=true
					}
				}

				if (splitval[1]) {
					if (splitval[1].length > format[1]) {
						invalid=true
					}
				}
			}

			if (invalid==true) {
				var confirm_str = arrJsPopLabel['INVALID'] + fieldLabel;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			} else {
				return true;
			}
		} else {
			var splitval = value.split(".")
			var arr_len = splitval.length;
			var len = 0;
			if(splitval[0] > 18446744073709551615) {
				var confirm_str = fieldLabel + arrJsPopLabel['EXCEEDMAXIMUMLIMIT'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
			if(negativeallowed == true) {
				var re=/^(-|)(\d)*(\.)?\d+(\.\d\d*)*$/
			} else {
				var re=/^(\d)*(\.)?\d+(\.\d\d*)*$/
			}
		}

		//for precision check. ie.number must contains only one "."
		var dotcount=0;
		for (var i = 0; i < value.length; i++) {
			if (value.charAt(i) == ".")
				dotcount++;
		}

		if(dotcount>1) {
			var confirm_str = arrJsPopLabel['INVALID']+fieldLabel;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}

		if (!re.test(value)) {
			var confirm_str = arrJsPopLabel['INVALID']+fieldLabel;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false
		}
	} else if(type == 'E') {
		if (!re_patternValidate(value,fieldLabel+" (Email Id)","EMAIL"))
			return false
	}

	return true;
}

//确定按钮事件
function merge_fields_direct_saveRecordMerge(){
	//editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 15:44 
    var popupobj=CrmPopup.getPopupObj("last");
    
    var params =CrmPopup.findHtmlobj(popupobj.divid,"merge_fields_form").find('[name]').serializeArray();
    var surl = "index.php";
    ldAjax(surl, params, function (data) {
        if (data.code == 1) {
            popupobj.CancelEvent();
            popupobj=CrmPopup.getPopupObj("last");
            if(popupobj.type==ListPagePopup.type)
            {
                //合并
				// @edit:liushuai,2021-07-16,reason: 0046957: https://81mis.com/kfbcrm/ [^]，客户管理——客户——合并两条客户信息后，继续合并其他客户时点击合并无反应
                    ld("#selectedboxes").val("");//edit；can 20200724 如果不添加该语句 ，合并后不刷新界面继续合并，会有错误
                    ld("#allselectedboxes").val("");//取得是name=allselectedboxes的值
                	getListViewEntries_js(popupobj.module,"start="+ld("#"+popupobj.divid+" [name=pagenum]").val());//刷新页面
            }
            else//自动查重合并
                getDuplicateListViewEntries_jss(popupobj.module,"start="+ld("#"+popupobj.divid+" [name=pagenum]").val());
        }else{
			RemindsMsg("","LdPopWidth400px",module,"yes","yes",data.msg);
			return false;
		}
        DelProgressObjs();
        // window.location.reload();
    });
    /*
    CrmPopup.findHtmlobj(popupobj.divid,"merge_fields_form").submit();*/
}
//editor:gyq_72 reason:查重合并样式修改 date:20180705
function duplicate_check_merge_field(selectedNames,module,parent_tab) {
    var select_options=document.getElementsByName(selectedNames);
    var x= select_options.length;
    var pass_url="";
    var xx = 0;
    for(var i = 0; i < x ; i++)
    {
        if(select_options[i].checked)
        {
            pass_url = pass_url+select_options[i].value +","
            xx++
        }
    }
    
    if(xx > 1) {
    	//editor:gyq_72  date:20180710	0034508: 客户、联系人、服务收费管理列表界面>更多>自动查重合并>选择字段查重>勾选单据合并：合并单据后应该回到查重界面而不是跳转到单据列表界面去。
        var surl = "module=" + module + "&action=" + module + "Ajax&file=field_merge&mergemode=mergefields&passurl=" + pass_url + "&excludedRecords=&parenttab=&second_action=find_duplicate";
		ldAjaxNoProgress('index.php?' + surl,'',function (data) {
			if (data.code == 1) {
				$("status").style.display = "none";
				var crmPopupobj = CrmPopup.load(data.result.title, merge_fields_direct_saveRecordMerge, "", "LdPopWidth950px", module, '', data.result.oktext, "", data.result.canceltext);
				crmPopupobj.Okfun.funname = 'merge_fields_direct_saveRecordMerge';
				CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
				ld('#'+crmPopupobj.divid+'_scroll').css('max-height',crmPopupobj.getPopContentHeight())
				crmPopupobj.center();
				if(cls_wxOpenDataobj!=undefined&& typeof cls_wxOpenDataobj!='undefined'){
					cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
				}
			}
		});
    }else{
        var confirm_str = arrJsPopLabel['SELECTLEASTTWO'];
		MessagePopup.TipOne_warning(confirm_str);
        return false;
    }
}
//查重合并已改为其他方法 editor:gyq_72 reason:查重合并样式修改 date:20180705
function merge_fieldss(selectedNames,module,parent_tab)
{
	var select_options=document.getElementsByName(selectedNames);
	var x= select_options.length;
	var req_module=module;
	var num_group=$("group_count").innerHTML;
	var pass_url="";
	var flag=0;
	//var i=0;
	var xx = 0;
	for(i = 0; i < x ; i++)
	{
		if(select_options[i].checked)
		{
			pass_url = pass_url+select_options[i].value +","
			xx++
		}
	}
	var tmp = 0
	if ( xx != 0)
	{
		if(xx > 0)
		{
			for(j=0;j<num_group;j++)
			{
				flag = 0
				var group_options=document.getElementsByName("group"+j);
				for(i = 0; i < group_options.length ; i++)
				{
					if(group_options[i].checked)
					{
						flag++;
					}
				}
				if(flag > 0)
					tmp++;
			}
			if (tmp > 1)
			{
				var confirm_str = arrJsPopLabel['GROUPFROSAMEMERGE'];
                RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
				return false;
			}
			if(xx <2)
			{
				var confirm_str = arrJsPopLabel['SELECTLEASTTWO'];
                RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
				return false;
			}

		}
		var tmpurl = cls_encryptyurl.Puyoung_Encryptyurl("index.php?module="+req_module+"&action=ProcessDuplicates&mergemode=mergefields&passurl="+pass_url+"&parenttab="+parent_tab,"");
		window.open(tmpurl,"Merge","width=750,height=602,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes");
	}
	else
	{
		var confirm_str = arrJsPopLabel['SELECTLEASTTWO'];
        RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
		return false;
	}
}
/*
andrew
20140103
修正window.open打开窗口无法最大化
*/
function selectSalesOrders(mod)
{
	
   
    
    var popupobj=CrmPopup.getPopupObj('last');
    
	var record_id = '';
	var parent_module = '';
    var form=document.EditView;
    if(form==undefined)
    {
        form=document.QcEditView;
    }
	var acc_element = form.account_id;
	var cnt_element =form.contact_id;
    // var module=form.module.value;
    var accountid;
    var vendorid;
    var idstring = '';
	if (acc_element != null) {
		record_id= acc_element.value;
		parent_module = 'Accounts';
	} else if (cnt_element != null) {
		record_id= cnt_element.value;
		parent_module = 'Contacts';
	}
	var rowcnt='';
	if(ld("#"+popupobj.divid+" [name=rowcnt]").length>0){//document.getElementById('rowcnt') != undefined){
		rowcnt =ld("#"+popupobj.divid+" [name=rowcnt]").val();// document.getElementById('rowcnt').value;//产品明细当前行数
	}
    var listval = '';
    if(ld("#"+popupobj.divid+" [name=selectlistval]").length>0&&ld("#"+popupobj.divid+" [name=selectlistval]").val()!="")//document.getElementById('selectlistval')!=undefined && document.getElementById('selectlistval').value!="")
    {
        listval =ld("#"+popupobj.divid+" [name=selectlistval]").val();// document.getElementById('selectlistval').value;
    }
    var issourcedetailfield='no';
    if(popupobj.detailfieldmodule=='Products'&&ld("#"+popupobj.divid+' [name=selectsource]').length>0)
    {
        
        var tmp_selectmodule=ld("#"+popupobj.divid+' [name=selectsource]').val();
		//wym BUG0069933 kfbcrm-服务合同-新建-没有选择源单类型，选择源单会弹出源单选择页面(应该提示选择源单不能为空的信息）
		if(empty(tmp_selectmodule)){
			var str = arrJsPopLabel['SOURCEMODULE']+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",str);
			return false;
		}
        ld.each(popupobj.sourcemodule_arr ,function(tmpindex,tmpinfo){
            if(tmpinfo['entitytype']==tmp_selectmodule)
            {
                issourcedetailfield='yes';
                
                return false;
            }
            
        })
    }
    


    /*出库、采购、发票选择合同订单源单*/
    if(mod == 'Invoice'||mod == 'CashBill'
            ||mod == 'SendCashBill'||mod == 'PurchaseOrder'
            ||mod == 'PurchaseInquiryOrder'||mod == 'OutboundOrder' || mod == 'PurchaseInvoice'
             || mod == 'Stock' || mod == 'PaymentPlan' || mod == 'SendPayment'
             ||mod=='CustomForm11'||mod=='CustomForm12'||mod=='CustomForm13'
             ||mod=='CustomForm14'||mod=='CustomForm15'||mod=='CustomForm16'
             ||mod=='CustomForm17'||mod=='CustomForm18'||mod=='CustomForm19'||mod=='CustomForm20'||mod=='SalesOrder'
             ||mod=='CustomForm36'||mod=='CustomForm37'||mod=='CustomForm38'||mod=='CustomForm39'||mod=='CustomForm40'
             ||mod=='CustomForm41'||mod=='CustomForm42'||mod=='CustomForm43'||mod=='CustomForm44'||mod=='CustomForm45'
             ||mod=='Quotes'||(mod=='Commission'&&account_version=='langjie' 
             ||issourcedetailfield=='yes'
             ||(mod=='Potentials'&&potentials_ShowProductDetail=='yes')))
    {

		var url_str = '';
		if(mod == 'Stock' || mod == 'PurchaseInvoice' || mod == 'SendCashBill' || mod == 'SendPayment' || mod == 'PurchaseInquiryOrder'){
			if(form.vendor_id != undefined){
				url_str = '&vendorid='+ld("#"+popupobj.divid+" [name=vendor_id]").val();//form.vendor_id.value;
			}
		}else{
			if(form.account_id != undefined){
				url_str = '&accountid='+ld("#"+popupobj.divid+" [name=account_id]").val();//form.account_id.value;
			}
		}
		var isModule = 'SalesOrder';
		if(ld("#"+popupobj.divid+" [name=selectsource]").length>0){//document.getElementById('selectsource') != undefined){
			isModule =ld("#"+popupobj.divid+" [name=selectsource]").val();// document.getElementById('selectsource').value;	
		}
		if(ld("#"+popupobj.divid+" [name=selectsourcename]").length>0 && isModule != ld("#"+popupobj.divid+" [name=selectsourcename]").val()){
			listval = '';
		}
        //var listval = document.getElementById('listvalall').value;
        var moduleSource = 'SalesOrder';
		if(ld("#"+popupobj.divid+" [name=selectsource]").length>0){//document.getElementById('selectsource') != undefined){
			moduleSource =ld("#"+popupobj.divid+" [name=selectsource]").val();// document.getElementById('selectsource').value;
		}
		var is_enable = '';
		if(mod != 'PaymentPlan' && mod != 'SendPayment'){
			is_enable = 'select=enable';
		}
      
		if(empty(moduleSource)){
			var str = arrJsPopLabel['SOURCEMODULE']+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",str);
			return false;
		}
		var surl = "module="+moduleSource+"&action=Popup&ReportHeader=dheader&html=Popup_picker&popuptype=selectsource&form=EditView&"+is_enable+"&listval="+listval+url_str+"&parent_module="+isModule+"&frommodule="+mod+"&popup=yes&page_popup=yes";
        if(mod==='PaymentPlan')
        {
            //edit:can 20210205 44622: （本地8.3.7）财务管理-收款计划/付款计划-编辑；编辑收/付款计划单机，清除选择源单时，点击没有任何反应
            surl+="&fieldname=entitytypeid";
        }
        else if(mod=='SendPayment')
        {
            //edit:can 20210205 44622: （本地8.3.7）财务管理-收款计划/付款计划-编辑；编辑收/付款计划单机，清除选择源单时，点击没有任何反应
            surl+="&fieldname=purchaseorder_id";
        }
		else if(mod == 'CashBill'||mod == 'SendCashBill')
		{
			//zkt 20240731 BUG20240729-06 收款计划只能看到自己的188条，收款单源单选择收款计划，能看到所有的，页面设置，选择源单，数据范围是权限查询的，用户管理数据范围设置的是查看编辑自己的
			surl+="&fieldname=selectlistval";
		}
        var  requestvalues="{";
 
          ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
           if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0)
            requestvalues+='"'+tmpfieldinfo.columnname+'":"'+ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val()+'",';
          })
          requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
          requestvalues+="}"
         
          surl+="&requestvalues="+encodeURIComponent(requestvalues);
		// ljj 20231114 XUQIU1002047 选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
		surl+='&isselectsearchdetail=yes';
		surl+='&setsequence=yes';
    	CrmPopupWindow(mod,surl,moduleSource);
    }
    else if(mod == 'Project'){
        if(form.account_id != undefined){
            record_id = form.account_id.value;   
        }
        var isModule =ld("#"+popupobj.divid+" [name=selectsource]").val();// document.getElementById('selectsource').value;
		showrelatedlist(mod,isModule,"select");
    }
    /*else if(mod=='SalesOrder'){
            var surl="module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&form=EditView"+'&frommodule='+mod+"&popup=yes&page_popup=yes";
		CrmPopupWindow(mod,surl,'SalesOrder');
    }*/
    else
    {

		showrelatedlist(mod,'SalesOrder',"select");
	}
}



function originBill_selects(mod)
{
	// To support both B2B and B2C model
	var record_id = '';
	var parent_module = '';
	var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
    var form=document.EditView;
    if(form==undefined)
    {
        form=document.QcEditView;
    }
	var acc_element = CrmPopup.findHtmlobj(divid,"account_id");
	var cnt_element =CrmPopup.findHtmlobj(divid,"contact_id");
    var module=CrmPopup.findHtmlobj(divid,"contact_id").val();
    var accountid;
    var vendorid;
    var idstring = '';
    var popupobj=CrmPopup.getPopupObj('last');
    
	if (acc_element != null) {
		record_id= acc_element.val();
		parent_module = 'Accounts';
	} 
	//0017816: 采购订单-新增界面：选择供应商名称后，再选择合同订单，结果合同订单选择窗口无法显示出数据
	/*else if (cnt_element != null) {
		contact_id= cnt_element.value;
		parent_module = 'Contacts';
	}*/
	var rowcnt='';
	if(document.getElementById('rowcnt') != undefined){
		rowcnt = document.getElementById('rowcnt').value;//产品明细当前行数
	}
    var listval = '';
    if(document.getElementById('selectlistval')!=undefined && document.getElementById('selectlistval').value!="")
    {
        listval = document.getElementById('selectlistval').value;
    }
  
        if(form.account_id != undefined)
        {
            record_id = form.account_id.value;
        }
		//alert(record_id);
		if(mod == 'Quotes'){
			var surl = "module=PurchaseInquiryOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=selectsource&form=EditView&select=enable&accountid="+record_id+"&rowcnt="+rowcnt+"&listval="+listval+"&parent_module="+mod+"&frommodule="+mod;
			CrmPopupWindow(mod,surl,'PurchaseInquiryOrder');
			//window.open("index.php?,"test","resizable=1,scrollbars=1");
		}else{
		 
			if(record_id != ''){
				if(mod=='ServiceContracts'){//服务合同模块选择合同订单（只能选择一条）edit:cyb date:2016-06-07
					var surl = "module=SalesOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=specific&fieldname=salesorder_id&form=EditView&accountid="+record_id+"&rowcnt="+rowcnt+"&listval="+listval+"&parent_module="+mod+"&frommodule="+mod;
					CrmPopupWindow(mod,surl,'SalesOrder');
				}
                else if(mod=='SalesOrder'&&popupobj.module=='SalesOrder')
                {
                    	var surl = "module=SalesOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=specific&fieldname=salesorder_id&form=EditView&listval="+listval+"&rowcnt="+rowcnt+"&frommodule="+mod;
					    CrmPopupWindow(mod,surl,'SalesOrder');
                }
                else{
					var surl = "module=SalesOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=specific&form=EditView&select=enable&accountid="+record_id+"&rowcnt="+rowcnt+"&listval="+listval+"&parent_module="+mod+"&frommodule="+mod;
					CrmPopupWindow(mod,surl,'SalesOrder');
				}
			}  
			else{
				if(mod=='ServiceContracts'){//服务合同模块选择合同订单（只能选择一条）edit:cyb date:2016-06-07
					var surl = "module=SalesOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=specific&fieldname=salesorder_id&form=EditView&listval="+listval+"&rowcnt="+rowcnt+"&frommodule="+mod;
					    CrmPopupWindow(mod,surl,'SalesOrder');
				}
                else if(mod=='SalesOrder'&&popupobj.module=='SalesOrder')
                {
                    	var surl = "module=SalesOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=specific&fieldname=salesorder_id&form=EditView&listval="+listval+"&rowcnt="+rowcnt+"&frommodule="+mod;
					    CrmPopupWindow(mod,surl,'SalesOrder');
                }
                else{
					var surl = "module=SalesOrder&action=Popup&ReportHeader=dheader&popup=yes&html=Popup_picker&popuptype=specific&fieldname=salesorder_id&form=EditView&select=enable&listval="+listval+"&rowcnt="+rowcnt+"&frommodule="+mod;
					CrmPopupWindow(mod,surl,'SalesOrder');
				}
			}
		}
}

/**
edit:can
reason:指定审批人(V5.6),当审批步骤改变，要修改指定审批步骤文本的值
**/
function ApproveStepChange(objsel)
{
  
    var popupobj=CrmPopup.getPopupObj('last');
    var approveid=document.forms['frmapproveblock'].approveid.value;
    //var stepid=objsel.options[objsel.selectedIndex].value;
	var stepid=ld(objsel).val();
   var recordid = document.forms['frmapproveblock'].record.value;
   ldAjaxHtmlNoProgress('index.php?', 'module=Approve&action=ApproveAjax&file=stepApproveUser&approveid='+approveid+"&stepid="+stepid+"&recordid="+recordid+"&ReportHeader=dheader",function(ajaxhtml) {
	   var results=ajaxhtml.split('###SUCCESS###');
	   var userinfos=results[1].split(':');
	   var specifyapproverid=userinfos[2];
	   //edit:can 2021-03-05 44864: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），合同订单（合同编号：SO289）审批时，选择下一步审批步骤后，对应步骤的审批人没有改变（需要补丁）
	   document.getElementById('userid_0').value=userinfos[0];
	   var userids=userinfos[0].split(',');
	   // //25851: 联系记录：控制面板-审批流程中，用户可以指定审批步骤，这里指定下一步审批步骤时，下一步骤的审批人没有根据选择的步骤变
	   //@edit:liushuai,2020-09-18,reason: 0042754 同上
	   // document.getElementById('userid_name').value=userinfos[1];
	   //edit:can 20210903 047814: (https://kehu001.com/KH/kh30033 [^])客户--重庆普阳会计；问题1：登录到成员（朱昱熹）账户，收款单模块报错。问题2：审批人显示报错
	   ld("#userid_name_0").val(userinfos[1]);
	   ld("#userid_name_0").html(userinfos[1]);

	   //edit:zkt 【审批，审批人添加框样式优化】--切换审批步骤
	   var tmpuseridtonames = userinfos[4].split(',');
	   if(tmpuseridtonames != ''){
		   var stepindex = 0;
		   var ulhtml = '';
		   for(i=0;i<tmpuseridtonames.length;i++){
			   var tmpuseridtonamearr = tmpuseridtonames[i].split('##');
			   var tmpid = tmpuseridtonamearr[0];
			   var tmpname = tmpuseridtonamearr[1];
			   //zkt 20220607 52560001通用问题，审批弹框乱码
			   ulhtml += "<li class='ld-input-inner-div-item' itemid='approver_"+stepindex+"_"+tmpid+"' title='"+tmpname+"'><span class='item-name'>"+tmpname+"</span>";
			   if(parseInt(specifyapproverid)!=1){//修改本步骤的审批（1：否）
				   ulhtml += '<span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,\'userid_'+stepindex+'\',\'userid_name_'+stepindex+'\')">×</span>';
			   }
			   ulhtml += '</li>';
		   }
		   var approverdivobj =ld('#before_approve_selectdiv_'+stepindex).find('div[name=approvers_div_'+stepindex+']');
		   if(ld(approverdivobj).find('ul').length>0){
			   ld(approverdivobj).find('ul').html(ulhtml);
			   if(ld(approverdivobj).find('ul').next().length>0){
				   if(parseInt(specifyapproverid)==1){
					   ld(approverdivobj).find('ul').next().css('display','none');
				   }
				   else{
					   ld(approverdivobj).find('ul').next().css('display','');
				   }
			   }
		   }
	   }




	   var ckboxes=document.forms['frmapproveblock'].cb_select_user;
	   ld("#"+popupobj.divid+" [tag=label_countersigner]").css('display','none');
	   ld("#"+popupobj.divid+" [tag=label_approver]").css('display','none');
	   if(userinfos[3]=='yes'){
		   //edit：can 20200713 选择了会签审批步骤，修改为“会签审批人”
		   ld("#"+popupobj.divid+" [tag=label_countersigner]").css('display','');
	   }
	   else{
		   ld("#"+popupobj.divid+" [tag=label_approver]").css('display','');
	   }
	   if(parseInt(specifyapproverid)==1){//修改本步骤的审批（1：否）
		   ld("#before_approve_select").css("display",'none');
		   ld("#userid_name").unbind("click");  //如果本步骤不允许修改审批人，则+加号隐藏，点击框也应该不能选择（取消框的点击事件）
		   //ld("#username_approver").css("display",'none');
		   ld("#userid_name").get(0).removeEventListener("click",approve_selectuser,false);
		   ld("#userid_name").attr("onclick",'');
		   //ld("#userid_name").get(0).click=null;
		   //ld("#userid_name").get(0).click=false;
	   }
	   else{
		   // ld("#username_approver").css("display",'');
		   ld("#before_approve_select").css("display",'');

		   ld("#userid_name").unbind("click").bind("click",function(){

			   approve_selectuser();
		   })
	   }
	   var j=0;
	   //edit:can 20210903 047814: (https://kehu001.com/KH/kh30033 [^])客户--重庆普阳会计；问题1：登录到成员（朱昱熹）账户，收款单模块报错。问题2：审批人显示报错

	   if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
		   //通讯录(pc端企业微信要绑定)
		   cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
	   if(!empty(ckboxes)){
		   for(var i=0;i<ckboxes.length;i++)
		   {
			   for( j=0;j<userids.length;j++)
			   {

				   if(document.getElementById('txt_user_'+i).value==userids[j])
				   {

					   ckboxes[i].checked=true;
					   j=-1;
					   break;
				   }
			   }

			   if(j>-1)
			   {

				   ckboxes[i].checked=false;
			   }

		   }
	   }
   });
    
}
/**
*@author:andy
*@data:20141027
*@reason:选客户带入联系人，及关联字段信息
*@version:v5.8
*/
function customerintocontacts(record,formobj,frommodule,actionmodule)
{
    var obj_name;
	var obj_id;
    $("status").style.display='inline';
	ldAjaxHtmlNoProgress('index.php?',"module=Users&action=UsersAjax&file=customerintocontact&ajax=true&record="+record+'&actionmodule='+actionmodule,function(ajaxhtml) {
		$("status").style.display="none";
		if(actionmodule == 'Accounts'){
			obj_name = formobj.contacts_name;
			obj_id = formobj.contact_id;
		}else if(actionmodule == 'Contacts'){
			obj_name = formobj.accounts_name;
			obj_id = formobj.account_id;
		}
		if(ajaxhtml.indexOf("###SUCCESS###")!=-1){
			result = ajaxhtml.split('###SUCCESS###');
			var strs= new Array(); //定义一数组
			strs=result[1].split("-@#$&%*-"); //字符分割


			if(formobj.name=='QcEditView'){

				obj_name.value=strs[1];
				obj_id.value=strs[0];
				obj_name.disabled  = true;
				obj_name.style.cursor = 'not-allowed';

			}
			else if(formobj.name=='EditView'){
				obj_name.value=strs[1];
				obj_id.value=strs[0];
				obj_name.disabled  = true;
				obj_name.style.cursor = 'not-allowed';
				if(actionmodule == 'Accounts'){
					getAccountsContactsInfo(record,strs[0],frommodule,'EditView');
				}else{
					getAccountsContactsInfo(strs[0],record,frommodule,'EditView');
				}
			}
		}
		/**
		 *@edit: andy
		 *@date: 2014-11-19
		 *@reason: 0012490: 单据重新选择客户名称后，关联的联系人姓名没有自动刷新，希望修正。
		 *@version: v5.8
		 */
		else{

			if(formobj.name=='QcEditView'){
				if(actionmodule == 'Accounts'){
					form.contacts_name.value='';
					form.contact_id.value='';
				}else{
					form.accounts_name.value='';
					form.account_id.value='';
				}
			}
			if(formobj.name=='EditView'){
				obj_name.value='';
				obj_id.value='';
				getAccountsContactsInfo(record,'',frommodule,'EditView');

			}
		}
		//$("ListViewContents").innerHTML= result[2];
	});
}
/**
 * @edit:chj
 * @date:2014-9-22
 * @reason:点击客户名称、联系姓名标签的清除按钮  清除对应的关联字段信息
 * @description:关联客户、联系人关联字段模块 module:当前模块  bemodule：关联模块  mode：EditView编辑页
 */
function clearAccountsContactsInfos(module,bemodule,mode)
{  
    var accountid = '';
    var contactid = '';
    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或者编辑界面
	//客户服务单 - 清除客户名称
    if(module=='HelpDesk'&&bemodule == 'Accounts'&&mode=='EditView'){
		if(document.getElementById('accountid') != undefined){
			document.getElementById('accountid').value ='';	
		}
        getAccountByHelpDeskHistory(accountid,'',popupobj);
    }
    if(bemodule == 'Accounts')
    {
		if(document.EditView != undefined)
        {
             if(document.EditView.contact_id != undefined)//edit:can 不能把该语句和document.EditView!=undefiend放在一行
             {
                contactid = document.EditView.contact_id.value;
             }
        }
			
		else{
			if(document.QcEditView.contact_id != undefined)
			{
				contactid = document.QcEditView.contact_id.value;		
			}
		}
		
    }
    else if(bemodule == 'Contacts' && document.EditView.account_id != undefined)
    {
       
		if(document.EditView != undefined)//edit:can 不能把该语句和document.EditView!=undefiend放在一行
        {
            if( document.EditView.account_id != undefined)
            	accountid = document.EditView.account_id.value;   
        }
		
		else
			accountid = document.QcEditView.account_id.value;
    }
  
	if(document.EditView != undefined)
		var frommodule = document.EditView.module.value;
	else if(document.DetailView != undefined)
		var frommodule = document.DetailView.module.value;
	else
		var frommodule = module;
  //36711: （1.6）合同订单明细界面>关联创建出库单>将联系人或者客户字段擦除：擦除时会将源单也清除掉，编辑历史的出库单也有该问题，直接新增出库是正常的
  //不用做模块的特殊判断
  if(bemodule=='Accounts')//
      clearAccountsContactsInfo.other_clear();
    //alert('module=Users&action=UsersAjax&file=getAccountsContactsInfo&mode='+mode+'&accountid='+accountid+'&contactid='+contactid+'&frommodule='+frommodule);
    //alert($("showAccountsContactsInfoTr").style.display);
    if(typeof $("showAccountsContactsInfoTr") != 'undefined' && $("showAccountsContactsInfoTr").style.display != 'none'){
		ldAjaxHtmlNoProgress('index.php?','module=Users&action=UsersAjax&file=getAccountsContactsInfo&mode='+mode+'&accountid='+accountid+'&contactid='+contactid+'&frommodule='+frommodule,function(ajaxhtml) {
			if(ajaxhtml != ''){
				var results = trim(ajaxhtml).split('###SUCCESS###');
				if(results[1] != 1){
					$("showAccountsContactsInfo").innerHTML = results[1];
					$("showAccountsContactsInfoTr").style.display="";
					//$("showAccountsContactsInfo").style.display="block";
				}
				if(trim(response.responseText) == '###SUCCESS###'){
					$("showAccountsContactsInfoTr").style.display="none";
				}
			}
		});
    }
    
}
/**
 *@edit:andy 
 *@date:2015/3/31
 *@reason:权限管理、部门 设置成员事件
 *@version:V6.0 角色权限改进
 */
function clickSelectMembers(obj,divname){
    
	var objMember = '';
    var pinyinArray = new Array();
	if(document.getElementById(divname) != undefined){
		objMember = document.getElementById(divname);
	}
	var allmemberlen = objMember.length;
	var isSel=0;
	var isSelectOpteion =0;
	var objlength = obj.value.length;
	if(obj.value != '')
	{
		var selectHeight = objMember.scrollHeight;//下拉框的高度
		var optionHeight = selectHeight/allmemberlen;
		for(var i=0;i<allmemberlen; i++)
		{
			//字符串
			var selectValue = objMember.options[i].text;
			var selT = selectValue.indexOf(obj.value);
         
			//拼音
			var pinyin = makePy(selectValue);//17222: (71mis.com/crm)控制面板>部门设置/权限管理,关于设置成员模糊搜索的问题
            
           pinyin=pinyin.join("").toLowerCase();
           pinyinArray[i]=pinyin;
           
			var selP = pinyin.indexOf(obj.value);

			if(selT >=0 || selP >=0)
			{
				if(isSel == 0)
				{
					if(selP > 0){
					   if(pinyinArray[i].indexOf(obj.value)>0){
					       objMember.options[i].selected = true;
                           isSel = 1
					   }
						//if(pinyin.substring(0, objlength) == obj.value){
							//objMember.options[i].selected = true;
							//isSel = 1;
						//}
					}
					else{
						objMember.options[i].selected = true;
						isSel = 1;
					}
					
					isSelectOpteion = i;
				}
				else{
					objMember.options[i].selected = false;
				}
			}
			else{
				if(objMember.options[i].selected = true)
				{
					objMember.options[i].selected = false;
				}
			}
		}
		if(isSelectOpteion >=10){
			ld("#"+divname).animate({ scrollTop: optionHeight*isSelectOpteion-70});
			//objMember.scrollTop = ;
		}else{
			ld("#"+divname).animate({ scrollTop: 0});
		}
		
	}
	else{
		for(var i=0;i<allmemberlen; i++)
		{
			if(objMember.options[i].selected == true)
			{
				objMember.options[i].selected = false;
			}
		}
		isSel = 0;
		objMember.scrollTop =0;
	}
}
function getPY(ch)   
{   
	 if(ch !='')  {            
		 var code = ansi(ch);
		 var py = '';   
		 if(code>=45217 && code<=45252) {      
			 py = "A"  
		 } else if(code>=45253 && code<=45760) {   
			 py = "B"  
		 } else if(code>=45761 && code<=46317) {   
			 py = "C"  
		 } else if(code>=46318 && code<=46825) {   
			 py = "D"  
		 } else if(code>=46826 && code<=47009) {   
			 py = "E"  
		 } else if(code>=47010 && code<=47296) {   
			 py = "F"  
		 } else if((code>=47297 && code<=47613) || (code == 63193)) {   
			 py = "G"  
		 } else if(code>=47614 && code<=48118) {   
			 py = "H"  
		 } else if(code>=48119 && code<=49061) {   
			 py = "J"  
		 } else if(code>=49062 && code<=49323) {   
			 py = "K"  
		 } else if(code>=49324 && code<=49895) {   
			 py = "L"  
		 } else if(code>=49896 && code<=50370) {   
			 py = "M"  
		 } else if(code>=50371 && code<=50613) {   
			 py = "N"  
		 } else if(code>=50614 && code<=50621) {   
			 py = "O"  
		 } else if(code>=50622 && code<=50905) {   
			 py = "P"  
		 } else if(code>=50906 && code<=51386) {   
			 py = "Q"  
		 } else if(code>=51387 && code<=51445) {   
			 py = "R"  
		 } else if(code>=51446 && code<=52217) {   
			 py = "S"  
		 } else if(code>=52218 && code<=52697) {   
			 py = "T"  
		 } else if(code>=52698 && code<=52979) {   
			 py = "W"  
		 } else if(code>=52980 && code<=53688) {   
			 py = "X"  
		 } else if(code>=53689 && code<=54480) {   
			 py = "Y"  
		 } else if(code>=54481 && code<=62289) {   
			 py = "Z"  
		 } else {   
			 py =ch;
		 }   
		 return py;   
	}else{
		 return '';
	}   
 }
/**
 * 
 * @param 采购关联创建入库单  合同订单关联创建入库单
 * @returns true
 * @author Chj 
 */
function checkProductNum(module,recordid,type,accountid,tag_url){
   var urlstring = "module=Users&action=UsersAjax&file=ProductNum&recordid="+recordid+"&type="+type+"&frommodule="+module+"&ajax=true";
   var hrefurl='';//跳转路径
   if(tag_url == undefined) tag_url=  '';
   ldAjaxHtmlNoProgress('index.php?',urlstring,function(ajaxhtml) {
	   if(ajaxhtml.indexOf('###error###') == -1){


		   hrefurl = "index.php?module="+module+"&action=EditView&return_action=DetailView&relatedcreate=yes&Create=true&fromid="+recordid+tag_url;
		   if(accountid > 0){
			   /**
				* 出库单的客户字段应该是account_id，而不是accountid
				* @reason 0015063: 合同订单查看界面：关联创建出库单时，没有带出“客户名称”字段值
				* @author Tujt 2015-05-20
				*/
			   hrefurl +="&account_id="+accountid;
		   }
		   hrefurl = cls_encryptyurl.Puyoung_Encryptyurl(hrefurl);
		   window.open(hrefurl);
	   }else{
		   if(type == 2){
			   var confirm_str = arrJsPopLabel['THEDOCUMENTSHAVEALLOUT'];//该合同订单已经全部出库，不允许创建出库单！
		   }else{
			   var confirm_str = arrJsPopLabel['THEDOCUEMNTSHAVEBEENPUTINSTORAGE'];//该采购订单已经全部入库，不允许创建入库单！

		   }
		   RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
		   return false;
	   }
   });
	
}
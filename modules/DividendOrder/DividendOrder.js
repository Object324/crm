function sendDividendOrderSms(module){
	if(module != ''){
		var settingsobj=new getSmssettings(module);
	}
	return false;
}
function getSmssettings(module){
	var url_string = 'module='+module+'&action='+module+'Ajax&file=SmsSettings';
    var cur_this=this;
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:url_string,
		onComplete: function(response) {
			lingdangJS_DialogBox.block();
			if(response.responseText != ''){
				$('smssettings_div').innerHTML=response.responseText;
				
			}
			fnvshobj(this, 'smssettings');
           
			cur_this.dividendOrder_sms_Bind(module);
            ld("#sms_save").click(function(){
                cur_this.save();
            });
		}
	});
}
//短信设置按钮事件
getSmssettings.prototype.dividendOrder_sms_Bind = function(module){
	var tabid;
    
    var cur_this=this;
	if(ld('#tabid') != undefined){
		tabid = ld('#tabid').val();
	}
	//设置短信格式
	ld("#is_dividend_settings,#is_anti_dividend_settings").click(function() {
		var tag  =ld(this).attr('tag');
		var url_string = 'module='+module+'&action='+module+'Ajax&file=SmsSettings&get_sms_content=yes&dividend_type='+tag;
		new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:url_string,
			onComplete:function (response) {
				lingdangJS_DialogBox.block();
				if(response.responseText != ''){
					$('smssettings_div').innerHTML=response.responseText;
					
				}
				fnvshobj(this, 'smssettings');
				if(tabid > 0){
					OutboundOrdermoduleSel(tabid);
				}
				//document.getElementById("selField").value="[var."+obj.value+"]";
				cur_this.smsContentBind(module);
			}
		}); 
	});
	
}
getSmssettings.prototype.save=function()
{
    //短信设置  保存
		var textDividendContent;//派息内容不能为空
		if(ld('#textDividendContent') != undefined){
			if(ld('#textDividendContent').val() == ''){
				alert(arrJsPopLabel['DIVIDENDCONTENT']+arrJsPopLabel['CANOTEMPTY']);
				ld('#textDividendContent').focus();
				return false;
			}else{
				textDividendContent = encodeURIComponent(ld('#textDividendContent').val());
			}
		}
        
		var textAntiDividendContent;//反派息内容不能为空
		if(ld('#textAntiDividendContent') != undefined){
			if(ld('#textAntiDividendContent').val() == ''){
				alert(arrJsPopLabel['ANTIDIVIDENDCONTENT']+arrJsPopLabel['CANOTEMPTY']);
				ld('#textAntiDividendContent').focus();
				return false;
			}else{
				textAntiDividendContent = encodeURIComponent(ld('#textAntiDividendContent').val());
			}
		}
		//请选择要发送短信到哪些手机
		var chk_fieldname_value =[];
		ld('input[name="mobile_fieldname"]:checked').each(function(){//遍历每一个名字为mobile_fieldname的复选框，其中选中的执行函数    
			chk_fieldname_value.push(ld(this).val());//将选中的值添加到数组chk_fieldname_value中      
		});
		if(chk_fieldname_value.length < 1){
			alert(arrJsPopLabel['CHOOSEWHICHPHONETOSENDTEXTMASSEAGEJSPOP']);
			return false;
		}
		var is_dividend_checked = 0;//派息后是否立即发送短信通知
		var is_anti_dividend_checked = 0;//反派息后是否立即发送短信通知
		if(ld("#is_dividend").is(':checked') == false){
			is_dividend_checked = 1;
		}
		if(ld("#is_anti_dividend").is(':checked') == false){
			is_anti_dividend_checked = 1;
		}
       
		var url_string = 'module=DividendOrder&action=DividendOrderAjax&file=SmsSettings&is_dividend_checked='+is_dividend_checked+'&is_anti_dividend_checked='+is_anti_dividend_checked+'&save_sms=yes';
		url_string += '&textDividendContent='+textDividendContent;
		url_string += '&textAntiDividendContent='+textAntiDividendContent;
		url_string += '&mobile_fieldname='+chk_fieldname_value.join(',');
		new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:url_string,
			onComplete: function(response) {
				fninvshnew('smssettings');
			}
		});
	
}
//设置短信格式事件
getSmssettings.prototype.smsContentBind = function(module){
    var cur_this=this;
	//X 取消 按钮
	ld("#colose_sms_content,#D_pbtncancel").click(function() {
		fninvshnew('smssettings');
       // getSmssettings(module);
		sendDividendOrderSms(module);
	});
	//插入到内容模板
	ld('#InsertTemplate').click(function(){
		if(trim(ld('#selField').val())==""){
			//请选择字段！
			alert(arrJsPopLabel['PLEASESELECTFIELD']);
			return false;
		}
		(function($){
			$.fn.extend({
				insertAtCaret: function(myValue){
					var $t=$(this)[0];
					if (document.selection) {
						this.focus();
						sel = document.selection.createRange();
						sel.text = myValue;
						this.focus();
					}else if ($t.selectionStart || $t.selectionStart == '0') {
						var startPos = $t.selectionStart;
						var endPos = $t.selectionEnd;
						var scrollTop = $t.scrollTop;
						$t.value = $t.value.substring(0, startPos) + myValue + $t.value.substring(endPos, $t.value.length);
						this.focus();
						$t.selectionStart = startPos + myValue.length;
						$t.selectionEnd = startPos + myValue.length;
						$t.scrollTop = scrollTop;
					}else {
						this.value += myValue;
						this.focus();
					}
				}
			}) 
		})(ld);
		ld('#CKcontent').insertAtCaret(ld('#selField').val());
	});
	//保存
	ld("#save_sms_content").click(function() {
		var dividend_type;
		var sms_content;
		//内容模板不能为空
		if(trim(ld('#CKcontent').val()) == ''){
			alert(arrJsPopLabel['CONTENTTEMPLATEEMPTY']);
			return false;
		}else{
			sms_content = encodeURIComponent(ld('#CKcontent').val());
		}
		if(ld('#dividend_type') != undefined){
			dividend_type = ld('#dividend_type').val();
		}
		var url_string = 'module='+module+'&action='+module+'Ajax&file=SmsSettings&sms_templates=yes&dividend_type='+dividend_type+'&sms_content='+sms_content;
		new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:url_string,
			onComplete:function (response) {
				if(response.responseText != ''){
					$('smssettings_div').innerHTML=response.responseText;
					
				}
				fnvshobj(this, 'smssettings');
				cur_this.triggerBind(module);
			}
		}); 
	});


}
//选择字段
function fieldSel(obj){
    if(document.getElementById("moduleSelID") != undefined && document.getElementById("moduleSelID").value=='14'){
        document.getElementById("selField").value="[Pvar."+obj.value+"]";
    }else{
        document.getElementById("selField").value="[var."+obj.value+"]";    
    }
}



/**
 * 派息单  - 派息 、反派息
 * @param	operationtype： mass 列表批量  listivew 列表操作列按钮  detailview 详情页按钮
 *			idkey：单据ID
 *			stype：0 派息  1 反派息
 * @returns
 * @author Chj 
 */
function massDividend(obj,operationtype,idkey,stype){
	var idstring;
	var obj_relatedid;
	//operationtype mass 列表批量  listivew 列表操作列按钮  detailview 详情页按钮
	if(operationtype == 'mass'){
		
		var select_options = document.getElementById('allselectedboxes').value;
		if(select_options == 'all'){
			document.getElementById('idlist').value = select_options;
			idstring = select_options;
		//	var skiprecords = excludedRecords.split(";");
		//	var count = skiprecords.length;
		//	if(count > 1){
			//	count = numOfRows - count + 1;
			//} else {
				count = $('numOfRows').value;
		//	}
		}else{
			var x = select_options.split(";");
			count = x.length;
		   
			if (count > 1) {
				document.getElementById('idlist').value = select_options;
				idstring = select_options;
			} else { 
				alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
			//we have to decrese the count value by 1 because when we split with semicolon we will get one extra count
			count = count - 1;
		}
	}else{
		idstring = idkey;
		count = 1;
	}
	var url_string = "module=DividendOrder&action=DividendOrderAjax&file=UpdateDividendOrderStatus&operationtype="+operationtype+"&idlist="+idstring;
	if(operationtype == 'mass'){
		var alert_str = arrJsPopLabel['TODATERMINETHESELECTEDDIVIDEND'] + ' ' + parseInt(count) + ' ' + arrJsPopLabel['RECORDS'] + '？';
		if( parseInt(count) > parseInt(getMaxMassOperationLimit())) {
			alert_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count),getMaxMassOperationLimit(),'');
		}
		var viewid = getviewId();
		var searchurl = $('search_url').value;
		var searchScope="";
		if(document.getElementById("SmOwnerSearchScope")!=undefined)
			searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
		url_string += "&viewname="+viewid+searchurl+"&SearchScope="+searchScope;
	}else{
		if(idkey > 0){
			if(stype == 0){
				var alert_str = arrJsPopLabel['TODATERMINETHEDIVIDEND'];		
			}else if(stype == 1){
				var alert_str = arrJsPopLabel['SUREYOUWANTTOREVERSETHEDIVIDEND'];
			}
		}
	}
	url_string += "&stype="+stype;
	//关联相关信息派息单 - 点击派、反派息按钮
	if(obj != undefined){
		obj_relatedid = ld(obj).attr('relatedid');
	}
	
	if(confirm(alert_str)){
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:url_string,
				onComplete: function(response) {
				   
				    //21821: （金融账套）合同订单明细界面，点击相关信息-派息单，点击【新建派息单】后取消：点击单据后的【派息】按钮后没有变更为【反派息】
					   document.getElementById("status").style.display="none";
                   
					if(empty(response.responseText)) return false;
					//相关信息
					if(obj_relatedid > 0){
						resetRelated(obj_relatedid);
					}else{
						if(operationtype == 'mass'){
							var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
							createElementDiv('dividend_div');//创建DIV
							ld('#dividend_divtitlename').html(restobj.title.value);//弹出层标题
							sethtml(document.getElementById('dividend_divcontent'),restobj.log.value);//弹出层内容
							ld('#dividend_div .D_pbtn .D_pbtncancel').css('display','none');//取消按钮
							ld('#dividend_div .D_pbtn .D_pbtnok').unbind('click').on('click',function(){//确定按钮
								fninvshnew('dividend_div');lingdangJS_DialogBox.unblock();
								$('basicsearchcolumns').innerHTML = '';
								$('allselectedboxes').value='';
								$('excludedRecords').value='';
								getListViewEntries_js('DividendOrder',restobj.start.value);//刷新页面
							});
						}else if(operationtype == 'listview'){
							var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
							getListViewEntries_js('DividendOrder',restobj.start.value);//刷新页面
						}else{
							window.location.reload();
						}
					}
				}
			});
		return false;
	}
}
/**
明细调整
**/
function divdendorderDetail_Adjustment(rowindex)
{
    document.getElementById("dividorderdetail_span_"+rowindex).style.display="none";
    document.getElementById("editarea_dividorderdetail_"+rowindex).style.display="block";
}
/**
调整保存
**/
function dividendordertail_save(rowindex,detailid)
{
    var money=document.getElementById("txtbox_dividorderdetail_"+rowindex).value;
    var adjustment=document.getElementById("dividorderdetail_adjustment_"+rowindex).innerHTML;
    var url_string="module=DividendOrder&action=DividendOrderAjax&adjustment="+adjustment+"&money="+money+"&detailid="+detailid;
    if(!isNaN(money))
    {
        new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:url_string,
				onComplete: function(response) {
					$("status").style.display="none";
					document.getElementById("dividorderdetail_span_"+rowindex).style.display="block";
                    document.getElementById("editarea_dividorderdetail_"+rowindex).style.display="none";
                    document.getElementById("hidden_adjstment_dividorderdetail_"+rowindex).innerHTML=adjustment;
                    document.getElementById("dividorderdetail_span_"+rowindex).innerHTML=money;
				}
			});
    }
    else
    {
        alert(arrJsPopLabel['AMOUNTILLEGAL']);
    }
}
function dividendordertail_money(rowindex,obj)
{
    var adjustment=document.getElementById("dividorderdetail_adjustment_"+rowindex).innerHTML;
    //alert(adjustment);
    if(adjustment!="")
    {
        adjustment=trim(adjustment.split(",").join(""));
      //  adjustment=parseFloat(adjustment).toFixed(2);
      
    }
    else
    {
        adjustment=parseFloat("0").toFixed(2);
    }
    var now_money;
    if(obj.value==""||isNaN(obj.value))
    {
        now_money=parseFloat("0").toFixed(2);
    }
    else
    {
        now_money=parseFloat(obj.value).toFixed(2);
    }
    var old_money=document.getElementById("dividorderdetail_span_"+rowindex).innerHTML;
   var minus=parseFloat(now_money).toFixed(2)-parseFloat(old_money).toFixed(2);
   
    adjustment=parseFloat(adjustment)+parseFloat(minus);
     
    document.getElementById("dividorderdetail_adjustment_"+rowindex).innerHTML=parseFloat(adjustment).toFixed(2);
}
/**
调整取消
**/
function dividendordertail_cancel(rowindex)
{
    document.getElementById("dividorderdetail_span_"+rowindex).style.display="block";
    document.getElementById("editarea_dividorderdetail_"+rowindex).style.display="none";
    var old_money=document.getElementById("dividorderdetail_span_"+rowindex).innerHTML;
    var old_adjustment=document.getElementById("hidden_adjustment_dividorderdetail_"+rowindex).innerHTML;
    document.getElementById("dividorderdetail_adjustment_"+rowindex).innerHTML=parseFloat(old_adjustment).toFixed(2);
    document.getElementById("txtbox_dividorderdetail_"+rowindex).value=parseFloat(old_money).toFixed(2);
}
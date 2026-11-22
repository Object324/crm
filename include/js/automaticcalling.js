//汉天呼叫中心自动外呼功能 begin
/**
 * @project 汉天呼叫中心时添加自动外呼功能
 * @author Tujt 2015-04-29
 */
var callcenter_record = [];
function automaticcalling(btnobj,setype){
	//判断是否为全选所有状态(暂不支持全选所有)
	if('all' == document.getElementById('allselectedboxes').value){
		var confirm_str = arrJsPopLabel['LBL_SUPPORTTHESELECTALL'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if(ld('input[name=selected_id]:checked').length == 0){//请至少选择一条记录
		var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var i = 0;var accountid = '';
	ld('input[name=selected_id]:checked').each(function(){
		//callcenter_record[i] = ld(this).val();i ++;
		accountid += ld(this).val()+',';
	});
	//添加删除数组元素
	Array.prototype.remove = function(dx){
		if(isNaN(dx)||dx>this.length){return false;}
		for(var i=0,n=0;i<this.length;i++){
			if(this[i] != this[dx]){
				this[n++] = this[i]
			}
		}
		this.length -= 1;
	}
	//获取客户的电话号码
	var ustring = 'module=Users&action=UsersAjax&file=callStaticMethod';
	ustring += '&static=Accounts&method=getAccountPhone';
	ustring += '&accountid='+accountid;
	showBgDiv();
	RequestAjax(ustring,function(rest){
		closeDiv();
		//将返回值格式化为对象
		callcenter_record = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		callcenter_record['titlelabel'] = ld(btnobj).html();
		if(empty(callcenter_record.phone)){//没有可供外呼的电话，或电话字段未设置为外呼字段。
			var confirm_str = arrJsPopLabel['LBL_CALLNOTAVAILABLE'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
			callcenter_record = [];
			DelProgressObjs();
			return false;
		}
		//创建弹出层
		var divid = 'callCenterCreateNote';
		if(0 == ld('#'+divid).length){//当层未创建时，创建层
			divObj = document.createElement("div");
			divObj.setAttribute('id',divid);
			divObj.className = 'D_pop_box LdPopWidth800px';
			divObj.style.position = "absolute";
			divObj.style.zIndex = "10001";
			divObj.style.top = "50%";
			divObj.style.left = "40%";
			divObj.style.display = "none";
			divObj.style.backgroundColor = "#ffffff";
			document.body.appendChild(divObj);
		}
		callCenterCallMobile();//调用快速创建联系记录窗口
	});
}
/**
 * 快速创建联系记录
 * @author Tujt 2015-04-29
 */
function callCenterCallMobile(){
	//外呼计划所选择客户全部拨打完成，不再走下面的逻辑
	if(callcenter_record['record'].length == 0){//应该需要有关闭窗口之类的逻辑，功能做完再处理
		var confirm_str = arrJsPopLabel['LBL_CALLOUTBOUNDENDED'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		//ld('#'+divid+' .D_pbtn .D_pbtncancel').click();//关闭窗口
		getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
		callcenter_record = [];
		fninvshnew('callCenterCreateNote');
		DelProgressObjs();
		return false;
	}
	var record = callcenter_record['record'][0];//永远都获取第一个客户ID
	var idx = callcenter_record['phone'][record]['idx'];//获取当前客户的可拨打电话数量
	//该值必定大于0，不多做判断
	if(idx > 1){//超过一个电话
		if(ld('#callCenterCreateNote').length > 0){
			//ld('#callCenterCreateNote .D_pbtn .D_pbtncancel').click();//关闭窗口
			getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
			fninvshnew('callCenterCreateNote');
		}
		//弹出界面供用户选择要拨打的号码
		var divid = 'callcenter_selectid';
		var divobj = createElementDiv(divid);
		var divhtml = '<table class="DetailContentTable" width="100%" cellspacing="1" cellpadding="0" border="0"><tbody>';
		//客户
		divhtml += '<tr><td class="DetailedTd1Label" width="20%" align="right">';
		divhtml += callcenter_record['modulelabel']['ld_account'];
		divhtml += '</td><td class="DetailedTd2Info" width="30%" align="left" colspan="3">';
		divhtml += '<a href="index.php?module=Accounts&action=DetailView&record='+record+'" target="_blank">';
		divhtml += callcenter_record['phone'][record]['accountname'] + '</a></td>';
		//首要联系人
		//divhtml += '<td class="DetailedTd1Label" width="20%" align="right">';
		//divhtml += callcenter_record['modulelabel']['ld_contactdetails'];
		//divhtml += '</td><td class="DetailedTd2Info" width="30%" align="left">';
		//var contactid = callcenter_record['phone'][record]['contactid'];
		//divhtml += '<a href="index.php?module=Contacts&action=DetailView&record='+contactid+'" target="_blank">';
		//divhtml += callcenter_record['phone'][record]['lastname'] + '</a>';
		//divhtml += '</td>';
		//循环显示要外呼的电话
		divhtml += '</tr><tr>';var foridx = 0;var mobile = '';
		ld.each(callcenter_record['header'],function(tab,tabObj){
			ld.each(tabObj,function(fld,fldObj){
				mobile = callcenter_record['phone'][record]['call'][tab][fld];
				if(empty(mobile)) return true;
				divhtml += '<td class="DetailedTd1Label" width="20%" align="right">';
				divhtml += fldObj.label;
				divhtml += '</td><td class="DetailedTd2Info" width="30%" align="left">';
				divhtml += '<a href="javascript:;" mobile="'+mobile+'">';
				divhtml += mobile + '</a></td>';
				foridx ++;
				if(foridx % 2 == 0){
					divhtml += '</tr><tr>';
				}
			});
		});
		divhtml += '</tr>';
		divhtml += '</tbody></table>';
		ld('#callcenter_selectidcontent').html(divhtml);
		ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['LBL_SELECTNUMBERCALL']);
		ld(divobj).find('.D_pbtn').css('display','none');
		ld('#'+divid).find('a[mobile]').on('click',function(){
			var mobile = ld(this).attr('mobile');
			callCenterCreateNote(mobile);//外呼电话并创建联系记录
			//ld('#'+divid).find('.D_pop_tit a.D_ptitc').click();
			fninvshnew(divid);
		});
		// 关闭事件
		ld('#'+divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
			ld('#'+divid+' .D_pbtn .D_pbtncancel').click();
			return false;
		});
		ld('#'+divid+' .D_pbtn .D_pbtncancel').attr('onclick','');
		ld('#'+divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
			if(confirm(arrJsPopLabel['LBL_CANCELCALLQUEUE'])){
				getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
				callcenter_record = [];
				fninvshnew(divid);
			}
			return false;
		});
	}else{
		var mobile = '';
		ld.each(callcenter_record['header'],function(tab,tabObj){
			ld.each(tabObj,function(fld,fldObj){
				mobile = callcenter_record['phone'][record]['call'][tab][fld];
				if(!empty(mobile)) return false;
			});
		});
		callCenterCreateNote(mobile);//外呼电话并创建联系记录
	}
}
/**
 * 电话外呼兼创建联系记录
 * @author Tujt 2015-04-30
 */
var callcenter_time = 5;
function callCenterCreateNote(mobile){
	//1、电话外呼
	var urlfilter = 'module=Users&action=UsersAjax&file=CallCenterHandle';
	urlfilter += '&setype=call&mobile='+mobile;
	showBgDiv();
	RequestAjax(urlfilter,function(rest){
		closeDiv();
		if(empty(rest)) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		if(0 != restobj.code){//外呼失败
			RemindsMsg("","LdPopWidth400px","","yes","yes",restobj.message);
			getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
			callcenter_record = [];
			DelProgressObjs();
			return false;
		}
		//创建联系记录
		var divid = 'callCenterCreateNote';
		var record = callcenter_record['record'][0];//永远都获取第一个客户ID
		var ustring = 'module=ContactRecords&action=ContactRecordsAjax&file=QuickCreate&ajax=true';
		ustring += '&type=gengjin&qcreatetype=menu&Create=true&records='+record;
		showBgDiv();
		RequestAjax(ustring,function(rest){
			closeDiv();
			ld('#'+divid).html(rest);
			fnvshobj('', divid);
			ld('#'+divid+' .D_pop_tit .D_ptita').html(callcenter_record['titlelabel']);
			// 关闭事件
			ld('#'+divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
				ld('#'+divid+' .D_pbtn .D_pbtncancel').click();
				return false;
			});
			ld('#'+divid+' .D_pbtn .D_pbtncancel').attr('onclick','');
			ld('#'+divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
				if(confirm(arrJsPopLabel['LBL_CANCELCALLQUEUE'])){
					getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
					callcenter_record = [];
					fninvshnew(divid);
				}
				return false;
			});
			//保存事件
			ld('#'+divid+' .D_pbtn .D_pbtnok').attr('type','button');
			ld('#'+divid+' .D_pbtn .D_pbtnok').attr('onclick','');
			ld('#'+divid+' .D_pbtn .D_pbtnok').unbind('click').click(function(){
				ld(this).attr('disabled',true);
				getJsScript('include/js/QuickCreate.js',function(){
					if(getFormValidate('qcform')){
						//拷贝的 FieldDuplicateValidate 方法代码
						var obj = ld(this).get(0);
						var module = 'ContactRecords';
						var oform = document.QcEditView;
						callcelter_FieldDuplicateValidate(module,oform,obj,function(){
							ustring = 'module=Users&action=UsersAjax&file=callStaticMethod';
							ustring += '&static=Users&method=saveCallNode&return_id='+record;
							var isinput = 1;//循环form表单下的控件
							ld(oform).find('input[name],select[name],textarea').each(function(index, el) {
								//从表单控件开始，避过form表单自带的module、action等hidden变量
								if(1 == isinput){
									//只要开始读取表单控件就停止hidden的判断，因为account_id就是hidden
									if(ld(this).attr('type') != 'hidden'){
										isinput = 2;//避免再次进去到这个循环判断中
									}else{
										return true;//跳出本次循环
									}
								}
								ustring += '&'+ld(this).attr('name')+'='+ld(this).val();
							});
							//保存联系记录
							showBgDiv();
							RequestAjax(ustring,function(rest){
								closeDiv();
								callcenter_record['record'].remove(0);
								if(callcenter_record['record'].length == 0){//应该需要有关闭窗口之类的逻辑，功能做完再处理
									var confirm_str = arrJsPopLabel['LBL_CALLOUTBOUNDENDED'];
									RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
									//ld('#'+divid+' .D_pbtn .D_pbtncancel').click();//关闭窗口
									getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
									callcenter_record = [];
									fninvshnew(divid);
									getListViewEntries_js('Accounts','start='+callcenter_record['start']);//刷新当前页
									return false;
								}
								ld('#'+divid+' .D_pop_bod').after('<div class="D_pop_content" style="padding:10px;text-align:center;"></div>');
								ld('#'+divid+' .D_pop_bod').css('display','none');
								ld('#'+divid+' .D_pop_content').html('<span style="color:#D96066;font-size:18px;"></span>&nbsp;&nbsp;'+arrJsPopLabel['LBL_CALLSECONDSNEXTCUSTOMER']);
								callCenterTime();//5秒后呼叫下一个客户
								//增加暂停、开始功能
								ld('#'+divid+' .D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_STOP']);
								ld('#'+divid+' .D_pbtn .D_pbtnok').attr('disabled',false);
								ld('#'+divid+' .D_pbtn .D_pbtnok').unbind('click').click(function(){
									if(-1 != callcenter_time){//暂停
										callcenter_time = -1;
										ld('#'+divid+' .D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_START']);
									}else{//开始
										callcenter_time = 5;
										callCenterTime();//5秒后外呼
										ld('#'+divid+' .D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_STOP']);
									}
								});
								DelProgressObjs();
							})
						});
					}  else {
						this.disabled = false;
					}
				});
				return false;
			});
			DelProgressObjs();
		});
	});
}

/**
 * 5秒后外呼下一个客户
 * @author Tujt 2015-04-30
 */
function callCenterTime(){
	if(-1 == callcenter_time){//暂停外呼计划
		return false;
	}else if(0 == callcenter_time){//5秒后
		callcenter_time = 5;//恢复5秒初始值
		callCenterCallMobile();//呼叫下一个客户
	}else{
		ld('#callCenterCreateNote .D_pop_content span').html(callcenter_time);
		callcenter_time --;
		window.setTimeout(callCenterTime,1000);
	}
}

/**
 * 复制的FieldDuplicateValidate代码，不同的是提交表单调用回传事件
 */
function callcelter_FieldDuplicateValidate(module,oform,obj,callback)
{
	puyoungJS_DialogBox.block();

	var url="";
	var fieldvalue="";
	var recordid=oform.record.value;
	if(module=='Events')
	{
		module='Calendar';//edit:can reason:014634: 公司CRM：编辑日程管理，然后再保存，结果提示undefined。(账号：liver)
	}
	for(var i=0;i<oform.length;i++)
	{

		if(oform[i].getAttribute("fieldonly")&&oform[i].getAttribute("fieldonly")=="1")
		{
			fieldvalue=(trim(oform[i].value));
			if(oform[i].tagName.toLowerCase()=="select")
			{
				fieldvalue=trim(oform[i].options[oform[i].options.selectedIndex].value);
			}
			if(fieldvalue=="")
			{
				continue;
			}
			var bill_city='';
			var bill_state='';
			fieldvalue=encodeURIComponent(fieldvalue);
			url="index.php?module="+module+"&action=module="+module+"Ajax&file=FieldDuplicate&fieldname="+oform[i].name+"&fieldvalue="+fieldvalue+"&fieldid="+recordid;
			//edit:can date:20140821 reason:10837: 【保存】单据时，若提示单据编号重复，建议点击确定后，系统会自动生成新的，并且不重复的流水编号
			if(document.getElementById('bill_city')!=undefined)
			{
				bill_city=document.getElementById('bill_city').value;
				url=url+'&bill_city='+encodeURIComponent(bill_city);
			}
			if(document.getElementById('bill_state')!=undefined)
			{
				bill_state=document.getElementById('bill_state').value;
				url=url+'&bill_state='+encodeURIComponent(bill_state);
			}
			http_reqfield=createfieldXMLHTTP();
			http_reqfield.open("POST",url,false);
			isDuplicate=false;
			http_reqfield.onreadystatechange=RequestFieldDuplicate;
			http_reqfield.setRequestHeader("If-Modified-Since","0");
			http_reqfield.send(null);
			if(isDuplicate)
			{
				oform[i].focus();
				if(obj!=undefined)//edit:can reason:快速创建可以重复点击
				{
					obj.disabled=false;
				}
				return false;
			}

		}
	}
	if(module=='PaymentPlan' && oform.paymentstatus!=undefined)
	{

		if(oform.paymentstatus[oform.paymentstatus.selectedIndex].value.indexOf('已收')!=-1)
		{

			if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])==false)
			{
				puyoungJS_DialogBox.unblock();
				return false;
			}
		}

	}
	if(module=='SendPayment' && oform.cpstatus!=undefined)
	{

		if(oform.cpstatus[oform.cpstatus.selectedIndex].value.indexOf('已付')!=-1)
		{

			if(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe']==false)
			{
				puyoungJS_DialogBox.unblock();
				return false;
			}
		}

	}

	if(module=='Users')//用户姓名判断是否重复，会用到该函数
	{
		return true;
	}
	else
	{
		//diony 2014-11-26 合同订单保存判断仓库是否被禁用，如果被禁用弹出窗口
		if(module=='SalesOrder'&&document.getElementById('autowarehouseid')!=undefined)
		{
			fnvshobj(this,'outboundorderDiv');
			return false;;
		}
		else
		{
			//只有这儿与FieldDuplicateValidate方法不一样，如果FieldDuplicateValidate
			//方法变更，可以全盘拷贝过来，把submit()提交改成调用回传事件
			callback();
			return false;
		}
	}
	return false;
}

function SalesSmOwnerSearchScope(selectView,module)
{
	var viewName = encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
	/**
	 * 查看范围 高级功能实现
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-25
	 */
	if('smowner_search_senior' == viewName){//高级
		SmOwnerSearchSenior(module,viewName);return false;
	}
	var actionname=document.getElementById('actionname').value;
	var editresult=document.getElementById('editresult').value;
	window.location.href="index.php?module="+module+"&action="+actionname+"&query="+editresult+"&parenttab=Tools&SmOwnerSearchScope="+viewName+"&show="+'yes';
}
//汉天呼叫中心自动外呼功能 end
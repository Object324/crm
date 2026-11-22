/**
* edit:chj
* date:2014-7-10
* reason:费用报销,项目原单选择事件
*/
//editor:gyq_161 reason:选择源单模块类型事件   2019/11/26 16:11
function SelectSources(module,obj,list)
{
    var sourceModule = obj.value;
    var url = '';
    var id = '';

    /**
     *@edit: andy
     *@date: 2014122
     *@reason:销售发票、收款单增加源单信息区块,源单类型切换
     *@version: v5.9
     */
    var popupobj=CrmPopup.getPopupObj("last");

	var prev_sourceModule = sourceModule;
	if(ld("#" + popupobj.divid + " [name=selectsourcename]").length>0){
		prev_sourceModule = ld("#" + popupobj.divid + " [name=selectsourcename]").get(0).value;
	}

    //if(document.getElementById('selectsourcename') != undefined){
    if(ld('#'+popupobj.divid+' [name="selectsourcename"]').size() > 0){
    	//var isSelectOrderModule = document.getElementById('selectsourcename').value;
        var isSelectOrderModule = ld('#'+popupobj.divid+' [name="selectsourcename"]').get(0).value;
        if(ld('#'+popupobj.divid+' [name="resultdiv"]').size() >0  && ld('#'+popupobj.divid+' [name="relaredordertable"]').size() >0){
            if(sourceModule != isSelectOrderModule){
                ld('#'+popupobj.divid+' [name="resultdiv"]').get(0).style.display='block';
                ld('#'+popupobj.divid+' [name="relaredordertable"]').get(0).style.display='none';
            }else{
                ld('#'+popupobj.divid+' [name="resultdiv"]').get(0).style.display='none';
                ld('#'+popupobj.divid+' [name="relaredordertable"]').get(0).style.display='block';
            }
        }
		/*if(document.getElementById('resultdiv') != undefined  && document.getElementById('relaredordertable') != undefined){
			if(sourceModule != isSelectOrderModule){
				document.getElementById('resultdiv').style.display='block';
                document.getElementById('relaredordertable').style.display='none';
			}else{
				document.getElementById('resultdiv').style.display='none';
				document.getElementById('relaredordertable').style.display='block';
			}
		}*/
    }
    //end
    if(module == 'Expense' || module == 'Project' || module == 'PaymentPlan' || module == 'SendPayment')
    {
        if(ld('#'+popupobj.divid+' [name="issourcemodule"]').size() > 0){
            ld('#'+popupobj.divid+' [name="issourcemodule"]').get(0).value = sourceModule;
        }
        //var isSelectModule = document.getElementById('selectsourcename').value;
        var isSelectModule = ld('#'+popupobj.divid+' [name="selectsourcename"]').get(0).value;
        if(sourceModule != isSelectModule)
        {
			//zkt 20240716 BUG20240715-28  基于合同模块创建回款计划。有2个单子保存回款计划再次编辑回款计划中的付款条件及日期字段，保存后，源单显示为空了呢。--收款计划切换源单类型js报错
			if(ld('#'+popupobj.divid+' [name="salesorder_id"]').length>0){
            	ld('#'+popupobj.divid+' [name="salesorder_name"]').get(0).value='';
            	ld('#'+popupobj.divid+' [name="salesorder_id"]').get(0).value='';
			}
        }else{
			if(ld('#'+popupobj.divid+' [name="salesorder_id"]').length>0&&ld('#' + popupobj.divid + ' [name="entitytypeid"]').length>0) {
				ld('#' + popupobj.divid + ' [name="salesorder_name"]').get(0).value = ld('#' + popupobj.divid + ' [name="listvalall"]').get(0).value;
				ld('#' + popupobj.divid + ' [name="salesorder_id"]').get(0).value = ld('#' + popupobj.divid + ' [name="entitytypeid"]').get(0).value;
			}
        }
        /*if(sourceModule != isSelectModule)
        {
            document.EditView.salesorder_name.value='';
            document.EditView.salesorder_id.value='';
        }else{
            document.EditView.salesorder_name.value= document.getElementById('listvalall').value;
            document.EditView.salesorder_id.value= document.getElementById('entitytypeid').value;
        }*/
		//汇款计划编辑，如果选择原单是销售发票，则回款计划类型不可以编辑
		if(module == 'PaymentPlan'){
			var popupobj=CrmPopup.getPopupObj("last");
			var divid=popupobj.divid;
			if(sourceModule == 'Invoice'){
				if(CrmPopup.isExistsObj(divid,'cmb_a_paymenttype'))
				{
					CrmPopup.findHtmlobj(divid,'cmb_a_paymenttype').removeAttr("onclick");
					CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_paymenttype').val('计划回款日期');
					CrmPopup.findHtmlobj(divid,'cmb_a_paymenttype').find('div').hide();
				}
			}else{
				if(CrmPopup.isExistsObj(divid,'cmb_a_paymenttype'))
				{
					CrmPopup.findHtmlobj(divid,'cmb_a_paymenttype').attr("onclick","return CrmPopup.getPopupObj('last').picklist_arrow_click(event,'paymenttype')");
					CrmPopup.findHtmlobj(divid,'cmb_a_paymenttype').find('div').show();
				}
			}
		}
    }
    else
    {

		if(module == 'SalesOrder'){

			var isSelectModule = ld('#'+popupobj.divid+' [name="selectsourcename"]').get(0).value;
			var entitytype = ld('#'+popupobj.divid+' [name="selectlistval"]').get(0);
            var entittypevalue=entitytype.value;
			if(obj.value == null)
				var sourceModule = isSelectModule;

			if(sourceModule != isSelectModule)
			{
				entitytype.value='';
				//document.EditView.selectlistval_label.value = '';
                ld('#'+popupobj.divid+' [name="selectlistval_label"]').get(0).value;
			}
		}else{
			//var isSelectModule = document.getElementById('selectsourcename').value;
			var isSelectModule = ld('#'+popupobj.divid+' [name="selectsourcename"]').get(0).value;
			//var entitytype = document.getElementById('selectlistval');
			var entitytype = ld('#'+popupobj.divid+' [name="selectlistval"]').get(0);
			if(obj.value == null)
				var sourceModule = isSelectModule;
            var entittypevalue=entitytype.value;

			if(sourceModule != isSelectModule)
			{
				entitytype.value='';
				//document.EditView.selectlistval.value = '';
                ld('#'+popupobj.divid+' [name="selectlistval"]').get(0).value = '';
			}else{
				//entitytype.value= document.EditView.selectsourcename.value;
				entitytype.value= ld('#'+popupobj.divid+' [name="selectsourcename"]').get(0).value;
			}
		}
        var str = arrJsPopLabel['CHANGEENTITYTYPETIP'];
       //38231: （51mis.com/kfbcrm）新建单据界面：若分录明细为空，选择源单字段，【更换源单类型】时应该不弹出提示信息
        //if(document.getElementById('selectlistval_label').value!=''&&document.getElementById('selectlistval_label').value!=',')
        var withproductdetail='yes';
		var withproductdetail_after='yes';
        ld.each(popupobj.sourcemodule_arr,function(tmpindex,sourcemoduleinfo){
            if(sourcemoduleinfo.entitytype==isSelectModule)//切换前的值
            {
                withproductdetail=sourcemoduleinfo.withdetail;
            }
			if(sourcemoduleinfo.entitytype==sourceModule)//切换后的值
			{
				withproductdetail_after=sourcemoduleinfo.withdetail;
			}
        });
		//wym 240417 BUG20240412-62  付款单新建界面，选择自动带出所选源单的产品分录的源单类型时，界面应该不显示“付款信息”区块
		if(ld('#'+popupobj.divid+' [name="sendcashbilltitle"]').length>0){
			var titileobj=ld('#'+popupobj.divid+' [name="sendcashbilltitle"]');
		}else if(ld('#'+popupobj.divid+' [name="cashbilltitle"]').length>0){
			var titileobj=ld('#'+popupobj.divid+' [name="cashbilltitle"]');
		}
		if(titileobj&&titileobj.length>0){
			if(withproductdetail_after=='no'){
				titileobj.get(0).show();
			}else{
				titileobj.get(0).hide();
			}
		}

        if(  ld('#'+popupobj.divid+' [name="selectlistval_label"]').get(0).value !=''&&ld('#'+popupobj.divid+' [name="selectlistval_label"]').get(0).value !=',')
			RemindsMsg("","LdPopWidth400px","","yes","yes",str);
        else
            clearModuleProduct(obj,module,'');

		var remindspopupobj = CrmPopup.getPopupObj("last");
    	//点击确认
      	ld("#"+remindspopupobj.divid+' input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            //37446: 发票、出库单等单据选择源单功能，应该控制只能选择一种源单
		clearModuleProduct(obj,module,'');
        });
		//zkt 20240801 点击取消 BUG20240731-45 选择源单销售订单，改为服务合同，弹窗提示信息，选择取消 再次打开收款单详情，选择源单这里还是显示的服务合同，问题1：选择源单处没有取消变成销售订单； 问题2：+号源单没有显示空
		ld("#"+remindspopupobj.divid+' input[tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
			obj.value = prev_sourceModule;
		});

    }
}

/*
 * edit:chj
 * date:2014/12/17
 * 编辑、新增页面，切换币种，更改银行账户和当前页的所有金额字段
 */
async function getCurrencyRateAmounts(obj,module,cur_id,formname)
{


    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

	//根据原单自动带出币种ID,根据币种ID自动默认币种类型、银行账户
    var formobj=document.forms[formname];
    if(cur_id > 1)
	{
		//默认币种类型
		if(CrmPopup.isExistsObj(divid,'currency_id'))
		{
		      CrmPopup.findHtmlobj(divid,currency_id).val(cur_id);
			//formobj.currency_id.value = cur_id;
             CrmPopup.findHtmlobj(divid,'hidden_currency_id').val(cur_id);
			//formobj.hidden_currency_id.value = cur_id;

			//formobj.currency_id.value = cur_id;
		}
		//默认银行账户
		if(CrmPopup.isExistsObj(divid,'bankaccountsetid'))
		{
			var bankaccountset = CrmPopup.findHtmlobj(divid,'bankaccountsetid');
            var optionobj=bankaccountset.find("option");
			var bank_len = optionobj.length;
			var opts = 0;
			for(var k = 0; k < bank_len; k++)
			{

				if(optionobj[opts].attr('bank_curid') != cur_id)
				{
					bankaccountset.options.remove(opts);
				}else{
					opts++;
				}
			}
		}
		return false;
	}
    var currency_id = obj.value;    //选择后的币种ID
    var before_currency_id = '';    //选择前的币种ID
    var mode = '';
    if(CrmPopup.isExistsObj(divid,'mode'))
        mode = CrmPopup.findHtmlobj(divid,'mode').val();


    if(module != 'BankAccountSet')//银行初始化不需要提醒
    {
        var currency_id_from_related = CrmPopup.findHtmlobj(divid,'currency_id_from_related').val();
        if(currency_id_from_related == 'yes'){
            confirmChangCurrency(module,formobj,divid,currency_id,before_currency_id,mode);
            return;
        }
    	var confirm_str = arrJsPopLabel['ALLCURRENCYOFAMOUNTWILLBEFIXED'];
    	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        var remindpopupobj=CrmPopup.getPopupObj('last');
		//2023-8-14 xxy 修改了弹窗重写的绑定事件，并改成使用异步
        try {
			await new Promise((resolve, reject) => {
				ld('#'+remindpopupobj.divid+' input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					//确认切换币种
					resolve();
				})
				ld('#'+remindpopupobj.divid+' [tagclick="msgConfirmCancel"]').unbind('click').on('click',function(){
					//取消，币种默认值还原
					reject();
				})
			});
			confirmChangCurrency(module,formobj,divid,currency_id,before_currency_id,mode);
		} catch {
			CrmPopup.findHtmlobj(divid,'currency_id').val(CrmPopup.findHtmlobj(divid,'hidden_currency_id').val());
		}
        return false;
        /*
        if(window.confirm())
        {
        }
        else
        {
            //取消，币种默认值还原
            CrmPopup.findHtmlobj(divid,'currency_id').val(CrmPopup.findHtmlobj(divid,'hidden_currency_id').val());
            //formobj.currency_id.value = formobj.hidden_currency_id.value;
            return false;
        }
        */
    }
    //确认切换币种
    confirmChangCurrency(module,formobj,divid,currency_id,before_currency_id,mode);
}
//确认切换币种
function confirmChangCurrency(module,formobj,divid,currency_id,before_currency_id,mode){

    if(CrmPopup.isExistsObj(divid,'hidden_currency_id'))
    {
        before_currency_id = CrmPopup.findHtmlobj(divid,'hidden_currency_id').val();
        CrmPopup.findHtmlobj(divid,'hidden_currency_id').val(currency_id);
        CrmPopup.findHtmlobj(divid,'currency_id').val(currency_id);
    }
    var sourcemodule = '';
    if(CrmPopup.isExistsObj(divid,'selectsource')){
        sourcemodule = CrmPopup.findHtmlobj(divid,'selectsource').val();
    }

    //alert('module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&return_module='+module+'&currency_id='+currency_id+'&before_currency_id='+before_currency_id);
    ldAjaxHtmlNoProgress('index.php?','module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&return_module='+module+'&currency_id='+currency_id+'&before_currency_id='+before_currency_id+'&sourcemodule='+sourcemodule,function(ajaxhtml) {
		if(ajaxhtml.indexOf('###SUCCESS###') > -1)
		{
			var results=ajaxhtml.split('###SUCCESS###');
			//获取结果集 0：选择前币种汇率 1：选择后的币种汇率 2：金额fieldname字段3:币种对应的银行账户信息
			var result=results[1].split('|');
			var fieldnameArr = result[2].split(',');
			var beforecurrency_rate = parseFloat(result[0]);//获取选择前的币种在数据库中的汇率
			var selectcurrency_rate = parseFloat(result[1]);//获取选择后的币种在数据库中的汇率
			if(CrmPopup.isExistsObj(divid,'hidden_currency_rate'))
			{
				CrmPopup.findHtmlobj(divid,'hidden_currency_rate').val(result[1]);

			}
			var popupobj=CrmPopup.getPopupObj('last');

			//提现单和存现单 有转出和转入2个账户  select命名不一致
			if(CrmPopup.isExistsObj(divid,'bankaccountsetid'))
			{
				var selectValue = ld("#"+popupobj.divid+" [name=bankaccountsetid]").get(0);	//银行账户
				UpdateBankAccount(selectValue,result[3]);
				var cls_resetComboxHtmlobj=new cls_resetComboxHtml('bankaccountsetid');
				//zxm kfbcrm 付款单--新建---更改币种---账号字段宽度会变小  BUG0064172 C:\ldcrm\www\crm\include\js\SystemPopup\CreatePagePopup.js   uitype == 251  寬度寫死的280
				cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
				// cls_resetComboxHtmlobj.setComboxObjHtml();
				ld('[name=dv_drop_bankaccountsetid]').css('width',ld('[name=dv_chzn_bankaccountsetid').width());
			}
			if(CrmPopup.isExistsObj(divid,'inaccount') )
			{
				var selectValue = ld("#"+popupobj.divid+" [name=inaccount]").get(0);	//转入账户

				UpdateBankAccount(selectValue,result[3]);
				var cls_resetComboxHtmlobj=new cls_resetComboxHtml('inaccount');

				cls_resetComboxHtmlobj.setComboxObjHtml();
			}
			if(CrmPopup.isExistsObj(divid,'outaccount'))
			{
				var selectValue = ld("#"+popupobj.divid+" [name=outaccount]").get(0);	//转出账户
				UpdateBankAccount(selectValue,result[3]);
				var cls_resetComboxHtmlobj=new cls_resetComboxHtml('outaccount');

				cls_resetComboxHtmlobj.setComboxObjHtml();
			}
			//editor:gyq_161* reason:确认币种切换   2019/11/26 15:20
			//收款单特殊控制 原单金额//付款单
			if(module === 'CashBill' || module == 'SendCashBill')
			{
				//zkt 20240724 BUG20240614-38 亿海蓝：给美元合同（XSHT2023120100006）建收款单时，在设置收款单上的币种时会引起下面收款金额的重算（附件有视频）
				var tmpdetail_beforcurrency_rate = beforecurrency_rate;
				//zkt 20220920 BUG0056671收/付款单->页面设置，不带产品分录明细，选择源单切换单据头的币种时，本次收款金额没有换算
				if(ld("#"+popupobj.divid+" [name=inventory_currency]").length>0){
					tmpdetail_beforcurrency_rate = ld("#"+popupobj.divid+" [name=inventory_currency] option:selected").attr('currate');
					ld("#"+popupobj.divid+" [name=inventory_currency]").get(0).value = currency_id;
				}
				BillChangCurrencychangeDetail(popupobj,sourcemodule,selectcurrency_rate,tmpdetail_beforcurrency_rate);
			}
			//佣金单
			if(module == 'Commission')
			{
				var tableName =ld("#"+popupobj.divid+ " table[name='proTab']").get(0);// document.getElementById('proTab');
				var prev = tableName.rows.length - 1;//列头函数
				//本次收款
				for(var i = 1; i<=prev; i++)
				{
					if(ld("#"+popupobj.divid+" [name=amount"+i+"]").length>0&&ld("#"+popupobj.divid+" [name=amount"+i+"]").val()>0)
					{
						var noamount =ld("#"+popupobj.divid+" [name=amount"+i+"]").val();// document.getElementById('amount'+i).value;
						noamount = parseFloat(noamount);
						if(parseInt(beforecurrency_rate,10) == 1)
							noamount = noamount*selectcurrency_rate;
						else
							noamount = parseFloat(noamount/beforecurrency_rate)*selectcurrency_rate;
						noamount = noamount.toFixed(2);
						ld("#"+popupobj.divid+" [name=amount"+i+"]").val(noamount);
						ld("#"+popupobj.divid+" [name=amount"+i+"]").get(0).onchange();
						//	document.getElementById('amount'+i).value = noamount;
						//	document.getElementById('amount'+i).onchange();
					}
				}
				//调整
				if(ld("#"+popupobj.divid+" [name=noamount]").length > 0&&ld("#"+popupobj.divid+" [name=noamount]").val()>0)
				{
					var setnoamount =ld("#"+popupobj.divid+" [name=noamount]").val();// document.getElementById('noamount').value;
					setnoamount = parseFloat(setnoamount);
					if(parseInt(beforecurrency_rate,10) == 1)
						setnoamount = setnoamount*selectcurrency_rate;
					else
						setnoamount = parseFloat(setnoamount/beforecurrency_rate)*selectcurrency_rate;
					setnoamount = setnoamount.toFixed(2);
					//document.getElementById('noamount').value = setnoamount;
					ld("#"+popupobj.divid+" [name=noamount]").val(setnoamount);
					ld("#"+popupobj.divid+" [name=noamount]").get(0).onchange();
					//document.getElementById('noamount').onchange();
				}
			}
			//费用报销
			if(module == 'Expense')
			{
				var tableName =ld("#"+popupobj.divid+ " table[name='proTab']").get(0);// document.getElementById('proTab');
				var prev = tableName.rows.length - 1;//列头函数
				//本次收款
				for(var i = 1; i<=prev; i++)
				{
					if(ld("#"+popupobj.divid+" [name=money"+i+"]").length > 0&&ld("#"+popupobj.divid+" [name=money"+i+"]").val()>0)
					{
						var money = ld("#"+popupobj.divid+" [name=money"+i+"]").val();
						money = parseFloat(money);
						if(parseInt(beforecurrency_rate,10) == 1)
							money = money*selectcurrency_rate;
						else
							money = parseFloat(money/beforecurrency_rate)*selectcurrency_rate;
						money = money.toFixed(2);
						//	document.getElementById('money'+i).value = money;
						ld("#"+popupobj.divid+" [name=money"+i+"]").val(money);
						ld("#"+popupobj.divid+" [name=money"+i+"]").get(0).onchange();
						//document.getElementById('money'+i).onchange();

					}
				}
			}

			for(var k= 0; k <popupobj.fields.length; k++)
			{
				var fieldname = fieldnameArr[k];
				if(CrmPopup.isExistsObj(divid,fieldname) && CrmPopup.findHtmlobj(divid,fieldname).val()>0)
				{
					var amount = CrmPopup.findHtmlobj(divid,fieldname).val();
					amount=parseFloat(amount);

					//选择前币种为人民币  默认1
					if(parseInt(beforecurrency_rate,10) == 1)
						//人民币 - 非人民币 / 公式：金额*非人民币汇率
						amount = amount*selectcurrency_rate;
					else
						//非人民币 - 非人民币 or  非人民币  - 人民币 / 公式:(金额/选择前汇率)*选择后汇率
						amount = parseFloat(amount/beforecurrency_rate)*selectcurrency_rate;
					amount = amount.toFixed(2);
					CrmPopup.findHtmlobj(divid,fieldname).val(amount);
				}
			}
		}
		return false;
	});
}

function AjaxDuplicateValidates(module,fieldname,oform)
{

	var fieldvalue = encodeURIComponent(trim(getObj(fieldname,oform).value));
    /*
    edit by LD Can var recordid = getObj('record').value;
   reason:快速创建中新增"客户"时，点击保存，程序报错，提示'options' 为空或不是对象，希望修正。
    */
	var recordid = getObj('record',oform).value;

	if(fieldvalue == '')
	{
		alert(arrJsPopLabel['CUSTOMERNAMECANOTEMPTY']);
		return false;
	}

	puyoungJS_DialogBox.block();

	var url = "module="+module+"&action="+module+"Ajax&file=Save&"+fieldname+"="+fieldvalue+"&dup_check=true&record="+recordid;
	/*
    edit:can
    date:20130531
    reason:创建和编辑权限分开
    
    */
    if(oform.Create!=undefined)
    {
        var create=oform.Create.value;
        url=url+"&Create="+create;
    }
	ldAjaxHtmlNoProgress('index.php?',url,function (ajaxhtml) {
		var str = ajaxhtml;
		if(str.indexOf('SUCCESS') > -1)
		{
			oform.submit();
		}else
		{
			puyoungJS_DialogBox.unblock();
			str = str.replace(/<\/?.+?>/g,"");
			str = str.replace(/[\r\n]/g, "");
			return false;
		}
	});
}
function changepasss(){
 // $("status").style.display="inline";
  var popupobj=CrmPopup.getPopupObj("last");

  ldAjax("index.php?module=Users&action=ChangePassword&form=DetailView&ajax=true&id="+popupobj.record,{},function(data){
    	var crmPopupobj=CrmPopup.load(data.result.title,set_password,"","LdPopWidth400px",'Users',"",data.result.oktext,"",data.result.canceltext);
        crmPopupobj.show(data.result.content)
        crmPopupobj.record=data.result.id;
        DelProgressObjs();
        if(ld("#old_password").is(":hidden")){
			ld("#new_password").focus();
		}
		else{
			ld("#old_password").focus();
		}
  })

}

/* 相关信息 begin */
/******************************************
 * DetailView RelatedList                 *
 * 详细信息页面，相关信息左右结构js事件   *
 * Add:Tujt Date:20140331                 *
 ******************************************/
 /**
  * 显示单条相关信息
  * @param obj 事件出发的docoument
  * @param herder 当前模块
  * @param record 当前单据ID
  * @param relatedid 相关信息ID
  * @returns 调用 setRelListAjax 初始化单条相关信息方法
  * @author Tujt 20140331
  */
//isbalance = 1;
//relajax = '';
function show_rel_lists(obj,header,record,relatedid){

    if(isbalance != 1) return false;
    var tag = ld(obj).attr('tag');


            	var urldata = "&header="+header+"&record="+record+"";
            	urldata += "&relatedid="+relatedid+"&currpage=1&related_left_type=1";
            	var currobj = document.getElementById('currrelid');
            	document.getElementById('rel-list-'+relatedid).className='On';
            	if(currobj.value > 0){
     	            //0032889: 单据明细界面>点击详细资料>在点击详细资料的下面的字段>点击详细资料>点击纤细资料下面的字段：结果两个字段都选中了。
            	    ld('#detailrelatedinfo_ul').find('li a:first').removeClass('On');
            		if(currobj.value != relatedid){
            			document.getElementById('rel-list-'+currobj.value).className='';
            		}
            	}
            	if(relajax == 'balance'){
            		relajax = 'list';
            	}


                    var isrecordmod = ',Accounts,Potentials,Contacts,HelpDesk,SalesOrder,ProjectTask,Project,';
            		if(isrecordmod.indexOf(','+header+',') > -1){
            			/**
            			 * 判断当前相关信息是否为联系记录，如果相等，则增加排序参数传递
            			 * @reason 0009845 刘总建议：联系记录按联系日期倒叙
            			 * @author Tujt 2014-07-07
            			 */
            			if(document.getElementById('rel-list-mod-ContactRecords') != undefined){
            				if(document.getElementById('rel-list-mod-ContactRecords').value == relatedid){
            					urldata += '&order_by=contactdate&sorder=DESC';
            				}
            			}
            		}

            		setRelListAjaxs(urldata,relatedid);




}


show_rel_lists.setRelateListButtonColor=function(liid)
{

}

show_rel_lists.hidedv_listhighersearch=function(){
      //  ld('#dv_listhighersearch').css("display",'none');
      var popupobj=CrmPopup.getPopupObj("last");
      popupobj.CancelEvent();
}
/**
 * 显示工作协同相关信息
 * @param obj 事件出发的docoument
 * @param herder 当前模块
 * @param record 当前单据ID
 * @param relatedid 相关信息ID
 * @returns 调用 setRelListAjax 初始化单条相关信息方法
 * @author andrew 20150527
 */
function show_workreports(obj,header,record,relatedid){

	var urldata = "&header="+header+"&record="+record+"";
	urldata += "&relatedid="+relatedid+"&currpage=1&related_left_type=1";

    setRelListWorkReportAjaxs(urldata,relatedid);



}
/**
 * 初始化工作协同相关信息方法
 * @param urldata ajax 的条件
 * @returns 相关信息html代码，显示相关信息到页面上
 * @author andrew 20150527
 */
function setRelListWorkReportAjaxs(urldata,relatedid){
	if(!urldata || urldata == '') return;
	isbalance = 2;//相关信息加载中
	//客户
  var tmpmodule="";
  var detailViewPopupObj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);//明细弹出层
	if(detailViewPopupObj.module=='Accounts')
	{

		urldata += "&account_id="+detailViewPopupObj.record;
        tmpmodule='Accounts';
	}
	//联系人
	if(document.getElementById('rcontact_id')!=null&&document.getElementById('rcontact_id')!=undefined&&document.getElementById('rcontact_id').value!='')
	{
		urldata += "&contact_id="+document.getElementById('rcontact_id').value;
        tmpmodule='Contacts';
	}
//	$("status").style.display="inline";

    //0023061: 联系人：相关信息-工作协同，点击【工作协同】会闪现一段表格
    ld('head').append('<link href="themes/softed/coordination.css" rel="stylesheet" type="text/css" />')
    //alert('module=Home&action=HomeAjax&file=setRelatedModList'+urldata);
	ldAjaxHtmlNoProgress('index.php?','module=Home&action=HomeAjax&file=setRelatedModList'+urldata,function(ajaxhtml) {
		$("status").style.display="none";
		isbalance = 1;//相关信息加载完毕
		var results = trim(ajaxhtml);
		if(results != ''){

			// set_return_account_address();

			ld('#'+detailViewPopupObj.divid+' .DivCTable').html(results);

			rightContentWidth();
			//ls 2021202 BUG0059404 客户、联系人相关信息->工作汇报列表，选择关联“产品管理”后，选择产品管理弹窗没有关闭，且点击关闭按钮时，需要点击两次才能关闭(重复绑定，Coordination.js已经绑定过点击事件了)
			// initWordReport();



			if(detailViewPopupObj.module=='Accounts')

			{

				var list_link_field=detailViewPopupObj.list_link_field;

				setAccountInfo(detailViewPopupObj.record,detailViewPopupObj.column_fields_value[list_link_field][0]);

			}
			else if(document.getElementById('rcontact_id')!=null&&document.getElementById('rcontact_id')!=undefined&&document.getElementById('rcontact_id').value!='' && tmpmodule == 'Contacts')
			{
				var list_link_field=detailViewPopupObj.list_link_field;

				setContactInfo(document.getElementById('rcontact_id').value,detailViewPopupObj.column_fields_value[list_link_field][0]);

			}
			selectAccount[tag]=[];
			WinPopup("sendLogsmownerDiv");
			WinPopup("sendemojicookieDiv");
			WinPopup("dialogDiv");
			WinPopup("remindsDiv");
			WinPopup("forwardDiv");
			//28776: 客户、联系人明细界面：相关信息-工作协同：多出了查看范围
			ld('.Module_Showselect').css('display','none');
			getJsScript('include/js/special_webuploader.js',function(){
				ld("[name=multiple_att").special_powerWebUpload({
					fileTypeDuplicate:'yes',	//附件类型判断
					fileNameDuplicate:'yes',	//同名附件判断
					mode:'',	//当前单据 create or edit
					module:'',	//当前模块
					jsonData:'',	//edit data,编辑界面显示已上传的附件
					record:'',	//单据单据id
					admin:'',//是否是管理员
					uitype:'',
					supportformat:'',//支持格式
					inputFileName:''	//选择附件后赋值标签的name
				});
				ld("[name=multiple").special_powerWebUpload({
					fileTypeDuplicate:'yes',	//附件类型判断
					fileNameDuplicate:'yes',	//同名附件判断
					mode:'',	//当前单据 create or edit
					module:'',	//当前模块
					jsonData:'',	//edit data,编辑界面显示已上传的附件
					record:'',	//单据单据id
					admin:'',//是否是管理员
					uitype:'69',
					supportformat:'',//支持格式
					inputFileName:''	//选择附件后赋值标签的name
				});
			});
		}
	});
}

/**
 * 相关信息设置按钮事件
 * 由于详情页，编辑页，新增页都有相关信息设置，所有抽出来
 */
function SetRelatedlists(obj,module,BLOCKIDSETTING,FIELDIDSETTING){
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"",'none',"","");
  crmPopupobj.prevshow();
	ld.ajax({
		url: 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetRelatedlists&parenttab=Settings&modulename='+module+'&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				if($("status") != undefined)
					$("status").style.display="none";
                //edit:can 2021-03-15 044977: （https://61mis.com/kfbcrm [^]）进入页面设置后再进入单据查看详情界面，点击【相关信息设置】->【保存】，弹出层没有关闭
				crmPopupobj.setParams(data.result.title,saveRelatedListDetailPage,"","LdPopWidth600px",module,"",data.result.oktext,"",data.result.canceltext);
				crmPopupobj.quickcreatehtml=data.result.content;
				crmPopupobj.show(data.result.content);
				// 需要去掉的给高度
				crmPopupobj.reduceBodyHeight = 50;
				// 设置内容最大高度
				crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
				/*edit:weiyannan
				date:2023-11-14
				reason:XUQIU1002049 系统穿梭框界面样式统一 客户管理--相关信息设置*/
				var tableobj = ld('#'+crmPopupobj.divid).find("table#relatedListsTable");
				var LeftObj = tableobj.find("#AssmablyList");
				var RightObj = tableobj.find("#selectedAssmablyColumns");
				//传入翻译参数
				var Drag_Transfer = new DragTransfer();
				var translabel = {
					available: arrJsPopLabel['OptionModules'],
					selected: arrJsPopLabel['Selectedmodule'],
					placeholder: arrJsPopLabel['PleaseEnterModuleSearchFor'],
				};
				Drag_Transfer.SetTranslabel(translabel);
				Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','210');
				crmPopupobj.center();

				// ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
				tooltip(".tip-items-pop", {transition: true, time: 200});
			}
		}
	});

}
function QuickSetactions(obj,module,BLOCKIDSETTING,FIELDIDSETTING)
{
    // $('status').style.display = "block";
    ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=QuickSetActions&parenttab=Settings&modulename='+module+'&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,function(ajaxhtml) {
		if(ajaxhtml.indexOf('###SUCCESS###')>-1){
			var results=ajaxhtml.split('###SUCCESS###');
			$("Quicksetactions_div").innerHTML=results[1];
			// $('status').style.display = "none";
			fnvshobj(obj, 'Quicksetactions_div');
		}

	});
}
//相关信息显示设置保存
function saveRelatedListDetailPage(){
	// $('status').style.display = "block";
	var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
	var opennewpage_presence = ld("#"+popupobj.divid+" #opennewpage_presence").prop('checked')?'yes':'no';//xxy 2023-11-24 XUQIU1002162 相关信息设置弹出层中，增加“相关模块显示“打开新页签”按钮”参数，可自定义相关模块打开新页签图标按钮是否显示
    //alert(selectedColumnsObj.options.length);

	for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
	 CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val(selectedColStr);

    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    var ColumnsObj=getObj("AssmablyList")
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++)
    {
		ColStr += ColumnsObj.options[i].value + ";"
    }
	CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val(ColStr);
	var formodule = CrmPopup.findHtmlobj(divid,'formodule').val();
	var tabid = CrmPopup.findHtmlobj(divid,'tabid').val();
	var tmpurlstring = 'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetRelatedlistsSave&formodule='+formodule+'&ajax=true&tabid='+tabid+'&AssmablyColumnsString='+ColStr+'&selectedAssmablyColumnsString='+selectedColStr+'&OpenNewPage='+opennewpage_presence;
	//jby 2024/12/13 XUQIU20241127-04 相关信息设置弹出层中，增加"置客户相关信息可以看见下级单据的数据 "参数
	if(ld("#"+popupobj.divid+" #superior_account_see").length>0){
		var superior_account_see = ld("#"+popupobj.divid+" #superior_account_see").prop('checked')?'yes':'no';
		tmpurlstring += '&SuperiorAccountSee='+superior_account_see;
	}
	ldAjaxHtmlNoProgress('index.php?',tmpurlstring,function(ajaxhtml) {
		// $('status').style.display = "block";
		cancelCrmPopup();
		var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
		DetailViewRelation.showpage_moduledetail(popupobj);

	});
}
function checkoptionvalus(from,type)
{
    formSelectColumnString_s(type);
   ldAjaxHtmlNoProgress('index.php?',ld(from).serialize(),function(ajaxhtml) {
	   window.location.reload();
   });
}
function formSelectColumnString_s(type)
{
    if(type == '1')
    {
        selectedColumnsObj=getObj("selectedAssmablyColumns");
    }
    else
    {
        selectedColumnsObj=getObj("beselected_module");
    }
    //selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    //alert(selectedColumnsObj.options.length);

    for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
    if(type == '1')
    {
        document.forms['Saveresults'].selectedAssmablyColumnsString.value = selectedColStr;
    }
    else
    {
        document.forms['Quicksetactions'].beselected_module_String.value = selectedColStr;
    }

    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    if( type == '1')
    {
        ColumnsObj=getObj("AssmablyList")
    }
    else
    {
        ColumnsObj=getObj("tobeselecte_module")
    }
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++)
    {
    ColStr += ColumnsObj.options[i].value + ";"
    }
    if( type =='1')
    {
        document.forms['Saveresults'].AssmablyColumnsString.value = ColStr;
    }
    else
    {
        document.forms['Quicksetactions'].tobeselecte_module_String.value = ColStr;
    }
}
/* 相关信息 end */

//wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
//保存设置关键字段信息区块可见字段
function saveSetDisplayFieldsPage(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
	var selectedColStr = "";
	if(selectedColumnsObj.options.length>20){
		var alert_str=arrJsPopLabel['KEYWORDSSAVE'];
		RemindsMsg("", "LdPopWidth400px", 'module', "yes", "yes", alert_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {

			for (i=0;i<selectedColumnsObj.options.length;i++)
			{
				selectedColStr += selectedColumnsObj.options[i].value + ";"
			}
			CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val(selectedColStr);
			var ColumnsObj=getObj("AssmablyList")
			var ColStr = "";
			for (i=0;i<ColumnsObj.options.length;i++)
			{
				ColStr += ColumnsObj.options[i].value + ";"
			}
			CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val(ColStr);
			var formodule = CrmPopup.findHtmlobj(divid,'formodule').val();
			var tabid = CrmPopup.findHtmlobj(divid,'tabid').val();
			var tmpurlstring = 'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetDisplayFieldsSave&formodule='+formodule+'&ajax=true&tabid='+tabid+'&AssmablyColumnsString='+ColStr+'&selectedAssmablyColumnsString='+selectedColStr;
			ldAjaxHtml('index.php?',tmpurlstring,function(ajaxhtml) {
				DelProgressObjs();
				cancelCrmPopup();
				sethtml(document.getElementById('cfList'),ajaxhtml);
				//wyt 221215 BUG0059870 kfbcrm 页面设置--关键信息栏--设置显示字段--点击保存后---无法移动字段，更改顺序
				// var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
				// DetailViewRelation.showpage_moduledetail(popupobj);
				layoutblockEventClick();
			});

		})

	}else{
		for (i=0;i<selectedColumnsObj.options.length;i++)
		{
			selectedColStr += selectedColumnsObj.options[i].value + ";"
		}
		CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val(selectedColStr);
		var ColumnsObj=getObj("AssmablyList")
		var ColStr = "";
		for (i=0;i<ColumnsObj.options.length;i++)
		{
			ColStr += ColumnsObj.options[i].value + ";"
		}
		CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val(ColStr);
		var formodule = CrmPopup.findHtmlobj(divid,'formodule').val();
		var tabid = CrmPopup.findHtmlobj(divid,'tabid').val();
		var tmpurlstring = 'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetDisplayFieldsSave&formodule='+formodule+'&ajax=true&tabid='+tabid+'&AssmablyColumnsString='+ColStr+'&selectedAssmablyColumnsString='+selectedColStr;
		ldAjaxHtml('index.php?',tmpurlstring,function(ajaxhtml) {
			DelProgressObjs();
			cancelCrmPopup();
			sethtml(document.getElementById('cfList'),ajaxhtml);
			//wyt 221215 BUG0059870 kfbcrm 页面设置--关键信息栏--设置显示字段--点击保存后---无法移动字段，更改顺序
			// var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
			// DetailViewRelation.showpage_moduledetail(popupobj);
			layoutblockEventClick();
		});
	}
}

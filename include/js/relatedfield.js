/**
 * 选择字段关联带出值
 * @param @selectmodule 选择的模块 @record 选择的单据 @entityname 选择的单据名称 @columnname 选择字段 @curmodule 当前模块 @selecttype 选择方式
 * @returns
 * @author Chj
 */

getRelatedFieldData.spop = '';
function getRelatedFieldData(selectmodule,record,entityname,columnname,curmodule,selecttype){

    if(empty(record) || record <= 0 ){//typeof为string的0，无法用empty判断
        return;	//chj 2022/7/12 多选时，传入的ID可能是逗号拼接的。暂时先注释掉
    }

    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//CrmPopup.getPopupObj('last');
    if(popupobj==undefined)
    {
        return ;
    }

    popupobj.hadusedtriggercolumnlist=[];
    popupobj.hadgivenvaluecolumnlist=[];//已经赋值过的字段
    popupobj.fieldrulevalues=[];//edit:can 20200730 因为界面的布局规则导致没有显示的字段，暂存
    popupobj.hadusedtriggercolumnlist.push(columnname);
    popupobj.hadgivenvaluecolumnlist.push(columnname);
    var fieldinfo= popupobj.fieldname_fields[columnname];
    var divid=popupobj.divid;


    tmpgetRelatedData(selectmodule,record,entityname,columnname,curmodule,selecttype);
    //edit:can 20220209 61313 服务记录单模块，剩余工时=合约工时-已用工时-本次工时（本次工时是默认为1，已用工时、合约工时是引用项目立项里面的数据
    ld.each(popupobj.hadgivenvaluecolumnlist,function(tmpindex,tmpcolumn){
        popupobj.mainfieldformulaobj.setvaluebyformula(tmpcolumn);
        popupobj.mainfieldformulaobj.hadcomputerfieldnames=[];
    })

    //如果热线单有关联的报损单，则自动带出报损单的产品明细到维修内容中
    if(CrmPopup.findHtmlobj(divid,'version_account').val() != undefined && CrmPopup.findHtmlobj(divid,'version_account').val() == 'climaveneta' && selectmodule == 'Potentials' && curmodule == 'OutboundOrder')
    {
        var urlstring ='module=OutboundOrder&action=OutboundOrderAjax&file=getPotentialForQuotes&record='+record;
        ldAjaxHtmlNoProgress('index.php?',urlstring,function(rest) {
            if(!empty(rest)){
                var lineitem_id = rest;
                var re = new RegExp(",","g");
                var productid = lineitem_id.replace(re, ";");
                var rowcnt = CrmPopup.findHtmlobj(divid,'rowcnt').val();
                var currencyid = CrmPopup.findHtmlobj(divid,'inventory_currency').val();
                var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader&getProductinfo=yes&wareid=0&accvenid=0&currencyid='+currencyid+'&rowid='+rowcnt+'&frommodule='+curmodule+'&productid='+productid+'&popup_selectsource=true&source_idstr='+lineitem_id+'&agian=yes&selectmodule=Quotes&popup_selectsource=yes';
                fun_selectproduct.getValue(1,urlstring);
            }
        });


        //触发单据的下拉选择触发事件
        OnclikModuleLinkName(selectmodule,'',record,entityname,columnname,'');

    }

    else if(selectmodule=='Contacts'||selectmodule=='Accounts')
    {

        OnclikModuleLinkName(selectmodule,'',record,entityname,columnname,'');
    }


    if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie'){
        // //朗捷：当“服务项目”选择“报关订单”的时候，根据报关单和费用类型带出分录
        // if((selectmodule == 'CustomForm22' || selectmodule == 'CustomForm23' || selectmodule == 'CustomForm24' || selectmodule == 'Potentials' || selectmodule == 'CustomForm21') && curmodule == 'CustomForm18'){
        // 	getLangjieModuleRelatedInfo(selectmodule,record);
        // }
        // 朗捷 客服下单->空运订单回传->空运订单回传单 空运订单回传单据分录自动根据选定的“空运订单”带出
        if(curmodule == 'CustomForm25')
        {
            getLangjieModuleRelatedInfo(selectmodule,record)
        }
    }


    if(curmodule=="CashBill"&&popupobj.column_fields['accountid']!=undefined){
        //选择客户

        if(selectmodule=='Accounts'||popupobj.fieldruleobj.values['account_id']!=ld("#"+popupobj.divid+' [name=account_id]').val()
            ||popupobj.fieldruleobj.values['currency_id']!=ld("#"+popupobj.divid+' [name=currency_id]').val()

            ||popupobj.hadgivenvaluecolumnlist.includes("account_id")){//选择原单带出客户
            //预收款信息
            if(ld("#"+popupobj.divid+" [name=bankaccountsetid]").length>0)
                var bankaccountsetid=ld("#"+popupobj.divid+" [name=bankaccountsetid]").val();
            else
                var bankaccountsetid=0;
            //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
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


    if(fieldinfo != undefined && (fieldinfo.bigtype=='users'||fieldinfo.bigtype=='picklist'))
    {
        //users：负责人选择
        var isreload=false;//cls_picklist
    }
    else
        var isreload=popupobj.fieldruleobj.CheckReLoadPopup();//是否重新加载界面

    if(curmodule=='CashBill'&&!isreload){
        popupobj.fieldruleobj.setDeskValues();

    }

    if(account_version=='langjie'&&curmodule=='CustomForm18')
    {
        if(selectmodule=='CustomForm27')//edit：can 20200803 local配送单
            setLangJieRelateFieldValue('customform27_id','CustomForm27');
        else if(selectmodule=='CustomForm23')
        {
            setLangJieRelateFieldValue('customform23_id','CustomForm23');//运输单
        }
        else if(selectmodule=='CustomForm24')
        {
            setLangJieRelateFieldValue('customform24_id','CustomForm24');//空运
        }
        else if(selectmodule=='CustomForm21')
        {
            setLangJieRelateFieldValue('customform21_id','CustomForm21');//海运
        }
        else if(selectmodule=='CustomForm22')
        {
            setLangJieRelateFieldValue('customform22_id','CustomForm22');//报关
        }
        else if(selectmodule=='Commission')
        {
            setLangJieRelateFieldValue('commission_id','Commission');//出入库
        }
    }
    if(account_version=='langjie'&&curmodule=='CustomForm19')
    {

        if(selectmodule=='CustomForm28')//edit：can 20200803 local配送单
            setLangJieRelateFieldValueCustomForm19('customform28_id','CustomForm28');
        else if(selectmodule=='CustomForm02')
        {
            setLangJieRelateFieldValueCustomForm19('customform02_id','CustomForm02');//运输单
        }
        else if(selectmodule=='CustomForm24')
        {
            setLangJieRelateFieldValueCustomForm19('customform24_id','CustomForm24');//空运
        }
        else if(selectmodule=='CustomForm21')
        {
            setLangJieRelateFieldValueCustomForm19('customform21_id','CustomForm21');//海运
        }
        else if(selectmodule=='CustomForm22')
        {
            setLangJieRelateFieldValueCustomForm19('customform22_id','CustomForm22');//报关
        }
        else if(selectmodule=='Commission')
        {
            setLangJieRelateFieldValueCustomForm19('commission_id','Commission');//出入库
        }
    }
}

function tmpgetRelatedData(selectmodule,record,entityname,columnname,curmodule,selecttype)
{
    var parentwindow = window;
    var urlstring ='module=Users&action=UsersAjax&file=getRelatedFieldsData&module_record='+record;
    urlstring +='&selectmodule='+selectmodule+'&columnname='+columnname+'&curmodule='+curmodule+'&selecttype='+selecttype;
    var popupobj=CrmPopup.getPopupObj("last");
    urlstring += '&module_recordid='+popupobj.record;

    //zxm  2022-0127 获取关联字段值 带入条件
    var lastprevpopupobj=CrmPopup.getPopupObj("last");
    //关联创建的查询条件
    var  requestvalues="{";
    var sensitiverequestfield = '';
    if(lastprevpopupobj.fields != undefined){
        var requestvaluearr = getPageValueByCrmPopupFields(lastprevpopupobj);
        requestvalues = requestvaluearr['requestvalue'];
        sensitiverequestfield = requestvaluearr['sensitiverequestfield'];
    }

    var mode = 'create';
    if(parentwindow.document.EditView != undefined && parentwindow.document.EditView.mode != undefined){
        mode = parentwindow.document.EditView.mode.value;
    }
    var tmpurlstring = 'index.php?'+urlstring;
    //zkt 20231014 XUQIU1001341 SQL注入
    var postdata = {"requestvalues": requestvalues,'sensitiverequestfield':sensitiverequestfield};
    tmpurlstring= cls_encryptyurl.Puyoung_Encryptyurl(tmpurlstring,{"requestvalues": requestvalues,'sensitiverequestfield':sensitiverequestfield});
    ld.ajax({
        url: tmpurlstring,
        type: 'POST',
        //ls 20220824 BUG0055492 管理费报销创建引用字段，引用员工表的收款信息，当引用字段两个字段时候有效，再添加第三个引用字段‘收款人银行账号’时，三个引用字段全部失效(Request-URI Too Long 改成post)
        data:{"requestvalues": requestvalues,'sensitiverequestfield':sensitiverequestfield},
        async: false,//
        timeout: 5000,
        success: function(rest)
        {
            if(empty(rest)) return false;
            if(rest!= '' && rest!= 'null' && rest!= '[null]')
            {
                var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                // @edit:liushuai,2020-8-4,reason:0042269: （61mis.com/kfbcrm）收款单新增界面>选择客户编号为“ACC1057”：该客户创建了“预收款单”，在创建“收款单”时选择该客户没有将“预收款”带出来，从客户模块相关创建收款单是正常的。（需要补丁）[缺少mode参数]
                setRelateValue(restobj,columnname,selecttype,curmodule,mode);
            }
        }
    });

}
function setRelateValue(restobj,columnname,selecttype,curmodule,mode)
{
    var input_obj;
    var popupobj=CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
    if(popupobj.hadusedtriggercolumnlist==undefined)
    {
        popupobj.hadgivenvaluecolumnlist=[];//已经赋值过的字段
        popupobj.hadusedtriggercolumnlist=[];
        popupobj.fieldrulevalues=[];//因为界面的布局规则导致没有显示的字段，暂存

    }
    if(columnname=='')
    {
        columnname='aabcedtfgh';
    }


    if(CrmPopup.isPopup()){
        var divid=popupobj.divid;

        input_obj = ld('#divid form[name=QcEditView]');
    }else{
        input_obj = ld('form[name=EditView]');
    }
    var reset_approver ='no';//duan 20231214 判断关联带出后是否需要更新审批人
    var user_uitype_arr = ['53','153','154'];
    var effectfieldnames=[];
    var effectfieldvalues=[];
    for(var i = 0; i<restobj.length; i++){
        if(i>150)
        {
            //edit:can 20200811 布局规则调用该函数，会进入死循环，没有找到原因，所以只能添加该判断
            break;
        }
        //负责人编辑页不允许修改
        if(restobj[i] == null || CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).length<= 0 || (restobj[i]['rawValue']['input_name'].indexOf('assigned_user_id')>=0 && popupobj.type == 'pagerecord') || restobj[i]['rawValue']['input_name'] == ''){

            if(restobj[i] != null)
            {
                if(popupobj.fieldrulevalues[columnname]==undefined)
                {
                    //popupobj.fieldrulevalues[columnname]=[];
                }

                popupobj.fieldrulevalues.push(restobj[i]);
            }
            continue;
        }

        if(ld.inArray(restobj[i]['rawValue']['input_name'],popupobj.hadgivenvaluecolumnlist)>=0)
        {
            //已经赋值过的字段不需要再赋值，例如客户和联系人可以循环赋值
            continue;
        }

        var tagname = CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).prop("tagName");
        popupobj.hadgivenvaluecolumnlist.push(restobj[i]['rawValue']['input_name']);//已经赋值过的字段

        if(!empty(tagname)){
            if (!empty(restobj[i]['picklist']) && restobj[i]['picklist']['optionvalue'].length>0) {
                //下拉框
                for(var k=0;k<popupobj.picklistcontent.length;k++)
                {
                    if(popupobj.picklistcontent[k].fieldname==restobj[i]['picklist']['fieldname'])
                    {
                        popupobj.picklistcontent[k].optionvalue=restobj[i]['picklist']['optionvalue'];
                        break;
                    }
                }
                popupobj.picklistobjarray[restobj[i]['picklist']['fieldname']]=new cls_picklist(restobj[i]['picklist']['fieldname'],restobj[i]['picklist']['optionvalue']);

                // ld("#" + popupobj.divid + ' [name=dv_cmb_' + restobj[i]['rawValue']['input_name'] + "]").trigger("click");//级联下拉框 联动带出值

            }

            //新增、编辑   不可编辑字段
            if(CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']) != undefined && CrmPopup.findHtmlobj(divid,'span_'+restobj[i]['rawValue']['input_name']).val() != undefined){
                CrmPopup.findHtmlobj(divid,'span_'+restobj[i]['rawValue']['input_name']).html(restobj[i]['value']['value']);
            }
            // fieldname_fields
            //


            //zkt 20231120 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
            if(restobj[i]['rawValue']['havesensitivevalue'] != undefined){
                if(popupobj.fieldSensitiveruleobj != undefined){
                    popupobj.fieldSensitiveruleobj.setfieldSensitiveinfo(restobj[i]['rawValue']['input_name'],restobj[i]['rawValue']['havesensitivevalue'],restobj[i]['rawValue']['sensitiveencryptvalue']);
                }
            }


            if(tagname.toLowerCase() == 'input'){
                if(!empty(restobj[i]['rawValue']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name']) ){
                    CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).val(restobj[i]['rawValue']['value']);
                    if('locationaddress' == restobj[i]['rawValue']['input_name']){
                        getLocationAddress('locationaddress','edit');
                    }else if(restobj[i]['rawValue']['uitype']==56){
                        //关联带出字段为复选框时
                        CrmPopup.findHtmlobj(divid,"sel_"+restobj[i]['rawValue']['input_name']).prop('checked',restobj[i]['rawValue']['value'] == 1?true:false);
                    }

                    if(!empty(restobj[i]['value']['value']) && (restobj[i]['value']['input_name'] == null || restobj[i]['value']['input_name'] == '')){
                        if(CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name']+'_name')){
                            CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']+'_name').val(restobj[i]['value']['value']);
                            CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']+'_name').html(restobj[i]['value']['value']);
                        }
                    }

                }
                if(!empty(restobj[i]['value']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['value']['input_name'])){
                    CrmPopup.findHtmlobj(divid,restobj[i]['value']['input_name']).val(restobj[i]['value']['value']);
                    if(restobj[i]['rawValue']['uitype'] == 154)
                        CrmPopup.findHtmlobj(divid,restobj[i]['value']['input_name']).html(restobj[i]['value']['value']);
                }
                if(!empty(restobj[i]['rawValue']['input_name']) && CrmPopup.isExistsObj(divid,'cmb_span_optiontext_'+restobj[i]['rawValue']['input_name'])){

                    CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+restobj[i]['rawValue']['input_name']).val(restobj[i]['value']['value']);

                }
                if(restobj[i]['rawValue']['input_name']=='account_id'&&restobj[i]['rawValue']['uitype']==73)
                {
                    if((restobj[i]['value']['input_name'] == 'accounts_name')){
                        //选择客户带出客户和联系人关联字段
                        if(document.getElementById('bemodulestatus') != undefined && document.getElementById('bemodulestatus').value == 'YES'){
                            getAccountsContactsInfo(restobj[i]['rawValue']['value'],'','Accounts','EditView');
                        }
                    }
                }
                if(restobj[i]['rawValue']['input_name']=='contact_id'&&restobj[i]['rawValue']['uitype']==57)
                {
                    if((restobj[i]['value']['input_name'] == 'accounts_name')){
                        //选择客户带出客户和联系人关联字段
                        if(document.getElementById('bemodulestatus') != undefined && document.getElementById('bemodulestatus').value == 'YES'){
                            getAccountsContactsInfo(restobj[i]['rawValue']['value'],'','Contacts','EditView');
                        }
                    }
                }
                //duan 20231214 修复关联带出的用户字段不可编辑时，无法更新审批人信息的问题
                if(user_uitype_arr.includes(restobj[i]['rawValue']['uitype'])){
                    reset_approver = 'yes';
                }
            }
            else if(tagname.toLowerCase() == 'textarea'){
                if(restobj[i]['rawValue']['uitype']==230 || restobj[i]['rawValue']['uitype']==231){
                    popupobj.oCKeditors[restobj[i]['rawValue']['input_name']].setContent(restobj[i]['rawValue']['value']);
                }else{
                    if(!empty(restobj[i]['rawValue']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name'])){
                        CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).html(restobj[i]['rawValue']['value']);
                        CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).val(restobj[i]['rawValue']['value']);
                        CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).trigger('input');//textarea根据内容自动调整大小
                    }
                    if(!empty(restobj[i]['value']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['value']['input_name'])){
                        CrmPopup.findHtmlobj(divid,restobj[i]['value']['input_name']).html(restobj[i]['value']['value']);
                        CrmPopup.findHtmlobj(divid,restobj[i]['value']['input_name']).trigger('input');//textarea根据内容自动调整大小
                    }
                }
            }
            else if(tagname.toLowerCase() == 'select'){
                var rawValue = restobj[i]['rawValue']['value'];

                if(CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name'])){
                    var fldname = restobj[i]['rawValue']['input_name'];
                    var objoption = CrmPopup.findHtmlobj(divid,fldname);
                    if (restobj[i]['rawValue']['uitype'] == 33) {//多选框处理
                        var rawValue_arr = rawValue.split(' |##| ');console.log(rawValue_arr);
                        objoption.val(rawValue_arr).trigger('change');
                        continue;
                    }
                    var optiontext='';
                    picklist=true;
                    var select_find = 'no';
                    if(objoption != undefined){

                        for(var k=0;k<objoption.find("option").length;k++)
                        {
                            if(objoption.find("option")[k].value==rawValue)
                            {
                                objoption.find("option")[k].selected=true;
                                optiontext=objoption.find("option")[k].text;
                                objoption.find("option")[k].selected=true;

                                objoption.find("option")[k].selectedIndex=k;
                                objoption.find("option")[k].value=rawValue;

                                if(fldname == 'currency_id'){
                                    CrmPopup.findHtmlobj(divid,'currency_id_from_related').val('yes');
                                }
                                if(typeof objoption.change=='function' && fldname != 'inventory_currency')
                                    objoption.change();
                                if(fldname == 'currency_id'){
                                    CrmPopup.findHtmlobj(divid,'currency_id_from_related').val('no');
                                }
                                if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
                                {
                                    var sourcename = objoption.name;
                                    var sourcevalue = objoption.value;

                                    fielddepend.fieldValueChange(sourcename, sourcevalue);
                                }
                                select_find = 'yes';
                                break;
                            }
                        }

                        //	if(!empty(optiontext)){
                        CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class","");
                        CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class",'chzn-single');
                        //edit:can 2020-09-11 42642: （https://61mis.com/KH/kh38230/测试账套 [^]）客户问题（四方光电），使用普通用户账号登录操作>合同订单模块>新建单据编辑界面：选择客户“菜单”，录入产品等信息点击保存后，列表不显示此单据
                        //kehu001的字段负责人，是html
                        var picklisttype=CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).attr('picklisttype');

                        if(picklisttype!=undefined&&'smownerpicklist'==picklisttype)
                        {
                            //负责人
                            if(select_find == 'yes'){//duan 20221009关联带出的负责人不在当前用户的数据范围内，不允许带出
                                CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).html(restobj[i]['value']['value']);
                            }
                        }
                        else
                            CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(restobj[i]['value']['value']);
                        CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).css("left","-9000px");//隐藏下拉框
                        //}
                    }
                }
            }
            else if(tagname.toLowerCase() == 'div'){
                var fldname = restobj[i]['rawValue']['input_name'];
                if(CrmPopup.isExistsObj(divid,fldname)){
                    //wym XUQIU1001671 引用附件字段自动带出附件图片
                    if(SaveDataRecord.isfileattachUitype(restobj[i]['rawValue']['uitype'])){
                        var fileuploader=CrmPopup.findHtmlobj(divid,fldname);
                        if(fileuploader.length>0) {
                            for(var j=0;j<popupobj.fields.length;j++){
                                if(popupobj.fields[j].fieldname==fldname){
                                    popupobj.filejsondata=restobj[i]['rawValue']['value'];
                                    if(popupobj.filejsondata){
                                        ld(fileuploader).html('');
                                        var uploadFile = new WebUploadFile();
                                        globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                                        uploadFile.setEvent(globalWebUploadType,fileuploader,popupobj,j);
                                    }else{
                                        ld(fileuploader).find('.uploader-list').html('');
                                        ld(fileuploader).find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            var effectfieldname=restobj[i]['rawValue']['input_name'];
            effectfieldnames.push(effectfieldname);
            effectfieldvalues.push(restobj[i]['rawValue']['value']);

            //duan 20240926字段变更后触发公共变化事件
            if(!empty(popupobj.common_field_event_obj)&&!empty(effectfieldname)){
                popupobj.common_field_event_obj.common_changefun(CrmPopup.findHtmlobj(divid,effectfieldname),effectfieldname);
            }
        }
    }
    //布局规则，是否重新加载界面
    popupobj.fieldruleobj.CheckReLoadPopup();//布局规则
    //duan 20231214用户字段变化后，需要重新获取审批人
    if(reset_approver == 'yes' && popupobj.ChangeApprove != undefined){
        popupobj.ChangeApprove();
    }

    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
    {

        //通讯录(pc端企业微信)
        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
    }
    ld.each(effectfieldnames,function(tmpindex,tmpeffectfieldname){
        var effectfieldname=tmpeffectfieldname;

        if(ld.inArray(effectfieldname,popupobj.hadusedtriggercolumnlist)<0)
        {

            popupobj.hadusedtriggercolumnlist.push(columnname);
            if(popupobj.fieldname_fields!=undefined&&popupobj.fieldname_fields[effectfieldname]!=undefined)
            {
                var tmpfieldinfo=popupobj.fieldname_fields[effectfieldname];

                if(popupobj.fieldname_fields!=undefined&&popupobj.fieldname_fields[effectfieldname]!=undefined)
                {
                    var tmpfieldinfo=popupobj.fieldname_fields[effectfieldname];

                    if(tmpfieldinfo.bigtype=='reference' || tmpfieldinfo.bigtype=='users' || tmpfieldinfo.bigtype=='selectoneuser' || tmpfieldinfo.bigtype=='selectsource')
                    {
                        if(effectfieldvalues[tmpindex]==null)
                        {
                            effectfieldvalues[tmpindex]=0;
                        }
                        //最小的改动
                        //37934: （1.6）新增【引用客户名称】字段，选择源单带出客户名称后，【引用客户名称】字段没有显示字段值（合同订单测试）
                        //edit:can 52375:： 	销售订单模块，选择客户名称，销售员的销售部门没有带出来，需要去再点一次销售员字段才能带出对应的销售部门。详情见附件
                        if(tmpfieldinfo.bigtype=='users'|| tmpfieldinfo.bigtype=='selectoneuser')
                            //wym XUQIU1000290 页面设置，“引用字段”增加可自定义引用成员管理字段（苏宁）
                            tmpgetRelatedData(tmpfieldinfo.referencemodule,effectfieldvalues[tmpindex],effectfieldvalues[tmpindex],effectfieldname,curmodule,'select');
                        else if(ld("#"+popupobj.divid+"  [name="+effectfieldname+"]").val()!=''&&ld("#"+popupobj.divid+"  [name="+effectfieldname+"]").val()!=0)
                            //liushuai 20230815 BUG0071130 合同订单模块，选择报价单后，对应的客户名称带出来了，但是客户模块引用的数据不会带过来。如图。如果再选择一次客户，才会被带出来。  (应该用columnname)
                            tmpgetRelatedData(tmpfieldinfo.referencemodule,effectfieldvalues[tmpindex],effectfieldvalues[tmpindex],effectfieldname,curmodule,selecttype);
                    }
                }
            }
        }
    })

}
//清除选择字段关联带出值
function clear_relatedfielddatas(selectmodule,record,entityname,columnname,curmodule,selecttype){


    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.hadusedcleartriggercolumn=[];
    tmpclear_relatefielddatas(selectmodule,record,entityname,columnname,curmodule,selecttype);
    if(curmodule=="CashBill"){
        //选择客户

        if(selectmodule=='Accounts'||popupobj.fieldruleobj.values['account_id']!=ld("#"+popupobj.divid+' [name=account_id]').val()){
            //预收款信息

            var tmpobj=getChooseRelateLists.getInstance(popupobj);//
            tmpobj.removeAllDebuction()
            //设置实际金额
            tmpobj.setActualTotal();
            tmpobj.setsubtotaltrshow();

        }
    }

    //布局规则，是否重新加载界面
    popupobj.fieldruleobj.CheckReLoadPopup();//布局规则
}
function tmpclear_relatefielddatas(selectmodule,record,entityname,columnname,curmodule,selecttype)
{
    var parentwindow = window;
    //zkt 20230824 BUG0071605  新建报价单选择项目XSXM-LNXY-20230624-0009之后清除联系人选择李祥，手机号变化但是联系人名称不变，具体问题详见附件视频
    var urlstring ='module=Users&action=UsersAjax&file=getRelatedFieldsData&module_record='+record;
    urlstring +='&selectmodule='+selectmodule+'&columnname='+columnname+'&curmodule='+curmodule+'&selecttype='+selecttype;
    //alert(urlstring);
    var mode = 'create';
    if(parentwindow.document.EditView != undefined && parentwindow.document.EditView.mode != undefined){
        mode = parentwindow.document.EditView.mode.value;
    }
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.hadusedcleartriggercolumn==undefined)
    {

        popupobj.hadusedcleartriggercolumn=[];
    }
    var i=0;
    var tmpurlstring = 'index.php?'+urlstring;
    //zkt 20231014 XUQIU1001341 SQL注入
    tmpurlstring= cls_encryptyurl.Puyoung_Encryptyurl(tmpurlstring,'');
    ld.ajax({
        url: tmpurlstring,
        type: 'POST',
        data:'',
        async: false,//
        timeout: 5000,
        success: function(rest)
        {
            if(empty(rest)) return false;
            if(rest != 'null'&&rest!=''){
                var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
                var input_obj;
                if(CrmPopup.isPopup()){
                    var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;

                    input_obj = ld('#divid form[name=QcEditView]');
                }else{
                    input_obj = ld('form[name=EditView]');
                }

                for( i = 0; i<restobj.length; i++){
                    if(restobj[i] == null || CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']) == undefined){
                        continue;
                    }
                    if(popupobj.record>0&&restobj[i]['rawValue']['input_name']=='assigned_user_id')
                    {
                        continue;//负责人编辑不能清空
                    }
                    if(popupobj.record>0&&restobj[i]['rawValue']['input_name']=='ServiceContractsassigned_user_id')
                    {
                        continue;//负责人编辑不能清空
                    }

                    if(restobj[i]['rawValue']['input_name']=='account_id'&&columnname=='lastname')
                    {

                        //35556: （1.6）跟进记录新增、编辑界面>选择客户和联系人后>点击联系人字段的擦除按钮：客户也会被擦除掉。
                        continue;
                    }
                    var tagname = CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).prop("tagName");
                    var referenceidvalue=0;
                    if(!empty(tagname)){
                        //新增、编辑   不可编辑字段
                        if(CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']) != undefined && CrmPopup.findHtmlobj(divid,'span_'+restobj[i]['rawValue']['input_name']).val() != undefined){
                            CrmPopup.findHtmlobj(divid,'span_'+restobj[i]['rawValue']['input_name']).html('');
                        }
                        if(tagname.toLowerCase() == 'input'){
                            if(!empty(restobj[i]['rawValue']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name']) ){
                                referenceidvalue=ld("#"+divid+" [name="+restobj[i]['rawValue']['input_name']+"]").val();

                                CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).val('');
                                if('locationaddress' == restobj[i]['rawValue']['input_name'] && ld("#"+divid+" [name=location_map_td]") != undefined){
                                    ld("#"+divid+" [name=location_map_td]").hide();
                                }
                            }
                            if(!empty(restobj[i]['value']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['value']['input_name'])){
                                //referenceidvalue=ld("#"+divid+" [name="+restobj[i]['rawValue']['input_name']+"]").val();
                                CrmPopup.findHtmlobj(divid,restobj[i]['value']['input_name']).val('');
                            }
                            if(!empty(restobj[i]['value']['value']) && (restobj[i]['value']['input_name'] == null || restobj[i]['value']['input_name'] == '')){
                                if(CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name']+'_name')){
                                    // referenceidvalue=ld("#"+divid+" [name="+restobj[i]['rawValue']['input_name']+"]").val();
                                    CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']+'_name').val('');
                                }
                            }
                        }
                        else if(tagname.toLowerCase() == 'textarea'){
                            if(!empty(restobj[i]['rawValue']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name'])){
                                CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).html('');
                                CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).val('');
                            }
                            if(!empty(restobj[i]['value']['input_name']) && CrmPopup.isExistsObj(divid,restobj[i]['value']['input_name'])){
                                CrmPopup.findHtmlobj(divid,restobj[i]['value']['input_name']).html('');
                            }
                        }
                        else if(tagname.toLowerCase() == 'select'){
                            var rawValue = '';

                            if(CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name'])){
                                var fldname = restobj[i]['rawValue']['input_name'];
                                var objoption = CrmPopup.findHtmlobj(divid,fldname);
                                var optiontext='';
                                picklist=true;

                                if(objoption != undefined){

                                    for(var k=0;k<objoption.find("option").length;k++)
                                    {
                                        if(objoption.find("option")[k].value==rawValue)
                                        {
                                            objoption.find("option")[k].selected=true;
                                            optiontext=objoption.find("option")[k].text;
                                            objoption.find("option")[k].selected=true;

                                            objoption.find("option")[k].selectedIndex=k;
                                            objoption.find("option")[k].value=rawValue;

                                            if(typeof objoption.change=='function')
                                                objoption.change();
                                            if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
                                            {
                                                var sourcename = objoption.name;
                                                var sourcevalue = objoption.value;

                                                fielddepend.fieldValueChange(sourcename, sourcevalue);
                                            }
                                            break;
                                        }
                                    }
                                    CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class","");
                                    CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class",'chzn-single');

                                    CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(optiontext);
                                    CrmPopup.findHtmlobj(divid,'dv_drop_'+fldname).css("left","-9000px");//隐藏下拉框
                                }
                            }
                        }
                        else if(tagname.toLowerCase() == 'div'){
                            var fldname = restobj[i]['rawValue']['input_name'];
                            if(CrmPopup.isExistsObj(divid,fldname)){
                                //wym XUQIU1001671 引用附件字段自动删除附件图片
                                if(SaveDataRecord.isfileattachUitype(restobj[i]['rawValue']['uitype'])){
                                    CrmPopup.findHtmlobj(divid,fldname).find('.uploader-list').html('');
                                    CrmPopup.findHtmlobj(divid,fldname).find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);
                                }
                            }
                        }
                    }

                    var effectfieldname=restobj[i]['rawValue']['input_name'];
                    if(ld.inArray(effectfieldname,popupobj.hadusedcleartriggercolumn)<0)
                    {

                        popupobj.hadusedcleartriggercolumn.push(effectfieldname);
                        if(popupobj.fieldname_fields!=undefined&&popupobj.fieldname_fields[effectfieldname]!=undefined)
                        {

                            var tmpfieldinfo=popupobj.fieldname_fields[effectfieldname];

                            if(tmpfieldinfo.bigtype=='reference')
                            {

                                tmpclear_relatefielddatas(tmpfieldinfo.referencemodule,referenceidvalue,'',effectfieldname,curmodule,selecttype);
                            }else if(tmpfieldinfo.bigtype=='users'|| tmpfieldinfo.bigtype=='selectoneuser'){
                                //wym XUQIU1000290 页面设置，“引用字段”增加可自定义引用成员管理字段（苏宁）
                                tmpclear_relatefielddatas(tmpfieldinfo.referencemodule,referenceidvalue,'',effectfieldname,curmodule,'select');
                            }
                        }
                    }
                }
                //如果热线单有关联的报损单，则自动带出报损单的产品明细到维修内容中
                if(CrmPopup.findHtmlobj(divid,'version_account').val() != undefined && CrmPopup.findHtmlobj(divid,'version_account').val() == 'climaveneta' && selectmodule == 'Potentials' && curmodule == 'OutboundOrder'){
                    clearModuleProduct('','OutboundOrder','');
                }



                // }
            }
        }
    });
}

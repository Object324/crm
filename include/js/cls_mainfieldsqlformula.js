//liushuai 20230718 XUQIU1001661 单据头字段录入方式增加“通过SQL查询”
function cls_mainfieldsqlformula()
{
    this.popupobj=CrmPopup.getPopupObj('last');
    this.haschangefieldname_arr = [];

    this.setPopupobj=function(popupobj)
    {
        this.popupobj=popupobj;
    }
    this.mainfieldformulaobj=this.popupobj.mainfieldformulaobj;
    this.setmainfieldformulaobj=function(mainfieldformulaobj)
    {
        this.mainfieldformulaobj=mainfieldformulaobj;
    }
    
    var that=this;

    
    //formulafieldname：引发计算的字段公式
    this.setvaluebyformula=function(formulafieldname){
        
       
        var record=that.popupobj.record;
      
         var formulafieldnameinfo=that.computerfieldnamesformula[formulafieldname];
        if(formulafieldnameinfo==undefined)
        {
            return ;
        }
      //  var profilefieldsinfo=that.popupobj.detailobj.profiledetailfields;//有权限的字段

        console.log(formulafieldnameinfo);
        var tmpneedcomputercols=[];
      //  var cls_encryptobj=new cls_encrypt();

        ld.each(formulafieldnameinfo,function(tmpindex,formulainfo){
           
             var formulastring=formulainfo.formulastring;
             var formulajson=that.html_decode(formulainfo.columnstring);
             var formulaarr=eval('('+ formulajson+')')?eval('('+formulajson +')'):JSON.parse(formulajson);
             var needcomputedfieldname=formulainfo.fieldname;//获取需要被计算的字段

            if (empty(formulainfo.functiontype)) {

           // try{
                var strformula='';
                var formulalen=formulastring.length;
                var letter='';
              
                for(var i=0;i<formulalen;i++)
                {
                  
                    letter=formulastring.substr(i,1);
                    var tmpfieldname='';
                    var  tmpcolumn='';
                    if(ld.inArray(letter,letters)>=0)
                    {
                      //  console.log(formulaarr.formulavar);
                        ld.each(formulaarr.formulavar,function(tmp_index,tmp_info){
                            
                            if(tmp_info.lettervar==letter)
                            {
                                //ls 20220712 BUG0053832(http://42.193.125.39:85/crm）材料采购合同新建无法保存(/被布局规则隐藏的字段参与计算公式计算需要重新初始化)
                                if (!empty(that.maincolumninfo[tmp_info.column])) {
                                    tmpfieldname=that.maincolumninfo[tmp_info.column].fieldname;
                                    tmpcolumn=tmp_info.column;
                                }
                                return false;
                            }
                        })
                       
                        if (empty(tmpcolumn))
                        {
                            strformula+='0';
                            break;
                        }
                        var tmpvalue=0;
                        var tmpobj=ld("#"+that.popupobj.divid+" [name="+that.maincolumninfo[tmpcolumn].fieldname+"]");
                        if(that.popupobj.pagetype==DetailViewPage.pagetype)
                        {
                            //查看界面(通过 后台处理 吧 )
                           // tmpobj=ld("#"+that.popupobj.divid+" [name='"+that.maincolumninfo[tmpcolumn].fieldname+"_name']");
                        }
                        if(that.maincolumninfo[tmpcolumn].displaytype==3)
                        {
                            if(that.popupobj.module=="CashBill")
                             {
                                  tmpobj=ld("#"+that.popupobj.divid+' [name=total]');
                             }
                             else if(that.popupobj.module=='SendCashBill')
                             {
                                  tmpobj=ld("#"+that.popupobj.divid+' [name=total]');
                             }
                             else if(tmpcolumn=='total')
                             {
                                tmpobj=ld("#"+that.popupobj.divid+' [name=total]');
                             }
                             else if(tmpcolumn=='adjustment'){
                                    tmpobj=ld("#"+that.popupobj.divid+' [name=adjustment]');
                            
                            }
                        }
                        else if(that.maincolumninfo[tmpcolumn].savedatabase=='no')
                        {
                            tmpobj=ld("#"+that.popupobj.divid+" [name=span_"+that.maincolumninfo[tmpcolumn].fieldname+"]");
                        }
                       
                        if(tmpobj.length>0)
                        {
                            if(that.maincolumninfo[tmpcolumn] != [] && that.maincolumninfo[tmpcolumn].havesensitivevalue != undefined && that.maincolumninfo[tmpcolumn].havesensitivevalue == 'yes'){
                                tmpvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(that.maincolumninfo[tmpcolumn].sensitiveencryptvalue,true,that.maincolumninfo[tmpcolumn]);
                            }
                            else{
                                if(tmpobj.is("input"))
                                {
                                    tmpvalue=ld(tmpobj).val();
                                }
                                else
                                {
                                    tmpvalue=ld(tmpobj).html();
                                }
                            }
                           
                        }
                        if(that.maincolumninfo[tmpcolumn].displaytype==3&&tmpcolumn=='adjustment')
                        {
                            if(ld("#"+popupobj.divid+" [name=adjustmentType]").val()=="-")
                            {
                                tmpvalue=0-tmpvalue;
                            }
                        }
                       
                        if(ld.trim(tmpvalue)=='')
                        {
                            tmpvalue=0;
                        }
                      
                        if(eval(tmpvalue)<0)
                        {
                            
                            tmpvalue='('+ tmpvalue +')'
                        }
                        strformula+=tmpvalue;
                    }
                    else
                    {
                        //日期变量{year},{halfyear} {quarter}{month}{week}{day};
                        
                        strformula+=letter;
                    }
                }


                var tmpobj=ld("#"+that.popupobj.divid+" [name="+needcomputedfieldname+"]");
                if(that.popupobj.pagetype==DetailViewPage.pagetype)
                {
                    //查看界面(通过后台处理吧)
                   // tmpobj=ld("#"+that.popupobj.divid+" [name="+needcomputedfieldname+"_name]");
                }
                if(tmpobj==that.inputobj||ld.inArray(needcomputedfieldname,that.mainfieldformulaobj.hadcomputerfieldnames)>=0)
                {
                   
                    return true;
                }
                
                that.mainfieldformulaobj.hadcomputerfieldnames.push(needcomputedfieldname);
                tmpneedcomputercols.push(needcomputedfieldname);
               
                if(tmpobj.length>0)
                {
                    var tmphavesetvalue = false;
                    if(that.popupobj.fieldSensitiveruleobj != undefined){
                        var fieldSensitiveruleobj = that.popupobj.fieldSensitiveruleobj;
                        var needcomputedfieldinfo = fieldSensitiveruleobj.getFieldInfoByfieldname(needcomputedfieldname);
                        if(needcomputedfieldinfo && needcomputedfieldinfo.havesensitivevalue == 'yes')
                        {
                            //设置值和设置小数位数是分开的
                            var tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(tmpevalvalue,false,needcomputedfieldinfo);//加密字段
                            fieldSensitiveruleobj.setfieldSensitiveinfo(needcomputedfieldname,needcomputedfieldinfo.havesensitivevalue,tmpEncryptytvalue);
                            tmpEncryptytvalue = that.setFieldLenDecimal(needcomputedfieldinfo);
                            tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(tmpEncryptytvalue,false,needcomputedfieldinfo);//加密字段
                            fieldSensitiveruleobj.setfieldSensitiveinfo(needcomputedfieldname,needcomputedfieldinfo.havesensitivevalue,tmpEncryptytvalue);
                            tmphavesetvalue = true;
                        }
                    }
                    else{
                        if(tmpobj.is("input"))
                        {
                            ld(tmpobj).val(eval(strformula));
                        }
                        else
                        {
                            ld(tmpobj).html(eval(strformula));
                        }
                        ld(tmpobj).val(that.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]));
                        if(that.popupobj.fieldname_fields[needcomputedfieldname].allowedit=='no')
                        {
                            ld("#"+that.popupobj.divid+" [name=span_"+needcomputedfieldname+"]").html(ld(tmpobj).val());
                        }
                    }
                   if(that.popupobj.pagetype==DetailViewPage.pagetype)
                    {
                        //(通过后台处理吧)
                       // ld("#"+that.popupobj.divid+" [name=dtlview_"+needcomputedfieldname+"]").html(ld(tmpobj).val());
                        
                    }
                  // that.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]); 
                }
               
           /* }
            catch(ex)
            {
                
            }*/

            }
            else{
                getJsScript('include/js/cls_mainfieldsqlformula.js',function(){

                });
                var tmp_value='';
                var tmp_valueid='';
                var requestvalues=getPageValueByCrmPopupFieldsNew(that.popupobj);
                //访问后台查询sql
                var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=getFldValueBySqlFormula';
                //zkt 20240911 BUG20240911-11 延期发货申请模块，自定义字段：“判断部门”，销售一部、销售二部可以取到值，后面的国际部教育事业部无法取到值
                ldAjax(urlstring,{"modulename":that.popupobj.module,"requestvalues": encodeURIComponent(requestvalues['requestvalue']),"sensitiverequestfield": requestvalues['sensitiverequestfield'],"requestvalue_arr": requestvalues['requestvalue_arr'],/*"sql": encodeURIComponent(formulainfo.formulastring),"columnstring":formulainfo.columnstring,*/"formulaid":formulainfo.formulaid},function(data){
                    if(data.code == 1){
                        tmp_value = data.result.tmp_value;

                        if (!empty(tmp_value)) {
                            tmp_valueid = data.result.tmp_valueid;

                            var tmpobj=ld("#"+that.popupobj.divid+" [name="+needcomputedfieldname+"]");

                            if(tmpobj==that.inputobj||ld.inArray(needcomputedfieldname,that.mainfieldformulaobj.hadcomputerfieldnames)>=0)
                            {
                                return true;
                            }

                            that.mainfieldformulaobj.hadcomputerfieldnames.push(needcomputedfieldname);
                            tmpneedcomputercols.push(needcomputedfieldname);

                            if(tmpobj.length>0)
                            {
                                if(tmpobj.is("input"))
                                {
                                    ld(tmpobj).val(tmp_value);
                                }
                                else
                                {
                                    ld(tmpobj).html(tmp_value);
                                }

                                ld(tmpobj).val(that.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]));
                                if(that.popupobj.fieldname_fields[needcomputedfieldname].allowedit=='no')
                                {
                                    ld("#"+that.popupobj.divid+" [name=span_"+needcomputedfieldname+"]").html(ld(tmpobj).val());
                                }

                            }
                        }

                    }
                    // DelProgressObjs();
                    ld('#rptContentLoading').hide();
                })

            }
        })

        ld.each(tmpneedcomputercols,function(index,tmpcol){
            if(tmpcol!=''&&ld.inArray(tmpcol,that.computerfieldnames)>=0)
            {
               
                 var tmp_formulainfo= that.computerfieldnamesformula[tmpcol];//查看当前被计算的字段，参与了哪些字段公式计算
                 ld.each(tmp_formulainfo,function(tmpindex,tmpinfo){
                       var fieldname=that.maincolumninfo[tmpinfo.columnname].fieldname;
                        var tmp_arr_index=ld.inArray(fieldname,that.mainfieldformulaobj.hadcomputerfieldnames);
                        if(tmp_arr_index>=0){
                            //已经计算的过的字段，但是其中参与计算的字段值改变，那么已经计算的字段需要重新计算
                            //例如导入
                            that.mainfieldformulaobj.hadcomputerfieldnames.splice(tmp_arr_index,1);
                        }
                 })
                 
                that.setvaluebyformula(tmpcol);
            }
        })
      
       
    }


    //访问后台去查询指定的sql
    this.getFldValueBySqlFormula=function(needcomputedfieldname,formulainfo){
        if(ld.inArray(needcomputedfieldname,that.mainfieldformulaobj.hadcomputerfieldnames)>=0)
        {
            return false;
        }
        var requestvalues=getPageValueByCrmPopupFieldsNew(that.popupobj);
        var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=getFldValueBySqlFormula';
        ldAjaxHtmlNoProgresssync(urlstring,{"modulename":that.popupobj.module,"requestvalues": encodeURIComponent(requestvalues['requestvalue']),"sensitiverequestfield": requestvalues['sensitiverequestfield'],"requestvalue_arr": requestvalues['requestvalue_arr'],/*"sql": encodeURIComponent(formulainfo.formulastring),"columnstring":formulainfo.columnstring,*/"formulaid":formulainfo.formulaid},function(ajaxhtml){
            if(empty(ajaxhtml)) return false;
            if(ajaxhtml!= '' && ajaxhtml!= 'null'){
                var restobj = eval('('+ ajaxhtml +')')?eval('('+ ajaxhtml +')'):JSON.parse(ajaxhtml);

                // var tmpobj=ld("#"+that.popupobj.divid+" [name="+needcomputedfieldname+"]");
                // that.mainfieldformulaobj.hadcomputerfieldnames.push(needcomputedfieldname);

                //页面赋值
                that.setSqlFormulaValue(restobj,needcomputedfieldname);
            }
        });

    }



    //给页面赋值
    this.setSqlFormulaValue=function(restobj,columnname)
    {
        var popupobj=that.popupobj;
        this.haschangefieldname_arr = [];

        if(columnname=='')
        {
            columnname='aabcedtfgh';
        }
        var divid=popupobj.divid;
        var before_value = '';
        var after_value = '';


        for(var i = 0; i<restobj.length; i++){
            if(i>150)
            {
                //edit:can 20200811 布局规则调用该函数，会进入死循环，没有找到原因，所以只能添加该判断
                break;
            }

            //其中负责人编辑页不允许修改
            if(restobj[i] == null || CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).length<= 0 || (restobj[i]['rawValue']['input_name'].indexOf('assigned_user_id')>=0 && popupobj.type == 'pagerecord') || restobj[i]['rawValue']['input_name'] == ''){
                if(restobj[i] != null)
                {
                    // popupobj.fieldrulevalues.push(restobj[i]);
                }
                continue;
            }

            if(ld.inArray(restobj[i]['rawValue']['input_name'],that.mainfieldformulaobj.hadcomputerfieldnames)>=0)
            {
                //已经赋值过的字段不需要再赋值，例如客户和联系人可以循环赋值
                continue;
            }
            var effectfieldname = restobj[i]['rawValue']['input_name'];
            var tagname = CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).prop("tagName");
            that.mainfieldformulaobj.hadcomputerfieldnames.push(restobj[i]['rawValue']['input_name']);//已经赋值过的字段
            after_value = restobj[i]['value']['value'];
            before_value = CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']).val();
            if(before_value != after_value){
                this.haschangefieldname_arr.push(restobj[i]['rawValue']['input_name']);
            }

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
                    //popupobj.picklistobjarray[restobj[i]['picklist']['fieldname']]=new cls_picklist(restobj[i]['picklist']['fieldname'],restobj[i]['picklist']['optionvalue']);
                }

                //新增、编辑   不可编辑字段
                if(CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']) != undefined && CrmPopup.findHtmlobj(divid,'span_'+restobj[i]['rawValue']['input_name']).val() != undefined){
                    CrmPopup.findHtmlobj(divid,'span_'+restobj[i]['rawValue']['input_name']).html(restobj[i]['value']['value']);
                }
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
                        }
                        if(!empty(restobj[i]['value']['value']) && (restobj[i]['value']['input_name'] == null || restobj[i]['value']['input_name'] == '')){//单选复制
                            if(CrmPopup.isExistsObj(divid,restobj[i]['rawValue']['input_name']+'_name')){
                                CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']+'_name').val(restobj[i]['value']['value']);
                                CrmPopup.findHtmlobj(divid,restobj[i]['rawValue']['input_name']+'_name').html(restobj[i]['value']['value']);
                            }else if(restobj[i]['rawValue']['uitype'] == 56 && CrmPopup.isExistsObj(divid,'sel_'+restobj[i]['rawValue']['input_name'])){
                                //BUG20241022-50 ls 241023 复选框类型字段 通过SQL查询 赋值不生效
                                CrmPopup.findHtmlobj(divid,'sel_'+restobj[i]['rawValue']['input_name']).prop("checked",restobj[i]['value']['value'] == 1?true:false);
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
                            var rawValue_arr = rawValue.split(' |##| ');
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
                //duan 20240926字段变更后触发公共变化事件
                if(!empty(popupobj.common_field_event_obj)){
                    popupobj.common_field_event_obj.common_changefun(CrmPopup.findHtmlobj(divid,effectfieldname),effectfieldname);
                }

            }
        }
        //布局规则，是否重新加载界面
        popupobj.fieldruleobj.CheckReLoadPopup();//布局规则

        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {

            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }

    }
    
    
    
}
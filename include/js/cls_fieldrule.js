 //39052:(列表界面新增) 海格->报价单->设置了页面布局:报价单类型=特价报价单时，必须录入“特价申请单编号”，但是选择其他类型报价单也提示必须录入
 var PageRecordPopupobj;
function cls_fieldrule(popupobj,fieldnames)
{
    //布局规则
    var that=this;
    that.popupobj=popupobj;
     this.hadreload='no';
    this.rulefieldname=fieldnames;
    this.reloadfieldname='';//引发布局字段的名称
    that.values=[];
    
    this.setEvent=function()
    {
        var popupobj=that.popupobj;
      
       if(that.rulefieldname==null||that.rulefieldname==undefined){
        //没有布局规则
        return false;
       }
       //that.rulefieldname:包含主表字段的布局规则和明细字段的布局规则
        ld.each(that.rulefieldname,function(index,fieldname){
                   var fieldinfo=popupobj.fieldname_fields[fieldname];
                   if(fieldinfo==undefined)
                   {
                    return true;
                   }
                  
                   if(fieldinfo.bigtype=='multipicklist')
                   {        
                        //多选框
                        ld("#"+popupobj.divid+" [name='"+fieldname+"[]']").on("select2:close", function (e){
                           that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                             that.reloadPopup();
                        })
                        
                        
                       ld("#"+popupobj.divid+" [name='"+fieldname+"[]']") .on("select2:unselecting", function(e) {
                        
                      
                                        setTimeout(function(){
                                            that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                                            ld("#"+popupobj.divid+" [name='"+fieldname+"[]']").select2("close");//BUG20240118-06 240118 ls 下拉框不会消失(选中后再反选)
                                             that.reloadPopup();
                                        },150)
                                            
                            });
                        
                   }
                    
                   else if(popupobj.module=="Potentials"&&fieldinfo.fieldname=='sales_stage')
                   {
                        //销售阶段
                     ld("#"+popupobj.divid+" [name="+fieldname+"]").bind('change',function(){
                            that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                            that.reloadPopup();
                        })
                   }
                   else if(fieldinfo.bigtype=='boolean'||(fieldinfo.uitype==56&&fieldinfo.savedatabase=='yes'))
                    {
                        ////edit:can 57849 （http://crm.airmaster.com.cn/crm）自定义表15，复选框引用字段，无法触发布局规则 --zxm20241011 改成点击事件才会触发
                     
                         ld("#"+popupobj.divid+" [name=sel_"+fieldname+"]").unbind("click").bind('click',function(){
                          that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                            that.reloadPopup();
                        })
                    }
                   
                   else if(fieldinfo.bigtype!='reference'&&(fieldinfo.bigtype!='picklist'))
                    {
                        //picklist:下拉框事件在cls_picklist调用reloadPopup函数（考虑有级联）
                        //选择单据无法获取事件，只能在赋值的时候调用reloadPopup函数
                        
                         ld("#"+popupobj.divid+" [name="+fieldname+"]").bind('change',function(){
                            that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                            that.reloadPopup();
                        })
                    }
                    
        });
    }
    this.setValues=function(values)
    {
        
        that.values=values;
        
    }
    this.CheckReLoadPopup=function()
    {
         if(that.rulefieldname==null||that.rulefieldname==undefined||(that.rulefieldname.length != undefined && that.rulefieldname.length<=0)){
        //没有布局规则
        return false;
       }
 
        var isreload='no';
        var popupobj=that.popupobj;
        that.reloadfieldname='';
        var fieldobj = '';
        var fieldinfoobj = new fieldinfo(popupobj);

        ld.each(that.rulefieldname,function(index,fieldanme){
            fieldobj =popupobj.fieldname_fields[fieldanme];
            if(fieldobj!=undefined&&fieldobj.displaytype==3)
            {
                if(fieldanme=='total'||fieldanme=='hdnGrandTotal')
                {
                    if(popupobj.before_totalvalue!=popupobj.now_totalvalue)
                    {
                        popupobj.before_totalvalue=popupobj.now_totalvalue;
                        
                          that.reloadPopup();
                    }
                }
                else
                    that.reloadPopup();
                return false;
            }
            
            else if(ld("#"+popupobj.divid+" [name="+fieldanme+"]").length<=0)
            {
                return true;
            }
            var pre_value = that.values[fieldanme];
            var post_value = ld("#"+popupobj.divid+" [name="+fieldanme+"]").val();
            //zkt 20240130 BUG20240125-44 创建销售合同时上传的附件保存后合同页面可以看到，但是在编辑合同上传新的附件保存后该合同的附件全部丢失了连新上传的附件没有了，合同显示附件都是空的（附带视频）
            // 单选用户字段 编辑解密后台获取到的columnfields_value值为0,但界面获取到的为''
            if((fieldobj.bigtype == 'selectoneuser' ||  fieldobj.bigtype == 'reference')){
                if(post_value == ''){
                    post_value = '0';
                }
                if(pre_value == '' || pre_value == null){
                    pre_value = '0';
                }
            }
            //数字类型的字段在判断验证规则时要转化成相同的小数位

            if(fieldinfoobj.isFldNumOrMoney(fieldobj)){
                if(!empty(fieldobj.typeofdata)){
                    var type_arr = fieldobj.typeofdata.split(',');
                    if(type_arr.length >1 && type_arr[1] >0){
                        pre_value = parseFloat(pre_value).toFixed(type_arr[1]);
                        post_value = parseFloat(post_value).toFixed(type_arr[1]);
                    }
                }
            }
            if( post_value!=pre_value)
           {
                if(pre_value==null&&post_value=='')
                {
                    
                }
                else
                {
                    that.reloadfieldname=fieldanme;
                    isreload='yes';
                }
           }
           that.values[fieldanme]=post_value;
        })
  
         if(isreload=='yes')
        {
            that.reloadPopup();
            return true;
        }
        else{
            return false;
        }
        
    }
      this.setDeskValues=function(){
         var popupobj=that.popupobj;
         
        ld.each(popupobj.fields,function(index,fieldinfo){
          
             if(ld("#"+popupobj.divid+" [name="+fieldinfo.fieldname+"]").length>0)
                  that.values[fieldinfo.fieldname]=ld("#"+popupobj.divid+" [name="+fieldinfo.fieldname+"]").val();
        });
    }
    
    this.reloadPopup=function()
    {
      
    //  return false;
    
    //等到合同订单等带明细的模块后，该处获取界面的url将来和ajax保存做通用代码
        var popupobj=that.popupobj;
        //duan 20241224 因为推进可能修改啊divid ,重置弹出层id,避免选择到其他对象
        if(!empty(popupobj.popupdivid)){
            popupobj.divid = popupobj.popupdivid;
        }
        var str="";
        var dataurl='aaaaaabbbb=1';
        var sensitiverequestfield_arr = [];
       ld.each(popupobj.fields,function(index,fieldinfo){
       
             var bigtype=fieldinfo.bigtype;
             var uitype=fieldinfo.uitype;
       
             //edit:can 2020-11-18 43327: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），客户服务单启用布局规则后，新建界面，选择客户（客户名称：客户创建时间提醒测试）带出定位地址，选择“处理状态”后，定位地址被清空（需要补丁）
             if(uitype==64)
             {
                return true;
             }
              var fieldname=fieldinfo.fieldname;
              var tmpfieldname=fieldname;
             
              if( SaveDataRecord.isfileattachUitype(fieldinfo.uitype))
              {
                  var tmpfileurl=SaveDataRecord.getFileAttachmenturl(fieldinfo,popupobj.divid);
                 
                  if(that.popupobj.filejsondata!=undefined&&that.popupobj.filejsondata[fieldinfo.columnname]!=undefined&&that.popupobj.filejsondata[fieldinfo.columnname].length>0)
                  {
                    //选择单据  有布局规则,该单据的引用字段有布局规则  ,会导致附件丢失
                     //  edit:can 20230721 69668 费用报销单，审批人编辑单据或者复制创建一条新单据，清空原先客户
                     var filenum=  getSearchString(fieldinfo.fieldname + "-file_num",tmpfileurl)
                     if(filenum==0||filenum==undefined)
                     {
                       tmpfileurl= SaveDataRecord.getFileAttachmenturlbyfileJsonData(that.popupobj,fieldinfo,popupobj.divid);
                     }
                    
                       
                      
                  }
                  dataurl+=tmpfileurl;
              }
              var tmpfieldvaue = '';
               if(bigtype=='multipicklist'&&popupobj.type!="detailviewpage")
               {
                 tmpfieldname+='[]';
               }
               if(bigtype=='picklistid')
               {
                    //下拉框id
                   // alert(ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").find("option:selected").text());
                   dataurl+="&"+fieldname+"_name="+ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").find("option:selected").text();
                    
               }
               if(bigtype=='selectsource')
               {
                   dataurl+="&selectsource="+ld("#"+popupobj.divid+" [name='selectsource']").val();
                 
                 if(popupobj.module=='PaymentPlan'||popupobj.module=='SendPayment')
                 {
                    //edit:can 20210205 044617: （http://www.xiaoshou360.com/xs/zezn [^]）上海智迩智能科技有限公司（张德广）；财务管理-付款计划-编辑，重新选择付款方式之后，源单信息会丢失。付款方式这个字段有一个布局规则
                     dataurl+="&salesorder_name="+ld("#"+popupobj.divid+" [name='salesorder_name']").val();
                   // str+="&salesorder_id="+ld("#"+popupobj.divid+" [name='salesorder_id']").val();
                // str+="&selectlistval="+ld("#"+popupobj.divid+" [name='entitytypeid']").val(); 
                  // str+="&selectlistval_name="+ld("#"+popupobj.divid+" [name='salesorder_name']").val();
                 }
                 else
                 {
                    //edit:can 20220908 （http://42.193.125.39:85/crm）自定义表18，当选择某个字段时，其他字段数值全部变成空白 
                     dataurl+="&selectlistval_name="+encodeURIComponent(ld("#"+popupobj.divid+" [name='selectlistval_label']").val());
                 }
                  if(popupobj.module=="SalesOrder" && uitype == 208){

                      dataurl+="&selectlistval="+ld("#"+popupobj.divid+" [name='quote_id']").val();
                  }
                  else
                  {
                      dataurl+="&"+fieldname+"="+ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").val();
                  }
                  return true;
               }
               else if(bigtype=='users'){
                   dataurl+="&"+fieldname+"="+ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").val();
               }
               else if(uitype==156){//是否是管理员
                   //BUG20241212-11 ls 241213 成员管理编辑系统管理员，删除职位级别后，是否管理员字段更新为否了(布局规则)
                   if(ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").attr('type') == 'hidden'){
                       tmpfieldvaue=ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").val();
                   }
                   else if (ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").attr('type') == 'checkbox') {
                       if (ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").prop("checked")) {
                           tmpfieldvaue="on";
                       }else{
                           tmpfieldvaue="off";
                       }
                   }

                   dataurl+="&"+fieldname+"="+tmpfieldvaue;
                    return true;
               }
               else if(bigtype=='boolean')
               {
               
                if(ld("#"+popupobj.divid+" [name=sel_"+tmpfieldname+"]").prop("checked"))
                    tmpfieldvaue="1";
                else
                    tmpfieldvaue="0";
                 if(fieldinfo.displaytype==2&&popupobj.columnfields_value[fieldname]!=undefined)
                   {
                       //客戶，新增公海未分配
                       console.log(fieldname+":"+popupobj.columnfields_value[fieldname]);

                       tmpfieldvaue=popupobj.columnfields_value[fieldname];
                   }
                   dataurl+="&"+fieldname+"="+tmpfieldvaue;
                 return true;
               }
               
               if(fieldinfo.displaytype==3)
               {
                     if(tmpfieldname=='currency_id')
                    {
                        if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                            tmpfieldvaue = fieldinfo.sensitiveencryptvalue;
                            sensitiverequestfield_arr.push(fieldinfo.fieldname);
                        }
                        else{
                            tmpfieldvaue = ld("#"+popupobj.divid+" [name=inventory_currency]").val();
                        }
                        dataurl+="&"+fieldname+"="+encodeURIComponent(tmpfieldvaue);
                    }
                    
                    else if(tmpfieldname=='hdnGrandTotal')
                    {
                        if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                            tmpfieldvaue = fieldinfo.sensitiveencryptvalue;
                            sensitiverequestfield_arr.push(fieldinfo.fieldname);
                        }
                        else{
                            tmpfieldvaue = ld("#"+popupobj.divid+" [name=grandTotal]").val();
                        }
                        dataurl+="&"+fieldname+"="+encodeURIComponent(tmpfieldvaue);
                    }
                    else{
                         if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                             tmpfieldvaue = fieldinfo.sensitiveencryptvalue;
                             sensitiverequestfield_arr.push(fieldinfo.fieldname);
                         }
                         else{
                             tmpfieldvaue = ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").val();
                         }
                         dataurl+="&"+fieldname+"="+encodeURIComponent(tmpfieldvaue);
                    }
                    return true;
               }
              else if(ld("#"+popupobj.divid+" [name='"+tmpfieldname+"']").length<=0)
                {
                    //zkt 20220523 51963销售商机模块，编辑已审批后的【商机状态】选择对应的值后，【报备状态】的内容被清空。单据编号：LS20220421-70 。
                    //多选框字段不可编辑时，通过以下方式获取值
                    if(bigtype=='multipicklist')
                   {
                       var strtmp = CrmPopup.getHtmlobjval(popupobj.divid, fieldname);
                       str+="&"+fieldname+"="+encodeURIComponent(strtmp);
                   }
                    
                    return true;
                }
              if(ld("#"+popupobj.divid+" [name='"+tmpfieldname+"']").length>0)
              {
                  if(bigtype=='multipicklist')
                  {
                      dataurl+="&"+fieldname+"="+encodeURIComponent(getMultiPickListSelectValue(tmpfieldname));
                      return true;
                  }


              }

               
              if(fieldinfo.uitype==230 || fieldinfo.uitype==231)
              {
                  if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                      tmpfieldvaue = fieldinfo.sensitiveencryptvalue;
                      sensitiverequestfield_arr.push(fieldinfo.fieldname);
                  }
                  else{
                      tmpfieldvaue = ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").val();
                  }
                  dataurl+="&"+fieldname+"="+encodeURIComponent(tmpfieldvaue);
              }else if (fieldinfo.uitype == 34) {
                  //edit:duan date:2024/10/24 reason:用户模块的职位级别字段特殊处理
                  tmpfieldvaue = CrmPopup.getHtmlobjval(popupobj.divid, fieldname);
                  dataurl += "&" + fieldname + "=" + encodeURIComponent(tmpfieldvaue);

                  var json_value = CrmPopup.getHtmlobjval(popupobj.divid, 'jsonvalue_'+fieldname);
                  dataurl += "&jsonvalue_" + fieldname + "=" + encodeURIComponent(json_value);
              }
               
              else{
                  if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                      tmpfieldvaue = fieldinfo.sensitiveencryptvalue;
                      sensitiverequestfield_arr.push(fieldinfo.fieldname);
                  }
                  else{
                      tmpfieldvaue = ld("#"+popupobj.divid+" [name="+tmpfieldname+"]").val();
                  }
                  dataurl+="&"+fieldname+"="+encodeURIComponent(tmpfieldvaue);
              }
              if(bigtype=='reference')
              {
                    if(fieldinfo.allowedit=='no'){
                        dataurl+="&"+fieldname+"_name="+encodeURIComponent(ld("#"+popupobj.divid+" [name=span_"+tmpfieldname+"]").html());
                    }
                    else{
						if(ld("#"+popupobj.divid+" [name="+tmpfieldname+"_name]").val() != undefined){
                            dataurl+="&"+fieldname+"_name="+encodeURIComponent(ld("#"+popupobj.divid+" [name="+tmpfieldname+"_name]").val());
						}
					 }
              }
              
       })
       //zkt 20231227 BUG0077838 kfbcrm-敏感规则字段参与的布局规则会报-100的错误
       str+="&sensitiverequestfield="+JSON.stringify(sensitiverequestfield_arr);
       var module=popupobj.module;
       //根据弹出层类型传输对应的disp_view
       if(popupobj.type=="createpage"){
            str += '&showpageruledisp_view=create_view';
       }
       else if(popupobj.type=="pagerecord"){
            str += '&showpageruledisp_view=edit_view';
       }
       else if(popupobj.type=="detailviewpage"){
            str += '&showpageruledisp_view=detail_view';
       }
     
       if(popupobj.type=="detailviewpage")
       {
            var url='index.php?module='+module+'&action='+module+'Ajax&file=showdetailPageByRule'+str;
       }
       else
            var url='index.php?module='+module+'&action='+module+'Ajax&file=showPageByRule'+str;
       url+="&record="+popupobj.record;
       var reloaddetailfield='no';
     //  console.log(popupobj.detailfieldrulefieldnames);
     //  console.log(that.reloadfieldname);
    
        if(popupobj.detailfieldrulefieldnames!=undefined&&ld.inArray(that.reloadfieldname,popupobj.detailfieldrulefieldnames)>=0){
            url+="&detailfieldrule=yes";
            reloaddetailfield='yes';
        }
      // console.log(reloaddetailfield);
       if(popupobj.module=='CashBill')
            url+="&cashbilltype="+popupobj.cashbilltype;

        //ls 2022-06-24 BUG0053136 机械使用单 这个单据进去"入库分类"这个字段是可以编辑的，这个字段是系统原本的功能是不可以编辑的(布局规则启用会影响)
        if (typeof linkmodulecustom != "undefined"&& popupobj != undefined && popupobj != 'undefined' && popupobj.type != undefined && popupobj.type != 'undefined' && popupobj.type !='relatelistpage') {
            url += '&is_linkmodulecustom='+linkmodulecustom;
            //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
            //获取链接模块viewname
            var page_addurl = getSearchString('page_addurl',location.href);
            if(page_addurl != undefined){
                var linkmodule_viewname = getSearchString('viewname',page_addurl);
                if(linkmodule_viewname != undefined){
                    url +='&linkmodule_viewname='+linkmodule_viewname;
                }
            }
        }
        ldAjaxNoProgresssync(url,dataurl,function(data)
        {

            // 朗捷 客服下单->报关单草单->报关类型与单据分录的特殊控制
            if(CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() == 'langjie' && module =='CustomForm22'){
                HideDetail()
            }
            //39052: 海格->报价单->设置了页面布局:报价单类型=特价报价单时，必须录入“特价申请单编号”，但是选择其他类型报价单也提示必须录入
            PageRecordPopupobj=popupobj;

            ld("#"+popupobj.divid+" [name=displayfields]").html(data.result.content);
            popupobj.fields=data.result.fields;
            if(popupobj.type!="detailviewpage")//edit:can 20230908 72372 项目信息（客户模块）设置了布局规则，“项目阶段”字段变更为中标项目时，附件字段“附件(中标通知或其他附件等)”变为必填，大编辑状态下没问题，
                popupobj.filejsondata=data.result.filejsondata;
            popupobj.columnfields_value=data.result.columnfields_value;
            popupobj.fieldname_fields=[];


            for(var i=0;i<popupobj.fields.length;i++)
            {
                var fieldname=popupobj.fields[i].fieldname;
                var columnname=popupobj.fields[i].columnname;
                popupobj.uitypes[fieldname]=popupobj.fields[i].uitype;
                popupobj.fieldname_fields[fieldname]=popupobj.fields[i];
            }
            //wym XUQIU1002285 新增编辑页,触发布局规则后,需要更新左侧区块定位栏;区块上的事件绑定在InitPageValue中
            if(popupobj.type=="createpage" || popupobj.type=="pagerecord"){
                popupobj.updateBlocklist();
            }
            popupobj.InitPageValue();

            if(popupobj.type=="createpage" || popupobj.type=="pagerecord"){
                popupobj.setRelatedFieldEvent();
            }

            //zkt 20230423 mainfieldformulaobj中使用了fieldname_fields 所以要先赋值 BUG0065360
            //ls 20220712 BUG0053832(http://42.193.125.39:85/crm）材料采购合同新建无法保存(/被布局规则隐藏的字段参与计算公式计算需要重新初始化)
            popupobj.mainfieldformulaobj.init();
            popupobj.mainfieldformulaobj.CreatePageComputer();
            popupobj.mainfieldformulaobj.setEvent();

            that.reloaddetailfield=reloaddetailfield;
            if(reloaddetailfield=='yes'){
                //重新显示/隐藏分录字段
                popupobj.detaildisplaycolumns=data.result.detailfieldruleinfo.displaycolumns;
                popupobj.detailhidecolumns=data.result.detailfieldruleinfo.hidecolumns;
                popupobj.detailfields=data.result.detailfields;
                that.resetDetailColumns();

            }
            that.reloaddetailfield='no';
            if(popupobj.type=="detailviewpage")
            {
                //查看界面
                if(itsonview==false)
                    return false;
                itsonview=false;
                //globalfieldlabel:是fieldname

                hndMouseOver(popupobj.globaluitype,popupobj.globalfieldlabel);
                show('crmspanid');
                handleEdit();
            }
            else if(popupobj.type=='pagerecord'||popupobj.type=='createpage')
            {
                //弹出层编辑和新增
                var obj=ld("#"+popupobj.divid);
                CrmPopup.center(obj,popupobj);
                var mode='create';
                if(popupobj.type=='pagerecord')
                    mode='edit';
                //edit:can 42347: （http://39.108.96.128/crm/ [^]）徐燕男客户问题（东莞市优速网络科技有限公司）项目管理模块（项目立项）>新建单据界面：选择源单“SO20”，没有带出“域名”，“域名备案”等引用字段信息（在合同相关创建项目可以直接带出）
                var restobjs=popupobj.fieldrulevalues;
                if(popupobj.detailfieldmodule=='Products')
                    popupobj.selectproductobj.setHtmlObj();
                getJsScript('include/js/relatedfield.js',function(){

                    if(restobjs!=undefined)
                    {

                        setRelateValue(restobjs,'','popupselectfield',popupobj.module,mode);
                    }
                    popupobj.fieldrulevalues=[];
                });

                var tableobj=popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
                if(data.result.subtotaltr!=undefined)
                    ld(tableobj).find("[name=detail_subtotal_row]").replaceWith(data.result.subtotaltr);
                //edit:can 43327: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），客户服务单启用布局规则后，新建界面，选择客户（客户名称：客户创建时间提醒测试）带出定位地址，选择“处理状态”后，定位地址被清空（需要补丁）
                if(ld("#"+popupobj.divid+" #locationaddress").length>0){
                    getLocationAddress('locationaddress','edit');
                }
                //chj 2021/6/22 46486: （81mis.com/kfbcrm）自定义表单02，通过设置的布局规则，触发“整行文本区域类型”字段显示后，字段变窄了
                ld('textarea').not('.proName_note').autosize();//textarea根据内容自动调整大小
                popupobj.mainfieldformulaobj.setEvent();
                //edit:can 20230105  60522 http://218.28.182.50:9031/crm/，销售管理——订单，新建 选择原单关联合同，中间一直转圈，报错
                if(!empty(popupobj.detail2mainformulaobj)){//BUG0076633 ls 20231205 模块CardApply的链接模块新建两条单据，第二条保存没反应
                    popupobj.detail2mainformulaobj.init();

                    popupobj.detail2mainformulaobj.setEvent();
                }

            }

            //郎捷：单据头->合同编号：当“服务项目”选择“报关订单/运输订单/空运订单”时，控制“客户合同编号/供应商合同编号”字段不可编辑；当“服务项目”选择“仓储订单”时允许选择“客户合同编号/供应商合同编号
            //if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie' && module == 'CustomForm18'){
            //showReferenceModuleFieldBtn();
            //}
        });
        
    }
    this.resetDetailColumns=function(){
                     var popupobj=that.popupobj;
                    var hidecolumns= popupobj.detailhidecolumns;
                    var displaycolumns= popupobj.detaildisplaycolumns;
                    
                     var tableobj=popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
                     var tablewidth=ld(tableobj).attr("tablewidth");
                     
                     if(tablewidth==undefined||tablewidth=="undefined"||tablewidth<=10)
                     {
                        //收款单，付款单
                        return ;
                     }

                    
                     var subtotaltrobj=ld(tableobj).find("[name=detail_subtotal_row]");//小计
                     that.setTrContent();
                     that.setDetailHead();


                      if(displaycolumns!=undefined&&hidecolumns==undefined){
                         return ;
                    }

                     var tdobjs=ld(tableobj).find("tr[tag=trhead]").find("td");
                     tablewidth=0;
                      var head_tool_width=0;
                     ld.each(ld(tdobjs),function(){
                        
                        if(ld(this).css('display')!='none'&& ld(this).attr("head_width")!=undefined){
                            tablewidth+=parseInt(ld(this).attr("head_width"));
                            if(ld(this).attr("head_tool")=='yes'){
                                head_tool_width+=parseInt(ld(this).attr("head_width"));
                            }
                        }
                     })
                 
            
                     ld(tableobj).css("width",tablewidth+"mm");
                      ld("#"+popupobj.divid+" [name=table_width]").val(tablewidth-head_tool_width);
                     setProductDivWidth(popupobj);//设置列宽
                     var trobjs=popupobj.getTrObjsByDelType("no");
                     var rowcnt=ld(trobjs).length;//CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val();
                    if(popupobj.detaildatavalue_arr != undefined && popupobj.detaildatavalue_arr.length ==0){
                        return '';
                    }
                     var isfirst='yes';
                    ////BUG20240618-12 费用报销单新建，报销类型选择其他，分录错行
        if(that.reloaddetailfield=='yes')  //新增行业调用了概函数,所以添加该判断
        {
            getJsScript('include/js/freezeEntriesColumns.js', function () {
                var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj, 'proTab');
                freezeEntriesColumnsobj.freezeTheadAndBody();
            });
        }
                    //20231010 hzx XUQIU1001801 页面设置，分录字段布局界面优化
                   /*if(that.reloaddetailfield=='yes')  //新增行业调用了概函数,所以添加该判断
                   {
                            //触发布局规则的字段值改变，则清空分录
                             //for(var tmpi=1;tmpi<=rowcnt;tmpi++){
                             ld.each(trobjs,function(){
                                //if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+tmpi+"]").val()==0){
                                    var tmpi=ld(this).attr("rowindex");

                                    if(isfirst=='yes'){
                                        if(popupobj.detailfieldmodule=="Products")
                                           fun_selectproduct.btn_clearProductInfo_Row(tmpi)
                                    }
                                    else{
                                            //popupobj.detaildatavalue_arr.splice(1,1);
                                            //edit:can  20230302 622111 61order 合同订单新建点取消点不动，可以找路总还原bug
                                         deleteRow(2);
                                    }
                                    isfirst='no';
                                //}

                             })

                       getJsScript('include/js/freezeEntriesColumns.js', function () {
                           var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj,'proTab');
                           freezeEntriesColumnsobj.freezeTheadAndBody();
                       });
                           //   freezecolumnsObj.init('proTab');//冻结列类初始化
                           //  freezecolumnsObj.freezeThColumn('set-sticky');

                    }*/
                    
        
    }
    this.setDetailHead=function()
    {
        var tablewidth;
        var hidecolumns=that.popupobj.detailhidecolumns;
        var displaycolumns=that.popupobj.detaildisplaycolumns;
        if(hidecolumns == undefined) hidecolumns = [];
        if(displaycolumns == undefined) displaycolumns = [];
         var tableobj=that.popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
         ld.each(hidecolumns,function(tmpindex,tmpcolumn){
                var head_detailfieldnameobj=ld(tableobj).find("[head_detailfieldname="+tmpcolumn+"]");
                if(head_detailfieldnameobj.length>1)
                {
                    //原单
                    ld.each(ld(head_detailfieldnameobj),function(){
                        
                        tablewidth=parseInt(tablewidth)-parseInt(ld(this).attr("head_width"));
                    })
                    
                }
                else
                    tablewidth=parseInt(tablewidth)-parseInt(ld(head_detailfieldnameobj).attr("head_width"));
                ld(head_detailfieldnameobj).css("display",'none');
                
                ld(tableobj).find("td[detailfieldname="+tmpcolumn+"]").css('display','none');
         });
         
         
         ld.each(displaycolumns,function(tmpindex,tmpcolumn){
                            var head_detailfieldnameobj=ld(tableobj).find("[head_detailfieldname="+tmpcolumn+"]");
                            if(head_detailfieldnameobj.length>1)
                            {
                                //原单
                                ld.each(ld(head_detailfieldnameobj),function(){
                                    
                                    tablewidth=parseInt(tablewidth)+parseInt(ld(this).attr("head_width"));
                                })
                                
                            }
                            else
                                tablewidth=parseInt(tablewidth)+parseInt(ld(head_detailfieldnameobj).attr("head_width"));
                            ld(head_detailfieldnameobj).css("display",'');
                            ld(tableobj).find("td[detailfieldname="+tmpcolumn+"]").css('display','');
                             
                            
         });
         
         
         
          ld.each(popupobj.detailfields,function(tmpindex,tmpfieldinfo){
              var columnname=tmpfieldinfo['columnname'];
              var requiredclass="td_required_"+columnname;
               var  theadobj=ld(tableobj).find("tr[tag=trhead]").find("td[head_detailfieldname="+columnname+"]") ;
               var fontobj=ld(theadobj).find("font");
            
              if(tmpfieldinfo['typeofdata'].indexOf("~M")>0)
              {
                    if(ld(fontobj).length>0)
                    {
                        ld(fontobj).css("display",'');
                    }
                    else{
                       ld(theadobj).html("<font color='red'>*</font>"+ld(theadobj).html());
                    }
              }
              else{
                 if(ld(fontobj).length>0)
                 {
                    ld(fontobj).css("display",'none');
                 }
              }
         })
        
    }
    this.setTrContent=function()
    {
        
        var hidecolumns=that.popupobj.detailhidecolumns;
        var displaycolumns=that.popupobj.detaildisplaycolumns;
         var tableobj=that.popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
         if(hidecolumns!=undefined&&hidecolumns.length>0&&hidecolumns[0]!='')
             {
                 
                    ld.each(hidecolumns,function(tmpindex,tmpcolumn){

                    ld(tableobj).find('td[detailfieldname='+tmpcolumn+']').css('display','none');
                    //ld(tableobj).find("#"+tmpcolumn).css('display','none');
                    //ld(tableobj).find("#span_"+tmpcolumn).css('display','none');
                 });
                
            }
                     
                    
            
            if(displaycolumns!=undefined&&displaycolumns.length>0&&displaycolumns[0]!='')
            {
               
               
                ld.each(displaycolumns,function(tmpindex,tmpcolumn){
                    ld(tableobj).find('td[detailfieldname='+tmpcolumn+']').css('display','');
                    //wym BUG0075406 含有可搜索下拉框的td需要隐藏select
                    if(ld(tableobj).find("#"+tmpcolumn).length>0&&ld(tableobj).find("#"+tmpcolumn).prop("tagName").toLowerCase() == 'select'&&ld(tableobj).find('div[name=dv_chzn_'+tmpcolumn+']')){
                        ld(tableobj).find("#"+tmpcolumn).css('display','none');
                    }
                    //ld(tableobj).find("#"+tmpcolumn).css('display','');
                  //  ld(tableobj).find("#span_"+tmpcolumn).css('display','');
                    
                });
                
                
            }
    }
}
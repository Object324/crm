function cls_PageValidata(){
    
    var popupobj=CrmPopup.getPopupObj('last');
    var frommodule=popupobj.frommodule;
    var that=this;
    this.tableobj;
    this.listid='dv_pagevalidata';//div的id 
    this.getList=function(){
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=getPageValidataList&frommodule="+frommodule,{},function(ajaxdata){
            ld("#"+that.listid).css("display",'');
            ld("#"+that.listid).html(ajaxdata.result.content);
            tooltip('.tip-items-lists', {transition: true, time: 200});
            that.tableobj=ld("#"+that.listid+" [name=table_pagevalidata]");
            DelProgressObjs();
            that.setListEvent();
        })
    }
    
    this.setListEvent=function(){
        //列表界面按钮事件
        ld('a[name=btn_add]').unbind('click').bind('click',function(){
                //新增
                that.operateData(0);
        
        });
        ld(that.tableobj).find(" [name=btn_edit]").unbind("click").bind("click",function(){
            //编辑
            var trobj=ld(this).parent();
            while(ld(trobj).prop("tagName").toLowerCase()!='tr')
            {
                trobj=ld(trobj).parent();
            }
             that.operateData(ld(trobj).attr("tagid"));
        })
        ld(that.tableobj).find(" [name=btn_del]").unbind("click").bind("click",function(){
            //删除
            var trobj=ld(this).parent();
            var alert_str = arrJsPopLabel['SUREWANTDELETE'];
            RemindsMsg("","LdPopWidth400px","LinkModuleCustom","yes","yes",alert_str);
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                while(ld(trobj).prop("tagName").toLowerCase()!='tr')
                {
                    trobj=ld(trobj).parent();
                }
                that.del(ld(trobj).attr("tagid"));
            });
            
        })
        ld(that.tableobj).find(" [name=btn_up]").unbind("click").bind("click",function(){
            //上移
            var trobj=ld(this).parent();
            while(ld(trobj).prop("tagName").toLowerCase()!='tr')
            {
                trobj=ld(trobj).parent();
            }
            that.move(ld(trobj).attr("tagid"),'up');
            
        })
        
        ld(that.tableobj).find(" [name=btn_down]").unbind("click").bind("click",function(){
            //下移
            var trobj=ld(this).parent();
            while(ld(trobj).prop("tagName").toLowerCase()!='tr')
            {
                trobj=ld(trobj).parent();
            }
            that.move(ld(trobj).attr("tagid"),'down');
        })
        
    }

    that.get_editurl = function (id) {
        var url = "index.php?module=Settings&action=SettingsAjax&file=PageValidataPopup&id="+id+"&frommodule="+frommodule;
        return url;
    };

    that.operateData=function(id){
        //新增/编辑
        var url = this.get_editurl(id);

        ldAjax(url,{},function(ajaxdata){
            
            var popupobj=CrmPopup.load(ajaxdata.result.title,that.save,"",'1000','Settings','',ajaxdata.result.oktext,'',ajaxdata.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,ajaxdata.result.content);
            
            popupobj.fields=ajaxdata.result.fields;
            popupobj.detailfields=ajaxdata.result.detailfields;
            popupobj.record=id;
            popupobj.frommodule=frommodule;
            popupobj.function_arr=ajaxdata.result.function_arr;//函数
            popupobj.nonelabel=ajaxdata.result.nonelabel;
            popupobj.sqllabel=ajaxdata.result.SQL;
            popupobj.groupbylabel=ajaxdata.result.groupbylabel;
            popupobj.funtype=ajaxdata.result.funtype;
            popupobj.detailfuntype=ajaxdata.result.detailfuntype;
            popupobj.selecttype_arr = ajaxdata.result.selecttype_arr;
            popupobj.comparatortype_arr = ajaxdata.result.comparatortype_arr;
            
            ld("#"+popupobj.divid+" [name=relatedtable]").val(ajaxdata.result.relatedtable);
            
            popupobj.filterobj = cls_validatacondition.getInstance();
            if(ajaxdata.result.relatedtable == 'ld_field'){
                popupobj.filterobj.field_arr = popupobj.fields;
            }else{
                popupobj.filterobj.field_arr = popupobj.detailfields;
            }
            
            //that.changefields(ld("#"+popupobj.divid+' [name=relatedtable]'));
            ld("#"+popupobj.divid+' [name=relatedtable]').unbind("change").bind("change",function(){
                popupobj.filterobj.clear();
                if(ld(this).val() == 'ld_field'){
                    popupobj.filterobj.field_arr = popupobj.fields;
                }else{
                    popupobj.filterobj.field_arr = popupobj.detailfields;
                }
                popupobj.filterobj.New_addNewConditionGroup();
            })
            if(id>0)
            {
                var advft_criteria = ajaxdata.result.advft_criteria;
                var advft_criteria_groups = ajaxdata.result.advft_criteria_groups;
                popupobj.filterobj.InitAdvftValue(advft_criteria,advft_criteria_groups);
                /*
                if(ajaxdata.result.funtype=='')
                    ld("#"+popupobj.divid+' [name=selectfield]').val(ajaxdata.result.selectfield);
                ld("#"+popupobj.divid+' [name=comparatortype]').val(ajaxdata.result.comparatortype);
                if(ajaxdata.result.detailfuntype=='')
                    ld("#"+popupobj.divid+' [name=comparefield]').val(ajaxdata.result.comparefield);
                */
            }else{
                popupobj.filterobj.New_addNewConditionGroup();
            }
            popupobj.filterobj.checksqlwildcardshow();
            ld("#"+popupobj.divid+' [name=tipzhtype],[name=tipentype]').bind('change',function(){
                popupobj.filterobj.checksqlwildcardshow();
            })

            ld("#showsqlwildcard").bind('click',function(){
                that.ShowDescrition(this);
            })
            
            
            
            popupobj.center();
        })
    }
    this.changefields=function(jqueryobj){
        
        var popupobj=CrmPopup.getPopupObj('last');
        
        //单据头，单据分录
        var selectfieldobj=ld('#'+popupobj.divid+' [name=selectfield]');//选择字段
        var comparefieldobj=ld("#"+popupobj.divid+' [name=comparefield]');//比较字段
        if(ld(jqueryobj).val()=='ld_field')
        {
            if(popupobj.funtype=='')
            {
                selectfieldobj.empty();
                selectfieldobj.append("<option value=''>"+popupobj.nonelabel+'</option>');
                
                ld.each(popupobj.fields,function(tmpindex,fieldinfo){
                    selectfieldobj.append("<option value='"+fieldinfo.fieldName+"'>"+fieldinfo.fieldLableKey+'</option>');
                })
            }
            if(popupobj.detailfuntype=='')
            {
                comparefieldobj.empty();
                comparefieldobj.append("<option value=''>"+popupobj.nonelabel+'</option>');
                ld.each(popupobj.fields,function(tmpindex,fieldinfo){
                    comparefieldobj.append("<option value='"+fieldinfo.fieldName+"'>"+fieldinfo.fieldLableKey+'</option>');
                })
            }
            
        }
        else{
            if(popupobj.funtype=='')
            {
                selectfieldobj.empty();
                selectfieldobj.append("<option value=''>"+popupobj.nonelabel+'</option>');
                
                ld.each(popupobj.detailfields,function(tmpindex,fieldinfo){
                    selectfieldobj.append("<option value='"+fieldinfo.columnName+"'>"+fieldinfo.fieldLableKey+'</option>');
                })
            }
            if(popupobj.detailfuntype=='')
            {
                comparefieldobj.empty();
                comparefieldobj.append("<option value=''>"+popupobj.nonelabel+'</option>');
                ld.each(popupobj.detailfields,function(tmpindex,fieldinfo){
                    comparefieldobj.append("<option value='"+fieldinfo.columnName+"'>"+fieldinfo.fieldLableKey+'</option>');
                })
            }
            
        }
        
        
        
    }
    
    this.del=function(id){
        //删除
         ldAjax("index.php?module=Settings&action=SettingsAjax&file=PageValidataDel&id="+id,{},function(ajaxdata){
            
            DelProgressObjs();
            that.getList();
         })
    }
    this.move=function(id,movetype){
        //移动
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=PageValidataOrderSave&id="+id+"&movetype="+movetype+"&frommodule="+frommodule,{},function(ajaxdata){
            
            DelProgressObjs();
            that.getList();
        })
        
    }
    this.save=function(){
        //保存
        var popupobj=CrmPopup.getPopupObj('last');
        var rulename=ld.trim(ld("#"+popupobj.divid+" [name=rulename]").val());//移动
        var relatedtable=ld("#"+popupobj.divid+" [name=relatedtable]").val();//验证区域
        // var status=ld("#"+popupobj.divid+" [name=status]").val();//状态
        var status=ld("#"+popupobj.divid).find("[name=status]").is(':checked')?'active':'inactive';
        var validataapplication='';
        var validataapplication_arr=new Array();
        var application_arr = new Array('create','edit','delete','submit','cancel','finish','advance_self');
        var i = 0;
        var tmp_label = '';
        for(i=0;i<application_arr.length;i++){
            tmp_label = application_arr[i];
            if(ld("#"+popupobj.divid+' #'+tmp_label).prop("checked")){
                validataapplication_arr.push(tmp_label);
            }
        }
        var len = validataapplication_arr.length;
        if(len > 0){
            validataapplication = validataapplication_arr.join(',');
        }
        
        //是否允许保存
        if(ld("#"+popupobj.divid+' [name=actionprevent]').prop('checked')){
            var actionprevent='yes';
        }else{
            var actionprevent='no';
        }
        
        var tipzhtype=ld.trim(ld("#"+popupobj.divid+' [name=tipzhtype]').val());
        var tipentype=ld.trim(ld("#"+popupobj.divid+' [name=tipentype]').val());
        
        var tipzh=ld.trim(ld("#"+popupobj.divid+' [name=tipzh]').val());
        var tipen=ld.trim(ld("#"+popupobj.divid+' [name=tipen]').val());

        var effectivemethod = ld("#"+popupobj.divid+" [name=effectivemethod]").val();
        /*
        var selectfield=ld("#"+popupobj.divid+' [name=selectfield]').val();
        var comparatortype=ld("#"+popupobj.divid+' [name=comparatortype]').val();
        var comparefield=ld("#"+popupobj.divid+' [name=comparefield]').val();
        */
        
        var params={'id':popupobj.record, 'frommodule':frommodule,'status':status,'validataapplication':validataapplication,'actionprevent':actionprevent,'tipzh':(tipzh),'tipen':(tipen),'tipzhtype':(tipzhtype),'tipentype':(tipentype),'effectivemethod':effectivemethod};
        
        if(popupobj.valiadvancefilterobj.New_checkAdvancedFilter()){
            params['advft_criteria'] = popupobj.advft_criteria;
            params['advft_criteria_groups'] = popupobj.advft_criteria_groups;
        }else{
            return false;
        }
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=PageValidataSave&rulename="+encodeURIComponent(rulename)+"&relatedtable="+relatedtable,params,function(ajaxdata){
            
            DelProgressObjs();
            if(ajaxdata.code==-1)
            {
                RemindsMsg("",400,frommodule,"","",ajaxdata.msg);
                return ;
            }else if(ajaxdata.code==-2){
                var dividname = ajaxdata.result.divname;
                audioRemindsMsg("",400,frommodule,"","",ajaxdata.msg);
                ld("#"+popupobj.divid+' [name='+dividname+']').addClass('border_red1');
                ld("#"+popupobj.divid+' [name='+dividname+']').bind('mouseover',function(){
                    ld(this).removeClass('border_red1');
                });
            }else{
                popupobj.CancelEvent();
                that.after_save(ajaxdata);
            }
            
        })
    }
    
    this.ShowDescrition = function(obj){
        var status = ld(obj).data('status');
        var childid = ld(obj).data('childid');
        if(status == 'hidden'){
            ld("#"+childid).show();
            ld(obj).data('status','show');
        }else{
            ld("#"+childid).hide();
            ld(obj).data('status','hidden');
        }
        //展开后将滚动条滚动到底部，方便查看
        var popupobj=CrmPopup.getPopupObj('last');
        var scrollobj = ld('#'+popupobj.divid+'_scroll').get(0);
        scrollobj.scrollTop = scrollobj.scrollTopMax;
        popupobj.center();
    }

    this.after_save = function(ajaxdata){
        this.getList();
    }
    
}

cls_PageValidata.getInstance=function(){
    if(cls_PageValidata.pagevalidataobj==undefined){
        cls_PageValidata.pagevalidataobj=new cls_PageValidata();
        
    }
    return cls_PageValidata.pagevalidataobj;
}
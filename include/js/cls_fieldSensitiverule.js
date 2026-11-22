function cls_fieldSensitiverule(popupobj,relatedfields)
{
    //布局规则
    var that=this;
    that.popupobj=popupobj;
    this.relatedfields=relatedfields;
    this.senditivefieldname_arr = [];//敏感规则字段
    this.relatedfieldname_arr = [];//会触发敏感规则
    this.fieldinfobyfieldname = {};//字段fieldinfo信息
    this.fieldinfobycolumnanme = {};//字段fieldinfo信息
    this.init=function()
    {
        var popupobj = this.popupobj;
        var relatedfields = this.relatedfields;
        var senditivefieldname_arr = [];
        var relatedfieldname_arr = [];
        if(relatedfields != undefined && relatedfields !=null)
        {
            ld.each(relatedfields,function(fieldname,relatedfieldarr){
                if(senditivefieldname_arr.indexOf(fieldname)<0){
                    senditivefieldname_arr.push(fieldname);
                }
                if(relatedfieldarr != undefined && relatedfieldarr != null &&relatedfieldarr.length>0){
                    ld.each(relatedfieldarr,function(tmpindex,relatedfieldname){
                        if(relatedfieldname_arr.indexOf(relatedfieldname)<0){
                            relatedfieldname_arr.push(relatedfieldname);
                        }
                    });
                }
            });
        }
        this.senditivefieldname_arr = senditivefieldname_arr;//敏感规则字段
        this.relatedfieldname_arr = relatedfieldname_arr;//会触发敏感规则
    }

    this.setEvent=function()
    {
        if(that.relatedfields==null||that.relatedfields==undefined){
            //没有敏感规则
            return false;
        }
        this.init();
        var popupobj=that.popupobj;
        var senditivefieldname_arr = this.senditivefieldname_arr;//敏感规则字段
        var relatedfieldname_arr = this.relatedfieldname_arr;//会触发敏感规则

        var fields = popupobj.fields;
        ld.each(fields,function(tmpindex,fieldinfo){
            if(fieldinfo==undefined)
            {
                return true;
            }
            var fieldname = fieldinfo.fieldname;

            that.fieldinfobyfieldname[fieldname] = fieldinfo;
            if(senditivefieldname_arr.indexOf(fieldname)<0&&relatedfieldname_arr.indexOf(fieldname)<0)
            {
                return true;
            }
            if(fieldinfo.bigtype=='multipicklist')
            {
                //多选框
                ld("#"+popupobj.divid+" [name='"+fieldname+"[]']").on("select2:close", function (e){
                    that.fieldnamechangeFun(fieldname);
                })
            }
            else if(popupobj.module=="Potentials"&&fieldinfo.fieldname=='sales_stage')
            {
                //销售阶段
                ld("#"+popupobj.divid+" [name="+fieldname+"]").bind('change',function(){
                    that.fieldnamechangeFun(fieldname);
                })
            }
            else if(fieldinfo.bigtype=='boolean'||(fieldinfo.uitype==56&&fieldinfo.savedatabase=='yes'))
            {
                ld("#"+popupobj.divid+" [name=sel_"+fieldname+"]").unbind("change").bind('change',function(){
                    that.fieldnamechangeFun(fieldname);
                })
            }
            else if(fieldinfo.bigtype!='reference'&&(fieldinfo.bigtype!='picklist'))
            {
                ld("#"+popupobj.divid+" [name="+fieldname+"]").bind('change',function(){
                    that.fieldnamechangeFun(fieldname);
                })
            }
        });

    }

    //判断是否为 会触发敏感规则字段
    this.IsRelatedfieldname = function(fieldname){
        var flag = false;
        if(this.relatedfieldname_arr.indexOf(fieldname)>=0)
        {
            //会触发敏感规则字段
            flag = true;
        }
        return flag;
    }
    //判断是否为 敏感规则字段字段
    this.IsSenditivefieldname = function(fieldname){
        var flag = false;
        if(this.senditivefieldname_arr.indexOf(fieldname)>=0)
        {
            //敏感规则字段字段
            flag = true;
        }
        return flag;
    }
    this.HaveSenditivefieldname = function(fieldnamearr){
        var flag = false;
        if(!empty(fieldnamearr)){
            ld.each(fieldnamearr,function (tmpindex,tmpfieldname){
                if(that.IsRelatedfieldname(tmpfieldname)||that.IsRelatedfieldname(tmpfieldname)){
                    flag = true;
                    return false;
                }
            })
        }
        return flag;
    }
    this.fieldnamechangeFun = function(fieldname){
        if(this.IsSenditivefieldname(fieldname))
        {
            //敏感规则字段,设置字段属性为未设置敏感值
            this.setfieldSensitiveinfo(fieldname,'no','');//设置为非
        }
        if(this.IsRelatedfieldname(fieldname))
        {
            //后台查询相关方法，重新返回field
            that.getRelatedSensitiveData(fieldname);
        }
    }
    //后台查询相关方法，重新返回field
    this.getRelatedSensitiveData = function(fieldname)
    {
        if(this.IsRelatedfieldname(fieldname) == false)
        {
            return ;
        }
        that.getAllSensitiveData(fieldname);
    }
    //fieldname如果有值,则返回除fieldname外其他字段值
    this.getAllSensitiveData = function(fieldname)
    {
        if(this.relatedfields == null || this.relatedfields == undefined || (this.relatedfields.length != undefined && this.relatedfields.length<=0)){
            return ;
        }
        var fieldinfo = this.getFieldInfoByfieldname(fieldname);
        var columnname = '';
        if(fieldinfo != undefined && fieldinfo != []){
            columnname = fieldinfo.columnname;
        }
        var popupobj = that.popupobj;
        var module = popupobj.module;
        var urlstring = "module="+module+"&action="+module+"Ajax&file=getSensitiveFieldsDatabyRule";
        if(popupobj.record != undefined){
            urlstring += "&record="+popupobj.record;
        }
        urlstring += "&fieldname="+fieldname;
        var sensitiverequestfield_arr = [];
        //关联创建的查询条件
        if(popupobj.fields != undefined){
            var  requestvalues={};
            var longtextarea = '';
            ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
                if(tmpfieldinfo.bigtype=='richtext'){
                    return true;
                }
                var tmpfieldvalue = "";
                if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0){
                    if(tmpfieldinfo.havesensitivevalue != undefined && tmpfieldinfo.havesensitivevalue == 'yes'){
                        tmpfieldvalue = tmpfieldinfo.sensitiveencryptvalue;
                        sensitiverequestfield_arr.push("requestvalues-"+tmpfieldinfo.fieldname);
                    }
                    else{
                        if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0)
                        {
                            tmpfieldvalue = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val();
                            if(tmpfieldinfo.bigtype=='reference'){
                                tmpfieldvalue +='","'+tmpfieldinfo.fieldname+'_name":"'+ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"_name]").val();
                            }
                        }
                        if (tmpfieldinfo.uitype == 33) {
                            //多选用户字段
                            var strtmp = getMultiPickListSelectValueByObj(ld("#"+popupobj.divid +" [name='"+tmpfieldinfo.fieldname + "[]"+"']"));
                            tmpfieldvalue = strtmp;
                        }
                    }
                    requestvalues[tmpfieldinfo.fieldname] = tmpfieldvalue;
                }
            })

            //requestvalues='['+requestvalues+']';//删除“，”
            urlstring += "&requestvalues="+encodeURIComponent(JSON.stringify(requestvalues));

            if(longtextarea != ''){
                urlstring += longtextarea;
            }
            urlstring += "&sensitiverequestfield="+JSON.stringify(sensitiverequestfield_arr);
        }
        ldAjaxNoProgresssync('index.php?'+urlstring,"",function(ajaxdata){
            if(ajaxdata.code == 1){
                var sensitivedata = ajaxdata.result.sensitivedata;
                if(sensitivedata != null){
                    getJsScript('include/js/relatedfield.js',function(){
                        popupobj.hadgivenvaluecolumnlist = [];
                        if(columnname != ''){
                            popupobj.hadgivenvaluecolumnlist.push(columnname);
                        }
                        setRelateValue(sensitivedata,columnname,'',module,'');
                    });
                }
            }
        });
    }

    this.getFieldvalue = function(fieldname,fieldvalue)
    {
        var popupobj = this.popupobj;
        var divid = popupobj.divid;
        if(empty(fieldvalue)){
            fieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
        }
        ld.each(fields,function(tmpindex,fieldinfo) {
            if (fieldinfo == undefined) {
                return true;
            }
            var tmpfieldname = fieldinfo.fieldname;
            if(tmpfieldname != fieldname){
                return true;
            }
            if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                fieldvalue = fieldinfo.sensitiveencryptvalue;
            }
        })
        return fieldvalue;

    }

    this.setfieldSensitiveinfo = function(fieldname,havesensitivevalue,sensitiveencryptvalue)
    {
        var popupobj = that.popupobj;
        tmpfieldinfo = this.getFieldInfoByfieldname(fieldname);
        if(tmpfieldinfo !=[] && tmpfieldinfo !=undefined){
            if(havesensitivevalue == 'yes'){
                tmpfieldinfo.havesensitivevalue = 'yes';
                tmpfieldinfo.sensitiveencryptvalue = sensitiveencryptvalue;
            }
            else{
                tmpfieldinfo.havesensitivevalue = 'no';
                tmpfieldinfo.sensitiveencryptvalue = '';
            }
        }
    }

    this.getFieldInfoByfieldname = function(fieldname){
        if(this.fieldinfobyfieldname[fieldname] != undefined){
            return this.fieldinfobyfieldname[fieldname];
        }
        var popupobj = that.popupobj;
        var fieldinfo = [];
        //新增,编辑,小编就,详情
        if(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype)
        {
            //popupobj.pagetype:新增和编辑的值一样
            if(popupobj.fieldname_fields[fieldname]!=undefined){
                fieldinfo = popupobj.fieldname_fields[fieldname];
            }
            else{
                if(popupobj.fields!=undefined){
                    ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
                        if(tmpfieldinfo.fieldname == fieldname){
                            fieldinfo = tmpfieldinfo;
                            return false;
                        }
                    })
                }
            }
        }
        if(fieldinfo !=[] && fieldinfo !=undefined){
            this.fieldinfobyfieldname[fieldname] = fieldinfo;
        }
        return fieldinfo;
    }
    this.getFieldInfoBycolumnanme = function(columnname){
        if(this.fieldinfobycolumnanme != undefined && this.fieldinfobycolumnanme[columnname] != undefined){
            return this.fieldinfobycolumnanme[columnname];
        }
        var popupobj = that.popupobj;
        var fieldinfo = [];
        //新增,编辑,小编就,详情
        if(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype)
        {
            if(popupobj.fields!=undefined){
                ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
                    if(tmpfieldinfo.columnname == columnname){
                        fieldinfo = tmpfieldinfo;
                        return false;
                    }
                })
            }
        }
        if(fieldinfo !=[] && fieldinfo !=undefined){
            this.fieldinfobycolumnanme[columnname] = fieldinfo;
        }
        return fieldinfo;
    }



}
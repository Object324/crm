/*
* edit:duan
* reason:新建编辑界面公共字段变化事件
* date:20240920
*
* */
function cls_common_field_event(popupobj)
{
    //布局规则
    var that=this;
    that.popupobj=popupobj;
    this.use_field_arr=popupobj.fields;
    that.values=[];

    this.set_use_field_arr = function (use_field_arr) {
        this.use_field_arr = use_field_arr;
    }

    this.setEvent=function()
    {
        var popupobj=that.popupobj;

        ld.each(that.use_field_arr,function(index,tmpinfo){
            var fieldinfo = tmpinfo;
            if(fieldinfo==undefined)
            {
                return true;
            }
            var fieldname = fieldinfo.fieldname;
            var typeofdata = fieldinfo.typeofdata;
            var tmpobj = ld("#"+popupobj.divid+" [name="+fieldname+"]");
            if(fieldinfo.bigtype=='multipicklist')
            {
                //多选框
                ld("#"+popupobj.divid+" [name='"+fieldname+"[]']").on("select2:close", function (e){
                    that.common_changefun(this,fieldname);
                })

                ld("#"+popupobj.divid+" [name='"+fieldname+"[]']") .on("select2:unselecting", function(e) {
                setTimeout(function(){
                    ld("#"+popupobj.divid+" [name='"+fieldname+"[]']").select2("close");//BUG20240118-06 240118 ls 下拉框不会消失(选中后再反选)
                    that.common_changefun(this,fieldname);
                },150)

                });

            }else if (typeofdata.toLocaleLowerCase().indexOf("d~") >= 0 || typeofdata.toLocaleLowerCase().indexOf("dt~") >= 0 || typeofdata.toLocaleLowerCase().indexOf("t~") >= 0) {
                tmpobj.bind("blur", function () {
                    that.common_changefun(this,fieldname);
                });
            }
            else if(popupobj.module=="Potentials"&&fieldinfo.fieldname=='sales_stage')
            {
                //销售阶段
                tmpobj.bind('change',function(){
                    that.common_changefun(this,fieldname);
                })
            }
            else if(popupobj.module=="Attachment"&&fieldinfo.fieldname=='reltab')
            {
                //附件管理：相关模块
                tmpobj = ld("#"+popupobj.divid+" [name=related_to_type]");
                tmpobj.bind('change',function(){
                    that.common_changefun(this,fieldname);
                })
            }
            else if(fieldinfo.bigtype=='boolean'||(fieldinfo.uitype==56&&fieldinfo.savedatabase=='yes'))
            {
                ld("#"+popupobj.divid+" [name=sel_"+fieldname+"]").unbind("change").bind('change',function(){
                    that.common_changefun(this,fieldname);
                })
            }
            else if(fieldinfo.bigtype!='reference')
            {
                tmpobj.bind('change',function(){
                    that.common_changefun(this,fieldname);
                })
            }

        });
    }
    //绑定分录事件
    this.setEntryEvent = function (rowid) {
        var popupobj = this.popupobj;
        var tableobj = popupobj.getDetailTableObj();
        var tmpdetailfield=popupobj.detailfields;
        var trobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
        var detail_type = '';

        var typeofdata = '';
        var tmpobj = '';

        ld.each(tmpdetailfield,function (tmp_index,fieldinfo) {
            var columnname = fieldinfo.columnname;
            var tmpobj=ld(trobj).find("#"+columnname);
            if(tmpobj.length == 0)return true;
            var jstmpobj = tmpobj.get(0);
            jstmpobj.rowindex = rowid;
            jstmpobj.cur_columnname = columnname;
            // 避免分录重复绑定事件
            if(jstmpobj.have_common_event == 'yes'){
                return true;
            }else{
                jstmpobj.have_common_event = 'yes';
            }

            typeofdata=fieldinfo.typeofdata;

            if(typeofdata.toLocaleLowerCase().indexOf("d~")>=0||typeofdata.toLocaleLowerCase().indexOf("dt~")>=0)
            {
                ld(tmpobj).bind("blur",function () {
                    that.common_entry_changefun(this,this.cur_columnname,this.rowindex);
                });
                return true;
            }
            ld(tmpobj).on("change",function () {
                that.common_entry_changefun(this,this.cur_columnname,this.rowindex);
            });
        })
    }

    this.setAllEntryEvent = function () {
        var popupobj = this.popupobj;
        var detail_type = '';
        if (popupobj.detailfieldmodule == 'Products')//产品分录保存
        {
            detail_type = 'product';
        }else if (popupobj.hasOwnProperty('detailfieldmodule') && popupobj.detailfieldmodule !== undefined && popupobj.detailfieldmodule.indexOf('detailhtml') > -1) {
            detail_type = 'normal';
        }else{
            return;
        }

        var trobjs = popupobj.getTrObjsByDelType('no');
        var rowindex = 0;
        ld.each(trobjs,function (tmp_index,tmp_obj) {
            rowindex = ld(tmp_obj).attr('rowindex');
            that.setEntryEvent(rowindex);
        })
    }

    //表头公共字段变化事件
    this.common_changefun = function (obj,fieldname) {
        var jq_obj = ld(obj);
        //字段值变化后判断审批信息是否需要更新
        var approvestep_changeobj = this.popupobj.approvestep_changeobj;
        if(!empty(approvestep_changeobj)){
            approvestep_changeobj.checkfieldchange(obj,fieldname);
        }
        //字段变化后判断是否需要清空分录
        if(!empty(this.popupobj.module_setting) && !empty(this.popupobj.module_setting.clear_detail_fieldname)){
            var clear_detail_fieldname_arr = popupobj.module_setting.clear_detail_fieldname;
            if(clear_detail_fieldname_arr.includes(fieldname) && !empty(this.popupobj.selectproductobj)){
                fun_selectproduct.emptyproductrow();
            }
        }

        //BUG20241211-68 ls 241211 团队成员字段(div)无法通过监听事件触发
        if(!empty(this.popupobj.mainfieldformulaobj) && !empty(this.popupobj.mainfieldformulaobj.computerfieldnames)){
            var computerfieldnames_arr = popupobj.mainfieldformulaobj.computerfieldnames;
            if(computerfieldnames_arr.includes(fieldname)){
                var param = [];
                param['data'] = {'formulafieldname':fieldname};
                popupobj.mainfieldformulaobj.startComputer(param);
            }
        }

    }
    //分录公共字段变化事件
    this.common_entry_changefun = function (obj,fieldname,rowid) {
        var jq_obj = ld(obj);
        //字段值变化后判断审批信息是否需要更新
        var approvestep_changeobj = this.popupobj.approvestep_changeobj;
        if(!empty(approvestep_changeobj)){
            approvestep_changeobj.checkentryfieldchange(obj,fieldname);
        }

        try {
            // 价格政策，含税单价变化，原价也变化
            if(that.popupobj.detailmodule=="Products")
            {
                var rowValObj = that.popupobj.detaildatavalue_arr[parseInt(rowid) - 1],
                    tmpVal = rowValObj.taxprice;
                if(fieldname === 'taxprice' && tmpVal && !isNaN(tmpVal)) {
                    rowValObj.tax_price_before_discounted = tmpVal;
                }
            }
        }
        catch (e) {
            console.log(e)
        }
    }

    //分录整行变化事件，例如选择源单、选择产品等、复制行、删除行等
    this.common_all_entry_changefun = function (rowid) {
        //字段值变化后判断审批信息是否需要更新
        var approvestep_changeobj = this.popupobj.approvestep_changeobj;
        if(!empty(approvestep_changeobj)){
            approvestep_changeobj.nocheckentryfieldchange();
        }
    }
}
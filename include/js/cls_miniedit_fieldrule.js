/*
* edit:duan
* date:20240112
* reason:小编辑布局规则触发事件
* */

function cls_miniedit_fieldrule(popupobj,fieldnames) {
    this.popupobj=popupobj;
    this.hadreload='no';
    this.rulefieldname=fieldnames;
    this.reloadfieldname='';//引发布局字段的名称
    this.values=[];
    this.parentobj = '';
    this.trigger_fields_arr = {};

    this.setParentobj = function (parentobj){
        this.parentobj = parentobj;
    }
    this.set_trigger_fields_arr = function (trigger_fields_arr){
        var length = trigger_fields_arr.length;
        for(var i = 0;i < length;i++){
            this.trigger_fields_arr[trigger_fields_arr[i]['fieldname']] = trigger_fields_arr[i];
        }
    }

    this.setEvent=function()
    {
        var popupobj=this.popupobj;

        if(this.rulefieldname==null||this.rulefieldname==undefined){
            //没有布局规则
            return false;
        }
        var that = this;
        var parentobj = this.parentobj;

        //that.rulefieldname:包含主表字段的布局规则和明细字段的布局规则
        ld.each(this.rulefieldname,function(index,fieldname){
            var fieldinfo=that.trigger_fields_arr[fieldname];
            if(fieldinfo==undefined)
            {
                return true;
            }

            if(fieldinfo.bigtype=='multipicklist')
            {
                //多选框
                parentobj.find(" [name='"+fieldname+"[]']").on("select2:close", function (e){
                    that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                    that.reloadPopup();
                })

                parentobj.find(" [name='"+fieldname+"[]']") .on("select2:unselecting", function(e) {
                    setTimeout(function(){
                        that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                        parentobj.find(" [name='"+fieldname+"[]']").select2("close");//BUG20240118-06 240118 ls 下拉框不会消失(选中后再反选)
                        that.reloadPopup();
                    },150)

                });

            }

            else if(popupobj.module=="Potentials"&&fieldinfo.fieldname=='sales_stage')
            {
                //销售阶段
                parentobj.find(" [name="+fieldname+"]").bind('change',function(){
                    that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                    that.reloadPopup();
                })
            }
            else if(fieldinfo.bigtype=='boolean'||(fieldinfo.uitype==56&&fieldinfo.savedatabase=='yes'))
            {
                ////edit:can 57849 （http://crm.airmaster.com.cn/crm）自定义表15，复选框引用字段，无法触发布局规则

                parentobj.find(" [name=sel_"+fieldname+"]").unbind("change").bind('change',function(){
                    that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                    that.reloadPopup();
                })
            }

            else if(fieldinfo.bigtype!='reference'&&(fieldinfo.bigtype!='picklist'))
            {
                //picklist:下拉框事件在cls_picklist调用reloadPopup函数（考虑有级联）
                //选择单据无法获取事件，只能在赋值的时候调用reloadPopup函数

                parentobj.find(" [name="+fieldname+"]").bind('change',function(){
                    that.reloadfieldname=fieldname;//edit:can 20200721 获取引发布局规则的字段名称
                    that.reloadPopup();
                })

            }
        });
    }

    this.setValues=function(values)
    {

        this.values=values;

    }
    this.CheckReLoadPopup=function()
    {
        var that = this;
        if(that.rulefieldname==null||that.rulefieldname==undefined||(that.rulefieldname.length != undefined && that.rulefieldname.length<=0)){
            //没有布局规则
            return false;
        }

        var parentobj = this.parentobj;
        var isreload='no';
        var popupobj=that.popupobj;
        that.reloadfieldname='';
        var fieldobj = '';
        var fieldinfoobj = new fieldinfo(popupobj);
        ld.each(that.rulefieldname,function(index,fieldanme){
            fieldobj =that.trigger_fields_arr[fieldanme];
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

            else if(parentobj.find(" [name="+fieldanme+"]").length<=0)
            {
                return true;
            }
            var pre_value = that.values[fieldanme];
            var post_value = parentobj.find(" [name="+fieldanme+"]").val();
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

    this.reloadPopup=function()
    {

    }

}


cls_miniedit_fieldrule.load = function (popupobj,fieldnames) {
    cls_miniedit_fieldrule.prototype = new cls_fieldrule(popupobj,fieldnames);
    cls_miniedit_fieldrule.prototype.constructor = cls_miniedit_fieldrule;
    var fieldruleobj = new cls_miniedit_fieldrule(popupobj,fieldnames);
    return fieldruleobj;
}

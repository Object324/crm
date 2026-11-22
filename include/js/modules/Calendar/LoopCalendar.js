//ls 20240412 XUQIU1002280  优化日程界面及其设置循环日程功能
function LoopCalendar() {
    var that = this;
    this.picklistdata = '';//新建编辑页面的下拉框/多选框字段数据
    this.pagemode = 'create';//当前页面类型 create edit
    this.popupobj=CrmPopup.getPopupObj('last');
    this.setPopupobj=function(popupobj) {
        this.popupobj=popupobj;
    }
    this.divid=this.popupobj.divid;

    this.gettableLoopUIobj = function()
    {
        return ld("#"+this.divid+" #addEventLoopUI");
    }

    this.setEvent=function()
    {

        // 绑定事件及初始化下拉框、多选框字段
        var cls_resetComboxHtmlobj = new cls_resetComboxHtml('loop_type');
        // cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
        // cls_resetComboxHtmlobj.searchhtmltype='div';
        // cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
        cls_resetComboxHtmlobj.setComboxObjHtml();
        var tableLoopUIObj = this.gettableLoopUIobj();
        ld(document).ready(function() {
            tableLoopUIObj.find('#loop_month').select2({closeOnSelect: true});
            tableLoopUIObj.find('#loop_dayvalue').select2({closeOnSelect: true});
            tableLoopUIObj.find('#reminder_setting').select2({closeOnSelect: true});
        });

        if (that.pagemode == 'edit') {
            that.changePage(that.picklistdata.loop_type_info.selected);//编辑页 初始化页面值
        }

        //切换“循环类型”事件
        tableLoopUIObj.find('[name=loop_type]').off("change").on("change",function(){
            var loop_type = ld(this).val();
            that.changePage(loop_type);
        })

    }
    this.get_calendar_picklistdata = function ()
    {
        var divid = that.popupobj.divid;
        var tableLoopUIObj = this.gettableLoopUIobj();
        CrmPopup.findHtmlobj(this.divid, curr_fieldname)

    }

    this.changePage=function(loop_type)
    {
        var tableLoopUIObj = this.gettableLoopUIobj();
        // console.log("changePage: "+loop_type);
        tableLoopUIObj.find('td[name=td_loop_month]').css("display",'none');
        tableLoopUIObj.find('td[name=td_loop_dayvalue]').css("display",'none');
        // tableLoopUIObj.find('tr[name=tr_reminder_setting]').css("display",'none');
        tableLoopUIObj.find('tr[name=tr_expiredate]').css("display",'none');
        if (loop_type == '' || loop_type == 'noreport') {

        }else if(loop_type == 'daily'){
            tableLoopUIObj.find('tr[name=tr_reminder_setting]').css("display",'');
            tableLoopUIObj.find('tr[name=tr_expiredate]').css("display",'');

        }else if(loop_type == 'weekly' || loop_type == 'biweekly'){
            tableLoopUIObj.find('td[name=td_loop_dayvalue]').css("display",'');
            tableLoopUIObj.find('tr[name=tr_reminder_setting]').css("display",'');
            tableLoopUIObj.find('tr[name=tr_expiredate]').css("display",'');

            //显示月的多选框拉框
            tableLoopUIObj.find("#loop_dayvalue").empty();//清空option
            tableLoopUIObj.find("#loop_dayvalue").nextAll('span').remove();//清空select2生成代码
            // console.log(that.picklistdata.loop_dayvalue_info);
            ld.each(that.picklistdata.loop_dayvalue_info,function(tmpindex,tmpoption){
                tableLoopUIObj.find("#loop_dayvalue").append("<option value='"+tmpoption[1]+"'" + tmpoption[2] +">"+tmpoption[0]+'</option>');
            })
            tableLoopUIObj.find("#loop_dayvalue").select2({closeOnSelect: true});

        }else if(loop_type == 'monthly'){
            tableLoopUIObj.find('td[name=td_loop_month]').css("display",'');
            tableLoopUIObj.find('td[name=td_loop_dayvalue]').css("display",'');
            tableLoopUIObj.find('tr[name=tr_reminder_setting]').css("display",'');
            tableLoopUIObj.find('tr[name=tr_expiredate]').css("display",'');

            // 1 |##| 3 |##| 5
            // console.log(loop_month_info);
            //显示月的多选框拉框
            tableLoopUIObj.find("#loop_dayvalue").empty();//清空option
            tableLoopUIObj.find("#loop_dayvalue").nextAll('span').remove();//清空select2生成代码

            ld.each(that.picklistdata.loop_dayvalue_monthinfo,function(tmpindex,tmpoption){
                tableLoopUIObj.find("#loop_dayvalue").append("<option value='"+tmpoption[1]+"'" + tmpoption[2] +">"+tmpoption[0]+'</option>');
            })
            tableLoopUIObj.find("#loop_dayvalue").select2({
                closeOnSelect: false,
                dropdownParent: ld("#" + that.divid)
            });
        }

    }


}
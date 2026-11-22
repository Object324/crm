function  gzYinheSalesGoalReport(){
    var that = this;
    that.module = 'SalesOrder';
    that.popupobj = undefined;
    that.divid = '';
    that.url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=gzYinheSalesGoalReport';
    that.popupJqObj = undefined;

    this.setPopupObj = function(popupobj){
        that.popupobj = popupobj;
        that.divid = popupobj.divid;
        that.popupJqObj = ld('#'+popupobj.divid);

    }
    this.setEvent = function(){
        //多选条件的样式 select2
        that.popupJqObj.find('#sqlvar_pinpai').select2({width:'90%',closeOnSelect: true});

        //目标年度改变事件--联动改变时间起止筛选控制
        that.popupJqObj.find('#sqlvar_targetyear').unbind('change').bind('change',function(){
            var value = ld(this).val();
            var selecteOpt = ld(this).find('option[value="'+value+'"]');

            var start = ld(selecteOpt).data('start');
            var end = ld(selecteOpt).data('end');
            var pinpai = ld(selecteOpt).data('pinpai');
            var pinpai_arr = pinpai.split(',');
            var pinpaihtml = '';
            ld.each(pinpai_arr,function(i,item){
                if(!empty(item)){
                    pinpaihtml+='<option selected value="'+item+'">'+item+'</option>';
                }
            })
            var starthtml = '<input readonly type="text" class="Wdate ld-input-inner" name="sqlvar_startdate" autocomplete="off" value="'+start+'" onclick="WdatePicker({startDate:\'%y-%M-%d\',dateFmt:\'yyyy-MM-dd\',minDate:\''+start+'\',maxDate:\''+end+'\'})">'
            var endhtml = '<input readonly type="text" class="Wdate ld-input-inner" name="sqlvar_enddate" autocomplete="off" value="'+end+'" onclick="WdatePicker({startDate:\'%y-%M-%d\',dateFmt:\'yyyy-MM-dd\',minDate:\''+start+'\',maxDate:\''+end+'\'})">'
            that.popupJqObj.find('#sqlvar_startdate_td').html(starthtml);
            that.popupJqObj.find('#sqlvar_enddate_td').html(endhtml);
            that.popupJqObj.find('#sqlvar_pinpai').html(pinpaihtml);

        });
        that.popupJqObj.find('[tag=search]').unbind('click').bind('click',function(){
            that.showList();
        });
    }
    
    this.setHeight = function(){
        var a = ld(' body').outerHeight(true);//头部高度
        var searchHeight = ld(' #searchList').outerHeight(true);//头部高度

        ld('#container_treediagram').css('height',a-searchHeight);
        ld('#container_treediagram').css('width','calc(100% - 10px)');
        ld('#container_treediagram').show();
        ld('#container_treediagram').css('opacity',1);
        ld('#container_treediagram').css('transition-duration','0.8s');
    }

    //获取目标 树结构
    this.showList = function(){
        var url = that.url;
        var params = {"function_name":"getData"};
        params['sqlvar_selectbumen'] = that.popupJqObj.find('#sqlvar_selectbumen').val();
        params['sqlvar_selectuser'] = that.popupJqObj.find('#sqlvar_selectuser').val();
        params['sqlvar_targetyear'] = encodeURIComponent(that.popupJqObj.find('#sqlvar_targetyear').val());

        params['sqlvar_startdate'] = that.popupJqObj.find('[name=sqlvar_startdate]').val();
        params['sqlvar_enddate'] = that.popupJqObj.find('[name=sqlvar_enddate]').val();
        params['sqlvar_pinpai'] = that.popupJqObj.find('#sqlvar_pinpai').val();

        ldAjaxNoProgress(url,params,function(res) {
            if (res.code == 1) {
                that.popupJqObj.find('#ld_gzyinhe_reportcontent').html(res.result.content);
                that.setHeight();
            }
        });
    }

}
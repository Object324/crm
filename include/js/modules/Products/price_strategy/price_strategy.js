//editor:gyq_84 reason:产品增加价格策略 2018/10/22 14:39
var price_strategy = (function () {
    //参数：传递给单例的一个参数集合
    function price_strategy() {
        this.name = 'price_strategy';
        this.module = 'Products';
    }
    //获取策略设置界面
    price_strategy.prototype.get_setting_windows  = function(obj,module,r_record){
       
        var the_this = this;
        var numrows;
        if(r_record > 0){
            numrows = 1;
        }else{
            List_CheckBox_Ids.getIds(module);
            numrows = List_CheckBox_Ids.num_rows;
        }
        if(numrows===0){
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
            return false;
        }else{
            if(r_record > 0){
                //明细界面
                record = r_record;
            }else{
                //序时簿
                var select_ids_arr = List_CheckBox_Ids.ids.split(';');
                var record = select_ids_arr[0];
            }
            ld.post("index.php",{record : record ,module:"Products",file:"index_price_strategy",'action':'ProductsAjax','second_action':"get_setting_windows"},function(response) {
                var data = ld.parseJSON(response);
                var crmPopupobj = CrmPopup.load(data.result.title, save_setting, "", "LdPopWidth800px", module, '', data.result.oktext, "", data.result.canceltext);
                crmPopupobj.Okfun.funname='save_setting';
                
                crmPopupobj.show(data.result.content);

                //下拉框默认选中
                ld("#ps_type").val(ld('#hidden_type').val());
                the_this.type_onchange(ld("#ps_type"));
                
                //当只有一行时，不显示删除按钮
                if(data.result.NUMROW1===1){
                    ld('#ps_type1').find('a[tag="delete"]').hide();
                }
                if(data.result.NUMROW3===1){
                    ld('#ps_type3').find('a[tag="delete"]').hide();
                }
                crmPopupobj.center();
            });
        }
        return false;
    }

    //增加行
    price_strategy.prototype.add_row  = function(obj,type){
        var last_row = ld('#ps_type'+type).find('tr[tag="row_content"]').last();
        last_row.after(last_row.clone());
        ld('#ps_type'+type).find('tr[tag="row_content"]').last().find('input').val('');
        ld('#ps_type'+type).find('a[tag="delete"]').show();
    }
    //删除行
    price_strategy.prototype.delete_row  = function(obj,type){
        var row_number = ld('#ps_type'+type).find('tr[tag="row_content"]').length;
        if(row_number > 1 ){
            var closest = ld(obj).closest('tr[tag="row_content"]');
            closest.remove();
            //删除后只有一行，隐藏删除按钮
            var right_row_number = ld('#ps_type'+type).find('tr[tag="row_content"]');
            if(right_row_number.length === 1){
                right_row_number.find('a[tag="delete"]').hide();
            }
        }
    }
    //设置界面保存
    price_strategy.prototype.save_setting  = function(obj){
        var ps_type = ld('#ps_type').val();
        var record = ld('#hidden_record').val();
        var reuslt_arr =[];
        var reuslt_arr2 =[];
        var reuslt_arr3 =[];
        var last_one = 0;
        var price_last_one = 0;
        var remind_mark = 0;
        var cell_number = 0;
        var error_obj = null;
        //editor:gyq_20181029 0035470: （1.6账套）产品管理列表界面>勾选一条没有设置价格策略的产品>点击打开价格策略弹出层：点击保存弹出提示“当前金额应大于前一行金额”
        if(ps_type === '0'){
            remind_mark = 0;
        }else{
            ld('#ps_type1 tr[tag="row_content"]').each(function (i) {
                var temp_tr_input = [];
                ld(this).find('input').each(function (j) {
                    /* editor:gyq_20181101 reason:报错立即终止，防止下面错误干扰
                    结束循环           用return false
                       结束本次循环      用return ture*/
                    if(remind_mark > 0){
                        return false;
                    }
                    if(ld(this).attr('tag')==='price_input'){
                        var price_right_one =parseFloat(ld(this).val()) ;
                        if(price_right_one >= price_last_one){
                            temp_tr_input.push(ld(this).val()) ;
                            price_last_one = price_right_one;
                        }else{
                            error_obj = ld(this);
                            remind_mark = 3;
                        }
                    }else{
                        cell_number = cell_number+ 1
                        var right_one =parseFloat(ld(this).val()) ;
                        //同行异行不同提示内容
                        if(cell_number%2 ===0){
                            //同行
                            if(right_one >=last_one ) {
                                temp_tr_input.push(ld(this).val());
                                last_one = right_one;
                            }else{
                                error_obj = ld(this);
                                remind_mark = 1;
                            }
                        }else{
                            //异行
                            if(right_one >last_one ) {
                                temp_tr_input.push(ld(this).val());
                                last_one = right_one;
                            }else{
                                error_obj = ld(this);
                                remind_mark = 2;
                            }
                        }
                    }
                });
                reuslt_arr.push(temp_tr_input);
            });
            if(ps_type==='2'){
                ld('#ps_type2').find('input').each(function (i) {
                    reuslt_arr2.push(ld(this).val());
                });
            }else if(ps_type==='3'){
                ld('#ps_type3 tr[tag="row_content"]').each(function (i) {
                    if(remind_mark > 0){
                        return false;
                    }
                    var temp_tr_input = [];
                    ld(this).find('input').each(function (j) {
                        if(ld(this).attr('tag')==='price_input'){
                            temp_tr_input.push(ld(this).val()) ;
                        }else{
                            cell_number = cell_number+ 1
                            var right_one =parseFloat(ld(this).val()) ;

                            //同行异行不同提示内容
                            if(cell_number%2 ===0){
                                //同行
                                if(right_one >=last_one ) {
                                    temp_tr_input.push(ld(this).val());
                                    last_one = right_one;
                                }else{
                                    error_obj = ld(this);
                                    remind_mark = 1;
                                }
                            }else{
                                //异行
                                if(right_one >last_one ) {
                                    temp_tr_input.push(ld(this).val());
                                    last_one = right_one;
                                }else{
                                    error_obj = ld(this);
                                    remind_mark = 2;
                                }
                            }
                        }
                    });
                    reuslt_arr3.push(temp_tr_input);
                });
            }
        }
        if(remind_mark===1){
            //当前数字应大于起始数字
            RemindsMsg("","LdPopWidth400px",'Products',"yes","yes",arrJsPopLabel['PRICESTRATEGYREMIND1']);
        }else if(remind_mark===2){
            //当前数字应大于前一行最大数字
            RemindsMsg("","LdPopWidth400px",'Products',"yes","yes",arrJsPopLabel['PRICESTRATEGYREMIND2']);
        }else if(remind_mark===3){
            //当前金额应不小于前一行金额
            RemindsMsg("","LdPopWidth400px",'Products',"yes","yes",arrJsPopLabel['PRICESTRATEGYREMIND3']);
        }
        //异常提示，终止保存
        if(remind_mark > 0){
            //重写提示框确认事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                error_obj.focus();
            });
            return false;
        }
        ld.post("index.php",{reocrd:record,para1:reuslt_arr ,para2:reuslt_arr2,para3:reuslt_arr3,type:ps_type,
            module:"Products",file:"index_price_strategy",'action':'ProductsAjax','second_action':"save_setting"},function(response) {
            var popupobj=CrmPopup.getPopupObj("last");
            popupobj.CancelEvent();
        });
    }
    //价格策略类型变更
    price_strategy.prototype.type_onchange  = function(obj){
        var ps_type = ld(obj).val();
        if(ps_type==='0'){
            ld('#ps_type1').hide();
            ld('#ps_type2').hide();
            ld('#ps_type3').hide();
        }else{
            if(ps_type==='1'){
                ld('#ps_type1').show();
                ld('#ps_type2').hide();
                ld('#ps_type3').hide();
            }else if(ps_type==='2'){
                ld('#ps_type1').show();
                ld('#ps_type2').show();
                ld('#ps_type3').hide();
            }else if(ps_type==='3'){
                ld('#ps_type1').show();
                ld('#ps_type3').show();
                ld('#ps_type2').hide();
            }
        }
        var popupobj=CrmPopup.getPopupObj("last");
        popupobj.center();
    }
    //实例容器
    var instance;
    var _static = {
        name: 'price_strategy',
        //获取实例的方法
        getInstance: function () {
            if (instance === undefined) {
                instance = new price_strategy();
            }
            return instance;
        }
    };
    return _static;
})();
function save_setting(){
    price_strategy.getInstance().save_setting(null)
}
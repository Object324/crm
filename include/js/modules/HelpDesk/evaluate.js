//editor:gyq_127 reason:服务小程序增加评价  2019/6/26 17:50 ID1000419
var evaluate = (function () {
    //参数：传递给单例的一个参数集合
    function evaluate() {
        this.name = 'evaluate';
        this.module = 'HelpDesk';
    }
    //获取策略设置界面
    evaluate.prototype.get_setting_windows  = function(obj,module){
        var the_this = this;
        the_this.module = module;
        var module_ajax = module+'Ajax';
        ld.post("index.php",{module:module,file:"index_evaluate",'action':module_ajax,'second_action':"get_setting_windows"},function(response) {
            var data = ld.parseJSON(response);
            var crmPopupobj = CrmPopup.load(data.result.title, save_setting, "", "LdPopWidth800px", module, module, data.result.oktext, "", data.result.canceltext);
            crmPopupobj.Okfun.funname='save_setting';
            crmPopupobj.show(data.result.content);
            crmPopupobj.center();
        });
        return false;
    }
    //设置界面保存
    evaluate.prototype.save_setting  = function(){
        var module = this.module;
        var module_ajax = module+'Ajax';
        ld.ajax({
            url: "index.php?module="+module+"&action="+module_ajax+"&file=index_evaluate&second_action=save_setting" ,//url
            type: 'POST',//方法类型
            async: true,
            dataType:'json',
            timeout: 10000,
            data: ld('#form').serialize(),
            success: function (data) {
                var popupobj=CrmPopup.getPopupObj("last");
                popupobj.CancelEvent();
            }
        });
    }
    //实例容器
    var instance;
    var _static = {
        name: 'evaluate',
        //获取实例的方法
        getInstance: function () {
            if (instance === undefined) {
                instance = new evaluate();
            }
            return instance;
        }
    };
    return _static;
})();
function save_setting(module){
    evaluate.getInstance().save_setting(module)
}
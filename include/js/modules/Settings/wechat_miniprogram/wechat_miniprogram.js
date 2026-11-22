//显示小程序扫码界面 editor:gyq_83 reason:微信小程序账号绑定及扫码 2018/10/15 15:49
function show_wechat_applet() {
    ld.ajax('index.php?module=Users&action=UsersAjax&file=index_mini_pro&second_action=qrcode_window&ajax=true')
        .done(function(response){
            $('mini_menu_create_div').innerHTML=response;
            getJsScript('include/js/modules/Settings/wechat_miniprogram/qrcode.min.js',function() {
                var corplink = ld('#CORPLINK').val();
                ld('#qrcode_content').qrcode(corplink);
            });
            fnvshobj(this, 'mini_menu_create_div');
            //取消
            ld("#colse_mobile_menu").on('click',function(){
                fninvshnew('mini_menu_create_div');
            });
            ld("#save_mobile_menu").on('click',function(){
                fninvshnew('mini_menu_create_div');
            });
        })
}

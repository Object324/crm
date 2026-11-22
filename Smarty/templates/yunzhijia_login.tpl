<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link href="{$corpurl}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap.min.css" rel="stylesheet" >
    <style>
        .form-control::-webkit-input-placeholder { /* WebKit browsers */
            color: #fff;
            font-size: 14px;
        }

        .form-control::-moz-placeholder { /* Mozilla Firefox 19+ */
            color: #fff;
            font-size: 14px;
        }

        .form-control:-ms-input-placeholder { /* Internet Explorer 10+ */
            color: #fff;
            font-size: 14px;
        }
    </style>
    <script type="text/javascript" src="{$corpurl}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$corpurl}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap.bundle.min.js" ></script>
    <title>Document</title>
</head>
<body style="height:100%;">
<div style="display:flex;justify-content: center;width:100%;height:100%;background-position: center !important;
    background-size: 100% 100% !important;background:url('{$corpurl}dataCache/test/logo/login_bg_001.png');position: absolute;">
    <div style="width:400px;margin-top: 160px;padding:50px;background:rgb(75, 129, 239,0.3) ">
        <form id="login_form">
            <div class="form-group">
                <input type="hidden" class="form-control" name="ticket" id="ticket" value="{$ticket}">
                <input type="hidden" class="form-control" name="client_id" id="client_id" value="{$client_id}">
                <input type="hidden" class="form-control" name="expire_time" id="expire_time" value="{$expire_time}">
                <input type="hidden" class="form-control" name="msgShowStyle" id="msgShowStyle" value="{$msgShowStyle}">
                <input type="hidden" class="form-control" name="corpurl" id="corpurl" value="{$corpurl}">
                <input type="hidden" class="form-control" name="applicationType" id="applicationType" value="{$applicationType}">
                <label style="color:#fff;" for="user_name">账号</label>
                <input style="background-color: rgba(255,255,255,0.1);color:#FFF;" type="text" name="user_name" class="form-control" id="user_name" placeholder="请输入账号">
            </div>
            <div class="form-group">
                <label style="color:#fff;" for="user_password">密码</label>
                <input style="background-color: rgba(255,255,255,0.1);color:#FFF;" type="password" class="form-control" id="user_password" name="user_password" placeholder="请输入密码">
            </div>
            <div class="btn-group btn-group-justified" role="group" aria-label="..." style="width: 300px;">
                <div class="btn-group" role="group" style="margin:0 auto;">
                    <div onclick="doLogin()" class="btn btn-primary" style="width: 130px;">登录</div>
                </div>
            </div>

        </form>
    </div>
</div>
<script>
    function doLogin(){
        var params = $('#login_form').serialize();
        var corpurl = $('#corpurl').val();
        var url = corpurl+'WeiXinApp/yunzhijia/getAuth.php?function=doLogin';
        $.ajax({
            type : "POST",
            url : url,
            data : params,
            success : function(e) {
                e = eval('(' + e + ')');
                if(e.code==1){
                    //真正登录
                    window.open(corpurl+'index.php?action=Authenticate&module=Users&'+params,'_self');
                }else if(e.code=="yunzhijia_bind"){
                    alert(e.msg);
                    var crmid = e.result.id;
                    params+= '&userid='+crmid;
                    $.ajax({
                        type: "POST",
                        url: url,
                        data: params,
                        success: function (e) {
                            e = eval('(' + e + ')');
                            if(e.code==1){
                                window.open(corpurl+'index.php?action=Authenticate&module=Users&'+params,'_self');
                            }else{
                                alert(e.msg);
                            }
                        }
                    });
                }else{
                    alert(e.msg);
                }
            }
        });
    }
</script>
</body>
</html>
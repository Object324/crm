<html lang="">
<link type="text/css" rel="stylesheet" href="{$CRMURL}themes/softed/common.css">
<style>
    body {
        text-align: center;
        background-color: #E7ECF3;
    }

    .container {
        height: 100%;
        /* 父容器开启flex布局 */
        display: flex;
        /* 水平垂直居中 */
        justify-content: center;
        align-items: center;

    }

    .content {
        width: 500px;
        height: 430px;
        background: #FFFFFF;
        box-shadow: 0px 2px 14px 0px rgba(56, 92, 141, 0.25);
        border-radius: 10px;
    }

    .content ul {
        display: block;
        height: 200px;
        width: 300px;
        padding: 0;
        margin: 0 100px;
        background-color: white;
        overflow-y: auto;
    }

    li {
        list-style-type: none;
    }

    .content .head {
        width: 500px;
        height: 50px;
        background: #FFFFFF;
        box-shadow: 0px 1px 0px 0px #EEEEEE;
        border-radius: 10px 10px 0px 0px;
        font-weight: 400;
        color: #3B4859;
        line-height: 50px;
        letter-spacing: 1px;
        font-size: 16px;
        text-align: left;
        text-indent: 30px;

    }

    .content .title {
        height: 80px;
        line-height: 80px;
    }

    .content li {
        text-align: left;
        font-size: 14px;
        line-height: 36px;
    }
    .content li label{
        display: block;
        width: 100%;
    }

    .content li span {
        display: inline-block;
        margin-left: 6px;
    }

    .content .foot {

    }

    .content .foot input {
        background-color: #3B7CFF;
        border-radius: 21px;
        border: 0px;
        width: 165px;
        height: 42px;
        box-shadow: 0px 2px 14px 0px rgba(56, 92, 141, 0.25);
        font-size: 16px;
        color: #fff;
        margin-top: 30px;
    }
</style>
<body>
<div class="container">
    <div class="content">
        <form action="{$THISURL}" method="get">
            <input type="hidden" name="userid" value="{$ERPUSERID}">
            <input type="hidden" name="corpurl" value="{$CRMURL}">
            <div class="head">选择绑定用户</div>
            <div class="title">选择需要绑定的CRM用户</div>
            <ul>
                {foreach key=User_Key item=User from=$ALLUSERS}
                    <li><label><input type="radio" name="crmuserid"
                                      value="{$User.id}"/><span>{$User.last_name}</span></label></li>
                {/foreach}
            </ul>
            <div class="foot">
                <input type="submit" value="绑定">
            </div>
        </form>
    </div>
</div>
</body>

</html>

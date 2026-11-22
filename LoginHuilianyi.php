<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header('Access-Control-Allow-Origin: *');
header('Content-Type:text/html;charset=UTF-8');
$root_dir=(dirname(__FILE__));//获取根目录
session_start();
require_once($root_dir.'/includefile.php');
global $adb,$current_user;

$key = 'lius_ctgf';//自定义加解密的key
if(isset($_REQUEST['crm']) && $_REQUEST['crm']=='yes'){
    $current_user = new Users();
    $current_user->retrieveCurrentUserInfoFromFile($_SESSION['authenticated_user_id']);
    $user_name = $current_user->user_name;

    //$url = "https://stage.huilianyi.com?clientName=ctgf&userinfo=".cus_encrypt($user_name,$key);//测试环境
    $url = "https://public.ctgf.com:1443?clientName=ctgf&userinfo=".cus_encrypt($user_name,$key);//生产环境
    header("Location: ".$url);
}else{
    //汇联易回调   回调是获取不到$_SESSION['authenticated_user_id']的，也就没有$user_name，因此根据userinfo解密后存在数据库则表示认证通过
    //1、解密message,数据库存在则返回成功
    $sReqData = file_get_contents('php://input');
    //file_put_contents(globalStatic::$root_directory.'aaatest2.txt',"\r\n".$sReqData,FILE_APPEND);
    $sReqData = json_decode($sReqData,true);
    //file_put_contents(globalStatic::$root_directory.'aaatest2.txt',"\r\n".json_encode($sReqData,JSON_UNESCAPED_UNICODE),FILE_APPEND);


    /*$sReqData = json_decode('{
        "companyOID": null,
        "message": "N6jMf4rKejKNvupqKXeGR+4f882ll/0wxmXyvfVhAyluHA2ZSqvCAuTY46TogHwVIc98PNsDwZjpUci74QxUSpDaQqY1JMnlu2b2K4xnV5iOdaqx91utri1BCs9pfwd5E7mTekHvR+ntycYabdHyHZ65X4W24/XwuF03nM35yao=",
        "timestamp": "1709103888511",
        "nonce": "oIUv93",
        "signature": "4a3648edad27a25fb803b7b43cc42edbb4a8ed09",
        "apiCode": "CUSTOMIZED_LOGIN",
        "apiVersion": "1.0",
        "tenantId": 1694094710999851009,
        "pushType": "TENANT",
        "encryptAlg": "2.3",
        "dataId": "f43ac92c-5b2a-438b-a08d-f2d5eb1cd1f4"
    }',true);*/

    if(isset($sReqData["apiCode"]) && $sReqData["apiCode"] == "CUSTOMIZED_LOGIN"){
        $sReqMsgSig = $sReqData["signature"];
        $sReqTimeStamp = $sReqData["timestamp"];
        $sReqNonce = $sReqData["nonce"];
        $sReqMessage = $sReqData["message"];//需要解密的内容


        $sMsg = "";  // 解析之后的明文  解密后已转为数组
        $token = "ctgf";
//        $encodingAesKey = "APCVKoPfdfauPksEzv3WnMRurytOtFQ3GNqKrE9GShT";//测试环境
        $encodingAesKey = "APCVK1PfdfauPksEzv3WnMRurytOtFQ32NqKrE9GShT";//生产环境
        $sReceiveId = $sReqData["tenantId"];
        require_once($root_dir.'/huilianyi/WXBizMsgCrypt.php');
        $wxcpt = new WXBizMsgCrypt($token, $encodingAesKey, $sReceiveId);
        $errCode = $wxcpt->DecryptMsg($sReqMsgSig, $sReqTimeStamp, $sReqNonce, $sReqMessage, $sMsg);

        if ($errCode == 0 && !empty($sMsg)) {
            $user_name = cus_decrypt($sMsg['password'],$key);//再次解密解密后的值

            //验证成功，根据账号获取对应邮箱，最后将sEchoStr返回
            $sql = "select phone_mobile from ld_users where user_name = ? and status = ? and deleted = 0 limit 1";
            $result = $adb->pquery($sql,array($user_name,'Active'));
            $mobile = '';
            if($adb->num_rows($result) > 0){
                $mobile = $adb->query_result($result,0,'phone_mobile');
            }

            if (empty($mobile)) {
                $sEchoStr = array("code"=>"ERROR","message"=>"登录失败，请检查账户状态或者手机!");
            }else{
                $sEchoStr = array(
                    "code" => "SUCCESS",
                    "message" => "OK",
                    "body" => array(
                        "id"=>$mobile
                    ),
                );
            }
        }elseif($sReqData["apiCode"] == "INIT"){
            $sEchoStr = array("code"=>"SUCCESS","message"=>$sReqData["tenantId"]);
        } else {
            $sEchoStr = array("code"=>"ERROR","message"=>"校验失败,errCode：".$errCode);

        }

    }else{
        $sEchoStr = array("code"=>"ERROR","message"=>"CRM无需捕捉埋点，请检查配置");

    }

    @ob_clean();
    @ob_flush();
    echo json_encode($sEchoStr);
    exit;

}

function cus_encrypt($plaintext, $key) {
    // 使用 XOR 进行简单的加密
    $encrypted = '';
    $keyLength = strlen($key);
    for ($i = 0; $i < strlen($plaintext); $i++) {
        $encrypted .= $plaintext[$i] ^ $key[$i % $keyLength];
    }
    return base64_encode($encrypted); // 使用 Base64 编码以便于输出
}

function cus_decrypt($ciphertext, $key) {
    $ciphertext = base64_decode($ciphertext); // 先解码 Base64
    $decrypted = '';
    $keyLength = strlen($key);
    for ($i = 0; $i < strlen($ciphertext); $i++) {
        $decrypted .= $ciphertext[$i] ^ $key[$i % $keyLength];
    }
    return $decrypted;
}
?>
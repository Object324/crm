<?php
class cls_dandian
{
    var $user_name;
    public function __construct($user_name)
    {
        $this->user_name=$user_name;
    }
     // 生成一个唯一的nonce
     private function generateNonce(){
         return bin2hex(random_bytes(8)); // 生成8字节长度的随机数并转换为16进制字符串
     }
    // 使用加密key生成Token
     public function generateToken($encryptedKey, $data){
         return md5(hash_hmac('sha256', $data, $encryptedKey)); // 临时使用的服务器端密钥
     }
    public function setgenerateTokenbyencryptedkey($encryptedKey){
         global $adb;
         $nonce = $this->generateNonce();
         $timestamp = time();
         $username = $this->user_name;
         $temporaryToken = $this->generateToken($encryptedKey,$username . '|' . $nonce . '|' . $timestamp);
         // 使用客户端传入的加密key生成临时Token
         $tokenkey = $username . '|' . $nonce . '|' . $timestamp;
         // 将nonce、timestamp和临时Token存储在数据库中
         $adb->pquery('INSERT INTO ld_token_log (username,token, tokenkey,createtime) VALUES (?,?,?,?);',array($username,$temporaryToken,$tokenkey,date("Y-m-d H:i:s")));
         return $temporaryToken;
     }

    // 获取授权码加密后的值
    public function getencryptedKeybykey($Key,$encryptedKeytimestamp){
        $username = $this->user_name;
        $expectedHMAC = $this->generateHMAC($Key, $username . "|" . $encryptedKeytimestamp);
        return $expectedHMAC;
    }
    public function gettokeninfobytoken($token){
        global $adb;
        $tmpresult = $adb->pquery("SELECT * FROM ld_token_log WHERE token = ?  ;",array($token));
        $return_arr = [];
        if($adb->num_rows($tmpresult)){
            $return_arr['createtime'] = $adb->query_result($tmpresult,0,'createtime');
            $return_arr['tokenkey'] = $adb->query_result($tmpresult,0,'tokenkey');
            $return_arr['count'] = $adb->query_result($tmpresult,0,'count');
            $return_arr['id'] = $adb->query_result($tmpresult,0,'id');
        }
        return $return_arr;
    }
    //更新token使用次数
    public function updatetokencountbytoken($tokenid){
        global $adb;
        $adb->pquery('UPDATE ld_token_log SET count = count+1 WHERE id = ?;',array($tokenid));
    }
    // 根据token获取加密使用的key(从数据库获取)
    public function gettokenKeybytoken($token){
        global $adb;
        $username = $this->user_name;
        $tmpresult = $adb->pquery("SELECT * FROM ld_token_log WHERE token = ? and username=? ;",array($token,$username));
        if($adb->num_rows($tmpresult)){
            $createtime = $adb->query_result($tmpresult,0,'createtime');
            $tokenkey = $adb->query_result($tmpresult,0,'tokenkey');
            $count = $adb->query_result($tmpresult,0,'count');
            $tmpid = $adb->query_result($tmpresult,0,'id');
            if($count>0){
                exit('访问错误！');//访问次数超限
            }
            // 检查时间戳是否在有效期内
            if (time() - strtotime($createtime) > 60) {
                echo json_encode(['success' => false, 'message' => 'Token已过期']);
                exit;
            }
            $adb->pquery('UPDATE ld_token_log SET count = count+1 WHERE id = ?;',array($tmpid));
            unset($count,$tmpid);
        }
    }

    //默认false表示加密，传入true表示解密
    public function ldencryptstring($string,$code,$operation=false){
        $code .='';
        $code = md5($code);
        $iv = substr($code,0,16);
        $key = substr($code,16);
        if($operation){
            return openssl_decrypt(base64_decode($string),"AES-128-CBC",$key,OPENSSL_RAW_DATA,$iv);
        }
        return base64_encode(openssl_encrypt($string,"AES-128-CBC",$key,OPENSSL_RAW_DATA,$iv));
    }

    // 使用HMAC生成加密值
    public function generateHMAC($key, $message) {
        return base64_encode(hash_hmac('sha256', $message, $key, true));
    }

    /**
     * @reason: 直接获取token的方法
     * @param:
     * @edit:zkt
     * @date:2024/12/25
     */
    public function getnewgenerateToken():array
    {
        $deployvalues=getSys_deploy(105);
        $secretKey = $deployvalues['deploy_value'];
        $timestamp = time();//加密key使用的时间戳
        $encryptedKey = $this->getencryptedKeybykey($secretKey,$timestamp);
        $temporaryToken = $this->setgenerateTokenbyencryptedkey($encryptedKey);
        return ['token'=>$temporaryToken,'timestamp'=>$timestamp];
    }

    /**
     * @reason: 判断token有效性
     * @param:
     * @edit:zkt
     * @date:2024/12/25
     */
    public function getisUserfulToken($providedToken,$encryptedKeytimestamp):array
    {
        global $adb;
        $deployvalues=getSys_deploy(105);
        $secretKey = $deployvalues['deploy_value'];
        $returnarr = ["success"=>'yes',"arrinfo"=>[], "msg"=>""];
        // 从数据库中获取tokenkey
        $tmpresult = $this->gettokeninfobytoken($providedToken);
        if(empty($tmpresult)){
            $returnarr = ["success"=>'no',"arrinfo"=>[],'token'=>$providedToken,"msg"=>"无效token"];
        }
        else{
            $count = $tmpresult['count']??0;
            if($count>0){
                $returnarr = ["success"=>'no',"arrinfo"=>[],'token'=>$providedToken,"msg"=>"Token已被使用"];
            }
            else{
                $createtime = $tmpresult['createtime']??'';
                if (time() - strtotime($createtime) > 5) {
                    $returnarr = ["success"=>'no',"arrinfo"=>[],'token'=>$providedToken,"msg"=>"Token已过期"];
                }
                else{
                    $tmpid = $tmpresult['id']??'';
                    $this->updatetokencountbytoken($tmpid);
                    $tokenkey = $tmpresult['tokenkey']??'';
                    $expectedHMAC = $this->getencryptedKeybykey($secretKey,$encryptedKeytimestamp);
                    $temporaryToken = $this->generateToken($expectedHMAC,$tokenkey);
                    if($temporaryToken!=$providedToken)
                    {
                        $returnarr = ["success"=>'no',"arrinfo"=>[],'token'=>$providedToken,"msg"=>"Token错误"];
                    }
                }
            }
        }
        return $returnarr;
    }
}



?>
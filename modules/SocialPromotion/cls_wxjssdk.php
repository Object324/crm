<?php

/**
* @edit:dong
* @data:2020/07/29
* @reason:微信分享的配置
* @description:
*/
class Wxjssdk
{
	private $appId = 'wx70bee1ea15cf5889';
	private $appSecret = 'd79210b50e2a616b5dfa3e3c9640f3e2';
    private $expires_in ='7200';
    private $accessTokenFilePath = '../../dataCache/weixin/weixinShareSign_accessToken.txt';
    private $ticketFilePath = '../../dataCache/weixin/weixinShareSign_ticket.txt';
	public function __construct($appId='',$appSecret='') {
//		$this->appId = $appId;
//		$this->appSecret = $appSecret;
	}
	public function getSignPackage($url) {
		$jsapiTicket = $this->getJsApiTicket();
		if(is_object($jsapiTicket)){
		    return $jsapiTicket;
        }
		$url = urldecode($url); //必须是调用JS接口页面的完整URL 而且不能转义 网址必须添加到js安全域名里面才可以
		$timestamp = time();
		$nonceStr = $this->createNonceStr();

		// 这里参数的顺序要按照 key 值 ASCII 码升序排序
		$string = "jsapi_ticket=$jsapiTicket&noncestr=$nonceStr&timestamp=$timestamp&url=$url";

		$signature = sha1($string);

        $signPackage = array(
            "appId" => $this->appId,
            "nonceStr" => $nonceStr,
            "timestamp" => $timestamp,
            "url" => $url,
            "signature" => $signature,
//            "rawString" => $string,
            "expires_in" => $this->expires_in
            //            "jsapi_ticket"=>$jsapiTicket
        );
		return $signPackage;
	}


	private function createNonceStr($length = 16) {
		$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
		$str = '';
		$charslen = strlen($chars);
		for ($i = 0; $i < $length; $i++) {
			$mt_rand = mt_rand(0, ($charslen - 1));
			$str .= substr($chars, $mt_rand, 1);
		}
		return $str;
	}

	public function getJsApiTicket() {

		// jsapi_ticket 应该全局存储与更新
		$accessToken = $this->getAccessToken();
		if(is_object($accessToken)){
		    return $accessToken;
        }
        $res = json_decode(file_get_contents($this->ticketFilePath));
        if($res == '' || $res->time+$res->expires_in <time()){
            $url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token={$accessToken}&type=jsapi";
            $res = json_decode($this->httpGet($url));
            $res->time=time();
            //错误代码直接返回
            if($res->errcode != 0){
                return $res;
            }
            file_put_contents($this->ticketFilePath,json_encode($res));
        }
        return isset($res->ticket) ? $res->ticket : '';
	}

	private function getAccessToken() {
		// access_token 应该全局存储与更新
        $res = json_decode(file_get_contents($this->accessTokenFilePath));
        if($res == '' || $res->time+$res->expires_in <time()){
            $url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=$this->appId&secret=$this->appSecret";
            $res = json_decode($this->httpGet($url));
            $res->time = time();
//            错误代码直接返回
            if(isset($res->errcode)){
                return $res;
            }
            file_put_contents($this->accessTokenFilePath,json_encode($res));
        }
        $access_token = isset($res->access_token) ? $res->access_token : '';
		return $access_token;
	}

	private function httpGet($url) {
		$curl = curl_init();
		//全部是https 加上这两句防止返回为空
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST,FALSE);

		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_TIMEOUT, 500);
		curl_setopt($curl, CURLOPT_URL, $url);

		$res = curl_exec($curl);
		curl_close($curl);

		return $res;
	}
}


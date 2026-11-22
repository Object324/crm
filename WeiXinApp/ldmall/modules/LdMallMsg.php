<?php


class LdMallMsg extends LdMall
{

    public function send(){
        $access_token = $this->getAccessToken();
        $access_token = '50_5D8HLaUhPKEmbetR3kq2oPbMp6nrmF4fjbNmmcKCySu55Cx6UlrJT0R5vRPyZqGVKsiq9SQf-hR__EpnmrXAFE9hE5KnUrM9TqiVcFa-tk0Aq0usrYy1bjpgq9e5WTDKTOaEFl6sdPJYUF7kQRAgAJADEN';
        $touser = $_REQUEST['open_id'];
        $template_id = "mxBSjUljqW7HKXdp0xZjqmv14yl0ZJboXw8PdaiaL3w";
        //$page = "";
        $data = '{
            "touser": "'.$touser.'",
            "template_id": "'.$template_id.'",
            "page": "index",
            "miniprogram_state":"developer",
            "lang":"zh_CN",
            "data": {
                "name1": {
                    "value": "周晓梅"
                },
                "date2": {
                    "value": "2021-11-03"
                },
                "amount3": {
                    "value": "91.89"
                },
                "character_string4": {
                    "value": "ldcrm20211103"
                },
                "character_string9": {
                   "value": "ldcrm20211104"
                },
                "thing5": {
                   "value": "你已经成功支付啦"
                }
            }
        }';
        $url = "https://api.weixin.qq.com/cgi-bin/message/subscribe/send?access_token=".$access_token;
        $res = $this->curlPost($url,$data);
        return [1,['msginfo'=>$res,'ttoken'=>$access_token],'success'];
    }
}
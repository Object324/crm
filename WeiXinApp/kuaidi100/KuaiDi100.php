<?php
//ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型
//====================================
// 实时查询示例代码
// 授权信息可通过链接查看：https://api.kuaidi100.com/manager/page/myinfo/enterprise
//====================================

class KuaiDi100
{
    public $key;// 客户授权key
    public $url;// 请求地址
    public $customer;// 查询公司编号
    public $key_type;//查询类型
    public $com_code;//快递公司对应编码

    public function __construct()
    {
        global $conf;
        if(!file_exists(globalStatic::$root_directory.'user_privileges/KuaiDi100.inc.php') && file_exists(globalStatic::$root_directory.'user_privileges/KuaiDi100_Default.inc.php')) {
            copy(globalStatic::$root_directory.'user_privileges/KuaiDi100_Default.inc.php',globalStatic::$root_directory.'user_privileges/KuaiDi100.inc.php');
        }
        $settingsInfo = $this->getSettingsInfo();
        $this->key = $settingsInfo->fields['para_three'];
        $this->customer = $settingsInfo->fields['para_two'];
        $this->key_type = $settingsInfo->fields['para_one'];
        $this->url = 'https://poll.kuaidi100.com/poll/query.do';
        if (empty($settingsInfo->fields['para_two']) && empty($settingsInfo->fields['para_three'])){
            if (file_exists(globalStatic::$root_directory.'user_privileges/KuaiDi100.inc.php')){
                require_once(globalStatic::$root_directory.'user_privileges/KuaiDi100.inc.php');
                $this->key = $conf['key'];
                $this->customer = $conf['customer'];
                $this->url = $conf['url'];// 实时查询请求地址
            }
        }
        $this->com_code = array(
            "顺丰速运"=>"shunfeng",
            "圆通速递"=>"yuantong",
            "韵达快递"=>"yunda",
            "中通快递"=>"zhongtong",
            "申通快递"=>"shentong",
            "天天快递"=>"tiantian",
            "百世快递"=>"huitongkuaidi",
            "EMS"=>"ems",
            "德邦"=>"debangwuliu",
            "德邦快递"=>"debangkuaidi",
            "极兔速递"=>"jtexpress",
            "京东物流"=>"jd",
            "丹鸟"=>"danniao",
            "邮政快递包裹"=>"youzhengguonei",
            "EMS包裹"=>"emsbg",
            "邮政标准快递"=>"youzhengbk",
            "速必达"=>"subida",
            "优速快递"=>"youshuwuliu",
            "宅急送"=>"zhaijisong",
            "安得物流"=>"annto",
            "百世快运"=>"baishiwuliu",
            "丰网速运"=>"fengwang",
            "安能快运"=>"annengwuliu",
            "京东快运"=>"jingdongkuaiyun",
            "韵达快运"=>"yundakuaiyun",
            "顺丰快运"=>"shunfengkuaiyun",
            "中通快运"=>"zhongtongkuaiyun",
            "中通国际"=>"zhongtongguoji",
            "顺心捷达"=>"sxjdfreight",//ls 20230112 BUG0060784 增加几个物流
            "宇鑫物流"=>"yuxinwuliu",
            "三志物流"=>"sanzhi56",
            "壹米滴答"=>"yimidida",
            "红滨物流"=>"",
        );
    }

    public function synquery($express_no,$express_company='',$phone='')
    {
        $express_code = '';//快递公司对应编码
        if (!empty($express_company)) {
            $express_code = $this->com_code[$express_company];
        }

        $param = array (
            'com' => $express_code,             // 快递公司编码
            'num' => $express_no,     // 快递单号
            'phone' => $phone,                // 手机号
            'from' => '',                 // 出发地城市
            'to' => '',                   // 目的地城市
            'resultv2' => '4',            // 是否开启行政区域解析
            'show' => '0',                // 返回格式：0：json格式（默认），1：xml，2：html，3：text
            'order' => 'desc'             // 返回结果排序:desc降序（默认）,asc 升序
        );

        $returnMessage = [
            200 => getFixedLabel('EXPRESS_QUERY_SUCCESS'),
            400 => getFixedLabel('EXPRESS_NOT_FIND_COMPANY'),
            401 => getFixedLabel('EXPRESS_NOT_EXIST'),
            501 => getFixedLabel('EXPRESS_SERVER_ERROR'),
            502 => getFixedLabel('EXPRESS_SERVER_BUSY'),
            503 => getFixedLabel('EXPRESS_SIGN_VERIFY_FAILED'),
            601 => getFixedLabel('EXPRESS_KEY_EXPIRED')];

        //请求参数
        $post_data = array();
        $post_data['customer'] = $this->customer;
        $post_data['param'] = json_encode($param, JSON_UNESCAPED_UNICODE);
        $sign = md5($post_data['param'].$this->key.$post_data['customer']);
        $post_data['sign'] = strtoupper($sign);

        $data = $this->curl_post($this->url,$post_data);
        $data['returnMessage'] = $returnMessage[$data["returnCode"]];
        /*
        $data['returnCode']
        信息代码	信息内容描述	原因及建议处理方式
        200	查询成功	查询成功
        400	找不到对应公司	提交数据不完整或者账号未充值, 检查提交的格式是否为x-www-form-urlencoded的post格式
        500	查询无结果，请隔段时间再查	表示查询失败，或没有POST提交
        501	服务器错误	快递100的服务器出现间歇或临时性异常，有时如果因为不按规范提交请求，比如快递公司参数没有按照文档规定填写等，也会报此错误
        502	服务器繁忙	快递100的服务器出现间歇或临时性异常，请联系快递100排查原因
        503	验证签名失败	请检查加密方式，param + key + customer 的顺序进行MD5加密，加密后字符串转大写
        601	key已过期	没有可用单量，账号需要充值使用*/

        return $data;

    }

    public function curl_post($url,$post_data)
    {
        // 发送post请求
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($post_data));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        $result = curl_exec($ch);
        // 第二个参数为true，表示格式化输出json
        $data = ldcrm_json_decode($result, true);

        return $data;
    }

    public function getSettingsInfo()
    {
        global $adb;
        $name = 'express_100_interface_setting';
        $query = 'select * from ld_wx_config where name = ?';
        return $adb->pquery($query, array($name));
    }

    public function updateSettingsInfo($kuaiDi_100_Obj)
    {
        global $adb;
        $name = 'express_100_interface_setting';
        $query = 'update ld_wx_config set para_one = ?, para_two = ?, para_three = ? where name = ?';
        $adb->pquery($query, array(($this->key_type == 'default') ? 'default' : 'self_purchase', $this->customer, $this->key, $name));
    }


// 定义一个函数和关联数组来存储状态码和对应的详细信息
    public function getStatusDetail($statusCode) {
        // 定义关联数组存储状态码和对应的描述
        $logisticsStatus = [
            1 => "快件揽件",
            101 => "已经下快件单",
            102 => "待快递公司揽收",
            103 => "快递公司已经揽收",
            0 => "快件在途中",
            1001 => "快件到达收件人城市",
            1002 => "快件处于运输过程中",
            1003 => "快件发往到新的收件地址",
            5 => "快件正在派件",
            501 => "快件已经投递到快递柜或者快递驿站",
            3 => "快件已签收",
            301 => "收件人正常签收",
            302 => "快件显示派件异常，但后续正常签收",
            303 => "快件已被代签",
            304 => "快件已从快递柜或者驿站取出签收",
            6 => "快件正处于返回发货人的途中",
            4 => "此快件单已退签",
            401 => "此快件单已撤销",
            14 => "收件人拒签快件",
            7 => "快件转给其他快递公司邮寄",
            2 => "快件存在疑难",
            201 => "快件长时间派件后未签收",
            202 => "快件长时间没有派件或签收更新",
            203 => "收件人发起拒收快递,待发货方确认",
            204 => "快件派件时遇到异常情况",
            205 => "快件在快递柜或者驿站长时间未取",
            206 => "无法联系到收件人",
            207 => "超出快递公司的服务区范围",
            208 => "快件滞留在网点，没有派送",
            209 => "快件破损",
            210 => "寄件人申请撤销寄件",
            8 => "快件清关",
            10 => "快件等待清关",
            11 => "快件正在清关流程中",
            12 => "快件已完成清关流程",
            13 => "货物在清关过程中出现异常"
        ];

        // 返回状态码对应的描述，如果没有则返回 "未知状态码"
        return $logisticsStatus[$statusCode] ?? "未知状态码";
    }



}
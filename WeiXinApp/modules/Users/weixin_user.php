<?php
//editor:gyq_123 reason:新增微信用户类，方便管理并取代$PlatformMC的信息以及临时放入REQUEST的信息  2019/6/17 16:38 ID1000512
/* 特殊标识
 * MINIJROLD 小程序兼容旧版本代码标识
 * */
class weixin_user
{
    //当前使用者的身份标识
    public $openid;
    //editor:gyq_144 reason:钉钉  2019/9/11 18:02
    //editor:gyq_149 reason:移动端手机号显示样式  2019/10/14 17:22 ID1000522
    //区分企业微信小程序wxwork、微信小程序weixin、微信自助小程序weixin_self_help、钉钉dingtalk、企业微信H5应用weixinh5
    public $environment;
    public $current_user;
    /*editor:gyq_20190620 reason:增加acton,标识当前一级操作，例如
        单据"复制"标识 is_duplicate  2019/6/20 11:43 【ID1000517】
        合同报表，序时簿显示 saleskitscope 2019/7/10 11:38 ID1000554
        创建单据默认审批流程 default_on_new 2019/7/23 10:08 ID1000479
        单据明细界面提交审批默认流程 default_on_submit 2019/7/23 10:08 ID1000479
        钉钉发送提醒 dingtalk_remind
        选择源单 select_related_popu.php related_popu
    */
    public $action;
    //editor:gyq_127 对应$PlatformMC['type'] = 'weixin';区分出微信端和PC端，true=>微信端，false=>PC端 2019/6/26 15:45
    public $environment_weixin=false;
    //初始化$current_user成员变量
    public function init_platform($r_platform){
        foreach ($r_platform['current_user'] as $key=>$value){
            $this->current_user[$key] = $value;
        }
    }
    //返回是否是移动端
    public function isMobile(){
        $arr = ['app','fanwei','weixinh5','weixin','wxwork','dingtalk','yunzhijia','zhiyuan'];
        if(in_array($weixin_user->environment, $arr)){
            return 'yes';
        }
        return 'no';
    }

    //获取移动端类型
    public function getMobiletype(){
        $mobiletype = $this->getMobiletypeByevenvironment($this->environment);
        return $mobiletype;
    }
    public function getMobiletypeByevenvironment($environment){
        $mobiletype = $environment;
        //企业微信端登录 weixinh5=》 qiyeweixin，企业微信小程序登录 wxwork=》mini_wxwork，微信小程序登录 weixin=》mini_weixin
        //不做转换的其他移动端：钉钉端登录dingtalk，云之家登录 yunzhijia ，源生app登录 app ，泛微OA fanwei
        $environment_to_mobiletype = ['weixinh5'=>'qiyeweixin','wxwork'=>'mini_wxwork','weixin'=>'mini_weixin'];
        if(array_key_exists($environment,$environment_to_mobiletype)){
            $mobiletype = $environment_to_mobiletype[$environment];
        }
        return $mobiletype;
    }
}
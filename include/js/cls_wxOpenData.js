
function cls_wxOpenData()
{ 
    var that=this;
    this.getConfig=function(){
        
    }
    this.bindAllOpenDataByPopupObj=function(popupobj){
       
         //WWOpenData.bindAll(document.querySelectorAll('ww-open-data'));
      //alert(ld("#"+popupobj.divid+" [name=wxopendata").length);
     // if (/MicroMessenger/i.test(navigator.userAgent)) {
        //edit:can 2020-09-23 042729: （https://kehu001.com/KH/kh30033 [^] ）客户问题（普阳会计），销售管理->签约客户，查看范围选择高级，选择成员点击【确认】后，界面一直显示加载中，且界面下方显示空白
        if(popupobj!=undefined)
             WWOpenData.bindAll(ld("#"+popupobj.divid+" [name=wxopendata]"));
        else
            WWOpenData.bindAll(document.querySelectorAll('ww-open-data'));
      //}
    }
    this.bindAllOpenData=function(){
 
    
  // WWOpenData.bindAll(document.querySelectorAll('ww-open-data'));
       //if (/MicroMessenger/i.test(navigator.userAgent)) {
             WWOpenData.bindAll(ld(" [name=wxopendata]"));
      // }
    }
    this.bindAllTipData=function(){
        WWOpenData.bindAll(ld(" .tool_tip").find("[name=wxopendata]"));
    }
    this.init=function(){
        
        
           try {
              
                if (/MicroMessenger/i.test(navigator.userAgent)) {
                    
                     wxconfig(window.configParams)
                }
              
                 else{
                    agentConfig();
                    
                 }
          
              
              
            } catch (error) {
               
               console.log(error)
            }
          
             function wxconfig(config) {
                
                       
                      wx.config({
                        beta: true,// 必须这么写，否则wx.invoke调用形式的jsapi会有问题
                        debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                        appId: wx_corpid, // 必填，企业微信的corpID
                        timestamp: wx_timestamp, // 必填，生成签名的时间戳
                        nonceStr: wx_nonceStr, // 必填，生成签名的随机串
                        signature: wx_signature,// 必填，签名，见 附录-JS-SDK使用权限签名算法
                        jsApiList: ['selectExternalContact'], // 必填，需要使用的JS接口列表，凡是要调用的接口都需要传进来
                       
                    });
                      wx.ready(function(){
                        
                        agentConfig()
                        // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
                    });
            
            }
           
             function agentConfig() {
                   
                    wx.agentConfig({"agentid":wx_agentid,
                                "corpid":wx_corpid,
                                "jsApiList":['selectExternalContact'],
                                "nonceStr":wx_nonceStr,
                                "signature":wx_agent_signature,
                                "timestamp":wx_timestamp,
                              success:function(res){
                               
                              
                                
                                 if (WWOpenData.checkSession) {
                                        WWOpenData.checkSession({
                                            success:function() {
                                            //    alert('open-data 登录态校验成功1')
                                            },
                                            fail:function() {
                                               // alert('open-data 登录态过期1')
                                            },
                                        })
                                    }
                                    if (WWOpenData.on) {
                                   
                                        WWOpenData.on('update', function(event){
                                            const openid = event.detail.element.getAttribute('openid')
                                           
                                        })
                                        /**
                                         * ww-open-data 获取数据失败时触发
                                         */
                                        WWOpenData.on('error', function(){
                                            console.error('获取数据失败')
                                        })
                                    }
                                   
                                
                                    that.bindAllOpenData();
                          
                                
                                
                            }, 
                            fail:function(res){
                                console.log(res);
                                    //alert('res fail')
                            }
                })
                
            }
        
        
    }
    
}
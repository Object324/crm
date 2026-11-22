function lingdang(vueobj){
  var that=this;
  this.vueobj=vueobj;
  this.mobileSource = sessionStorage.getItem('mobileSource');

  this.get_userid=function(pagename){
    let cu_this = that.vueobj;
    var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/';
    if(that.mobileSource == 'fanwei'){
      url += 'fanwei/event.php';
    }
    if(that.mobileSource == 'zhiyuan'){
      url += 'zhiyuan/event.php';
    }
    var params = {
      action: 'get_userid',
      diony: Tools.randomString(8)
    };
    if(that.mobileSource == 'fanwei'){
      params['fanwei_userid_encode'] = sessionStorage.getItem('gonghao');
    }
    if(that.mobileSource == 'zhiyuan'){
      params['zhiyuan_ticket'] = sessionStorage.getItem('zhiyuan_ticket');
    }
    lingdangAjax(url, params, function(data){
      if(data.code == 1){
        sessionStorage.setItem('userid', data.result.userid);
        if(that.mobileSource == 'zhiyuan'){
          sessionStorage.setItem('zhiyuan_userid', data.result.zhiyuan_userid);
        }
        if(pagename == 'home'){
          cu_this.getTabbar();//获取打开标签
          cu_this.checkExpiredTime();
          cu_this.getPublicFixedLabel();
          cu_this.getHome();
        }
        if(pagename == 'index'){
          cu_this.getTabbar();//获取打开标签
          cu_this.getPublicFixedLabel();
          cu_this.getModuleData();//获取模块信息
        }
        if(pagename == 'list'){
          cu_this.getTabInfo();
        }
        if(pagename == 'detail'){
          cu_this.getDeailView();
        }
        if(pagename == 'work_list'){
          cu_this.getModuleData();
        }
        if(pagename == 'work_detail'){
          cu_this.getDeailView();
        }
      }
      else{
        cu_this.popPromptBox(data.msg);//弹出框提示
        return;
      }
    });
  }

  this.dingding_check_login=function(){
    if (dd.env.platform !== "notInDingTalk") {
      var fromlogintype=sessionStorage.getItem('fromlogintype');
      var _config = JSON.parse(sessionStorage.getItem('_config'));
      if(_config && fromlogintype != 'remindsmsg'){
        //钉钉JSAPI鉴权
        lingdang.dingtalk_config();
        // 查看鉴权错误信息
        dd.error(function(err) {
          alert('dd error2: ' + JSON.stringify(err));
        });
      }
      else{
        let corpid = sessionStorage.getItem('corpid');
        if(corpid==''){
          corpid = getQueryStringByName('corpid');
          sessionStorage.setItem('corpid',corpid);
          sessionStorage.setItem('corpurl',getQueryStringByName('corpurl'));
        }
        
        // 获取鉴权信息
        var corpurl = sessionStorage.getItem('corpurl');
        var url = corpurl + 'WeiXinApp/dingtalk/event.php';
        var params = {
          action: 'isvConfig',
          corpurl: encodeURIComponent(corpurl),
          // corpurl_new: 'selfbuildSass',
          diony: Tools.randomString(8)
        };
        $.ajaxSettings.async = false;
        lingdangAjax(url, params, function(data){
          $.ajaxSettings.async = true;
          if(data.code == 1){
            var _config = Object();
            _config.agentId = data.result.agentId;
            _config.corpId = data.result.corpId;
            _config.timeStamp = data.result.timeStamp;
            _config.nonceStr = data.result.nonceStr;
            _config.signature = data.result.signature;
            sessionStorage.setItem('_config',JSON.stringify(_config));

            //钉钉JSAPI鉴权
            lingdang.dingtalk_config();

            // 查看鉴权错误信息
            dd.error(function(err) {
              alert('dd error1: ' + JSON.stringify(err));
            });
          }
          else{
            alert(data.msg);//弹出框提示
            return;
          }
        });
      }
    }
  }

  this.yuanzhijia_get_corpurl=function(){
    if (sessionStorage.getItem("corpurl") != '' && sessionStorage.getItem("corpurl") != null && sessionStorage.getItem("corpurl") != 'undefined') {
    }
    else{
      let url = 'http://www.51mis.cn/webapi/yunzhijia/index.php?controller=order&function=getCrmCorpurl';
      var params = {
        eid: sessionStorage.getItem('corpid'),
        diony: Tools.randomString(8)
      };
      $.ajaxSettings.async = false;
      lingdangAjax(url, params, function(data){
        $.ajaxSettings.async = true;
        if(data.code == 1){
          let corpurl = data.data.corpurl;
          let corpurl_last = corpurl.substr(corpurl.length-1,1)
          if(corpurl_last != '/'){
            corpurl = corpurl + '/';
          }
          sessionStorage.setItem('corpurl', corpurl);
        }
        else{
          alert('获取URL失败');
          return;
        }
      });
    }
  }
  this.yuanzhijia_get_userid=function(pagename){
    let cu_this = that.vueobj;
    that.yuanzhijia_get_corpurl();

    var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/yunzhijia/event.php';
    var params = {
      action: 'get_userid',
      openid: sessionStorage.getItem('y_openId'),
      wbnetworkid: sessionStorage.getItem('y_wbnetworkid'),
      wbuserid: sessionStorage.getItem('y_wbuserid'),
      applicationType: 'common',//common market
      diony: Tools.randomString(8)
    };
    lingdangAjax(url, params, function(data){
      if(data.code == 1){
        sessionStorage.setItem('userid', data.result.userid);
        if(pagename == 'home'){
          cu_this.getTabbar();//获取打开标签
          cu_this.getPublicFixedLabel();
          cu_this.getHome();
        }
        if(pagename == 'index'){
          cu_this.getTabbar();//获取打开标签
          cu_this.getPublicFixedLabel();
          cu_this.getModuleData();
        }
        if(pagename == 'list'){
          cu_this.getTabInfo();
        }
        if(pagename == 'detail'){
          cu_this.getDeailView();
        }
        if(pagename == 'work_list'){
          cu_this.getModuleData();
        }
        if(pagename == 'work_detail'){
          cu_this.getDeailView();
        }
      }
      else{
        cu_this.popPromptBox(data.msg);//弹出框提示
        return;
      }
    });
  }

  this.home_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          if(userid=='' || userid==null){
            dd.runtime.permission.requestAuthCode({
              corpId: sessionStorage.getItem('corpid'), // 企业id
              onSuccess: function (info) {
                var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/dingtalk/event.php';
                var params = {
                  action: 'get_userid',
                  code: info['code'],
                  diony: Tools.randomString(8)
                };
                lingdangAjax(url, params, function(data){
                  if(data.code == 1){
                    sessionStorage.setItem('userid', data.result.userid);
                    cu_this.getTabbar();//获取打开标签
                    cu_this.getPublicFixedLabel();
                    cu_this.getHome();
                  }
                  else{
                    cu_this.popPromptBox(data.msg);//弹出框提示
                    return;
                  }
                });
              }
            });
          }
          else{
            cu_this.getTabbar();//获取打开标签
            cu_this.getPublicFixedLabel();
            cu_this.getHome();
          }

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_zero = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'home'){
                if(cu_this.showChooseUsersPage){
                  lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                  cu_this.showDashboard = true;
                  cu_this.showChooseUsersPage = false;
                  return false;
                }
                else if(cu_this.showCustomPage){
                  lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                  cu_this.showDashboard = true;
                  cu_this.showCustomPage = false;
                  return false;
                }
                else if(cu_this.showDateApprovePage){
                  lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                  cu_this.showDashboard = true;
                  cu_this.showDateApprovePage = false;
                  return false;
                }
                else if(cu_this.showDashboardSecondPage){
                  lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                  cu_this.showListviewPage = true;
                  cu_this.showDashboardSecondPage = false;
                  return false;
                }
                else{
                  dd.biz.navigation.close();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_zero, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'home'){
                  if(cu_this.showChooseUsersPage){
                    lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                    cu_this.showDashboard = true;
                    cu_this.showChooseUsersPage = false;
                    return false;
                  }
                  else if(cu_this.showCustomPage){
                    lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                    cu_this.showDashboard = true;
                    cu_this.showCustomPage = false;
                    return false;
                  }
                  else if(cu_this.showDateApprovePage){
                    lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                    cu_this.showDashboard = true;
                    cu_this.showDateApprovePage = false;
                    return false;
                  }
                  else if(cu_this.showDashboardSecondPage){
                    lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                    cu_this.showListviewPage = true;
                    cu_this.showDashboardSecondPage = false;
                    return false;
                  }
                  else{
                    dd.biz.navigation.close();  
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
      else{
        // 浏览器模拟登陆，无法使用钉钉接口
        sessionStorage.setItem('dingding_demo' ,'no');
        if(sessionStorage.getItem('dingding_demo') == 'yes'){
          sessionStorage.setItem('userid' ,'075406153236347787');
          sessionStorage.setItem('corpurl' ,'https://www.81mis.com/kfbcrm/');
          cu_this.getTabbar();//获取打开标签
          cu_this.getPublicFixedLabel();
          cu_this.getHome();
        }
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      if(userid=='' || userid==0 ||  userid==null){
        // 获取个人信息
        qing.call('getPersonInfo', {
          success : function(res){
            // alert(JSON.stringify(res));
            sessionStorage.setItem('y_openId',res.data.openId);
            sessionStorage.setItem('y_wbnetworkid',res.data.wbnetworkid);
            sessionStorage.setItem('y_wbuserid',res.data.wbuserid);
            sessionStorage.setItem('corpid', res.data.eid);

            that.yuanzhijia_get_userid('home');
          }
        });
        // 浏览器模拟登陆，无法使用云之家接口
        // sessionStorage.setItem('y_openId', '5f83b321e4b08696ef184b5b');
        // sessionStorage.setItem('y_wbnetworkid', '5f7fffa7e4b02233506f7d85');
        // sessionStorage.setItem('y_wbuserid', '550f7ac1dd9487b27870727f');
        // sessionStorage.setItem('corpurl' ,'https://www.81mis.com/kfbcrm/');
        // that.yuanzhijia_get_userid('home');
      }
      else{
        cu_this.getTabbar();//获取打开标签
        cu_this.getPublicFixedLabel();
        cu_this.getHome();//获取模块信息
      }

      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'home'){
            lingdang.closeWindows();
          }
        }
      });

      lingdang.getDeviceid();
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      if(userid=='' || userid==0 ||  userid==null){
        that.get_userid('home');
      }
      else{
        cu_this.getTabbar();//获取打开标签
        cu_this.getPublicFixedLabel();
        cu_this.getHome();//获取首页信息
      }
    }
    else if(that.mobileSource == 'app'){
      cu_this.getTabbar();//获取打开标签
      cu_this.checkExpiredTime();
      cu_this.getPublicFixedLabel();
      cu_this.getHome();//获取首页信息

      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.showChooseUsersPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
            cu_this.showDashboard = true;
            cu_this.showChooseUsersPage = false;
            return false;
          }
          else if(cu_this.showCustomPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
            cu_this.showDashboard = true;
            cu_this.showCustomPage = false;
            return false;
          }
          else if(cu_this.showDateApprovePage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
            cu_this.showDashboard = true;
            cu_this.showDateApprovePage = false;
            return false;
          }
          else if(cu_this.showDashboardSecondPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
            cu_this.showListviewPage = true;
            cu_this.showDashboardSecondPage = false;
            return false;
          }
          else{
            lingdang.closeWindows();
            return false;
          }
        });
      }
    }
    else{
      cu_this.getTabbar();//获取打开标签
      cu_this.checkExpiredTime();
      cu_this.getPublicFixedLabel();
      cu_this.getHome();//获取首页信息
      //执行jssdk接口，页面加载时可用
      wx.ready(function () {
        wx.hideAllNonBaseMenuItem();//隐藏所有按钮（“传播类”和“保护类"）
        lingdang.hideMenuItemsBefore();
        lingdang.getAgentConfig();//agentConfig调用

        if(wx.onHistoryBack){
          wx.onHistoryBack(function(){
            if(cu_this.$route.name == 'home'){
              if(cu_this.showChooseUsersPage){
                lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                cu_this.showDashboard = true;
                cu_this.showChooseUsersPage = false;
                return false;
              }
              else if(cu_this.showCustomPage){
                lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                cu_this.showDashboard = true;
                cu_this.showCustomPage = false;
                return false;
              }
              else if(cu_this.showDateApprovePage){
                lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                cu_this.showDashboard = true;
                cu_this.showDateApprovePage = false;
                return false;
              }
              else if(cu_this.showDashboardSecondPage){
                lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPWORKBENCH);
                cu_this.showListviewPage = true;
                cu_this.showDashboardSecondPage = false;
                return false;
              }
            }
            else{
              return true;
            }
          });
        }
      });
    }
  }

  this.register_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'register'){
            lingdang.closeWindows();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      //执行jssdk接口，页面加载时可用
      wx.ready(function () {
        wx.hideAllNonBaseMenuItem();//隐藏所有按钮（“传播类”和“保护类"）
        lingdang.hideMenuItemsBefore();
      });
    }
  }

  this.index_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPFUNCTION);//设置导航栏标题
          cu_this.getTabbar();//获取打开标签
          cu_this.getPublicFixedLabel();
          cu_this.getModuleData();//获取模块信息

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_home = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'first'){
                let democlass = $('#panel-js-demo').attr('class');
                if(democlass.indexOf('active') > -1) {
                  $.closePanel();
                }
                else if(cu_this.showCommonmodulesPage){
                  lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPFUNCTION);
                  cu_this.showIndexPage = true;
                  cu_this.showCommonmodulesPage = false;
                  return false;
                }
                else {
                  dd.biz.navigation.close();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_home, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'first'){
                  let democlass = $('#panel-js-demo').attr('class');
                  if(democlass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else if(cu_this.showCommonmodulesPage){
                    lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPFUNCTION);
                    cu_this.showIndexPage = true;
                    cu_this.showCommonmodulesPage = false;
                    return false;
                  }
                  else {
                    dd.biz.navigation.close();
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
      else{
        // 浏览器模拟登陆，无法使用钉钉接口
        if(sessionStorage.getItem('dingding_demo') == 'yes'){
          cu_this.getTabbar();
          cu_this.getPublicFixedLabel();
          cu_this.getModuleData();
        }
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      if(userid=='' || userid==0 ||  userid==null){
        // 获取个人信息
        qing.call('getPersonInfo', {
          success : function(res){
            // alert(JSON.stringify(res));
            sessionStorage.setItem('y_openId',res.data.openId);
            sessionStorage.setItem('y_wbnetworkid',res.data.wbnetworkid);
            sessionStorage.setItem('y_wbuserid',res.data.wbuserid);
            sessionStorage.setItem('corpid', res.data.eid);

            that.yuanzhijia_get_userid('index');
          }
        });
      }
      else{
        cu_this.getTabbar();//获取打开标签
        cu_this.getPublicFixedLabel();
        cu_this.getModuleData();//获取模块信息
      }

      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'first' || cu_this.$route.name == undefined){
            let democlass = $('#panel-js-demo').attr('class');
            if(democlass.indexOf('active') > -1) {
              $.closePanel();
            }
            else if(cu_this.showCommonmodulesPage){
              lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPFUNCTION);
              cu_this.showIndexPage = true;
              cu_this.showCommonmodulesPage = false;
              return false;
            }
            else{
              lingdang.closeWindows();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      if(userid=='' || userid==0 ||  userid==null){
        that.get_userid('index');
      }
      else{
        cu_this.getTabbar();//获取打开标签
        cu_this.getPublicFixedLabel();
        cu_this.getModuleData();//获取模块信息
      }
    }
    else if(that.mobileSource == 'app'){
      cu_this.getTabbar();//获取打开标签
      cu_this.getPublicFixedLabel();
      cu_this.getModuleData();//获取模块信息

      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.showSystemPermissionPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPSETTINGS);
            cu_this.showIndexPage = true;
            cu_this.showSystemPermissionPage = false;
            return false;
          }
          else if(cu_this.showCallRecordingPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPSETTINGS);
            cu_this.showIndexPage = true;
            cu_this.showCallRecordingPage = false;
            return false;
          }
          else if(cu_this.showPrivacyPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPSETTINGS);
            cu_this.showIndexPage = true;
            cu_this.showPrivacyPage = false;
            return false;
          }
          else if(cu_this.showAboutPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPSETTINGS);
            cu_this.showIndexPage = true;
            cu_this.showAboutPage = false;
            return false;
          }
          else if(cu_this.showCommonmodulesPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPFUNCTION);
            cu_this.showIndexPage = true;
            cu_this.showCommonmodulesPage = false;
            return false;
          }
          else{
            lingdang.closeWindows();
            return false;
          }
        });
      }
    }
    else{
      cu_this.getTabbar();//获取打开标签
      cu_this.getPublicFixedLabel();
      cu_this.getModuleData();//获取模块信息
      wx.ready(function () {
        if(wx.onHistoryBack){
          wx.onHistoryBack(function(){
            if(cu_this.$route.name == 'first'){
              if(cu_this.showCommonmodulesPage){
                lingdang.setDocumentTitle(cu_this.arrFixedLabel.APPFUNCTION);
                cu_this.showIndexPage = true;
                cu_this.showCommonmodulesPage = false;
                return false;
              }
            }
            else{
              return true;
            }
          });
        }
      });
    }
  }

  this.second_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_zero = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'second'){
                dd.biz.navigation.close();
              }
            };
            document.addEventListener('backbutton', backbutton_zero, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'second'){
                  dd.biz.navigation.close();
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'second'){
            let approveclass = $('#panel-js-approve').attr('class');
            if(approveclass.indexOf('active') > -1) {
              $.closePanel();
            }
            else{
              lingdang.closeWindows();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.showChooseUsersPage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.staydo);
            cu_this.showApprovePage = true;
            cu_this.showChooseUsersPage = false;
            return false;
          }
          else if(cu_this.showQuickCreatePage){
            lingdang.setDocumentTitle(cu_this.arrFixedLabel.staydo);
            cu_this.showWaitingPage = true;
            cu_this.showQuickCreatePage = false;
            return false;
          }
          else{
            lingdang.closeWindows();
            return false;
          }
        });
      }
    }
  }

  this.third_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_third = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'third'){
                dd.biz.navigation.close();
              }
            };
            document.addEventListener('backbutton', backbutton_third, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'third'){
                  dd.biz.navigation.close();
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'third'){
            lingdang.closeWindows();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          lingdang.closeWindows();
          return false;
        });
      }
    }
    else{
    }
  }

  this.list_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          if(userid=='' || userid==null){
            dd.runtime.permission.requestAuthCode({
              corpId: sessionStorage.getItem('corpid'), // 企业id
              onSuccess: function (info) {
                var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/dingtalk/event.php';
                var params = {
                  action: 'get_userid',
                  code: info['code'],
                  diony: Tools.randomString(8)
                };
                lingdangAjax(url, params, function(data){
                  if(data.code == 1){
                    sessionStorage.setItem('userid', data.result.userid);
                    cu_this.getTabInfo();
                  }
                  else{
                    cu_this.popPromptBox(data.msg);//弹出框提示
                    return;
                  }
                });
              }
            });
          }
          else{
            cu_this.getTabInfo();//页签信息
          }

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_list = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'listview'){
                if(cu_this.showRepeatPage){
                  cu_this.showListviewPage = true;
                  cu_this.showRepeatPage = false;
                }
                else if(cu_this.showChooseUsersPage){
                  cu_this.showListviewPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showSubmitApprovePage){
                  cu_this.showListviewPage = true;
                  cu_this.showSubmitApprovePage = false;
                }
                else{
                  let democlass = $('#panel-js-demo').attr('class');
                  let searchclass = $('#panel-js-search').attr('class');
                  if(democlass.indexOf('active') > -1 || searchclass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else {
                    dd.biz.navigation.goBack();
                  }
                }
              }
            };
            document.addEventListener('backbutton', backbutton_list, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'listview'){
                  if(cu_this.showRepeatPage){
                    cu_this.showListviewPage = true;
                    cu_this.showRepeatPage = false;
                  }
                  else if(cu_this.showChooseUsersPage){
                    cu_this.showListviewPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showSubmitApprovePage){
                    cu_this.showListviewPage = true;
                    cu_this.showSubmitApprovePage = false;
                  }
                  else{
                    let democlass = $('#panel-js-demo').attr('class');
                    let searchclass = $('#panel-js-search').attr('class');
                    if(democlass.indexOf('active') > -1 || searchclass.indexOf('active') > -1) {
                      $.closePanel();
                    }
                    else {
                      dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                      dd.biz.navigation.goBack();
                    }
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
      else{
        // 浏览器模拟登陆，无法使用钉钉接口
        if(sessionStorage.getItem('dingding_demo') == 'yes'){
          cu_this.getTabInfo();
        }
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      if(userid=='' || userid==0 ||  userid==null){
        // 获取个人信息
        qing.call('getPersonInfo', {
          success : function(res){
            // alert(JSON.stringify(res));
            sessionStorage.setItem('y_openId',res.data.openId);
            sessionStorage.setItem('y_wbnetworkid',res.data.wbnetworkid);
            sessionStorage.setItem('y_wbuserid',res.data.wbuserid);
            sessionStorage.setItem('corpid', res.data.eid);

            that.yuanzhijia_get_userid('list');
          }
        });
      }
      else{
        cu_this.getTabInfo();
      }

      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'listview'){
            lingdang.setDocumentTitle(cu_this.modulelable);
            if(cu_this.showRepeatPage){
              cu_this.showListviewPage = true;
              cu_this.showRepeatPage = false;
            }
            else if(cu_this.showChooseUsersPage){
              cu_this.showListviewPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showListviewPage = true;
              cu_this.showSubmitApprovePage = false;
            }
            else{
              let democlass = $('#panel-js-demo').attr('class');
              let searchclass = $('#panel-js-search').attr('class');
              if(democlass.indexOf('active') > -1 || searchclass.indexOf('active') > -1) {
                $.closePanel();
              }
              else{
                history.back();
              }
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      if(userid=='' || userid==0 ||  userid==null){
        that.get_userid('list');
      }
      else{
        cu_this.getTabInfo();
      }
    }
    else if(that.mobileSource == 'app'){
      cu_this.getTabInfo();
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'listview'){
            if(cu_this.showRepeatPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showRepeatPage = false;
              return false;
            }
            else if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showSubmitApprovePage = false;
              return false;
            }
            else{
              let democlass = $('#panel-js-demo').attr('class');
              let searchclass = $('#panel-js-search').attr('class');
              if(democlass.indexOf('active') > -1 || searchclass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      cu_this.getTabInfo();
      wx.hideAllNonBaseMenuItem();//隐藏所有按钮（“传播类”和“保护类"）
      lingdang.hideMenuItemsBefore();
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'listview'){
            if(cu_this.showRepeatPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showRepeatPage = false;
              return false;
            }
            else if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showSubmitApprovePage = false;
              return false;
            }
            else if(cu_this.showDetailViewPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showListviewPage = true;
              cu_this.showDetailViewPage = false;
              return false;
            }
            else{
              let democlass = $('#panel-js-demo').attr('class');
              let searchclass = $('#panel-js-search').attr('class');
              if(democlass.indexOf('active') > -1 || searchclass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.listglobal_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_list = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'listviewglobal'){
                let democlass = $('#panel-js-demo').attr('class');
                if(democlass.indexOf('active') > -1) {
                  $.closePanel();
                }
                else {
                  dd.biz.navigation.goBack();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_list, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'listviewglobal'){
                  let democlass = $('#panel-js-demo').attr('class');
                  if(democlass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else {
                    dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                    dd.biz.navigation.goBack();
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'listviewglobal'){
            let democlass = $('#panel-js-demo').attr('class');
            if(democlass.indexOf('active') > -1) {
              $.closePanel();
            }
            else{
              history.back();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'listviewglobal'){
            let democlass = $('#panel-js-demo').attr('class');
            if(democlass.indexOf('active') > -1) {
              $.closePanel();
              return false;
            }
            else{
              return true;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'listviewglobal'){
            let democlass = $('#panel-js-demo').attr('class');
            if(democlass.indexOf('active') > -1) {
              $.closePanel();
              return false;
            }
            else{
              return true;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.create_edit_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          if(userid=='' || userid==null){
            dd.runtime.permission.requestAuthCode({
              corpId: sessionStorage.getItem('corpid'), // 企业id
              onSuccess: function (info) {
                var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/dingtalk/event.php';
                var params = {
                  action: 'get_userid',
                  code: info['code'],
                  diony: Tools.randomString(8)
                };
                lingdangAjax(url, params, function(data){
                  if(data.code == 1){
                    sessionStorage.setItem('userid', data.result.userid);
                    cu_this.gotoCreateOrEdit();
                  }
                  else{
                    cu_this.popPromptBox(data.msg);//弹出框提示
                    return;
                  }
                });
              }
            });
          }
          else{
            cu_this.gotoCreateOrEdit();//获取新增、编辑信息
          }

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_create = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'creat_edit_view'){
                lingdang.setDocumentTitle(cu_this.wechattitle);
                if(cu_this.showChooseUsersPage){
                  cu_this.showListPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showRelationPage){
                  cu_this.showListPage = true;
                  cu_this.showRelationPage = false;
                }
                else if(cu_this.showOptionPage){
                  cu_this.showListPage = true;
                  cu_this.showOptionPage = false;
                }
                else if(cu_this.showRepeatPage){
                  cu_this.showListPage = true;
                  cu_this.showRepeatPage = false;
                }
                else if(cu_this.showTablePage){
                  cu_this.showListPage = true;
                  cu_this.showTablePage = false;
                }
                else if(cu_this.showTablebeforlistPage){
                  cu_this.showListPage = true;
                  cu_this.showTablebeforlistPage = false;
                }
                else if(cu_this.showAddressPage){
                  cu_this.showListPage = true;
                  cu_this.showAddressPage = false;
                }
                else if(cu_this.showSubmitApprovePage){
                  cu_this.showListPage = true;
                  cu_this.showSubmitApprovePage = false;
                }
                else if(cu_this.showPoisListPage){
                  cu_this.showListPage = true;
                  cu_this.showPoisListPage = false;
                }
                else if(cu_this.showQuickCreatePage){
                  cu_this.showListPage = true;
                  cu_this.showQuickCreatePage = false;
                }
                else if(cu_this.showFilePreviewPage){
                  cu_this.showListPage = true;
                  cu_this.showFilePreviewPage = false;
                }
                else{
                  dd.device.notification.confirm({
                    message: cu_this.arrFixedLabel.DISCARDTHEMODIFICATION,
                    title: cu_this.weuiTitle,
                    buttonLabels: [sessionStorage.getItem("CANCEL"), sessionStorage.getItem("CONFIRMED")],
                    onSuccess : function(result) {
                      if(result.buttonIndex==0){
                      }
                      else if(result.buttonIndex==1){
                        lingdang.localStorageOldHaveNewEmpty(cu_this.systemsDataCreate, cu_this.mainmodule, cu_this.accountType);//暂存：将new赋值到old
                        dd.biz.navigation.goBack();//返回上一级页面
                      }
                    },
                    onFail : function(err) {}
                  });
                }
              }
            };
            document.addEventListener('backbutton', backbutton_create, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'creat_edit_view'){
                  lingdang.setDocumentTitle(cu_this.wechattitle);
                  if(cu_this.showChooseUsersPage){
                    cu_this.showListPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showRelationPage){
                    cu_this.showListPage = true;
                    cu_this.showRelationPage = false;
                  }
                  else if(cu_this.showOptionPage){
                    cu_this.showListPage = true;
                    cu_this.showOptionPage = false;
                  }
                  else if(cu_this.showRepeatPage){
                    cu_this.showListPage = true;
                    cu_this.showRepeatPage = false;
                  }
                  else if(cu_this.showTablePage){
                    cu_this.showListPage = true;
                    cu_this.showTablePage = false;
                  }
                  else if(cu_this.showTablebeforlistPage){
                    cu_this.showListPage = true;
                    cu_this.showTablebeforlistPage = false;
                  }
                  else if(cu_this.showAddressPage){
                    cu_this.showListPage = true;
                    cu_this.showAddressPage = false;
                  }
                  else if(cu_this.showSubmitApprovePage){
                    cu_this.showListPage = true;
                    cu_this.showSubmitApprovePage = false;
                  }
                  else if(cu_this.showPoisListPage){
                    cu_this.showListPage = true;
                    cu_this.showPoisListPage = false;
                  }
                  else if(cu_this.showQuickCreatePage){
                    cu_this.showListPage = true;
                    cu_this.showQuickCreatePage = false;
                  }
                  else if(cu_this.showFilePreviewPage){
                    cu_this.showListPage = true;
                    cu_this.showFilePreviewPage = false;
                  }
                  else{
                    dd.device.notification.confirm({
                      message: cu_this.arrFixedLabel.DISCARDTHEMODIFICATION,
                      title: cu_this.weuiTitle,
                      buttonLabels: [sessionStorage.getItem("CANCEL"), sessionStorage.getItem("CONFIRMED")],
                      onSuccess : function(result) {
                        if(result.buttonIndex==0){
                        }
                        else if(result.buttonIndex==1){
                          lingdang.localStorageOldHaveNewEmpty(cu_this.systemsDataCreate, cu_this.mainmodule, cu_this.accountType);//暂存：将new赋值到old
                          dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                          dd.biz.navigation.goBack();//返回上一级页面
                        }
                      },
                      onFail : function(err) {}
                    });
                  }
                }
              },
              onFail : function(err) {}
            });
          }
          dd.device.base.getUUID({
            onSuccess: function (data) {
              cu_this.DeviceId = data['uuid'];
            },
            onFail: function (err) {
            }
          });
        });
      }
      else{
        // 浏览器模拟登陆，无法使用钉钉接口
        if(sessionStorage.getItem('dingding_demo') == 'yes'){
          cu_this.gotoCreateOrEdit();
        }
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      cu_this.gotoCreateOrEdit();
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'creat_edit_view'){
            lingdang.setDocumentTitle(cu_this.wechattitle);
            if(cu_this.showChooseUsersPage){
              cu_this.showListPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showListPage = true;
              cu_this.showRelationPage = false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showListPage = true;
              cu_this.showOptionPage = false;
            }
            else if(cu_this.showRepeatPage){
              cu_this.showListPage = true;
              cu_this.showRepeatPage = false;
            }
            else if(cu_this.showTablePage){
              cu_this.showListPage = true;
              cu_this.showTablePage = false;
            }
            else if(cu_this.showTablebeforlistPage){
              cu_this.showListPage = true;
              cu_this.showTablebeforlistPage = false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showListPage = true;
              cu_this.showAddressPage = false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showListPage = true;
              cu_this.showSubmitApprovePage = false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showListPage = true;
              cu_this.showPoisListPage = false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showListPage = true;
              cu_this.showQuickCreatePage = false;
            }
            else if(cu_this.showFilePreviewPage){
              cu_this.showListPage = true;
              cu_this.showFilePreviewPage = false;
            }
            else{
              cu_this.createBackTip();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      cu_this.gotoCreateOrEdit();
    }
    else if(that.mobileSource == 'app'){
      cu_this.gotoCreateOrEdit();
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'creat_edit_view'){
            if(cu_this.showChooseUsersPage){
              cu_this.showListPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showListPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showListPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRepeatPage){
              cu_this.showListPage = true;
              cu_this.showRepeatPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showTablePage){
              cu_this.showListPage = true;
              cu_this.showTablePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showTablebeforlistPage){
              cu_this.showListPage = true;
              cu_this.showTablebeforlistPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showListPage = true;
              cu_this.showAddressPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showListPage = true;
              cu_this.showSubmitApprovePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showListPage = true;
              cu_this.showPoisListPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showListPage = true;
              cu_this.showQuickCreatePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showFilePreviewPage){
              cu_this.showListPage = true;
              cu_this.showFilePreviewPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      cu_this.gotoCreateOrEdit();
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'creat_edit_view'){
            if(cu_this.showChooseUsersPage){
              cu_this.showListPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showListPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showListPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRepeatPage){
              cu_this.showListPage = true;
              cu_this.showRepeatPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showTablePage){
              cu_this.showListPage = true;
              cu_this.showTablePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showTablebeforlistPage){
              cu_this.showListPage = true;
              cu_this.showTablebeforlistPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showListPage = true;
              cu_this.showAddressPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showListPage = true;
              cu_this.showSubmitApprovePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showListPage = true;
              cu_this.showPoisListPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showListPage = true;
              cu_this.showQuickCreatePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showFilePreviewPage){
              cu_this.showListPage = true;
              cu_this.showFilePreviewPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.create_edit2_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'creat_edit_view'){
            if(cu_this.showChooseUsersPage){
              cu_this.showListPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showListPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showListPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRepeatPage){
              cu_this.showListPage = true;
              cu_this.showRepeatPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showTablePage){
              cu_this.showListPage = true;
              cu_this.showTablePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showTablebeforlistPage){
              cu_this.showListPage = true;
              cu_this.showTablebeforlistPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showListPage = true;
              cu_this.showAddressPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.re_create_edit_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_rcreate = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'relative_createdit_view'){
                lingdang.setDocumentTitle(cu_this.wechattitle);//设置导航栏标题
                if(cu_this.showChooseUsersPage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showRelationPage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showRelationPage = false;
                }
                else if(cu_this.showOptionPage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showOptionPage = false;
                }
                else if(cu_this.showAddressPage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showAddressPage = false;
                }
                else if(cu_this.showSubmitApprovePage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showSubmitApprovePage = false;
                }
                else if(cu_this.showPoisListPage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showPoisListPage = false;
                }
                else if(cu_this.showQuickCreatePage){
                  cu_this.showreLativelistPage = true;
                  cu_this.showQuickCreatePage = false;
                }
                else{
                  dd.device.notification.confirm({
                    message: cu_this.arrFixedLabel.DISCARDTHEMODIFICATION,
                    title: cu_this.weuiTitle,
                    buttonLabels: [sessionStorage.getItem("CANCEL"), sessionStorage.getItem("CONFIRMED")],
                    onSuccess : function(result) {
                      if(result.buttonIndex==0){
                      }
                      else if(result.buttonIndex==1){
                        dd.biz.navigation.goBack();//返回上一级页面
                      }
                    },
                    onFail : function(err) {}
                  });
                }
              }
            };
            document.addEventListener('backbutton', backbutton_rcreate, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'relative_createdit_view'){
                  lingdang.setDocumentTitle(cu_this.wechattitle);//设置导航栏标题
                  if(cu_this.showChooseUsersPage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showRelationPage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showRelationPage = false;
                  }
                  else if(cu_this.showOptionPage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showOptionPage = false;
                  }
                  else if(cu_this.showAddressPage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showAddressPage = false;
                  }
                  else if(cu_this.showSubmitApprovePage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showSubmitApprovePage = false;
                  }
                  else if(cu_this.showPoisListPage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showPoisListPage = false;
                  }
                  else if(cu_this.showQuickCreatePage){
                    cu_this.showreLativelistPage = true;
                    cu_this.showQuickCreatePage = false;
                  }
                  else{
                    dd.device.notification.confirm({
                      message: cu_this.arrFixedLabel.DISCARDTHEMODIFICATION,
                      title: cu_this.weuiTitle,
                      buttonLabels: [sessionStorage.getItem("CANCEL"), sessionStorage.getItem("CONFIRMED")],
                      onSuccess : function(result) {
                        if(result.buttonIndex==0){
                        }
                        else if(result.buttonIndex==1){
                          dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                          dd.biz.navigation.goBack();//返回上一级页面
                        }
                      },
                      onFail : function(err) {}
                    });
                  }
                }
              },
              onFail : function(err) {}
            });
          }

          dd.device.base.getUUID({
            onSuccess: function (data) {
              cu_this.DeviceId = data['uuid'];
            },
            onFail: function (err) {
            }
          });
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'relative_createdit_view'){
            lingdang.setDocumentTitle(cu_this.wechattitle);
            if(cu_this.showChooseUsersPage){
              cu_this.showreLativelistPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showreLativelistPage = true;
              cu_this.showRelationPage = false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showreLativelistPage = true;
              cu_this.showOptionPage = false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showreLativelistPage = true;
              cu_this.showAddressPage = false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showreLativelistPage = true;
              cu_this.showSubmitApprovePage = false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showreLativelistPage = true;
              cu_this.showPoisListPage = false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showreLativelistPage = true;
              cu_this.showQuickCreatePage = false;
            }
            else{
              cu_this.createBackTip();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'relative_createdit_view'){
            if(cu_this.showChooseUsersPage){
              cu_this.showreLativelistPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showreLativelistPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showreLativelistPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showreLativelistPage = true;
              cu_this.showAddressPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showreLativelistPage = true;
              cu_this.showSubmitApprovePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showreLativelistPage = true;
              cu_this.showPoisListPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showreLativelistPage = true;
              cu_this.showQuickCreatePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'relative_createdit_view'){
            if(cu_this.showChooseUsersPage){
              cu_this.showreLativelistPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showreLativelistPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showreLativelistPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showAddressPage){
              cu_this.showreLativelistPage = true;
              cu_this.showAddressPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showreLativelistPage = true;
              cu_this.showSubmitApprovePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showreLativelistPage = true;
              cu_this.showPoisListPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showreLativelistPage = true;
              cu_this.showQuickCreatePage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.re_create_edit2_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'relative_createdit_view'){
            if(cu_this.showChooseUsersPage){
              cu_this.showreLativelistPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showreLativelistPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showreLativelistPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.wechattitle);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.re_listview_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_relativelist = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'relativelistview'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_relativelist, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'relativelistview'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'relativelistview'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
    }
  }

  this.detail_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          if(userid=='' || userid==null){
            dd.runtime.permission.requestAuthCode({
              corpId: sessionStorage.getItem('corpid'), // 企业id
              onSuccess: function (info) {
                var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/dingtalk/event.php';
                var params = {
                  action: 'get_userid',
                  code: info['code'],
                  diony: Tools.randomString(8)
                };
                lingdangAjax(url, params, function(data){
                  if(data.code == 1){
                    sessionStorage.setItem('userid', data.result.userid);
                    cu_this.getDeailView();
                  }
                  else{
                    cu_this.popPromptBox(data.msg);//弹出框提示
                    return;
                  }
                });
              }
            });
          }
          else{
            cu_this.getDeailView();//获取明细信息
          }

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            backbutton_detail = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'detailview') {
                lingdang.setDocumentTitle(cu_this.modulelable + cu_this.arrFixedLabel.details2);//设置导航栏标题
                if (cu_this.showChooseUsersPage) {
                  cu_this.showDetailviewPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if (cu_this.showAutographPage) {
                  cu_this.showDetailviewPage = true;
                  cu_this.showAutographPage = false;
                }
                else if (cu_this.showRemarksPage) {
                  cu_this.showDetailviewPage = true;
                  cu_this.showRemarksPage = false;
                }
                else if (cu_this.showModuleMapPage) {
                  cu_this.showDetailviewPage = true;
                  cu_this.showModuleMapPage = false;
                }
                else if (cu_this.showTablePage) {
                  cu_this.showDetailviewPage = true;
                  cu_this.showTablePage = false;
                }
                else if (cu_this.showQuickCreatePage) {
                  cu_this.showDetailviewPage = true;
                  cu_this.showQuickCreatePage = false;
                }
                else if(cu_this.showSubmitApprovePage){
                  cu_this.showDetailviewPage = true;
                  cu_this.showSubmitApprovePage = false;
                }
                else if(cu_this.showApproveExpeditingPage){
                  cu_this.showDetailviewPage = true;
                  cu_this.showApproveExpeditingPage = false;
                }
                else if(cu_this.showAdvanceTaskPage){
                  cu_this.showDetailviewPage = true;
                  cu_this.showAdvanceTaskPage = false;
                }
                else if(cu_this.showAdvanceDetailPage){
                  cu_this.showDetailviewPage = true;
                  cu_this.showAdvanceDetailPage = false;
                }
                else if(cu_this.showFilePreviewPage){
                  cu_this.showDetailviewPage = true;
                  cu_this.showFilePreviewPage = false;
                }
                else {
                  document.removeEventListener('backbutton', backbutton_detail, false)
                  dd.biz.navigation.goBack();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_detail, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'detailview') {
                  lingdang.setDocumentTitle(cu_this.modulelable + cu_this.arrFixedLabel.details2);//设置导航栏标题
                  if (cu_this.showChooseUsersPage) {
                    cu_this.showDetailviewPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if (cu_this.showAutographPage) {
                    cu_this.showDetailviewPage = true;
                    cu_this.showAutographPage = false;
                  }
                  else if (cu_this.showRemarksPage) {
                    cu_this.showDetailviewPage = true;
                    cu_this.showRemarksPage = false;
                  }
                  else if (cu_this.showModuleMapPage) {
                    cu_this.showDetailviewPage = true;
                    cu_this.showModuleMapPage = false;
                  }
                  else if (cu_this.showTablePage) {
                    cu_this.showDetailviewPage = true;
                    cu_this.showTablePage = false;
                  }
                  else if (cu_this.showQuickCreatePage) {
                    cu_this.showDetailviewPage = true;
                    cu_this.showQuickCreatePage = false;
                  }
                  else if(cu_this.showSubmitApprovePage){
                    cu_this.showDetailviewPage = true;
                    cu_this.showSubmitApprovePage = false;
                  }
                  else if(cu_this.showApproveExpeditingPage){
                    cu_this.showDetailviewPage = true;
                    cu_this.showApproveExpeditingPage = false;
                  }
                  else if(cu_this.showAdvanceTaskPage){
                    cu_this.showDetailviewPage = true;
                    cu_this.showAdvanceTaskPage = false;
                  }
                  else if(cu_this.showAdvanceDetailPage){
                    cu_this.showDetailviewPage = true;
                    cu_this.showAdvanceDetailPage = false;
                  }
                  else if(cu_this.showFilePreviewPage){
                    cu_this.showDetailviewPage = true;
                    cu_this.showFilePreviewPage = false;
                  }
                  else {
                    dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                    dd.biz.navigation.goBack();//返回上一级页面
                  }
                }
              },
              onFail: function (err) {
              }
            });
          }
        });
      }
      else{
        // 浏览器模拟登陆，无法使用钉钉接口
        if(sessionStorage.getItem('dingding_demo') == 'yes'){
          cu_this.getDeailView();
        }
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      if(userid=='' || userid==0 ||  userid==null){
        // 获取个人信息
        qing.call('getPersonInfo', {
          success : function(res){
            // alert(JSON.stringify(res));
            sessionStorage.setItem('y_openId',res.data.openId);
            sessionStorage.setItem('y_wbnetworkid',res.data.wbnetworkid);
            sessionStorage.setItem('y_wbuserid',res.data.wbuserid);
            sessionStorage.setItem('corpid', res.data.eid);

            that.yuanzhijia_get_userid('detail');
          }
        });
      }
      else{
        cu_this.getDeailView();//获取明细信息
      }

      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'detailview'){
            lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
            if(cu_this.showChooseUsersPage){
              cu_this.showDetailviewPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showAutographPage){
              cu_this.showDetailviewPage = true;
              cu_this.showAutographPage = false;
            }
            else if(cu_this.showRemarksPage){
              cu_this.showDetailviewPage = true;
              cu_this.showRemarksPage = false;
            }
            else if(cu_this.showModuleMapPage){
              cu_this.showDetailviewPage = true;
              cu_this.showModuleMapPage = false;
            }
            else if(cu_this.showTablePage){
              cu_this.showDetailviewPage = true;
              cu_this.showTablePage = false;
            }
            else if(cu_this.showQuickCreatePage){
              cu_this.showDetailviewPage = true;
              cu_this.showQuickCreatePage = false;
            }
            else if(cu_this.showSubmitApprovePage){
              cu_this.showDetailviewPage = true;
              cu_this.showSubmitApprovePage = false;
            }
            else if(cu_this.showApproveExpeditingPage){
              cu_this.showDetailviewPage = true;
              cu_this.showApproveExpeditingPage = false;
            }
            else if(cu_this.showAdvanceTaskPage){
              cu_this.showDetailviewPage = true;
              cu_this.showAdvanceTaskPage = false;
            }
            else if(cu_this.showAdvanceDetailPage){
              cu_this.showDetailviewPage = true;
              cu_this.showAdvanceDetailPage = false;
            }
            else if(cu_this.showFilePreviewPage){
              cu_this.showDetailviewPage = true;
              cu_this.showFilePreviewPage = false;
            }
            else{
              if (cu_this.fromRemind == 'yes') {
                lingdang.closeWindows();//关闭应用
              }
              else {
                history.back();
              }
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      if(userid=='' || userid==0 ||  userid==null){
        that.get_userid('detail');
      }
      else{
        cu_this.getDeailView();
      }
    }
    else if(that.mobileSource == 'app'){
      cu_this.getDeailView();
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'detailview'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showModuleMapPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showModuleMapPage = false;
              return false;
            }
            else if(cu_this.showAutographPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showAutographPage = false;
              return false;
            }
            else if(cu_this.showRemarksPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showRemarksPage = false;
              return false;
            }
            else if(cu_this.showTablePage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showTablePage = false;
              return false;
            }
            else if(cu_this.showQuickCreatePage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showQuickCreatePage = false;
              return false;
            }
            else if(cu_this.showSubmitApprovePage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showSubmitApprovePage = false;
              return false;
            }
            else if(cu_this.showApproveExpeditingPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showApproveExpeditingPage = false;
              return false;
            }
            else if(cu_this.showAdvanceTaskPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showAdvanceTaskPage = false;
              return false;
            }
            else if(cu_this.showAdvanceDetailPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showAdvanceDetailPage = false;
              return false;
            }
            else if(cu_this.showFilePreviewPage){
              lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
              cu_this.showDetailviewPage = true;
              cu_this.showFilePreviewPage = false;
              return false;
            }
            else{
              return true;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      cu_this.getDeailView();
      wx.ready(function () {
        wx.hideAllNonBaseMenuItem();//隐藏所有按钮（“传播类”和“保护类"）
        lingdang.hideMenuItemsBefore();
        if(wx.onHistoryBack){
          wx.onHistoryBack(function(){
            if(cu_this.$route.name == 'detailview'){
              if(cu_this.showChooseUsersPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showChooseUsersPage = false;
                return false;
              }
              else if(cu_this.showMailListPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showMailListPage = false;
                return false;
              }
              else if(cu_this.showModuleMapPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showModuleMapPage = false;
                return false;
              }
              else if(cu_this.showAutographPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showAutographPage = false;
                return false;
              }
              else if(cu_this.showRemarksPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showRemarksPage = false;
                return false;
              }
              else if(cu_this.showTablePage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showTablePage = false;
                return false;
              }
              else if(cu_this.showQuickCreatePage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showQuickCreatePage = false;
                return false;
              }
              else if(cu_this.showSubmitApprovePage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showSubmitApprovePage = false;
                return false;
              }
              else if(cu_this.showApproveExpeditingPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showApproveExpeditingPage = false;
                return false;
              }
              else if(cu_this.showAdvanceTaskPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showAdvanceTaskPage = false;
                return false;
              }
              else if(cu_this.showAdvanceDetailPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showAdvanceDetailPage = false;
                return false;
              }
              else if(cu_this.showFilePreviewPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showFilePreviewPage = false;
                return false;
              }
            }
            else{
              return true;
            }
          });
        }
      });
    }
  }
  this.detail2_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      wx.ready(function () {
        if(wx.onHistoryBack){
          wx.onHistoryBack(function(){
            if(cu_this.$route.name == 'listview'){
              if(cu_this.showChooseUsersPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showChooseUsersPage = false;
                return false;
              }
              else if(cu_this.showMailListPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showMailListPage = false;
                return false;
              }
              else if(cu_this.showModuleMapPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showModuleMapPage = false;
                return false;
              }
              else if(cu_this.showAutographPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showAutographPage = false;
                return false;
              }
              else if(cu_this.showRemarksPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showRemarksPage = false;
                return false;
              }
              else if(cu_this.showTablePage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showTablePage = false;
                return false;
              }
              else if(cu_this.showQuickCreatePage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showQuickCreatePage = false;
                return false;
              }
              else if(cu_this.showSubmitApprovePage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showSubmitApprovePage = false;
                return false;
              }
              else if(cu_this.showApproveExpeditingPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showApproveExpeditingPage = false;
                return false;
              }
              else if(cu_this.showAdvanceTaskPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showAdvanceTaskPage = false;
                return false;
              }
              else if(cu_this.showAdvanceDetailPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.showDetailviewPage = true;
                cu_this.showAdvanceDetailPage = false;
                return false;
              }
              else if(cu_this.$parent.showDetailViewPage){
                lingdang.setDocumentTitle(cu_this.modulelable+cu_this.arrFixedLabel.DETAIL_1);
                cu_this.$dispatch("detailview-back", "");
                return false;
              }
            }
          });
        }
      });
    }
  }

  this.entry_commission_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'CommissionEntry'){
              if(cu_this.showRelation){
                cu_this.dataSelected('', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.entry_commission2_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'CommissionEntry'){
              if(cu_this.showRelation){
                cu_this.dataSelected('', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.entry_expense_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'ExpenseEntry'){
              if(cu_this.showRelation){
                cu_this.dataSelected('', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.entry_expense2_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'ExpenseEntry'){
              if(cu_this.showRelation){
                cu_this.dataSelected('', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.entry_product_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'ProductView'){
              if(cu_this.showProductRelationPage){
                cu_this.dataSelected('', '', '', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.entry_product2_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'ProductView'){
              if(cu_this.showProductRelationPage){
                cu_this.dataSelected('', '', '', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.quoteschange_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(wx_current_view != '') {
            if(wx_current_view == 'QuoteschangeView'){
              if(cu_this.showProductRelationPage){
                cu_this.dataSelected('', '');
                return false;
              }
              else{
                wx_current_view = '';
                cu_this.cancel();
                return false;
              }
            }
          }
        });
      }
    }
  }

  this.signmodule_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_nearby = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'signmodule') {
                lingdang.setDocumentTitle(cu_this.wechattitle);//设置导航栏标题
                if (cu_this.showChooseUsersPage) {
                  cu_this.showSignPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if (cu_this.showRelationPage) {
                  cu_this.showSignPage = true;
                  cu_this.showRelationPage = false;
                }
                else if (cu_this.showOptionPage) {
                  cu_this.showSignPage = true;
                  cu_this.showOptionPage = false;
                }
                else if (cu_this.showPoisListPage) {
                  cu_this.showSignPage = true;
                  cu_this.showPoisListPage = false;
                }
                else {
                  if(cu_this.showSignFirst){
                    dd.biz.navigation.goBack();
                  }
                  else{
                    cu_this.gotoSignTabbar('1');
                  }
                }
              }
            };
            document.addEventListener('backbutton', backbutton_nearby, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'signmodule') {
                  lingdang.setDocumentTitle(cu_this.wechattitle);//设置导航栏标题
                  if (cu_this.showChooseUsersPage) {
                    cu_this.showSignPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if (cu_this.showRelationPage) {
                    cu_this.showSignPage = true;
                    cu_this.showRelationPage = false;
                  }
                  else if (cu_this.showOptionPage) {
                    cu_this.showSignPage = true;
                    cu_this.showOptionPage = false;
                  }
                  else {
                    if(cu_this.showSignFirst){
                      dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                      dd.biz.navigation.goBack();
                    }
                    else{
                      cu_this.gotoSignTabbar('1');
                    }
                  }
                }
              },
              onFail: function (err) {
              }
            });
          }

          dd.device.base.getUUID({
            onSuccess: function (data) {
              cu_this.DeviceId = data['uuid'];
            },
            onFail: function (err) {
            }
          });
          cu_this.gotoOpenSign();
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'signmodule'){
            if(cu_this.showChooseUsersPage){
              cu_this.showSignPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showSignPage = true;
              cu_this.showRelationPage = false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showSignPage = true;
              cu_this.showOptionPage = false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showSignPage = true;
              cu_this.showPoisListPage = false;
            }
            else{
              cu_this.createBackTip();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'signmodule'){
            if(cu_this.showChooseUsersPage){
              cu_this.showSignPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showSignPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showSignPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showSignPage = true;
              cu_this.showPoisListPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else{
              if(cu_this.showSignFirst){
                cu_this.createBackTip();
                return false;
              }
              else{
                cu_this.gotoSignTabbar('1');
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'signmodule'){
            if(cu_this.showChooseUsersPage){
              cu_this.showSignPage = true;
              cu_this.showChooseUsersPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showSignPage = true;
              cu_this.showRelationPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else if(cu_this.showOptionPage){
              cu_this.showSignPage = true;
              cu_this.showOptionPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else if(cu_this.showPoisListPage){
              cu_this.showSignPage = true;
              cu_this.showPoisListPage = false;
              lingdang.setDocumentTitle(cu_this.modulelable);
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.work_list_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk" ) {
        dd.ready(function () {
          if(userid=='' || userid==null){
            dd.runtime.permission.requestAuthCode({
              corpId: sessionStorage.getItem('corpid'), // 企业id
              onSuccess: function (info) {
                var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/dingtalk/event.php';
                var params = {
                  action: 'get_userid',
                  code: info['code'],
                  diony: Tools.randomString(8)
                };
                lingdangAjax(url, params, function(data){
                  if(data.code == 1){
                    sessionStorage.setItem('userid', data.result.userid);
                    cu_this.getModuleData();
                  }
                  else{
                    cu_this.popPromptBox(data.msg);//弹出框提示
                    return;
                  }
                });
              }
            });
          }
          else{
            cu_this.getModuleData();//页签信息
          }

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_work = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'work'){
                if(cu_this.showChooseUsersPage){
                  cu_this.showWorkListPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showChooseUsersPage){
                  cu_this.showWorkListPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else{
                  let filterclass = $('#panel-js-filter').attr('class');
                  let worklistclass = $('#panel-js-worklist').attr('class');
                  if(filterclass.indexOf('active') > -1 || worklistclass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else{
                    dd.biz.navigation.goBack();
                  }
                }
              }
            };
            document.addEventListener('backbutton', backbutton_work, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'work'){
                  if(cu_this.showChooseUsersPage){
                    cu_this.showWorkListPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showChooseUsersPage){
                    cu_this.showWorkListPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else{
                    let filterclass = $('#panel-js-filter').attr('class');
                    let worklistclass = $('#panel-js-worklist').attr('class');
                    if(filterclass.indexOf('active') > -1 || worklistclass.indexOf('active') > -1) {
                      $.closePanel();
                    }
                    else{
                      dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                      dd.biz.navigation.goBack();
                    }
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
      else{
        cu_this.getModuleData();
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      if(userid=='' || userid==0 ||  userid==null){
        // 获取个人信息
        qing.call('getPersonInfo', {
          success : function(res){
            // alert(JSON.stringify(res));
            sessionStorage.setItem('y_openId',res.data.openId);
            sessionStorage.setItem('y_wbnetworkid',res.data.wbnetworkid);
            sessionStorage.setItem('y_wbuserid',res.data.wbuserid);
            sessionStorage.setItem('corpid', res.data.eid);

            that.yuanzhijia_get_userid('work_list');
          }
        });
      }
      else{
        cu_this.getModuleData();//获取菜单列表
      }

      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'work'){
            if(cu_this.showChooseUsersPage){
              cu_this.showWorkListPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showRemarksPage){
              cu_this.showWorkListPage = true;
              cu_this.showRemarksPage = false;
            }
            else{
              let filterclass = $('#panel-js-filter').attr('class');
              let worklistclass = $('#panel-js-worklist').attr('class');
              if(filterclass.indexOf('active') > -1 || worklistclass.indexOf('active') > -1) {
                $.closePanel();
              }
              else{
                history.back();
              }
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      if(userid=='' || userid==0 ||  userid==null){
        that.get_userid('work_list');
      }
      else{
        cu_this.getModuleData();
      }
    }
    else if(that.mobileSource == 'app'){
      cu_this.getModuleData();
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'work'){
            if(cu_this.showChooseUsersPage){
              cu_this.showWorkListPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showRemarksPage){
              cu_this.showWorkListPage = true;
              cu_this.showRemarksPage = false;
              return false;
            }
            else{
              let filterclass = $('#panel-js-filter').attr('class');
              let worklistclass = $('#panel-js-worklist').attr('class');
              if(filterclass.indexOf('active') > -1 || worklistclass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      cu_this.getModuleData();
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'work'){
            if(cu_this.showChooseUsersPage){
              cu_this.showWorkListPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showRemarksPage){
              cu_this.showWorkListPage = true;
              cu_thisv.showRemarksPage = false;
              return false;
            }
            else{
              let filterclass = $('#panel-js-filter').attr('class');
              let worklistclass = $('#panel-js-worklist').attr('class');
              if(filterclass.indexOf('active') > -1 || worklistclass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.work_write_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk" ) {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_write = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'work_write'){
                if(cu_this.showChooseUsersPage){
                  cu_this.showListPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showRelationPage){
                  cu_this.showListPage = true;
                  cu_this.showRelationPage = false;
                }
                else{
                  let msg = cu_this.arrFixedLabel.DISCARDTHEMODIFICATION;
                  if(cu_this.reportContentFalg || cu_this.logValueArrFalg){
                    msg = cu_this.arrFixedLabel.REPORTBEENTEMPORARILYSAVED;
                  }
                  dd.device.notification.confirm({
                    message: msg,
                    title: cu_this.weuiTitle,
                    buttonLabels: [sessionStorage.getItem("CANCEL"), sessionStorage.getItem("CONFIRMED")],
                    onSuccess : function(result) {
                      if(result.buttonIndex==0){
                      }
                      else if(result.buttonIndex==1){
                        dd.biz.navigation.goBack();//返回上一级页面
                      }
                    },
                    onFail : function(err) {}
                  });
                }
              }
            };
            document.addEventListener('backbutton', backbutton_write, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'work_write'){
                  if(cu_this.showChooseUsersPage){
                    cu_this.showListPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showRelationPage){
                    cu_this.showListPage = true;
                    cu_this.showRelationPage = false;
                  }
                  else{
                    let msg = cu_this.arrFixedLabel.DISCARDTHEMODIFICATION;
                    if(cu_this.reportContentFalg || cu_this.logValueArrFalg){
                      msg = cu_this.arrFixedLabel.REPORTBEENTEMPORARILYSAVED;
                    }
                    dd.device.notification.confirm({
                      message: msg,
                      title: cu_this.weuiTitle,
                      buttonLabels: ['取消', '确定'],
                      onSuccess : function(result) {
                        if(result.buttonIndex==0){
                        }
                        else if(result.buttonIndex==1){
                          dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                          dd.biz.navigation.goBack();//返回上一级页面
                        }
                      },
                      onFail : function(err) {}
                    });
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'work_write'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'work_write'){
            if(cu_this.showChooseUsersPage){
              cu_this.showListPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showListPage = true;
              cu_this.showRelationPage = false;
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'work_write'){
            if(cu_this.showChooseUsersPage){
              cu_this.showListPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showRelationPage){
              cu_this.showListPage = true;
              cu_this.showRelationPage = false;
              return false;
            }
            else{
              cu_this.createBackTip();
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.work_detail_load=function(){
    let cu_this=that.vueobj;
    let userid = sessionStorage.getItem('userid');
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk" ) {
        dd.ready(function () {
          if(userid=='' || userid==null){
            dd.runtime.permission.requestAuthCode({
              corpId: sessionStorage.getItem('corpid'), // 企业id
              onSuccess: function (info) {
                var url = sessionStorage.getItem('corpurl') + 'WeiXinApp/dingtalk/event.php';
                var params = {
                  action: 'get_userid',
                  code: info['code'],
                  diony: Tools.randomString(8)
                };
                lingdangAjax(url, params, function(data){
                  if(data.code == 1){
                    sessionStorage.setItem('userid', data.result.userid);
                    cu_this.getDeailView();
                  }
                  else{
                    cu_this.popPromptBox(data.msg);//弹出框提示
                    return;
                  }
                });
              }
            });
          }
          else{
            cu_this.getDeailView();//获取明细信息
          }

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_work = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'work_detail') {
                if (cu_this.showRemarksPage) {
                  cu_this.showWorkDetailPage = true;
                  cu_this.showRemarksPage = false;
                }
                else if (cu_this.showUserListPage) {
                  cu_this.showWorkDetailPage = true;
                  cu_this.showUserListPage = false;
                }
                else {
                  document.removeEventListener('backbutton', backbutton_detail, false)
                  dd.biz.navigation.goBack();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_work, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'work_detail') {
                  if(cu_this.showRemarksPage){
                    cu_this.showDetailviewPage = true;
                    cu_this.showRemarksPage = false;
                  }
                  else if (cu_this.showUserListPage) {
                    cu_this.showWorkDetailPage = true;
                    cu_this.showUserListPage = false;
                  }
                  else {
                    dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                    dd.biz.navigation.goBack();//返回上一级页面
                  }
                }
              },
              onFail: function (err) {
              }
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      if(userid=='' || userid==0 ||  userid==null){
        // 获取个人信息
        qing.call('getPersonInfo', {
          success : function(res){
            // alert(JSON.stringify(res));
            sessionStorage.setItem('y_openId',res.data.openId);
            sessionStorage.setItem('y_wbnetworkid',res.data.wbnetworkid);
            sessionStorage.setItem('y_wbuserid',res.data.wbuserid);
            sessionStorage.setItem('corpid', res.data.eid);

            that.yuanzhijia_get_userid('work_detail');
          }
        });
      }
      else{
        cu_this.getDeailView();//获取明细信息
      }

      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'work_detail'){
            if(cu_this.showRemarksPage){
              cu_this.showDetailviewPage = true;
              cu_this.showRemarksPage = false;
            }
            else if (cu_this.showUserListPage) {
              cu_this.showWorkDetailPage = true;
              cu_this.showUserListPage = false;
            }
            else{
              history.back();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
      if(userid=='' || userid==0 ||  userid==null){
        that.get_userid('work_detail');
      }
      else{
        cu_this.getDeailView();
      }
    }
    else if(that.mobileSource == 'app'){
      cu_this.getDeailView();
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'work_detail'){
            if(cu_this.showRemarksPage){
              cu_this.showDetailviewPage = true;
              cu_this.showRemarksPage = false;
            }
            else if (cu_this.showUserListPage) {
              cu_this.showWorkDetailPage = true;
              cu_this.showUserListPage = false;
            }
            else{
              return true;
            }
          }
        });
      }
    }
    else{
      cu_this.getDeailView();
      wx.ready(function () {
        wx.hideAllNonBaseMenuItem();//隐藏所有按钮（“传播类”和“保护类"）
        lingdang.hideMenuItemsBefore();
        if(wx.onHistoryBack){
          wx.onHistoryBack(function(){
            if(cu_this.$route.name == 'work_detail'){
              if(cu_this.showRemarksPage){
                cu_this.showDetailviewPage = true;
                cu_this.showRemarksPage = false;
              }
              else{
                return true;
              }
            }
          });
        }
      });
    }
  }

  this.work_forward_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk" ) {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : '转发'});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_write = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'forward'){
                dd.biz.navigation.goBack();//返回上一级页面
              }
            };
            document.addEventListener('backbutton', backbutton_write, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'forward'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'forward'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'forward'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.work_reportuserlist_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
    }
  }

  this.workreply_load=function (){
    let cu_this = that.vueobj;
    if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'workreply'){
            history.back();
          }
        }
      });
    }
  }

  this.atofmine_load=function(){
    let cu_this = that.vueobj;
    if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'atofmine'){
            history.back();
          }
        }
      });
    }
  }

  this.userinfo_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'userinfo'){
            history.back();
          }
        }
      });
    }
  }

  this.quickcreate_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      //钉钉JSAPI鉴权
      lingdang.dingtalk_config();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.device.base.getUUID({
            onSuccess: function (data) {
              cu_this.DeviceId = data['uuid'];
            },
            onFail: function (err) {
            }
          });
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
    }
  }

  this.address_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      //钉钉JSAPI鉴权
      lingdang.dingtalk_config();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : '定位地址'});//设置导航栏标题
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
    }
  }

  this.nearby_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      that.dingding_check_login();
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : cu_this.wechattitle});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_nearby = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'nearby'){
                if(cu_this.showChooseUsersPage){
                  dd.biz.navigation.setTitle({title : cu_this.wechattitle});//设置导航栏标题
                  cu_this.showNearbyPage = true;
                  cu_this.showChooseUsersPage = false;
                }
                else{
                  let democlass = $('#panel-js-nearby').attr('class');
                  if(democlass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else {
                    dd.biz.navigation.goBack();
                  }
                }
              }
            };
            document.addEventListener('backbutton', backbutton_nearby, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'nearby'){
                  if(cu_this.showChooseUsersPage){
                    dd.biz.navigation.setTitle({title : cu_this.wechattitle});//设置导航栏标题
                    cu_this.showNearbyPage = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else{
                    let democlass = $('#panel-js-nearby').attr('class');
                    if(democlass.indexOf('active') > -1) {
                      $.closePanel();
                    }
                    else {
                      dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                      dd.biz.navigation.goBack();
                    }
                  }
                }
              },
              onFail : function(err) {}
            });
          }

          // wx_loading = weui.loading(cu_this.weuiLoading);//显示加载
          //定位地址
          if(sessionStorage.getItem("nearby_kilometre")!=null && sessionStorage.getItem("nearby_kilometre") !='undefined'){
            cu_this.kilometre=sessionStorage.getItem("nearby_kilometre");
            $('a[kilometre=k_5000],a[kilometre=k_10000]').removeClass('active');
            $('a[kilometre=k_'+cu_this.kilometre+']').addClass('active');
          }
          if(sessionStorage.getItem("nearby_lat")!=null && sessionStorage.getItem("nearby_lat") !='undefined'){
            cu_this.latitude=sessionStorage.getItem("nearby_lat");
            cu_this.longitude=sessionStorage.getItem("nearby_long");
            cu_this.loadLocation();// 加载当前位置
          }
          else{
            cu_this.getLocation();//获取当前地理位置信息(单次定位)
          }        
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'nearby'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showNearbyPage = true;
              cu_this.showChooseUsersPage = false;
            }
            else{
              let democlass = $('#panel-js-nearby').attr('class');
              if(democlass.indexOf('active') > -1) {
                $.closePanel();
              }
              else{
                history.back();
              }
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei'){
    }
    else if(that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'nearby'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showNearbyPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else{
              let democlass = $('#panel-js-nearby').attr('class');
              if(democlass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'nearby'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.modulelable);
              cu_this.showNearbyPage = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else{
              let democlass = $('#panel-js-nearby').attr('class');
              if(democlass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.approvelist_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_zero = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'approvelist'){
                dd.biz.navigation.close();
              }
            };
            document.addEventListener('backbutton', backbutton_zero, false);
            let backbutton_list = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'approvelist'){
                if(cu_this.showChooseUsersPage){
                  cu_this.showChooseUsersPage = false;
                }
                else{
                  let approveclass = $('#panel-js-approve').attr('class');
                  if(approveclass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else {
                    dd.biz.navigation.goBack();
                  }
                }
              }
            };
            document.addEventListener('backbutton', backbutton_list, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'approvelist'){
                  if(cu_this.showChooseUsersPage){
                    cu_this.showChooseUsersPage = false;
                  }
                  else{
                    let approveclass = $('#panel-js-approve').attr('class');
                    if(approveclass.indexOf('active') > -1) {
                      $.closePanel();
                    }
                    else {
                      dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                      dd.biz.navigation.goBack();
                    }
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'approvelist'){
            if(cu_this.showChooseUsersPage){
              cu_this.showChooseUsersPage = false;
            }
            else{
              let approveclass = $('#panel-js-approve').attr('class');
              if(approveclass.indexOf('active') > -1) {
                $.closePanel();
              }
              else{
                history.back();
              }
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'approvelist'){
            if(cu_this.showChooseUsersPage){
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else{
              let approveclass = $('#panel-js-approve').attr('class');
              if(approveclass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'approvelist'){
            if(cu_this.showChooseUsersPage){
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else{
              let approveclass = $('#panel-js-approve').attr('class');
              if(approveclass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.approve_step_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_write = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'approve'){
                dd.biz.navigation.goBack();//返回上一级页面
              }
            };
            document.addEventListener('backbutton', backbutton_write, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'approve'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'approve'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
    }
  }

  this.calendar_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : cu_this.wechattitle});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_relativelist = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'calendar'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_relativelist, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'calendar'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'calendar'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'calendar'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.chinamap_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : cu_this.wechattitle});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_map = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'chinamap'){              
                if(cu_this.showChooseUsersPage){
                  cu_this.showChooseUsersPage = false;
                }
                else{
                  dd.biz.navigation.goBack();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_map, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'chinamap'){
                  if(cu_this.showChooseUsersPage){
                    cu_this.showChooseUsersPage = false;
                  }
                  else{
                    dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                    dd.biz.navigation.goBack();
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'chinamap'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'chinamap'){
            return true;
          }
          else{
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.electriccard_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : cu_this.wechattitle});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_relativelist = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'electriccard'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_relativelist, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'electriccard'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'electriccard'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
    }
    else{
    }
  }

  this.pdf_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          cu_this.platform = dd.env.platform;

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_detail = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'pdf') {
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_detail, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'pdf') {
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail: function (err) {
              }
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'pdf'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'pdf'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.shop_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_detail = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'shopproducts') {
                dd.biz.navigation.setTitle({title: cu_this.productsTitle});//设置导航栏标题
                if(cu_this.showCartListPage){
                  cu_this.showProductsPage = true;
                  cu_this.showCartListPage = false;
                }
                else if(cu_this.showProductsDetailPage){
                  cu_this.showProductsPage = true;
                  cu_this.showProductsDetailPage = false;
                }
                else if(cu_this.showAttributePage){
                  cu_this.showProductsPage = true;
                  cu_this.showAttributePage = false;
                }
                else {
                  dd.biz.navigation.goBack();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_detail, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'shopproducts') {
                  dd.biz.navigation.setTitle({title: cu_this.productsTitle});//设置导航栏标题
                  if(cu_this.showCartListPage){
                    cu_this.showProductsPage = true;
                    cu_this.showCartListPage = false;
                  }
                  else if(cu_this.showProductsDetailPage){
                    cu_this.showProductsPage = true;
                    cu_this.showProductsDetailPage = false;
                  }
                  else if(cu_this.showAttributePage){
                    cu_this.showProductsPage = true;
                    cu_this.showAttributePage = false;
                  }
                  else {
                    dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                    dd.biz.navigation.goBack();//返回上一级页面
                  }
                }
              },
              onFail: function (err) {
              }
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'shopproducts'){
            lingdang.setDocumentTitle(cu_this.productsTitle);
            if(cu_this.showCartListPage){
              cu_this.showProductsPage = true;
              cu_this.showCartListPage = false;
            }
            else if(cu_this.showProductsDetailPage){
              cu_this.showProductsPage = true;
              cu_this.showProductsDetailPage = false;
            }
            else if(cu_this.showAttributePage){
              cu_this.showProductsPage = true;
              cu_this.showAttributePage = false;
            }
            else{
              history.back();
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'shopproducts'){
            if(cu_this.showCartListPage){
              lingdang.setDocumentTitle(cu_this.productsTitle);
              cu_this.showProductsPage = true;
              cu_this.showCartListPage = false;
              return false;
            }
            else if(cu_this.showProductsDetailPage){
              lingdang.setDocumentTitle(cu_this.productsTitle);
              cu_this.showProductsPage = true;
              cu_this.showProductsDetailPage = false;
              return false;
            }
            else if(cu_this.showAttributePage){
              lingdang.setDocumentTitle(cu_this.productsTitle);
              cu_this.showProductsPage = true;
              cu_this.showAttributePage = false;
              return false;
            }
            else{
              return true;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'shopproducts'){
            if(cu_this.showCartListPage){
              lingdang.setDocumentTitle(cu_this.productsTitle);
              cu_this.showProductsPage = true;
              cu_this.showCartListPage = false;
              return false;
            }
            else if(cu_this.showProductsDetailPage){
              lingdang.setDocumentTitle(cu_this.productsTitle);
              cu_this.showProductsPage = true;
              cu_this.showProductsDetailPage = false;
              return false;
            }
            else if(cu_this.showAttributePage){
              lingdang.setDocumentTitle(cu_this.productsTitle);
              cu_this.showProductsPage = true;
              cu_this.showAttributePage = false;
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.password_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_password = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'password'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_password, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'password'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'password'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'password'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.personaledit_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_personal = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'personaledit'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_personal, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'personaledit'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'personaledit'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'personaledit'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.personalinfo_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : '个人资料'});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_personal = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'personalinfo'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_personal, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'personalinfo'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'personalinfo'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'personalinfo'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.set_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : '个人资料'});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_detail = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'settingsecond') {
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_detail, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'settingsecond') {
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail: function (err) {
              }
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'settingsecond'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'settingsecond'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.setting_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_setting = function (e) {
              e.preventDefault();
              if (cu_this.$route.name == 'setting') {
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_setting, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess: function (result) {
                if (cu_this.$route.name == 'setting') {
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail: function (err) {
              }
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'setting'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'setting'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.settingedit_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : '编辑筛选范围'});//设置导航栏标题
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'settingedit'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'settingedit'){
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.dashboard_detail_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : cu_this.reportLabel});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_nearby = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'dashboarddetailview'){
                if(cu_this.showChooseUsersPage){
                  lingdang.setDocumentTitle(cu_this.reportLabel);
                  cu_this.showDashboard = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showCustomPage){
                  lingdang.setDocumentTitle(cu_this.reportLabel);
                  cu_this.showDashboard = true;
                  cu_this.showCustomPage = false;
                }
                else{
                  let democlass = $('#panel-js-report').attr('class');
                  if(democlass.indexOf('active') > -1) {
                    $.closePanel();
                  }
                  else {
                    dd.biz.navigation.goBack();
                  }
                }
              }
            };
            document.addEventListener('backbutton', backbutton_nearby, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'dashboarddetailview'){
                  if(cu_this.showChooseUsersPage){
                    cu_this.showDashboard = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showCustomPage){
                    cu_this.showDashboard = true;
                    cu_this.showCustomPage = false;
                  }
                  else{
                    let democlass = $('#panel-js-report').attr('class');
                    if(democlass.indexOf('active') > -1) {
                      $.closePanel();
                    }
                    else {
                      dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                      dd.biz.navigation.goBack();
                    }
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'dashboarddetailview'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.$route.params.reportLabel);
              cu_this.showDashboard = true;
              cu_this.showChooseUsersPage = false;
            }
            else if(cu_this.showCustomPage){
              lingdang.setDocumentTitle(cu_this.$route.params.reportLabel);
              cu_this.showDashboard = true;
              cu_this.showCustomPage = false;
            }
            else{
              let democlass = $('#panel-js-report').attr('class');
              if(democlass.indexOf('active') > -1) {
                $.closePanel();
              }
              else{
                history.back();
              }
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboarddetailview'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.$route.params.reportLabel);
              cu_this.showDashboard = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showCustomPage){
              lingdang.setDocumentTitle(cu_this.$route.params.reportLabel);
              cu_this.showDashboard = true;
              cu_this.showCustomPage = false;
              return false;
            }
            else{
              let democlass = $('#panel-js-report').attr('class');
              if(democlass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboarddetailview'){
            if(cu_this.showChooseUsersPage){
              lingdang.setDocumentTitle(cu_this.$route.params.reportLabel);
              cu_this.showDashboard = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showCustomPage){
              lingdang.setDocumentTitle(cu_this.$route.params.reportLabel);
              cu_this.showDashboard = true;
              cu_this.showCustomPage = false;
              return false;
            }
            else{
              let democlass = $('#panel-js-report').attr('class');
              if(democlass.indexOf('active') > -1) {
                $.closePanel();
                return false;
              }
              else{
                return true;
              }
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.dashboard_list_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_reportlist = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'dashboardlistview'){
                dd.biz.navigation.goBack();
              }
            };
            document.addEventListener('backbutton', backbutton_reportlist, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'dashboardlistview'){
                  dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                  dd.biz.navigation.goBack();//返回上一级页面
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'dashboardlistview'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboardlistview'){
            return true;
          }
          else{
            return true;
          }
        });
      }
    }
    else{
    }
  }

  this.dashboard_module_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
    }
    else if(that.mobileSource == 'yunzhijia'){
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboardmodule'){
            if(cu_this.showChooseUsersPage){
              cu_this.showChooseUsersPage = false;
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboardmodule'){
            if(cu_this.showChooseUsersPage){
              cu_this.showChooseUsersPage = false;
              return false;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.dashboard_second_load=function(){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.navigation.setTitle({title : cu_this.reportLabel});//设置导航栏标题

          //返回按钮点击的事件监听
          if (dd.env.platform == "android") {
            let backbutton_nearby = function (e) {
              e.preventDefault();
              if(cu_this.$route.name == 'dashboardsecond'){
                if(cu_this.showChooseUsersPage){
                  cu_this.showDashboard = true;
                  cu_this.showChooseUsersPage = false;
                }
                else if(cu_this.showCustomPage){
                  cu_this.showDashboard = true;
                  cu_this.showCustomPage = false;
                }
                else{
                  dd.biz.navigation.goBack();
                }
              }
            };
            document.addEventListener('backbutton', backbutton_nearby, false);
          }
          if (dd.env.platform == "ios") {
            dd.biz.navigation.setLeft({
              control: true,//是否控制点击事件，true 控制，false 不控制， 默认false
              text: '',//控制显示文本，空字符串表示显示默认文本
              onSuccess : function(result) {
                if(cu_this.$route.name == 'dashboardsecond'){
                  if(cu_this.showChooseUsersPage){
                    cu_this.showDashboard = true;
                    cu_this.showChooseUsersPage = false;
                  }
                  else if(cu_this.showCustomPage){
                    cu_this.showDashboard = true;
                    cu_this.showCustomPage = false;
                  }
                  else{
                    dd.biz.navigation.setLeft({control: false, text: ''});//关闭左侧点击事件
                    dd.biz.navigation.goBack();
                  }
                }
              },
              onFail : function(err) {}
            });
          }
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('defback', {
        success: function () {
          if(cu_this.$route.name == 'dashboardsecond'){
            history.back();
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboardsecond'){
            if(cu_this.showChooseUsersPage){
              cu_this.showDashboard = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showCustomPage){
              cu_this.showDashboard = true;
              cu_this.showCustomPage = false;
              return false;
            }
            else{
              return true;
            }
          }
          else{
            return true;
          }
        });
      }
    }
    else{
      if(wx.onHistoryBack){
        wx.onHistoryBack(function(){
          if(cu_this.$route.name == 'dashboardsecond'){
            if(cu_this.showChooseUsersPage){
              cu_this.showDashboard = true;
              cu_this.showChooseUsersPage = false;
              return false;
            }
            else if(cu_this.showCustomPage){
              cu_this.showDashboard = true;
              cu_this.showCustomPage = false;
              return false;
            }
            else{
              return true;
            }
          }
          else{
            return true;
          }
        });
      }
    }
  }

  this.public_getLocation=function(type){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.device.geolocation.get({
            targetAccuracy: 200,
            coordinate: 1,
            withReGeocode: true,
            useCache: false, //默认是true，如果需要频繁获取地理位置，请设置false
            onSuccess: function (result) {
              if(type == 'create'){
                cu_this.signData.address = result.address;
                cu_this.signData.latitude = result.latitude;
                cu_this.signData.longitude = result.longitude;
                cu_this.getPlaceFromPoint(result.latitude, result.longitude);
              }
              else if(type == 'work_create' || type == 'sign'){
                cu_this.currentPlace = result.address;
                cu_this.sign_latitude = result.latitude;
                cu_this.sign_longitude = result.longitude;
                cu_this.getPlaceFromPoint(result.latitude, result.longitude);
              }
              else if(type == 'address'){
                cu_this.longitude = result.longitude;
                cu_this.latitude = result.latitude;
                cu_this.loadLocation();// 加载当前位置

                setTimeout(() => {
                  let tempCount = 0;
                  $('div.sign-map>div>div').each(function () {
                    tempCount++;
                    if(tempCount==2||tempCount==3){
                      $(this).remove();
                    }
                  });
                }, 500);
              }
              else if(type == 'nearby'){
                cu_this.latitude = result.latitude;
                cu_this.longitude = result.longitude;
                sessionStorage.setItem('nearby_lat', cu_this.latitude);
                sessionStorage.setItem('nearby_long', cu_this.longitude);
                cu_this.loadLocation();// 加载当前位置

                setTimeout(() => {
                  let tempCount = 0;
                  $('div.sign-map>div>div').each(function () {
                    tempCount++;
                    if(tempCount==2||tempCount==3){
                      $(this).remove();
                    }
                  });
                }, 500);
              }
            },
            onFail: function (err) {
              if(type == 'create'){
                cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;  
              }
              else if(type == 'work_create' || type == 'sign' || type == 'address'){
                cu_this.currentPlace = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
              }
            }
          });
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call('getLocation', {
        success: function(result){
          if(result.success == 'true'){
            if(type == 'create'){
              cu_this.signData.address = result.data.addressdetail;
              cu_this.signData.latitude = result.data.latitude;
              cu_this.signData.longitude = result.data.longitude;
              cu_this.getPlaceFromPoint(result.data.latitude, result.data.longitude);
            }
            else if(type == 'work_create' || type == 'sign'){
              cu_this.currentPlace = result.data.addressdetail;
              cu_this.sign_latitude = result.data.latitude;
              cu_this.sign_longitude = result.data.longitude;
              cu_this.getPlaceFromPoint(result.data.latitude, result.data.longitude);
            }
            else if(type == 'address'){
              cu_this.latitude = result.data.latitude;
              cu_this.longitude = result.data.longitude;
              cu_this.loadLocation();// 加载当前位置

              setTimeout(() => {
                let tempCount = 0;
                $('div.sign-map>div>div').each(function () {
                  tempCount++;
                  if(tempCount==2||tempCount==3){
                    $(this).remove();
                  }
                });
              }, 500);
            }
            else if(type == 'nearby'){
              cu_this.latitude = result.data.latitude;
              cu_this.longitude = result.data.longitude;
              sessionStorage.setItem('nearby_lat', cu_this.latitude);
              sessionStorage.setItem('nearby_long', cu_this.longitude);
              cu_this.loadLocation();// 加载当前位置
            }
          }
          else{
            if(type == 'create'){
              cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
            }
            else if(type == 'work_create' || type == 'sign' || type == 'address'){
              cu_this.currentPlace = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
            }
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei'){
      em.getLocation({
        locationType: '', // 默认使用高德定位，如果要google地图则值为：Google,百度为baidu
        timeout: 2, // 高德定位超时时间默认最小2秒，时间越长越准
        needGeocode: true, // 是否需要逆地理编码(位置名称) 不需要可以自行解析
        success: function (res) {
          // var latitude = res.latitude; // 纬度，浮点数，范围为90 ~ -90
          // var longitude = res.longitude; // 经度，浮点数，范围为180 ~ -180。
          // var speed = res.speed; // 速度，以米/每秒计
          // var accuracy = res.accuracy; // 位置精度
          // var address = res.address; // 地理位置，如上海市浦江镇泛联航路泛微软件软件大厦
          // var locationType=res.locationType; //定位类型 Google或者Amap 表明定位使用的地图
          // var name=res.name; //建筑物所在的名称 如泛微软件软件大厦等地名 (google独有)
          // var locationList=res.locationList; //附近的位置列表数组 字段和 res一致(google独有)
          // var likelihood=res.likelihood; //double类型 0-1标识位置的准确度，越高越准 locationList 里面每个元素都有该字段 降序排列的(google独有)
          if(type == 'create'){
            cu_this.signData.address = res.address;
            cu_this.signData.latitude = res.latitude;
            cu_this.signData.longitude = res.longitude;
            cu_this.getPlaceFromPoint(res.latitude, res.longitude);
          }
          else if(type == 'work_create' || type == 'sign'){
            cu_this.currentPlace = res.address;
            cu_this.sign_latitude = res.latitude;
            cu_this.sign_longitude = res.longitude;
            cu_this.getPlaceFromPoint(res.latitude, res.longitude);
          }
          else if(type == 'address'){
            cu_this.longitude = res.longitude;
            cu_this.latitude = res.latitude;
            cu_this.loadLocation();// 加载当前位置

            setTimeout(() => {
              let tempCount = 0;
              $('div.sign-map>div>div').each(function () {
                tempCount++;
                if(tempCount==2||tempCount==3){
                  $(this).remove();
                }
              });
            }, 500);
          }
          else if(type == 'nearby'){
            cu_this.latitude = res.latitude;
            cu_this.longitude = res.longitude;
            sessionStorage.setItem('nearby_lat', cu_this.latitude);
            sessionStorage.setItem('nearby_long', cu_this.longitude);
            cu_this.loadLocation();// 加载当前位置

            setTimeout(() => {
              let tempCount = 0;
              $('div.sign-map>div>div').each(function () {
                tempCount++;
                if(tempCount==2||tempCount==3){
                  $(this).remove();
                }
              });
            }, 500);
          }
        },
        onLocationChanged:function (res) {
          //位置变化时会调用，数据结构和success一致，由于单次定位的精度存在不高，定位不准的情况，客户端在位置得到更新后会回调此函数，建议处理为success一样的逻辑
          if(type == 'create'){
            cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
          }
          else if(type == 'work_create' || type == 'sign'){
            cu_this.currentPlace = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
          }
        },
        fail: function (res) {
          // alert(res.errMsg); // 失败时可以显示错误信息（如：定位权限被禁用,请授予应用定位权限）
          if(type == 'create'){
            cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
          }
          else if(type == 'work_create' || type == 'sign'){
            cu_this.currentPlace = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
          }
        }
      });
    }
    else if(that.mobileSource == 'zhiyuan'){
      cmp.lbs.getCurrentPosition({
        mode:1,
        success:function(res) {
          // console.log(res);
          cu_this.getPlaceFromPoint(res.coordinate.latitude, res.coordinate.longitude);
        },
        error:function(res) {
          // console.log(res);
          cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
        }
      });
    }
    else if(that.mobileSource == 'app'){
      lingdang.getLocation({
        type: 'wgs84',// 默认为wgs84的gps坐标，如果要返回直接给openLocation用的火星坐标，可传入'gcj02'
        success: function (res) {
          cu_this.getPlaceFromPoint(res.latitude, res.longitude);
        },
        cancel: function (res) {
          cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
        },
        fail: function (res) {
          cu_this.signData.address = cu_this.arrFixedLabel.NOADDRESSISOBTAINED;
        }
      });
    }
    else{
      wx.getLocation({
        type: 'wgs84',// 默认为wgs84的gps坐标，如果要返回直接给openLocation用的火星坐标，可传入'gcj02'
        success: function (res) {
          // alert(JSON.stringify(res));
          cu_this.translatePoint(res.latitude, res.longitude);
        },
        cancel: function (res) {
          if(type == 'create'){
            cu_this.signData.address = '获取经纬度失败';
          }
          else if(type == 'work_create' || type == 'sign'){
            cu_this.currentPlace = '获取经纬度失败';
          }
        },
        fail: function (res) {
          if(type == 'create'){
            cu_this.signData.address = '未获取经纬度';
          }
          else if(type == 'work_create' || type == 'sign'){
            cu_this.currentPlace = '未获取经纬度';
          }
        }
      });
      // wx.checkJsApi({
      //   jsApiList: ['getLocation'], // 需要检测的JS接口列表
      //   success: function(res) {
      //     alert(JSON.stringify(res));
      //   }
      // });
    }
  }

  this.public_scan=function(type, fieldname){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'dingding'){
      if (dd.env.platform !== "notInDingTalk") {
        dd.ready(function () {
          dd.biz.util.scan({
            type: String ,
            onSuccess: function(data) {
              let scantext = data.text;
              if(type == 'addproduct'){
                cu_this.scanAfterByAddProduct(scantext);
              }
              else{
                cu_this.scanAfter(scantext, fieldname);
              }
            },
            onFail : function(err) {
            }
          });
        });
      }
    }
    else if(that.mobileSource == 'yunzhijia'){
      qing.call("scanQRCode",  {
        "needResult":1,
        "isShowAlbum":true,
        "success": function(result) {
          let scantext = result.data.qrcode_str;
          if(type == 'addproduct'){
            cu_this.scanAfterByAddProduct(scantext);
          }
          else{
            cu_this.scanAfter(scantext, fieldname);
          }
        }
      });
    }
    else if(that.mobileSource == 'fanwei' || that.mobileSource == 'zhiyuan'){
    }
    else if(that.mobileSource == 'app'){
      lingdang.scanQRCode({
        desc: 'scanQRCode desc',
        needResult: 1, // 默认为0，扫描结果由企业微信处理，1则直接返回扫描结果，
        scanType: ["qrCode", "barCode"], // 可以指定扫二维码还是一维码，默认二者都有
        success: function(res) {
          let scantext = res.resultStr;
          if(type == 'addproduct'){
            cu_this.scanAfterByAddProduct(scantext);
          }
          else{
            cu_this.scanAfter(scantext, fieldname);
          }
        },
        error: function(res) {
          if (res.errMsg.indexOf('function_not_exist') > 0) {
            cu_this.topTipsBox(cu_this.arrFixedLabel.VERSIONLOWPLEASEUPGRADE);//顶部提示
            return;
          }
        }
      });
    }
    else{
      wx.scanQRCode({
        desc: 'scanQRCode desc',
        needResult: 1, // 默认为0，扫描结果由企业微信处理，1则直接返回扫描结果，
        scanType: ["qrCode", "barCode"], // 可以指定扫二维码还是一维码，默认二者都有
        success: function(res) {
          let scantext = res.resultStr;
          if(type == 'addproduct'){
            cu_this.scanAfterByAddProduct(scantext);
          }
          else{
            cu_this.scanAfter(scantext, fieldname);
          }
        },
        error: function(res) {
          // alert('失败');
          if (res.errMsg.indexOf('function_not_exist') > 0) {
            cu_this.topTipsBox(cu_this.arrFixedLabel.VERSIONLOWPLEASEUPGRADE);//顶部提示
            return;
          }
        }
      });
    }
  }

  // 通讯录选人接口
  this.selectEnterpriseContact=function(){
    let cu_this=that.vueobj;
    wx.invoke("selectEnterpriseContact", {
        "fromDepartmentId": 0,// 必填，-1表示打开的通讯录从自己所在部门开始展示, 0表示从最上层开始
        "mode": "multi",// 必填，选择模式，single表示单选，multi表示多选
        "type": ["department", "user"],// 必填，选择限制类型，指定department、user中的一个或者多个
        "selectedDepartmentIds": [],// 非必填，已选部门ID列表。用于多次选人时可重入
        "selectedUserIds": []// 非必填，已选用户ID列表。用于多次选人时可重入
      }, function (res) {
        cu_this.gotoEnterpriseContactAfter(res);
      }
    );
  }

  // 创建会话接口
  this.openEnterpriseChat=function(userIds, externalUserIds, groupName){
    let cu_this=that.vueobj;
    // 注意：userIds和externalUserIds至少选填一个，且userIds+openIds总数不能超过2000。
    wx.openEnterpriseChat({
      userIds: userIds,//参与会话的企业成员列表，格式为userid1;userid2;...，用分号隔开。
      externalUserIds: externalUserIds,// 参与会话的外部联系人列表，格式为userId1;userId2;…，用分号隔开。
      groupName: groupName,// 必填，会话名称。单聊时该参数传入空字符串""即可。
      success: function (res) {
        // 回调
      },
      fail: function (res) {
        if (res.errMsg.indexOf('function not exist') > -1) {
          cu_this.popPromptBox(cu_this.arrFixedLabel.WECHATVERSIONLOWPLEASEUPGRADE);//弹出框提示
        }
      }
    });
  }

  //外部联系人选人接口
  this.selectExternalContact=function(){
    let cu_this=that.vueobj;
    //外部联系人选人接口
    wx.invoke('selectExternalContact', {
      "filterType": 0, //0表示展示全部外部联系人列表，1表示仅展示未曾选择过的外部联系人。默认值为0；除了0与1，其他值非法。在企业微信2.4.22及以后版本支持该参数
    }, function (res) {
      cu_this.gotoExternalContactAfter(res);
    });
  }

  this.openAtt=function (attInfo){
    let cu_this=that.vueobj;
    if(attInfo.ext == 'video'){
      if(that.mobileSource == 'app'){
        cu_this.openAttAfter(attInfo.id, attInfo.isentry);
      }
      else{
        lingdang.gotoOpenUrl(attInfo.url);
      }
    }
    else if(attInfo.ext == 'ofd'){
      cu_this.openAttAfter(attInfo.id, attInfo.isentry);
    }
    else if(attInfo.ext == 'txt'){
      lingdang.gotoOpenUrl(attInfo.url);
    }
    else{
      if(attInfo.type == 'preview'){
        cu_this.openAttAfter(attInfo.id, attInfo.isentry);
      }
      else{
        if(that.mobileSource == 'qiyeweixin' && $.device['os'] == "ios"){
          lingdang.gotoOpenMenuItems();
          lingdang.previewFile(attInfo.url, attInfo.name, attInfo.size);
        }
        else if(that.mobileSource == 'dingding'){
          lingdang.previewFile(attInfo.url, attInfo.name);
        }
        else{
          lingdang.gotoOpenUrl(attInfo.url);
        }
      }
    }
  }

  // 轨迹地图
  this.tracklocationmap_load=function (attInfo){
    let cu_this=that.vueobj;
    if(that.mobileSource == 'app'){
      if(lingdang.onHistoryBack){
        lingdang.onHistoryBack(function(){
          if(cu_this.$route.name == 'tracklocationmap'){
            return true;
          }
        });
      }
    }
  }
}

// 引用各自独有js
let mobileSource = sessionStorage.getItem('mobileSource');
let builddate = '20240930';
if(mobileSource == 'dingding'){
  Tools.getScriptBack('static/common/ld_dingding.js?version='+builddate)
}
else if(mobileSource == 'yunzhijia'){
  Tools.getScriptBack('static/common/ld_yunzhijia.js?version='+builddate)
}
else if(mobileSource == 'fanwei' || mobileSource == 'zhiyuan'){
  Tools.getScriptBack('static/common/imagePreview.js?version='+builddate)
}
else if(mobileSource == 'app'){
  Tools.getScriptBack('static/common/ld_app.js?version='+builddate)
  Tools.getScriptBack('static/common/imagePreview.js?version'+builddate)
}
else{
  Tools.getScriptBack('static/common/ld_qiyeweixin.js?version='+builddate)
}

// 批量隐藏功能按钮接口
lingdang.hideMenuItemsBefore=function(){
  var mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'qiyeweixin'){
    wx.hideMenuItems({
      menuList: [
        'menuItem:setFont',//基本类-调整字体
        'menuItem:refresh',//基本类-刷新
        'menuItem:share:appMessage',//传播类-转发
        'menuItem:share:wechat',//传播类-微信
        'menuItem:favorite',//传播类-收藏
        'menuItem:copyUrl',//保护类-复制链接
        'menuItem:openWithSafari',//保护类-Safari
        'menuItem:share:email'//保护类-邮件
      ]
    });
  }
}
// 企业微信配置微信JS-SDK
lingdang.getWxConfigBefore=function(){
  var mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'qiyeweixin'){
    lingdang.getWxConfig();//配置微信JS-SDK
  }
}
// 企业微信agentConfig调用
lingdang.getAgentConfigBefore=function(){
  var mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'qiyeweixin'){
    lingdang.getAgentConfig();
  }
}

// 返回不同前端上传图片、附件URL
lingdang.getUploadUrl=function(){
  var mobileSource = sessionStorage.getItem('mobileSource');
  var allurl = sessionStorage.getItem('corpurl') + 'WeiXinApp/';
  if(mobileSource == 'dingding'){
    allurl += 'dingtalk/index.php';
  }
  else if(mobileSource == 'yunzhijia'){
    allurl += 'yunzhijia/index.php';
  }
  else if(mobileSource == 'fanwei'){
    allurl += 'fanwei/index.php';
  }
  else if(mobileSource == 'zhiyuan'){
    allurl += 'zhiyuan/index.php';
  }
  else if(mobileSource == 'app'){
    allurl += 'indexnative.php';
  }
  else{
    allurl += 'index.php'; 
  }
  allurl += '?module=Upload&action=uploadfile&related_module=Singin&userid=';
  if(mobileSource == 'app'){
    allurl += encodeURIComponent(sessionStorage.getItem('userid')) +"&appusertoken="+encodeURIComponent(sessionStorage.getItem("appusertoken"));
  }
  else{
    allurl += sessionStorage.getItem('userid');
  }
  return allurl;
}

//打开图片
lingdang.previewImage=function (imgArr, open_url){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    lingdang.previewImageDingding(imgArr, open_url);
  }
  else if(mobileSource == 'yunzhijia'){
    lingdang.previewImageYunzhijia(imgArr, open_url);
  }
  else if(mobileSource == 'app' || mobileSource == 'fanwei' || mobileSource == 'zhiyuan'){
    ImagePreview.init({url:open_url, url_arr:imgArr});
  }
  else{
    lingdang.previewImageQiyeweixin(imgArr, open_url);
  }
}

//打开URL
lingdang.gotoOpenUrl=function (url){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'qiyeweixin'){
    lingdang.gotoOpenUrlQiyeweixin(url);
  }
  else{
    window.location.href = url;
  }
}

//打开附件
lingdang.previewFile=function (url, name, size){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    lingdang.previewFileDingding(url, name, size);
  }
  else if(mobileSource == 'qiyeweixin'){
    lingdang.previewFileQiyeweixin(url, name, size);
  }
  else{
    window.location.href = url;
  }
}

//打开地图
lingdang.mapView=function (latitudeVal, longtitudeVal, signaddress, name, scale){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    lingdang.mapViewDingding(latitudeVal, longtitudeVal, signaddress, name, scale);
  }
  else if(mobileSource == 'yunzhijia'){
    lingdang.mapViewYunzhijia(latitudeVal, longtitudeVal, signaddress, name, scale);
  }
  else if(mobileSource == 'fanwei' || mobileSource == 'zhiyuan'){
  }
  else if(mobileSource == 'app'){
    lingdang.mapViewApp(latitudeVal, longtitudeVal, signaddress, name, scale);
  }
  else{
    lingdang.mapViewQiyeweixin(latitudeVal, longtitudeVal, signaddress, name, scale);
  }
}

//关闭应用
lingdang.closeWindows=function (){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    lingdang.closeWindowsDingding();
  }
  else if(mobileSource == 'yunzhijia'){
    qing.call('closeWebView');
  }
  else if(mobileSource == 'fanwei' || mobileSource == 'zhiyuan'){
    window.location.reload();//页面自动刷新
  }
  else if(mobileSource == 'app'){
    lingdang.LoginOff();
  }
  else{
    wx.closeWindow();
  }
}

//设置标题
lingdang.setDocumentTitle=function (title){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    lingdang.setDocumentTitleDingding(title);
  }
  else if(mobileSource == 'yunzhijia'){
    qing.call('setWebViewTitle', {'title': title});
  }
  else if(mobileSource == 'app'){
    lingdang.setDocumentTitleApp(title);
  }
  else{
    document.title = title;
  }
}

//复制
lingdang.clipboardData=function (copycontent){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    lingdang.clipboardDataDingding(copycontent);
  }
  else{
    // 创建input标签，将复制内容暂存为value值
    var copy_content = document.createElement("input");
    copy_content.setAttribute("value", copycontent);
    // 将input添加到body
    document.body.appendChild(copy_content);
    // 选中input的文本内容
    copy_content.select();
    // 执行复制
    document.execCommand("copy");
    // 删除input标签
    document.body.removeChild(copy_content);
  }
}

//水印
lingdang.gotoShuiyin=function (){
  if(sessionStorage.getItem("watermark_txt")!='' && sessionStorage.getItem("watermark_txt")!=null && sessionStorage.getItem("watermark_txt") !='undefined'){
    Tools.getScriptBack('static/common/shuiyin.js?version=1.0')
    watermark({"watermark_txt": sessionStorage.getItem('watermark_txt')});
  }
}

// 拨打电话
lingdang.smsPhonePage=function(phone){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'app'){
    lingdang.smsPhonePageApp(phone);
  }
  else{
    window.location.href = 'tel:' + phone;
  }
}
lingdang.smsPhone=function(phone){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'app'){
    lingdang.smsPhoneApp(phone);
  }
  else{
    window.location.href = 'tel:' + phone;
  }
}

// 返回正确模块名称
lingdang.getRealModuleName=function(tabname){
  if (tabname == 'PublicAccounts' || tabname == 'LeadsUpToAccounts') {
    tabname = 'Accounts';
  }
  if (tabname == 'PublicLeads') {
    tabname = 'Leads';
  }
  return tabname;
}

// 返回机器型号
lingdang.getMobileDevice=function(){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'app'){
    return lingdang.getMobileDeviceByApp();
  }
  else{
    if ($.device['os'] == "ios") {
      return 'ios';
    }
    else {
      return 'android';
    }
  }
}

// 暂存：将new赋值到old
lingdang.localStorageModuleName=function(tabname, type){
  let tabmodule = tabname;
  if(tabmodule == 'CashBill'){
    tabmodule += '_' + type;
  }
  return tabmodule;
}
lingdang.localStorageOldHaveNewEmpty=function(systemsDataCreate, tabname, type){
  if(systemsDataCreate && systemsDataCreate.deploy_357_value == 'yes'){
    let tabmodule = lingdang.localStorageModuleName(tabname, type);
    let key_new = sessionStorage.getItem('corpurl')+tabmodule+sessionStorage.getItem('userid')+'_create_new';
    let key_new_status = sessionStorage.getItem('corpurl')+tabmodule+sessionStorage.getItem('userid')+'_create_new_status';
    let key_old = sessionStorage.getItem('corpurl')+tabmodule+sessionStorage.getItem('userid')+'_create_old';
    localStorage.setItem(key_old, localStorage.getItem(key_new));
    localStorage.removeItem(key_new);
    localStorage.removeItem(key_new_status);
  }
}

// 轨迹-选用户
lingdang.setChooseUserValue=function(chooseuserarrstr){
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'app'){
    return lingdang.setChooseUserValueByApp(chooseuserarrstr);
  }
}

// 列表界面-拍名片
lingdang.imgSelectChange=function(e){
  imgSelectChange(e);
}

// 后台请求方法
function lingdangAjax(url, param, callback){
  $.ajax({
    url: url,
    type: 'POST',
    data: param,
    timeout: 5000,
    success: function(data){
      var result_obj = '';
      try{
        result_obj = eval("(" + data + ")") ? eval("(" + data + ")") : JSON.parse(data);
      }
      catch(ex){
      }
      callback(result_obj);
    }
  });
}
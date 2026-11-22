var userid = '';
var loginurl = '';
var phoneversion = '';
var enterprisename='';
var individualname='';
var loginpwd='';
var remember='';
var loginout='';
var sessionStorage = window.sessionStorage;//定义本地存储
//**********************************************************************************

//main.js 
var category = '';
var searchcontent='';//列表搜索内容
var work_searchcontent='';//工作查找
var imghtml = '',imgid = '';//图片、图片ID
var uploadCount = 1;
var popWorkAddtionMarginTop=''; //"工作"界面，“添加”弹出框居中
var imageTimeIntervalid=0;//IOS手机拍照时钟ID
var chooseModuleArray = ['10','51','53','153','57','58','59','73','75','76','78','79','80','81','82','96','102','173','200','202','240','241','242','243','154'];//模块选择的ID
var selectArray = ['15','33','56','117','251'];//下拉单选、下拉多选、选择框、货币、账户
var formulaArray = ['Quotes','SalesOrder','ServiceContracts','PurchaseOrder','Expense','Commission','AddJobBill','MinusJobBill','BusinessApply'];//需要加载字段公式的模块
//**********************************************************************************

//common.js 
var workreport_field_obj = {};//工作，字段
//同事、部门选择值
var choose_useridobj=[];var choose_usernameobj=[];
var choose_groupidobj=[];var choose_groupnameobj=[];
var choose_pa_usersidobj=[];var choose_pa_usersnameobj=[];//公告接收人
var choose_db_useridobj=[],choose_db_nameobj=[];//仪表盘，选择用户ID，名称
var choose_shared_useridobj=[];var choose_shared_usernameobj=[];//共享人
var choose_ba_usersidobj=[];var choose_ba_usersnameobj=[];//出差申请单同行人

var btnshowCCname = '';

var approveuserid = [];//审批人id
var approveusername = [];//审批人名称 
// 相关明细
var newmodulename = '';
var newmodule = '';
var relatedrecord ='';
var relatedmodule = '';
var related_id = '';
//**********************************************************************************

//crm.js 
var module = '',modulename = '',popmodule = '',approvemodule='';
var searchcontentDetail='';
var recordID = '';
var fieldStr = '';var fieldNameStr = '';var moduleNameStr = '';

var createpermit = '';//是否有创建权限，yes:有
var editpermit = '';//是否有编辑权限(yes:有)
var distributionpermit = '';//是否有分配权限(yes:有)
var allocateaccountpermit = '';//是否有公海分配权限(yes:有)
var receivepermit = '';//是否有领取权限
var sharepermit = '';//是否有领取权限
var advancepermit = '';//是否有推进权限(yes:有)
var submitapprove = '';//是否有提交审批按钮权限,yes:有
var approvepermit = '';//是否有审批按钮权限,yes:有
var cancelapprove = '';//是否有反审批按钮权限,yes:有
var delpermit = '';//是否有删除权限(yes:有)
var signuserid = 0;//查看签到用户ID

var rowcnt=1;//产品总行
var productcount = 0;//产品数量
var currencyid = 1;
var arrProductObj = {}; //产品明细字段数组
var noArrProductObj = {};//不显示并且有字段公式的自定义字段
var arrCurrencyObj = {}; //币种
var arrFormulaFieldObj = {};//字段公式数组
var fieldformulaobj ='';//字段公式对象
var editproductid = '';//编辑产品id组合
var editproductrow = '';//编辑产品行
var tax_cur = Array();//税别
var arrExpenseObj = {};//费用清单字段组
var arrOaDetailObj = {};//OA表单：加班单、请假单、出差申请单、佣金单字段组

var billfieldStr = '';//所有字段信息组合
var checkEmptyStr = '';//主表不为空字段信息组合
var fieldcheckEmptyStr = '';//分录不为空字段信息组合
var fieldonlyStr = '';//不能重复字段组合

var priceFieldName = Array();//模块表单金额字段
var priceFieldNameNum = 0;//模块表单金额字段数量

var emailFieldNameArray = Array();//模块表单Email字段
var emailFieldNameArrayNum = 0;//模块表单Email字段数量
//**********************************************************************************

//work.js 
var relationtype = '';//关联数据类型
var relationidkey='',relationnamekey='';//存储键值
var t_choose_a_relationidobj = [],t_choose_a_relationnameobj = [];//关联数据id,关联数据名称，临时保存 客户
var t_choose_c_relationidobj = [],t_choose_c_relationnameobj = [];//关联数据id,关联数据名称，临时保存 联系人
var t_choose_p_relationidobj = [],t_choose_p_relationnameobj = [];//关联数据id,关联数据名称，临时保存 产品
var btnshowRelationname='';
var searchtype='';//comment点评人，execute为执行人
var imglist = '';
var bigcategory = '1',smallcategory = 'all';
var entitytypetag = '';//当前发布的类别，大分类。分享、日志、任务
var savetype = 1;//当前发布的类别，小分类。日报、周计划、月计划
var is_mandatoryStr = '';//微博、日志、任务字段组合
//**********************************************************************************

var GVObj={
    deviceID:'',//唯一标识
    newstype:'',
    main_header:[],
    workrecord:0, 
    news_smallcategory:'',
    approveObj:{
        approvestatus:'',
        newapproveid:'',//新的审批流程ID
        //stepname:'',//当前审批步骤名称
        
    },
    workObj:{
        parentid:0,//是否是回复的回复
        liststatus:'search',//判断是首次加载列表，还是搜索列表，search为搜索，空为其他状态
        optperson:'',//点评人
        execution:''//执行人        
    },
    crmObj:{
        parentid:'',//选择弹框，上级ID
        liststatus:0,//0公共列表;1签到列表  
        quickcreateStatus:'yes'//判断是快速创建还是普通创建     
    },
    meObj:{        
    }
};
//ViewObj.rootScope.accountresult//客户标签
//ViewObj.rootScope.SearchScope//查看范围
//ViewObj.rootScope.publicstatus//是否开启公海客户
//ViewObj.rootScope.publicaccount//创建客户，公海类别：0普通客户、2公海已分配、1公海未分配
//ViewObj.rootScope.related_recordid//crm单据相关信息id
//ViewObj.rootScope.sys_49//单据明细中数量小数位数
//ViewObj.rootScope.sys_93//设置单据分录明细中单价字段小数位数
//ViewObj.rootScope.quickcreate//CRM列表界面，是否有快速创建功能
//ViewObj.rootScope.paiming : []//应用-仪表盘-排名数组
//ViewObj.rootScope.imginfo//图片来源，外勤签到
//ViewObj.rootScope.imagefrom//照片来源，其他
//ViewObj.rootScope.signpage//签到页面进入到第几层页面
//ViewObj.rootScope.hiddenlistprice//判断不含税单价是否隐藏。no是不隐藏，yes是隐藏
//ViewObj.rootScope.entitynamevlaue//记录当前模块entityname值，主要用来分配时提醒
//ViewObj.rootScope.camcard//记录当前名片创建时，对照ID
//ViewObj.rootScope.approvetype//审批提醒/审批中心：0:待审批,1:已审批,2:近30天
//ViewObj.rootScope.approvemodule
//ViewObj.rootScope.approvemodulename
//ViewObj.rootScope.defaultcountry
//ViewObj.rootScope.defaultstate
//ViewObj.rootScope.defaultcity
//ViewObj.rootScope.productstatus//add,edit,del
//ViewObj.rootScope.relatedCreationInfo//关联创建相关参数
//ViewObj.rootScope.productsstatus
//ViewObj.rootScope.attachmentdetailid//拍照上传返回的明细ID
//ViewObj.rootScope.workpage//工作页面打开页签
//ViewObj.rootScope.newspage//工作页面打开页签  (wn-worklist-view：待处理、@我的工作、我发出的工作、news-third-view：我发出工作回复、@我的回复、我收到的赞)
//ViewObj.rootScope.listsearchstr//列表查找
//ViewObj.rootScope.att_arr//附件信息
//ViewObj.rootScope.att_count//附件个数
//ViewObj.rootScope.att_maxcount//附件最大个数

//ViewObj.rootScope.approveid//审批流程ID
//ViewObj.rootScope.stepid//审批流程—步骤ID
//ViewObj.rootScope.nextstep//审批流程—下一步骤ID
//ViewObj.rootScope.laststepid//审批流程—上一步骤ID
//
//ViewObj.rootScope.openapprove//是否启用审批历史,yes:启用
//ViewObj.rootScope.opencomments//是否启用评论,yes:启用
//ViewObj.rootScope.operability//可操作性，主用选择产品，执行字段公式后使用
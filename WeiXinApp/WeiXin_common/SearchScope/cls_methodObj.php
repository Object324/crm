<?php
	class cls_methodObj {
		public $module;	//模块
		public $searchtype;	//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
		public $filterown;	//是否过滤自己(yes:过滤, no:不过滤)
		public $scopetype;	//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
		public $common; //是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
		public $isactive; //是否显示禁用用户（yes:显示,no:不显示  默认no）

		public function setModule($module){
			$this->module = $module;
		}

		public function setSearchType($searchtype){
			$this->searchtype = $searchtype;
		}

		public function setFilterown($filterown){
			$this->filterown = $filterown;
		}

		public function setScopeType($scopetype){
			$this->scopetype = $scopetype;
		}

		public function setCommon($common){
			$this->common = $common;
		}

		public function setActive($isactive){
			$this->isactive = $isactive;
		}

		public function getModule() {
			return $this->module;
		}

		public function getSearchType() {
            //editor:gyq
            // $deploy_values=getSys_deploy(110);
			//eidtor:gyq date:20170401 $_REQUEST['popup_type'] = 'Allocate'!!!!!!!!!!
			if($_REQUEST['popup_type'] == 'Allocate' || $_REQUEST['scopetype']=='share'){
                $result = 'all';
			}else{
                $result = $this->searchtype;
            }
			return $result;
		}

		public function getFilterown() {
			return $this->filterown;
		}

		public function getScopeType() {
			return $this->scopetype;
		}

		public function getCommon() {
			return $this->common;
		}

		public function getActive(){
			return $this->isactive;
		}
	}
	
?>
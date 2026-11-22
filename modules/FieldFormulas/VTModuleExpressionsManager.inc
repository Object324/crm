<?php
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ******************************************************************************/
require_once("include/events/SqlResultIterator.inc");
class VTModuleExpressionsManager{
	function __construct($adb){
		$this->adb = $adb;
	}

	/** Caching logic **/
	private static $cache = array();
	static function addToCache($key, $value) {
		 self::$cache[$key] = $value;
	}
	static function fromCache($key) {
		if(isset(self::$cache[$key])) return self::$cache[$key];
		return false;
	}
	static function clearCache() {
		self::$cache = array();
	}
	/** END **/
	
	function retrieve($moduleName){
		$adb = $this->adb;
		
		// Look at cache if we have the information
		$cachedinfo = self::fromCache($moduleName);
		if($cachedinfo === false) {
			
			$result = $adb->pquery('select * from LD_fieldformulas where modulename=?', array($moduleName));
			if($adb->num_rows($result)==0){
				self::addToCache($moduleName, array() );
			}else{
				$ee = unserialize(decode_html($adb->query_result($result, 0, "expression_engine")));
				$id = $adb->query_result($result, 0, "expressionid");
				self::addToCache($moduleName, array('expressionid'=>$id, 'expression_engine'=>$ee));
			}
			// Retrieve information from cache for consistency
			$cachedinfo = self::fromCache($moduleName);
		}
		
		$me = new VTModuleExpressions($moduleName, new VTExpressionEngine());
		if(!empty($cachedinfo)) {
			$me = new VTModuleExpressions($moduleName, $cachedinfo['expression_engine']);
			$me->id = $cachedinfo['expressionid'];
		}
		return $me;
		
	}

	function save($moduleExpressions){
		$adb = $this->adb;
		if(isset($moduleExpressions->id)){
			$adb->pquery('update LD_fieldformulas set expression_engine=? where expressionid=?',
			array(serialize($moduleExpressions->expressionEngine), $moduleExpressions->id));
		}else{
			$id = $adb->getUniqueId('LD_fieldformulas');
			$adb->pquery('insert into LD_fieldformulas
					(expressionid, modulename, expression_engine) values(?,?,?)', 
			array($id, $moduleExpressions->moduleName,
			serialize($moduleExpressions->expressionEngine)));
			$moduleExpressions->id = $id;
		}
		// Invalidate cache information
		self::clearCache();
	}


	function expressionFields($moduleName){
		global $current_user;
		$result = vtws_describe($moduleName, $current_user);
		$fields = $result['fields'];
		$arr = array();
		foreach($fields as $field){
			//Use the field name to figure out the custom field
			if(preg_match('/cf_\d+/', $field['name']) &&
			in_array($field['type']['name'], array('text', 'string','integer', 'double'))){
				$arr[$field['name']] = getTranslatedString($field['label'], $moduleName);
			}
		}
		return $arr;
	}

	function fields($moduleName){
		global $current_user;
		$result = vtws_describe($moduleName, $current_user);
		$fields = $result['fields'];
		$arr = array();
		foreach($fields as $field){
			//$arr[$field['name']] = getTranslatedString($field['label'],'');
			$arr[$field['name']] = $this->getFieldNameLanguage($moduleName,$field['name'],$field['label']);
		}
		return $arr;
	}
    function getFieldNameLanguage($module,$fieldname,$fieldlabel = '')
    {
        global $current_user;
        $adb = $this->adb;
        require('user_privileges/user_language_'.$current_user->id.'.php');
        
        $tabid = getTabid($module);
        $sql = "select fieldlabel from ld_tranlabel where languagetype = ? and trantable = ? and tabid = ? 
        and Relateid = (select fieldid from ld_field where tabid = $tabid and fieldname = '$fieldname' ";
		/**
		 * 字段公式，切换到联系人模块时，联系人的contact_id有两个值（经理、上级联系人）
		 * 所以需要特别处理，增加一个条件
		 * @reason 0011305 字段公式编辑方式不合理
		 * @author Tujt 2014-09-12
		 */
		if($module == 'Contacts' && $fieldname == 'contact_id' && !empty($fieldlabel)){
			$sql .= ' and fieldlabel = "'.$fieldlabel.'" ';
		}
		$sql .= ' limit 1) ';
        $result = $adb->pquery($sql,array($languageType,'LD_field',$tabid));
        return $adb->query_result($result,0,0);
    }
	function expressionFunctions(){
		//return array('concat' => 'concat(a,b)', 'time_diffdays' => 'time_diffdays(a,b)', 'time_diff' => 'time_diff(a,b)');
        return array(getFixedLabel('CONCAT') => 'concat(a,b)', getFixedLabel('TIMEDIFFDAYS') => 'time_diffdays(a,b)', getFixedLabel('TIMEDIFF') => 'time_diff(a,b)');
	}

	private function fieldNames($query, $moduleName){
		$adb = $this->adb;
		$result = $adb->pquery($query, array($moduleName));
		$it = new SqlResultIterator($adb, $result);
		$arr = array();
		foreach($it as $row){
			$arr[$row->fieldname]=$row->fieldlabel;
		}
		return $arr;
	}

	function expressionsForModule($moduleName){
		return $this->retrieve($moduleName)->asArray();
	}
}

class VTModuleExpressions{
	function __construct($moduleName, $expressionEngine){
		$this->moduleName=$moduleName;
		$this->expressionEngine=$expressionEngine;
	}

	function add($fieldName, $expression){
		try{
			$this->expressionEngine->loadExpressions(array($fieldName=>$expression));
			$this->state='savable';
		}catch(VTExpressionException $e){
			$this->state='error';
			$this->message=$e->getMessage();
		}
	}

	function remove($fieldName){
		$this->expressionEngine->removeExpression($fieldName);
	}

	function asArray(){
		return $this->expressionEngine->unparsedExpressions;
	}

	function parseExpression($expr){
		$parser = new VTParser(new SpaceFilter(new VTTokenizer($expr)));
		return $parser->expression();
	}

	function update($entity){
		$bound = $this->expressionEngine->evaluate($entity->getData());
		foreach($bound as $field => $value){
			$entity->set($field, $value);
		}
	}

	function getFieldsFromExpr($expr){
		function __getFieldsFromExpr($expr, &$arr){
			switch(get_class($expr)){
				case 'VTTreeNode':
					$params = $expr->getParams();
					foreach($params as $param){
						__vtGetFieldsFromExpr($param, $arr);
					}
					return;
				case 'Symbol':
					$arr[$expr->value] = $expr;
					return;
				default:
					return;
			}
		}
		__vtGetFieldsFromExpr($expr, $arr);
		return array_keys($arr);
	}
}

?>
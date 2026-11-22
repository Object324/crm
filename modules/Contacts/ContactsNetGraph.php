<?php

class ContactsNetGraph
{
    public function __construct($record)
    {
        global $adb;
        $this->adb = $adb;
        $this->contactid = $record;
    }

    public function getInstance() {

    }

    public function getNetGraphData() {
        $this->getCateories();
        $this->graphNodes = [];
        $this->graphLinks = [];
        $this->getNodesData();
        $graphData = [
            'legendData' => $this->legendData,
            'nodes' => $this->graphNodes,
            'links' => $this->graphLinks,
            'categories' => $this->graphCategories,
        ];
        ConvertTojsonString(1,$graphData,'');
    }

    public function getCateories() {
        $this->graphCategories = [];
        $this->categories = [];
        $this->legendData = [];
        $categories = [
            ['name'=>'curContact', 'label'=>'当前联系人'],
            ['name'=>'sysCompany', 'label'=>'国能龙源'],
            ['name'=>'curCompany', 'label'=>'当前公司'],
            ['name'=>'preCompany', 'label'=>'曾任职公司'],
        ];
        foreach ($categories as $index => $category) {
            $label = $category['label'];
            array_push($this->graphCategories,[
                "name" => $label ,
            ]);
            array_push($this->legendData,$label);
            $this->categories[$category['name']] = [
                "index" => $index,
                "label" => $label,
            ];
        }
    }

    public $nodeIndex = 0;
    public $symbolSize = 50;
    public $radius = 20;

    public function pushNode($parentNodeId, $nodeId, $name, $nodeData, string $categoryName = '') {
        if($parentNodeId === ''){
            $x = 0;
            $y = 0;
            $symbolSize = $this->symbolSize;
            $category = $this->categories[$categoryName]['index'];
        }
        else{
            $this->pushLink($nodeId,$parentNodeId);
            $parentNode = $this->getNodeById($parentNodeId);
            $symbolSize = $parentNode['symbolSize'] - 7;
            $rotate = $nodeData['rotate'];
            $x = $parentNode['x'] + $this->radius * cos( deg2rad($rotate) );
            $y = $parentNode['y'] + $this->radius * sin( deg2rad($rotate) );
            if(empty($categoryName))
                $category = $parentNode['category'];
            else
                $category = $this->categories[$categoryName]['index'];
        }
        $show = true;
        //if(strlen($name) > 12 || $symbolSize < 20)
        //$show = false;
        $symbol = "circle";
        if($nodeData['dengji'] === '高层领导') {
            $symbol = "roundRect";
        }
        $node =  [
            "id"=> $nodeId,
            "name"=> $name,
            "symbol"=> $symbol,
            "symbolSize"=> $symbolSize,
            "x"=> $x,
            "y"=> $y,
            "value"=> '',//$value,
            "label"=>[ "show" => $show ],
            "nodeData"=>$nodeData,
            "category"=> $category,
        ];
        array_push($this->graphNodes,$node);
        $this->nodeIndexList[$nodeId] = $this->nodeIndex;
        $this->nodeIndex ++;
    }

    public $linkIndex = 0;
    public function pushLink($source,$target){
        $link = [
            "id" => $this->linkIndex ++,
            "source" => $source,
            "target" => $target,
        ];
        array_push($this->graphLinks,$link);
    }

    public function setRotateInfo($nodeNum,$parentNodeId) {
        if(!isset($this->rotateInfoList[$parentNodeId])) {
            $parentNodeData = $this->getNodeById($parentNodeId)['nodeData'];
            $rotate = $parentNodeData['rotate'];
            $sector = $parentNodeData['sector'];
            if($parentNodeId === 'contact_'.$this->contactid)
                $sectorNum = $nodeNum;
            else
                $sectorNum = $nodeNum + 1;
            $this->rotateInfoList[$parentNodeId] = [
                'start' => $rotate - $sector / 2,
                'step' => $sector / $sectorNum,
            ];
        }
        return $this->rotateInfoList[$parentNodeId];
    }

    public function getNodeById($nodeId) {
        $nodeIndex = $this->nodeIndexList[$nodeId];
        return $this->graphNodes[$nodeIndex];
    }

    public function getNodesData() {
        $adb = $this->adb;
        $contactid = $this->contactid;
        $sql = "SELECT
                    ld_contactdetails.contactid AS node_id_1,
                    ld_contactdetails.lastname AS node_name_1,
                    node2.node_id_2,
                    node2.node_name_2,
                    node2.node_fullname_2,
                    node2.node_id_3,
                    node2.node_name_3,
                    node2.node_dep_3,
                    node2.node_zhiwu_3,
                    node2.node_dengji_3,
                    node2.node_id_4,
                    node2.node_name_4,
                    node2.node_fullname_4,
                    node2.node_id_5,
                    node2.node_name_5,
                    node2.node_dep_5,
                    node2.node_zhiwu_5,
                    node2.node_dengji_5
                FROM
                    ld_contactdetails
                JOIN (
                    SELECT
                        node2.node_id_2,
                        node2.node_name_2,
                        node2.node_fullname_2,
                        node2.node_id_3,
                        node2.node_name_3,
                        node2.node_dep_3,
                        node2.node_zhiwu_3,
                        node2.node_dengji_3,
                        node2.node_id_4,
                        node2.node_name_4,
                        node2.node_fullname_4,
                        node2.node_id_5,
                        node2.node_name_5,
                        node2.node_dep_5,
                        node2.node_zhiwu_5,
                        node2.node_dengji_5
                    FROM
                        (
                            (
                                SELECT
                                    node_sys.node_id_2,
                                    node_sys.node_name_2,
                                    node_sys.node_fullname_2,
                                    node3.node_id_3,
                                    node3.node_name_3,
                                    NULL AS node_dep_3,
                                    NULL AS node_zhiwu_3,
                                    NULL AS node_dengji_3,
                                    NULL AS node_id_4,
                                    NULL AS node_name_4,
                                    NULL AS node_fullname_4,
                                    NULL AS node_id_5,
                                    NULL AS node_name_5,
                                    NULL AS node_dep_5,
                                    NULL AS node_zhiwu_5,
                                    NULL AS node_dengji_5
                                FROM
                                    (
                                        SELECT
                                            'sysCompany' AS node_id_2,
                                            '国能龙源' AS node_name_2,
                                            '国能龙源' AS node_fullname_2
                                        FROM
                                            DUAL
                                    ) node_sys
                                LEFT JOIN (
                                    SELECT
                                        ld_contactrecords.smownerid AS node_id_3,
                                        ld_users.last_name AS node_name_3
                                    FROM
                                        ld_contactrecords
                                    LEFT JOIN ld_users ON ld_users.id = ld_contactrecords.smownerid
                                    WHERE
                                        FIND_IN_SET(
                                            ?, ld_contactrecords.relatedto_contact
                                        )
                                    AND ld_contactrecords.deleted = 0
                                ) node3 ON 1 = 1
                            )
                            UNION ALL
                                (
                                    SELECT
                                        CONCAT(
                                            'curCompany_',
                                            ld_contactdetails.accountid
                                        ) AS node_id_2,
                                        ld_accountscf.cf_7445 AS node_name_2,
                                        ld_account.accountname AS node_fullname_2,
                                        node3.node_id_3,
                                        node3.node_name_3,
                                        node3.node_dep_3,
                                        node3.node_zhiwu_3,
                                        node3.node_dengji_3,
                                        node4.node_id_4,
                                        node4.node_name_4,
                                        node4.node_fullname_4,
                                        node4.node_id_5,
                                        node4.node_name_5,
                                        node4.node_dep_5,
                                        node4.node_zhiwu_5,
                                        node4.node_dengji_5
                                    FROM
                                        ld_contactdetails
                                    LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
                                    LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
                                    LEFT JOIN (
                                        SELECT
                                            ld_contactdetails.accountid,
                                            ld_contactdetails.contactid,
                                            ld_contactdetails.department AS node_dep_3,
                                            ld_contactdetails.title AS node_zhiwu_3,
                                            ld_contactscf.cf_7641 AS node_dengji_3,
                                            ld_contactdetails.contactid AS node_id_3,
                                            ld_contactdetails.lastname AS node_name_3
                                        FROM
                                            ld_contactdetails
                                        LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
                                        WHERE
                                            ld_contactdetails.deleted = 0
                                        AND ld_contactscf.cf_7641 <> '员工'
                                    ) node3 ON node3.accountid = ld_contactdetails.accountid
                                    AND node3.contactid <> ld_contactdetails.contactid
                                    LEFT JOIN (
                                        SELECT
                                            ld_customform07.contactid,
                                            CONCAT(
                                                'preCompany_',
                                                ld_customform07.accountid
                                            ) AS node_id_4,
                                            ld_customform07.deleted,
                                            ld_accountscf.cf_7445 AS node_name_4,
                                            ld_account.accountname AS node_fullname_4,
                                            node5.node_id_5,
                                            node5.node_name_5,
                                            NULL AS node_dep_5,
                                            NULL AS node_zhiwu_5,
                                            NULL AS node_dengji_5
                                        FROM
                                            ld_customform07
                                        LEFT JOIN ld_account ON ld_account.accountid = ld_customform07.accountid
                                        LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
                                        LEFT JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
                                        LEFT JOIN (
                                            SELECT
                                                ld_customform07.contactid,
                                                ld_customform07.contactid AS node_id_5,
                                                ld_contactdetails.lastname AS node_name_5,
                                                ld_customform07.accountid,
                                                ld_customform07scf.cf_7473 AS stime,
                                                ld_customform07scf.cf_7474 AS etime
                                            FROM
                                                ld_customform07
                                            LEFT JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
                                            LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_customform07.contactid
                                            LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
                                            WHERE
                                                ld_customform07.deleted = 0
                                            AND ld_contactscf.cf_7641 <> '员工'
                                            UNION ALL
                                                SELECT
                                                    ld_contactdetails.contactid,
                                                    ld_contactdetails.contactid AS node_id_5,
                                                    ld_contactdetails.lastname AS node_name_5,
                                                    ld_contactdetails.accountid,
                                                    IFNULL(
                                                        ld_contactscf.cf_7657,
                                                        STR_TO_DATE(
                                                            '2019-01-01 00:00:00',
                                                            '%Y-%m-%d %H:%i:%s'
                                                        )
                                                    ) AS stime,
                                                    NOW() AS etime
                                                FROM
                                                    ld_contactdetails
                                                LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
                                                WHERE
                                                    ld_contactdetails.deleted = 0
                                                AND ld_contactscf.cf_7641 <> '员工'
                                        ) node5 ON node5.accountid = ld_customform07.accountid
                                        AND node5.contactid <> ld_customform07.contactid
                                        AND (
                                            node5.stime < ld_customform07scf.cf_7474
                                            AND node5.etime > ld_customform07scf.cf_7473
                                        )
                                        WHERE
                                            ld_customform07.deleted = 0
                                    ) node4 ON node4.contactid = node3.contactid
                                    AND node4.node_id_5 <> ld_contactdetails.contactid
                                    WHERE
                                        ld_contactdetails.contactid = ?
                                    AND ld_contactdetails.deleted = 0
                                )
                            UNION ALL
                                (
                                    SELECT
                                        CONCAT(
                                            'preCompany_',
                                            ld_customform07.accountid
                                        ) AS node_id_2,
                                        ld_accountscf.cf_7445 AS node_name_2,
                                        ld_account.accountname AS node_fullname_2,
                                        node3.node_id_3,
                                        node3.node_name_3,
                                        node3.node_dep_3,
                                        node3.node_zhiwu_3,
                                        node3.node_dengji_3,
                                        node4.node_id_4,
                                        node4.node_name_4,
                                        node4.node_fullname_4,
                                        node4.node_id_5,
                                        node4.node_name_5,
                                        node4.node_dep_5,
                                        node4.node_zhiwu_5,
                                        node4.node_dengji_5
                                    FROM
                                        ld_customform07
                                    LEFT JOIN ld_account ON ld_account.accountid = ld_customform07.accountid
                                    LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
                                    LEFT JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
                                    LEFT JOIN (
                                        SELECT
                                            ld_customform07.contactid,
                                            ld_customform07.contactid AS node_id_3,
                                            ld_contactdetails.lastname AS node_name_3,
                                            NULL AS node_dep_3,
                                            NULL AS node_zhiwu_3,
                                            NULL AS node_dengji_3,
                                            ld_customform07.accountid,
                                            ld_customform07scf.cf_7473 AS stime,
                                            ld_customform07scf.cf_7474 AS etime
                                        FROM
                                            ld_customform07
                                        LEFT JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
                                        LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_customform07.contactid
                                        LEFT JOIN ld_contactscf ON ld_contactdetails.contactid = ld_contactscf.contactid
                                        WHERE
                                            ld_customform07.deleted = 0
                                        AND ld_contactscf.cf_7641 <> '员工'
                                        UNION ALL
                                            SELECT
                                                ld_contactdetails.contactid,
                                                ld_contactdetails.contactid AS node_id_3,
                                                ld_contactdetails.lastname AS node_name_3,
                                                NULL AS node_dep_3,
                                                NULL AS node_zhiwu_3,
                                                NULL AS node_dengji_3,
                                                ld_contactdetails.accountid,
                                                IFNULL(
                                                    ld_contactscf.cf_7657,
                                                    STR_TO_DATE(
                                                        '2019-01-01 00:00:00',
                                                        '%Y-%m-%d %H:%i:%s'
                                                    )
                                                ) AS stime,
                                                NOW() AS etime
                                            FROM
                                                ld_contactdetails
                                            LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
                                            WHERE
                                                ld_contactdetails.deleted = 0
                                            AND ld_contactscf.cf_7641 <> '员工'
                                    ) node3 ON node3.accountid = ld_customform07.accountid
                                    AND node3.contactid <> ld_customform07.contactid
                                    AND (
                                        node3.stime < ld_customform07scf.cf_7474
                                        AND node3.etime > ld_customform07scf.cf_7473
                                    )
                                    LEFT JOIN (
                                        (
                                            SELECT
                                                ld_contactdetails.contactid,
                                                CONCAT(
                                                    'curCompany_',
                                                    ld_contactdetails.accountid
                                                ) AS node_id_4,
                                                ld_accountscf.cf_7445 AS node_name_4,
                                                ld_account.accountname AS node_fullname_4,
                                                node5.node_id_5,
                                                node5.node_name_5,
                                                node5.node_dep_5,
                                                node5.node_zhiwu_5,
                                                node5.node_dengji_5
                                            FROM
                                                ld_contactdetails
                                            LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
                                            LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
                                            LEFT JOIN (
                                                SELECT
                                                    ld_contactdetails.accountid,
                                                    ld_contactdetails.contactid,
                                                    ld_contactdetails.contactid AS node_id_5,
                                                    ld_contactdetails.lastname AS node_name_5,
                                                    ld_contactdetails.department AS node_dep_5,
                                                    ld_contactdetails.title AS node_zhiwu_5,
                                                    ld_contactscf.cf_7641 AS node_dengji_5
                                                FROM
                                                    ld_contactdetails
                                                LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
                                                WHERE
                                                    ld_contactdetails.deleted = 0
                                                AND ld_contactscf.cf_7641 <> '员工'
                                            ) node5 ON node5.accountid = ld_contactdetails.accountid
                                            WHERE
                                                ld_contactdetails.deleted = 0
                                        )
                                        UNION ALL
                                            (
                                                SELECT
                                                    ld_customform07.contactid,
                                                    CONCAT(
                                                        'preCompany_',
                                                        ld_customform07.accountid
                                                    ) AS node_id_4,
                                                    ld_accountscf.cf_7445 AS node_name_4,
                                                    ld_account.accountname AS node_fullname_4,
                                                    node5.node_id_5,
                                                    node5.node_name_5,
                                                    NULL AS node_dep_5,
                                                    NULL AS node_zhiwu_5,
                                                    NULL AS node_dengji_5
                                                FROM
                                                    ld_customform07
                                                LEFT JOIN ld_account ON ld_account.accountid = ld_customform07.accountid
                                                LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
                                                LEFT JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
                                                LEFT JOIN (
                                                    SELECT
                                                        ld_customform07.contactid,
                                                        ld_customform07.contactid AS node_id_5,
                                                        ld_contactdetails.lastname AS node_name_5,
                                                        ld_customform07.accountid,
                                                        ld_customform07scf.cf_7473 AS stime,
                                                        ld_customform07scf.cf_7474 AS etime
                                                    FROM
                                                        ld_customform07
                                                    LEFT JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
                                                    LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_customform07.contactid
                                                    LEFT JOIN ld_contactscf ON ld_contactdetails.contactid = ld_contactscf.contactid
                                                    WHERE
                                                        ld_customform07.deleted = 0
                                                    AND ld_contactscf.cf_7641 <> '员工'
                                                    UNION ALL
                                                        SELECT
                                                            ld_contactdetails.contactid,
                                                            ld_contactdetails.contactid AS node_id_5,
                                                            ld_contactdetails.lastname AS node_name_5,
                                                            ld_contactdetails.accountid,
                                                            IFNULL(
                                                                ld_contactscf.cf_7657,
                                                                STR_TO_DATE(
                                                                    '2019-01-01 00:00:00',
                                                                    '%Y-%m-%d %H:%i:%s'
                                                                )
                                                            ) AS stime,
                                                            NOW() AS etime
                                                        FROM
                                                            ld_contactdetails
                                                        LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
                                                        WHERE
                                                            ld_contactdetails.deleted = 0
                                                        AND ld_contactscf.cf_7641 <> '员工'
                                                ) node5 ON node5.accountid = ld_customform07.accountid
                                                AND node5.contactid <> ld_customform07.contactid
                                                AND (
                                                    node5.stime < ld_customform07scf.cf_7474
                                                    AND node5.etime > ld_customform07scf.cf_7473
                                                )
                                                WHERE
                                                    ld_customform07.deleted = 0
                                            )
                                    ) node4 ON node4.contactid = node3.contactid
                                    AND node4.node_id_5 <> node3.contactid
                                    AND node4.node_id_5 <> ld_customform07.contactid
                                    WHERE
                                        ld_customform07.contactid = ?
                                    AND ld_customform07.deleted = 0
                                )
                        ) node2
                ) node2
                WHERE
                    ld_contactdetails.contactid = ?;";
        $result = $adb->pquery($sql,[$contactid,$contactid,$contactid,$contactid]);
        $num = $adb->num_rows($result);
        if($num > 0){
            $NodesData = [];
            for($i = 0; $i < $num; $i ++){
                $Node = &$NodesData;
                for ($j = 1; $j <= 5; $j ++) {
                    $node_id = $adb->query_result($result,$i,'node_id_'.$j);
                    $node_name = $adb->query_result($result,$i,'node_name_'.$j);
                    $node_id = strval($node_id);
                    if(empty($node_id))
                        break;
                    if(!isset($Node[$node_id])){
                        $Node[$node_id] = [
                            "id" => $node_id,
                            "name" => $node_name,
                            "childNodes" => [],
                        ];
                        if($j === 2 || $j === 4) {
                            $Node[$node_id]["fullName"] = $adb->query_result($result,$i,'node_fullname_'.$j);
                        }
                        if($j === 3 || $j === 5) {
                            $Node[$node_id]["dep"] = $adb->query_result($result,$i,'node_dep_'.$j);
                            $Node[$node_id]["zhiwu"] = $adb->query_result($result,$i,'node_zhiwu_'.$j);
                            $Node[$node_id]["dengji"] = $adb->query_result($result,$i,'node_dengji_'.$j);
                        }
                    }
                    $Node = &$Node[$node_id]["childNodes"];
                }
            }
            $this->setNodes($NodesData);
        }
    }

    public function setNodes($NodesData) {
        //$this->setRotateList();
        $firstNode = $NodesData[$this->contactid];
        $newId = 'contact_'.$this->contactid;
        $firstNode['id'] = $newId;
        $nodeData = [
            'nodeType' => 'curContact',
            'nodeId' => $this->contactid,
            'sector' => 360,
            'rotate' => 0,
        ];
        $this->pushNode('',$firstNode['id'],$firstNode['name'],$nodeData,'curContact');
        $this->setCompanyNodes($firstNode);
    }

    public function setCompanyNodes($parentNode) {
        $nodes = $parentNode['childNodes'];
        $nodesNum = count($nodes);
        if($nodesNum === 0){
            return false;
        }
        $parentNodeId = $parentNode['id'];
        $rotateInfo = $this->setRotateInfo($nodesNum,$parentNodeId);
        $nodeIndex = 0;
        foreach ($nodes as $node_id => $nodeInfo) {
            if(count($nodeInfo['childNodes']) === 0)
                continue;
            $node_name = empty($nodeInfo['name']) ? '空' : $nodeInfo['name'];
            if($node_id === 'sysCompany'){
                $categoryName = 'sysCompany';
            }
            else{
                $categoryName = explode('_',$node_id)[0];
            }
            $newId = $parentNodeId.'_'.$node_id;
            $nodeInfo['id'] = $newId;
            $nodeData = [
                'nodeType' => 'company',
                'nodeId' => $node_id,
                'fullName' => $nodeInfo['fullName'],
                'sector' => $rotateInfo['step'] * 2,
                'rotate' => $rotateInfo['start'] + $rotateInfo['step'] * ($nodeIndex + 1),
            ];
            $this->pushNode($parentNodeId,$newId,$node_name,$nodeData,$categoryName);
            $this->setContactNodes($nodeInfo,$categoryName);
            $nodeIndex ++;
        }
    }

    public function setContactNodes($parentNode,$categoryName) {
        $nodes = $parentNode['childNodes'];
        $nodesNum = count($nodes);
        if($nodesNum === 0){
            return false;
        }
        $parentNodeId = $parentNode['id'];
        $rotateInfo = $this->setRotateInfo($nodesNum,$parentNodeId);
        $nodeIndex = 0;
        foreach ($nodes as $node_id => $nodeInfo) {
            //if($node_id === $this->contactid)
            //continue;
            $node_name = $nodeInfo['name'];
            $newId = $parentNodeId.'_'.$node_id;
            $nodeInfo['id'] = $newId;
            $nodeData = [
                'nodeType' => 'contact',
                'nodeId' => $node_id,
                'sector' => $rotateInfo['step'] * 2,
                'rotate' => $rotateInfo['start'] + $rotateInfo['step'] * ($nodeIndex + 1),
                'dep' => $nodeInfo['dep'],
                'zhiwu' => $nodeInfo['zhiwu'],
                'dengji' => $nodeInfo['dengji'],
            ];
            $this->pushNode($parentNodeId,$newId,$node_name,$nodeData,$categoryName);
            $this->setCompanyNodes($nodeInfo);
            $nodeIndex ++;
        }
    }

}

?>
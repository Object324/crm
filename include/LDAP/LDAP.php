<?php
require_once(globalStatic::$root_directory . "include/LDAP/Interface/ConnectionInterface.php");

/**
 * Class Ldap. LDAP协议操作公共类
 */
class LDAP implements ConnectionInterface
{

    /**
     * 当前连接的LDAP主机 域名
     *
     * @var string|null  host eg: 127.0.0.1
     */
     protected $host;
    /**
     * 完整的ldap链接url  <协议>://<主机（host）>:<端口>/<路径>?<查询参数>#<片段标识符>
     *
     * @var string|null  eg: ldap://127.0.0.1:389
     */
    protected $website;

    /**
     * 当前LDAP连接资源.
     *
     * @var resource
     */
    protected $connection;

    /**
     * 连接的绑定状态.
     *
     * @var bool
     */
    protected $bound = false;

    /**
     * 是否必须通过SSL绑定连接.
     *
     * @var bool
     */
    protected $useSSL = false;

    /**
     * 是否必须通过TLS绑定连接.
     *
     * @var bool
     */
    protected $useTLS = false;
    /**
     * 当查询返回一个引用时,遵循它。by ls
     * 设置与AD连接的ldap选项，自己加的属性，也可以忽略
     *
     * @var int
     */
    protected $followReferrals = 0;

    /**
     * 根域的后缀，一般为必填 by ls
     * */
    protected $accountSuffix = "";//@mydomain.local
    /**
     * 根域的后缀，分割，一般为必填，搜索等操作使用 by ls
     * */
    protected $baseDn = "";//DC=mydomain,DC=local
    /**
     * 默认端口
     * */
    protected $port= "389";

    /**
     * config里管理员账号
     * */
    private $username = NULL;
    /**
     * config里管理员密码，敏感信息，必须私有
     * */
    private $password = NULL;

    public function __construct(array $options = [])
    {
        if ($this->ldapSupported() === false) {
            throw new Exception('No LDAP support for PHP.  See: http://www.php.net/ldap');
        }

        $this->resetSettings($options);

    }

    /**
     * 用来重置连接，不传默认使用config里配置
     * */
    public function resetSettings(array $options=[]): bool{
        global $ldapconfig;

        $this->close();
        if (count($options)>0) {
            if (array_key_exists("host",$options)) { $this->setHost($options["host"]);}
            if (array_key_exists("account_suffix",$options)) { $this->setAccountSuffix($options["account_suffix"]); }
            if (array_key_exists("base_dn",$options)) { $this->setBaseDn($options["base_dn"]); }
            if (array_key_exists("username",$options)) { $this->setUsername($options["username"]); }
            if (array_key_exists("password",$options)) { $this->setPassword($options["password"]); }
            if (array_key_exists("mode", $options)) {

                if (strtolower($options["mode"]) == 'ssl') {
                    $this->setUsingSSL();
                    $this->setPort(self::PORT_SSL);//只有ssl默认用636
                } elseif (strtolower($options["mode"]) == 'tls') {
                    $this->setUsingTLS();
                }
            }
            if (array_key_exists("port",$options)) {  $this->setPort($options["port"]); }
        }else{
            if (isset($ldapconfig["host"])) { $this->setHost($ldapconfig["host"]);}
            if (isset($ldapconfig["account_suffix"])) { $this->setAccountSuffix($ldapconfig["account_suffix"]);}
            if (isset($ldapconfig["base_dn"])) { $this->setBaseDn($ldapconfig["base_dn"]);}
            if (isset($ldapconfig["username"])) { $this->setUsername($ldapconfig["username"]);}
            if (isset($ldapconfig["password"])) { $this->setPassword($ldapconfig["password"]);}
            if (isset($ldapconfig["mode"])) {
                if (strtolower($ldapconfig["mode"]) == 'ssl') {
                    $this->setUsingSSL();
                    $this->setPort(self::PORT_SSL);//只有ssl默认用636
                } elseif (strtolower($ldapconfig["mode"]) == 'tls') {
                    $this->setUsingTLS();
                }
            }
            if (isset($ldapconfig["port"])) {  $this->setPort($ldapconfig["port"]); }//自定义端口号
        }

        return true;
    }

    public static function getInstance()
    {
        static $ldapobj = null;

        if ($ldapobj === null) {
            $ldapobj = new self();
        }

        return $ldapobj;
    }

    /*
     * @return resource
     * */
    public function connect()
    {
        $this->website = $this->getConnectionString($this->host, $this->getProtocol(), $this->getPort());//$this->getProtocol().$this->host.':'.$this->getPort();

        // 如果重新初始化连接，则重置绑定状态。
        $this->bound = false;

        $this->connection = ldap_connect($this->website);
        if (!$this->connection) {
            throw new Exception("Could not connect to LDAP server，".$this->getLastError());
        }

        // 设置与AD连接的ldap选项
        ldap_set_option($this->connection, LDAP_OPT_PROTOCOL_VERSION, 3);
        ldap_set_option($this->connection, LDAP_OPT_REFERRALS, $this->followReferrals);

        return $this->connection;
    }

    /*
     * @return resource
     * */
    public function bind($sasl = false)
    {
        //在未绑定之前，把连接升级到TLS
        if ($this->isUsingTLS() && !$this->isBound()) {
            $this->startTLS();
        }

        if ($sasl) {
            $this->bound = ldap_sasl_bind($this->connection, null, null, 'GSSAPI');
        }else{
            $this->bound = ldap_bind(
                $this->connection,
                $this->getUsername(),
                html_entity_decode($this->getPassword())
            );
        }


        if (!$this->bound) {
            throw new Exception('Bind to Active Directory failed. Check the login credentials and/or server details. AD said: ' . $this->getLastError());
        }


        return $this->bound;
    }


    /**
     * 用户身份认证    单点登录验证可以使用,返回布尔。第三个参数可以控制是否切换回管理账户，By: liushuai 20241224
     *
     * @param string $username A user's AD username
     * @param string $password A user's AD password
     * @param bool optional $preventRebind   是否阻止重绑，默认会重绑
     * @return bool
     */
    public function authenticate($username, $password, $preventRebind = false): bool{
        if ($username === NULL || $password === NULL) { return false; }
        if (empty($username) || empty($password)) { return false; }

        // 认证用户
        $ret = true;
        $this->bound = @ldap_bind($this->getConnection(), $username . $this->getAccountSuffix(), $password);
        if (!$this->bound) {
            $ret = false;
        }


        //如果有配置，则切换回管理模式
        if ($this->getUsername() !== NULL && !$preventRebind) {
            $this->bound = @ldap_bind($this->getConnection(), $this->getUsername() . $this->getAccountSuffix() , $this->getPassword());
            if (!$this->bound) {
                //这在理论上是不会发生的。
                throw new Exception('Rebind to Active Directory failed. AD said: ' . $this->getLastError());
            }
        }
        return $ret;
    }

    function __destruct() {
        $this->close();
    }

    /**
     * Getters and Setters
     *
     * ?string  return值可能是字符串或null
     *
     * {@inheritdoc}  表示是从接口继承过来的，有的新加的方法可能没写此标识
     */
    public function setUsername($username)
    {
        $this->username = $username;
    }
    private function getUsername(): ?string
    {
        return $this->username;
    }

    public function setPassword($password)
    {
        $this->password = $password;
    }
    private function getPassword(): ?string
    {
        return $this->password;
    }

    public function setBaseDn($baseDn)
    {
        $this->baseDn = $baseDn;
    }
    public function getBaseDn(): ?string
    {
        return $this->baseDn;
    }

    public function setAccountSuffix($accountSuffix)
    {
        $this->accountSuffix = $accountSuffix;
    }
    public function getAccountSuffix(): ?string
    {
        return $this->accountSuffix;
    }

    public function isBound(): ?string
    {
        return $this->bound;
    }

    public function canChangePasswords()
    {
        return $this->isUsingSSL() || $this->isUsingTLS();
    }


    public function setUsingSSL($enabled = true)
    {
        $this->useSSL = $enabled;

        return $this;
    }
    public function isUsingSSL(): bool
    {
        return $this->useSSL;
    }

    public function setUsingTLS($enabled = true)
    {
        $this->useTLS = $enabled;

        return $this;
    }
    public function isUsingTLS(): bool
    {
        return $this->useTLS;
    }


    public function getHost(): ?string
    {
        return $this->host;
    }
    public function setHost($host='')
    {
        $this->host = $host;
        return $this;
    }


    public function getPort(): string
    {
        return $this->port;
    }
    public function setPort($port='')
    {
        $this->port = $port;
        return $this;
    }


    /**
     * {@inheritdoc}
     *
     * @return mixed  主要是resource
     */
    public function getConnection()
    {
        if ($this->connection) {
            return $this->connection;
        }
        return false;
    }

    /**
     * {@inheritdoc}
     */
    public function getEntries($searchResults): mixed
    {
        return ldap_get_entries($this->connection, $searchResults);
    }

    /**
     * {@inheritdoc}
     */
    public function getFirstEntry($searchResults)
    {
        return ldap_first_entry($this->connection, $searchResults);
    }

    /**
     * {@inheritdoc}
     */
    public function getNextEntry($entry)
    {
        return ldap_next_entry($this->connection, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function getAttributes($entry)
    {
        return ldap_get_attributes($this->connection, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function countEntries($searchResults)
    {
        return ldap_count_entries($this->connection, $searchResults);
    }

    /**
     * {@inheritdoc}
     */
    public function compare($dn, $attribute, $value)
    {
        return ldap_compare($this->connection, $dn, $attribute, $value);
    }

    /**
     * {@inheritdoc}
     */
    public function getLastError()
    {
        return ldap_error($this->connection);
    }

    /**
     * {@inheritdoc}
     */
    public function getDetailedError(): array
    {
        //如果返回的错误号为0，表示最后一次LDAP操作成功。不会返回详细的错误。
        $err_arr = [];
        if ($number = $this->errNo()) {
            ldap_get_option($this->connection, LDAP_OPT_DIAGNOSTIC_MESSAGE, $message);

            $err_arr = [
               "errorCode"=>$number,
               "errorMessage"=>$this->err2Str($number),
               "diagnosticMessage"=>$message,
           ];
        }

        return $err_arr;
    }

    /**
     * {@inheritdoc}
     */
    public function getValuesLen($entry, $attribute)
    {
        return ldap_get_values_len($this->connection, $entry, $attribute);
    }

    /**
     * {@inheritdoc}
     */
    public function setOption($option, $value)
    {
        return ldap_set_option($this->connection, $option, $value);
    }

    /**
     * {@inheritdoc}
     */
    public function setOptions(array $options = [])
    {
        foreach ($options as $option => $value) {
            $this->setOption($option, $value);
        }
    }

    /**
     * {@inheritdoc}
     */
    public function setRebindCallback(callable $callback)
    {
        return ldap_set_rebind_proc($this->connection, $callback);
    }

    /**
     * {@inheritdoc}
     */
    public function startTLS()
    {
        try {
            return ldap_start_tls($this->connection);
        } catch (\ErrorException $e) {
            throw new Exception($e->getMessage(), $e->getCode(), $e);
        }
    }

    public function close()
    {
        $result = is_resource($this->connection) ? ldap_close($this->connection) : false;//ldap_close是 ldap_unbind 的別名

        $this->bound = false;

        return $result;
    }

    public function search($dn, $filter, array $fields, $onlyAttributes = false, $size = 0, $time = 0)
    {
        return ldap_search($this->connection, $dn, $filter, $fields, $onlyAttributes, $size, $time);
    }

    /**
     * {@inheritdoc}
     */
    public function listing($dn, $filter, array $fields, $onlyAttributes = false, $size = 0, $time = 0)
    {
        return ldap_list($this->connection, $dn, $filter, $fields, $onlyAttributes, $size, $time);
    }

    /**
     * {@inheritdoc}
     */
    public function read($dn, $filter, array $fields, $onlyAttributes = false, $size = 0, $time = 0)
    {
        return ldap_read($this->connection, $dn, $filter, $fields, $onlyAttributes, $size, $time);
    }

    /**
     * 从ldap结果中提取信息.  通过 ldap_list() 或者 ldap_search() 返回的 LDAP\Result 实例
     *
     * @link https://www.php.net/manual/en/function.ldap-parse-result.php
     *
     * @param resource $result
     * @param int      $errorCode
     * @param string   $dn
     * @param string   $errorMessage
     * @param array    $referrals
     * @param array    $serverControls
     *
     * @return bool
     */
    public function parseResult($result, &$errorCode, &$dn, &$errorMessage, &$referrals, &$serverControls = [])
    {
        return $this->supportsServerControlsInMethods() && !empty($serverControls) ?
            ldap_parse_result($this->connection, $result, $errorCode, $dn, $errorMessage, $referrals, $serverControls) :
            ldap_parse_result($this->connection, $result, $errorCode, $dn, $errorMessage, $referrals);
    }


    /**
     * {@inheritdoc}
     */
    public function add($dn, array $entry)
    {
        return ldap_add($this->connection, $dn, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function delete($dn)
    {
        return ldap_delete($this->connection, $dn);
    }

    /**
     * {@inheritdoc}
     */
    public function rename($dn, $newRdn, $newParent, $deleteOldRdn = false)
    {
        return ldap_rename($this->connection, $dn, $newRdn, $newParent, $deleteOldRdn);
    }

    /**
     * {@inheritdoc}
     */
    public function modify($dn, array $entry)
    {
        return ldap_modify($this->connection, $dn, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function modifyBatch($dn, array $values)
    {
        return ldap_modify_batch($this->connection, $dn, $values);
    }

    /**
     * {@inheritdoc}
     */
    public function modAdd($dn, array $entry)
    {
        return ldap_mod_add($this->connection, $dn, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function modReplace($dn, array $entry)
    {
        return ldap_mod_replace($this->connection, $dn, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function modDelete($dn, array $entry)
    {
        return ldap_mod_del($this->connection, $dn, $entry);
    }

    /**
     * {@inheritdoc}
     */
    public function freeResult($result)
    {
        return ldap_free_result($result);
    }

    /**
     * {@inheritdoc}
     */
    public function errNo()
    {
        return ldap_errno($this->connection);
    }

    /**
     * {@inheritdoc}
     */
    public function getExtendedError()
    {
        return $this->getDiagnosticMessage();
    }

    /**
     * {@inheritdoc}
     */
    public function getExtendedErrorHex()
    {
        if (preg_match("/(?<=data\s).*?(?=\,)/", $this->getExtendedError(), $code)) {
            return $code[0];
        }
    }

    /**
     * {@inheritdoc}
     */
    public function getExtendedErrorCode()
    {
        return $this->extractDiagnosticCode($this->getExtendedError());
    }

    /**
     * {@inheritdoc}
     */
    public function err2Str($number)
    {
        return ldap_err2str($number);
    }

    /**
     * {@inheritdoc}
     */
    public function getDiagnosticMessage()
    {
        ldap_get_option($this->connection, LDAP_OPT_ERROR_STRING, $message);

        return $message;
    }

    /**
     * {@inheritdoc}
     */
    public function extractDiagnosticCode($message)
    {
        preg_match('/^([\da-fA-F]+):/', $message, $matches);

        return isset($matches[1]) ? $matches[1] : false;
    }

    /**
     * 返回要用于当前连接的LDAP协议.
     *
     * @return string
     */
    public function getProtocol()
    {
        return $this->isUsingSSL() ? $this::PROTOCOL_SSL : $this::PROTOCOL;
    }

    /**
     * 确定当前PHP版本是否支持服务器控件.
     *
     * @return bool
     */
    public function supportsServerControlsInMethods()
    {
        return version_compare(PHP_VERSION, '7.3.0') >= 0;
    }

    /**
     * 生成LDAP链接所要用的完整url
     *
     * @param string|array $hosts
     * @param string       $protocol
     *
     * @return string
     */
    protected function getConnectionString($hosts, $protocol, $port)
    {
        //异常处理，如果端口错误则修改
        if ($this->isUsingSSL() && $port == 389) {
            $port = self::PORT_SSL;
        }

        $hosts = is_array($hosts) ? $hosts : [$hosts];

        $hosts = array_map(function ($host) use ($protocol, $port) {
            return "{$protocol}{$host}:{$port}";
        }, $hosts);

        return implode(' ', $hosts);
    }


    /**
     * 检查php是否支持LDAP  by：ls 241225
     *
     * @return bool
     */
    protected function ldapSupported(): bool
    {
        //是否开启扩展
        if (!extension_loaded('ldap')) {
            return false;
        }
        if (!function_exists('ldap_connect')) {
            return false;
        }
        return true;
    }
}

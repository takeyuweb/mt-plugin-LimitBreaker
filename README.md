Limit Breaker MovableType Plugin
===

* Author:: Yuichi Takeuchi <info@takeyu-web.com>
* Website:: http://takeyu-web.com/
* Copyright:: Copyright 2014 Yuichi Takeuchi
* License:: MIT License

アイテムのアップロード時に`CGIMaxUpload`を無視して大きなファイルをアップロードできるようになります。

動作しそうな環境
-----------

たぶん

* MT5以上
* CGI / PSGI対応のはず

利用方法
-----------

インストールすると、アイテムのアップロード時に、「CGIMaxUploadを無視する」チェックボックスが追加されるので、大容量ファイルをアップロードしたいときにチェックしてください。

制限
-----------

- Webサーバ側の制限には無力です。
  - TimeOut Error
  - Request Entity Too Large Error

注意
-----------

セキュリティ機構を無理矢理回避するので、サーバに大量のデータをPOSTで送りつける攻撃が容易に成立するようになってしまいます。

どうしても使いたいときは、最低でもBasic認証を行うなど、信頼できる人しかmt.cgiにアクセスできなくしてください。

お約束
-----------

ご利用は自己責任で。


# Agent APP 数据库结构

- 均自带`gorm.Model`，含`id`、`created_at`、`updated_at`、`deleted_at`

## accounts用户

- `username`：`unique;varchar(50);not null`
  - 用户名，不可重复，最长50字符，非空
- `password`: `varchar(100);not null`
  - 密码，经过加密，不会明文存储，最长100字符，非空
- `OneToMany`
  - `schedules`：用户拥有的行程

## schedules行程

- `name`：``varchar(50);not null;default:`默认行程名` ``
  - 行程名，最长50字符，非空，默认值为“默认行程名”
- `current_version`：`int;not null`
  - 当前版本号，非空
- `status`: `varchar(50);not null`
  - 状态，分为`active`和`lock`以及`deciding`，由后端管理，防止用户和agent并发问题以及用于判断是否处于等待接受Agent建议的阶段  
- `account_id`：`foreignKey;not null`
  - 归属用户的`id`，用于指向归属的用户，外键，非空
- `OneToMany`
  - `plans` 行程下的各个版本的旅行计划
  - `chats` 行程下的各个会话

## plans旅行计划

- `version`：`int;not null`
  - 版本号，非空
- `updated_by`：`enum('account','agent');not null`
  - 操作来源/更新者，限定内容只能为`account`或者`agent`，非空
- `schedule_id`：`foreignKey;not null`
  - 归属行程的`id`，用于指向归属的行程，外键，非空
- `OneToMany`
  - `items` 计划项

## items计划项

- `type`: `varchar(20);not null`
  - 类型，最长20字符，非空
- `name`： `varchar(20);not null`
  - 名字，最长20字符，非空
- `date`： `date;not null`
  - 日期，格式限定为YYYY-MM-DD，非空
- `time_slot`：`varchar(20);;not null;check:schedule REGEXP '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]-([0-1]?[0-9]|2[0-3]):[0-5][0-9]$'`
  - 时间段，格式限定为HH:MM-HH:MM，非空
- `notes`：`varchar(100)`
  - 说明，最长100字符
- `status`：`varchar(20);not null`
  - 当前状态，最长20字符，非空
- `plan_id`：`foreignKey;not null`
  - 归属旅行计划的`id`，用于指向归属的旅行计划，外键，非空

## chats会话

- `name`：``varchar(20);not null;default:`默认会话` ``
  - 会话名，最长20字符，非空
- `schedule_id`：`foreignKey;not null`
  - 归属行程的`id`，用于指向归属的行程，外键，非空
- `OneToMany`
  - `messages` 会话下的消息历史

## messages消息

- `role`：`enum('user','assistant','system');not null`
  - 消息角色，限定为`user`、`assistant`或`system`，非空
- `content`：`text;not null`
  - 消息文本内容，非空
- `chat_id`：`foreignKey;not null`
  - 归属会话的`id`，用于指向归属的会话，外键，非空
- `OneToMany`
  - `message_files` 消息关联的文件

## message_files消息文件关联

- `message_id`：`foreignKey;not null`
  - 归属消息的`id`，外键，非空
- `file_id`：`foreignKey;not null`
  - 关联文件的`id`，外键，非空

## files文件

- `name`：`varchar(100);not null`
  - 文件名，最长100字符，非空
- `path`：`varchar(255);not null`
  - 文件存储路径，最长255字符，非空
- `size`：`bigint;not null`
  - 文件大小（字节），非空
- `mime_type`：`varchar(50);not null`
  - MIME类型，最长50字符，非空
- `account_id`：`foreignKey;not null`
  - 上传用户的`id`，外键，非空，用于权限控制
- `OneToMany`
  - `message_files` 文件关联的消息
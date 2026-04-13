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
  <!-- TODO:暂定如此，需要考虑到因为有历史版本的存在，不同历史版本拥有同一个计划项是否在数据库层级上也指向一个计划项，需要开会讨论 -->

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
<!-- 需要和agent对接，具体内容待定 -->
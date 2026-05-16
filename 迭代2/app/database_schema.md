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
  - `records` 行程下的所有记录

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
- `start_time`： `date;not null`
  - 开始时间，格式限定为YYYY-MM-DDTHH:mm:ss+8:00，非空
- `end_time`： `date;not null`
  - 结束时间，格式限定为YYYY-MM-DDTHH:mm:ss+8:00，非空
- `notes`：`varchar(100)`
  - 说明，最长100字符
- `status`：`varchar(20);not null`
  - 当前状态，最长20字符，非空
- `isConfirmed`：`boolean; not null`
  - 是否被接收
- `cost`：`int; not null`
  - 预估花费  
- `details`：`json; not null`
  - `type`：`not null`
    - 类型，最长20字符，非空  
  - `data`：`not null`
    - 有以下五种

    ```json
    {
      "type": "attraction",
      "suggested_duration": 1,//int
      "opening_hours": "string",
      "booking_reference": "string",
      "location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      },
      "tags": ["string[]"]
    }
    ```

    ```json
    {
      "type": "hotel",
      "contact_phone": "string",
      "room_type": "string",
      "booking_reference": "string",
      "location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      },
      "tags": ["string[]"]
    }
    ```

    ```json
    {
      "type": "food",
      "recommend_dishes": ["string[]"],
      "opening_hours": "string",
      "location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      },
      "tags": ["string[]"]
    }
    ```

    ```json
    {
      "type": "transport_long",
      "transport_mode": "string",
      "departure_station": "string",
      "arrival_station": "string",
      "vehicle_number": "string",
      "seat_info": "string",
      "booking_reference": "string",
      "departure_location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      },
      "arrival_location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      }
    }
    ```

    ```json
    {
      "type": "transport_short",
      "routes": [{
        "estimated_duration": 1,//int
        "route_description": "string",
        "navigation_link": "string",
      }],
      "departure_location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      },
      "arrival_location": {
        "poi_id": "string",
        "poi_name": "string",
        "address": "string",
        "lng": "double",
        "lat": "double"
      }
    }
    ```

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

## records记录

- `data`: `MEDIUMTEXT;not null`
  - 具体内容，后端不负责，只存储，最长16,777,215 字节 (16 MB)（如有需要可使用更大的类型）
- `OneToOne`
  - `question` 对应的问的`message`
- `ManyToOne`
  - `schedule` 所属行程

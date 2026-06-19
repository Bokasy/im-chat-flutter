-- 创建数据库
CREATE DATABASE IF NOT EXISTS im_chat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE im_chat;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    `user_code` VARCHAR(20) UNIQUE NOT NULL COMMENT '用户唯一ID号',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `avatar` VARCHAR(500) COMMENT '头像URL',
    `signature` VARCHAR(255) COMMENT '个性签名',
    `status` TINYINT DEFAULT 1 COMMENT '状态 1-在线 2-离线 3-忙碌 4-勿扰',
    `last_login_time` DATETIME COMMENT '最后登录时间',
    `last_login_ip` VARCHAR(50) COMMENT '最后登录IP',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 好友关系表
CREATE TABLE IF NOT EXISTS `friend` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `friend_id` BIGINT NOT NULL COMMENT '好友ID',
    `remark` VARCHAR(50) COMMENT '好友备注',
    `group_name` VARCHAR(50) DEFAULT '默认分组' COMMENT '分组名称',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY `uk_friend` (`user_id`, `friend_id`),
    INDEX `idx_friend_id` (`friend_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='好友关系表';

-- 好友申请表
CREATE TABLE IF NOT EXISTS `friend_apply` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `applicant_id` BIGINT NOT NULL COMMENT '申请人ID',
    `target_id` BIGINT NOT NULL COMMENT '目标用户ID',
    `message` VARCHAR(255) COMMENT '申请消息',
    `status` TINYINT DEFAULT 0 COMMENT '状态 0-待处理 1-已接受 2-已拒绝 3-已忽略',
    `reject_reason` VARCHAR(255) COMMENT '拒绝理由',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_target` (`target_id`, `status`),
    INDEX `idx_applicant` (`applicant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='好友申请表';

-- 消息表
CREATE TABLE IF NOT EXISTS `message` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    `msg_id` VARCHAR(64) UNIQUE NOT NULL COMMENT '消息唯一ID（用于幂等）',
    `sender_id` BIGINT NOT NULL COMMENT '发送者ID',
    `receiver_id` BIGINT NOT NULL COMMENT '接收者ID（用户ID或群组ID）',
    `chat_type` TINYINT NOT NULL COMMENT '聊天类型 1-私聊 2-群聊',
    `msg_type` TINYINT NOT NULL DEFAULT 1 COMMENT '消息类型 1-文本 2-图片 3-语音 4-文件 5-系统',
    `content` TEXT COMMENT '消息内容',
    `media_url` VARCHAR(500) COMMENT '媒体文件URL',
    `thumbnail_url` VARCHAR(500) COMMENT '缩略图URL',
    `reply_msg_id` VARCHAR(64) COMMENT '引用消息ID',
    `at_user_ids` VARCHAR(500) COMMENT '@用户ID列表，逗号分隔',
    `is_recalled` TINYINT DEFAULT 0 COMMENT '是否撤回 0-否 1-是',
    `is_read` TINYINT DEFAULT 0 COMMENT '是否已读 0-否 1-是',
    `expire_time` DATETIME COMMENT '阅后即焚过期时间',
    `seq_id` BIGINT COMMENT '消息序列号（用于排序）',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_receiver` (`receiver_id`, `create_time`),
    INDEX `idx_sender` (`sender_id`, `create_time`),
    INDEX `idx_msg_id` (`msg_id`),
    INDEX `idx_seq` (`seq_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- 会话表
CREATE TABLE IF NOT EXISTS `session` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `target_id` BIGINT NOT NULL COMMENT '目标ID（用户ID或群组ID）',
    `chat_type` TINYINT NOT NULL COMMENT '聊天类型 1-私聊 2-群聊',
    `last_msg_id` BIGINT COMMENT '最后一条消息ID',
    `last_msg_content` VARCHAR(255) COMMENT '最后消息内容预览',
    `last_msg_time` DATETIME COMMENT '最后消息时间',
    `unread_count` INT DEFAULT 0 COMMENT '未读消息数',
    `is_pinned` TINYINT DEFAULT 0 COMMENT '是否置顶 0-否 1-是',
    `is_muted` TINYINT DEFAULT 0 COMMENT '是否免打扰 0-否 1-是',
    `is_archived` TINYINT DEFAULT 0 COMMENT '是否归档 0-否 1-是',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_user_target` (`user_id`, `target_id`, `chat_type`),
    INDEX `idx_user` (`user_id`, `is_archived`, `last_msg_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会话表';

-- 群组表
CREATE TABLE IF NOT EXISTS `group_info` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '群组ID',
    `group_name` VARCHAR(50) NOT NULL COMMENT '群名称',
    `group_avatar` VARCHAR(500) COMMENT '群头像URL',
    `notice` VARCHAR(500) COMMENT '群公告',
    `owner_id` BIGINT NOT NULL COMMENT '群主用户ID',
    `max_members` INT DEFAULT 500 COMMENT '最大成员数',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_owner` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='群组表';

-- 群成员表
CREATE TABLE IF NOT EXISTS `group_member` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `group_id` BIGINT NOT NULL COMMENT '群组ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `group_nickname` VARCHAR(50) COMMENT '群内昵称',
    `role` TINYINT DEFAULT 0 COMMENT '角色 0-成员 1-管理员 2-群主',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除 0-未删除 1-已删除',
    `join_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    UNIQUE KEY `uk_group_user` (`group_id`, `user_id`),
    INDEX `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='群成员表';

-- 插入测试数据
-- 密码均为 123456
INSERT INTO `user` (`username`, `user_code`, `password`, `nickname`, `avatar`, `signature`, `status`) VALUES
('zhangsan', '10000001', '123456', '张三', 'https://api.dicebear.com/7.x/avataaars/png?seed=zhangsan', '生活不止眼前的苟且', 1),
('lisi', '10000002', '123456', '李四', 'https://api.dicebear.com/7.x/avataaars/png?seed=lisi', '代码改变世界', 1),
('wangwu', '10000003', '123456', '王五', 'https://api.dicebear.com/7.x/avataaars/png?seed=wangwu', '热爱生活', 2),
('zhaoliu', '10000004', '123456', '赵六', 'https://api.dicebear.com/7.x/avataaars/png?seed=zhaoliu', '永远年轻', 1),
('sunqi', '10000005', '123456', '孙七', 'https://api.dicebear.com/7.x/avataaars/png?seed=sunqi', '追求卓越', 2);

-- 添加好友关系（张三和李四是好友）
INSERT INTO `friend` (`user_id`, `friend_id`, `remark`) VALUES
(1, 2, '李四'),
(2, 1, '张三');

-- 添加一些聊天记录
INSERT INTO `message` (`msg_id`, `sender_id`, `receiver_id`, `chat_type`, `msg_type`, `content`, `seq_id`, `create_time`) VALUES
('msg001', 1, 2, 1, 1, '你好，李四！', 10001, '2024-01-15 10:00:00'),
('msg002', 2, 1, 1, 1, '你好，张三！最近怎么样？', 10002, '2024-01-15 10:01:00'),
('msg003', 1, 2, 1, 1, '挺好的，在学习Flutter开发', 10003, '2024-01-15 10:02:00'),
('msg004', 2, 1, 1, 1, '哇，我也在学！一起交流啊', 10004, '2024-01-15 10:03:00'),
('msg005', 1, 2, 1, 1, '好的，有空一起写代码', 10005, '2024-01-15 10:04:00');

-- 更新会话表
INSERT INTO `session` (`user_id`, `target_id`, `chat_type`, `last_msg_content`, `last_msg_time`, `unread_count`) VALUES
(1, 2, 1, '好的，有空一起写代码', '2024-01-15 10:04:00', 0),
(2, 1, 1, '好的，有空一起写代码', '2024-01-15 10:04:00', 0);

-- 添加更多好友关系
INSERT INTO `friend` (`user_id`, `friend_id`, `remark`) VALUES
(1, 3, '王五'), (3, 1, '张三'),
(2, 3, '王五'), (3, 2, '李四');

-- ============================================
-- 管理系统数据库初始化脚本
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `mgr_base` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `mgr_base`;

-- ============================================
-- 创建表结构
-- ============================================

-- 资源表
CREATE TABLE IF NOT EXISTS `resources` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '资源名称',
  `path` varchar(255) NOT NULL COMMENT '资源路径',
  `method` varchar(255) NOT NULL COMMENT '请求方法: GET, POST, PUT, DELETE',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `type` varchar(255) DEFAULT NULL COMMENT '类型: api, menu, button',
  `parent_id` bigint unsigned DEFAULT NULL COMMENT '父资源ID',
  `sort` int DEFAULT '0' COMMENT '排序',
  `icon` varchar(255) DEFAULT NULL COMMENT '图标',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_resources_path` (`path`),
  KEY `idx_resources_deleted_at` (`deleted_at`),
  KEY `idx_resources_parent_id` (`parent_id`),
  CONSTRAINT `fk_resources_parent` FOREIGN KEY (`parent_id`) REFERENCES `resources` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='资源表';

-- 角色表
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '角色名称',
  `description` varchar(255) DEFAULT NULL COMMENT '角色描述',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_roles_name` (`name`),
  KEY `idx_roles_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 权限表
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '权限名称',
  `code` varchar(255) NOT NULL COMMENT '权限代码',
  `description` varchar(255) DEFAULT NULL COMMENT '权限描述',
  `resource_id` bigint unsigned NOT NULL COMMENT '关联资源ID',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_permissions_name` (`name`),
  UNIQUE KEY `idx_permissions_code` (`code`),
  KEY `idx_permissions_deleted_at` (`deleted_at`),
  KEY `idx_permissions_resource_id` (`resource_id`),
  CONSTRAINT `fk_permissions_resource` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- 角色权限关联表（多对多关系）
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` bigint unsigned NOT NULL,
  `permission_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  KEY `fk_role_permissions_permission` (`permission_id`),
  CONSTRAINT `fk_role_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- 用户表
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码（bcrypt哈希）',
  `email` varchar(255) DEFAULT NULL COMMENT '邮箱',
  `status` int DEFAULT '1' COMMENT '状态: 1-正常, 0-禁用',
  `role_id` bigint unsigned NOT NULL COMMENT '角色ID',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_username` (`username`),
  KEY `idx_users_deleted_at` (`deleted_at`),
  KEY `idx_users_role_id` (`role_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 日志表
CREATE TABLE IF NOT EXISTS `logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL COMMENT '用户ID',
  `username` varchar(255) DEFAULT NULL COMMENT '用户名',
  `action` varchar(255) DEFAULT NULL COMMENT '操作类型',
  `module` varchar(255) DEFAULT NULL COMMENT '模块',
  `content` text COMMENT '操作内容',
  `ip` varchar(255) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(255) DEFAULT NULL COMMENT '用户代理',
  `status` int DEFAULT NULL COMMENT '状态: 1-成功, 0-失败',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_logs_deleted_at` (`deleted_at`),
  KEY `idx_logs_user_id` (`user_id`),
  KEY `idx_logs_username` (`username`),
  KEY `idx_logs_action` (`action`),
  KEY `idx_logs_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='日志表';

-- IP访问统计表
CREATE TABLE IF NOT EXISTS `ip_accesses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL COMMENT 'IP地址',
  `date` date NOT NULL COMMENT '访问日期',
  `country` varchar(255) DEFAULT NULL COMMENT '国家',
  `province` varchar(255) DEFAULT NULL COMMENT '省份',
  `city` varchar(255) DEFAULT NULL COMMENT '城市',
  `isp` varchar(255) DEFAULT NULL COMMENT '运营商',
  `access_count` int DEFAULT '1' COMMENT '访问次数',
  `created_at` datetime(3) DEFAULT NULL,
  `updated_at` datetime(3) DEFAULT NULL,
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ip_accesses_ip` (`ip`),
  KEY `idx_ip_accesses_date` (`date`),
  KEY `idx_ip_accesses_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='IP访问统计表';

-- ============================================
-- 初始化默认数据
-- ============================================

-- 插入默认管理员角色
INSERT INTO `roles` (`id`, `created_at`, `updated_at`, `name`, `description`) 
VALUES (1, NOW(), NOW(), 'admin', '系统管理员')
ON DUPLICATE KEY UPDATE `name` = `name`;

-- 插入默认管理员用户
-- 密码: admin123 (bcrypt哈希值)
INSERT INTO `users` (`id`, `created_at`, `updated_at`, `username`, `password`, `email`, `status`, `role_id`)
VALUES (1, NOW(), NOW(), 'admin', '$2a$10$1QucJZZHosnm50D8T6ptOuSrvz0pdBCpl4uoVpLVAu75AxtdMaTpS', 'admin@example.com', 1, 1)
ON DUPLICATE KEY UPDATE `username` = `username`;

-- 初始化菜单资源
INSERT INTO `resources` (`id`, `created_at`, `updated_at`, `name`, `path`, `method`, `description`, `type`, `parent_id`, `sort`, `icon`)
VALUES
  (1, NOW(), NOW(), '仪表盘', '/dashboard', 'GET', '仪表盘菜单', 'menu', NULL, 10, 'House'),
  (2, NOW(), NOW(), '系统管理', '/system', 'GET', '系统管理菜单', 'menu', NULL, 20, 'Setting'),
  (3, NOW(), NOW(), '消息公告', '/notices', 'GET', '消息公告菜单', 'menu', NULL, 30, 'Bell'),
  (4, NOW(), NOW(), '日志管理', '/logs', 'GET', '日志管理菜单', 'menu', NULL, 40, 'List'),
  (5, NOW(), NOW(), 'IP统计', '/ip-statistics', 'GET', 'IP统计菜单', 'menu', NULL, 60, 'DataAnalysis'),
  (12, NOW(), NOW(), '系统监控', '/system-monitor', 'GET', '系统监控菜单', 'menu', NULL, 45, 'Monitor')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `description` = VALUES(`description`),
  `type` = VALUES(`type`),
  `parent_id` = VALUES(`parent_id`),
  `sort` = VALUES(`sort`),
  `icon` = VALUES(`icon`);

INSERT INTO `resources` (`id`, `created_at`, `updated_at`, `name`, `path`, `method`, `description`, `type`, `parent_id`, `sort`, `icon`)
VALUES
  (6, NOW(), NOW(), '用户管理', '/users', 'GET', '用户管理菜单', 'menu', 2, 10, 'User'),
  (7, NOW(), NOW(), '角色管理', '/roles', 'GET', '角色管理菜单', 'menu', 2, 20, 'UserFilled'),
  (8, NOW(), NOW(), '权限管理', '/permissions', 'GET', '权限管理菜单', 'menu', 2, 30, 'Lock'),
  (9, NOW(), NOW(), '资源管理', '/resources', 'GET', '资源管理菜单', 'menu', 2, 40, 'Document'),
  (10, NOW(), NOW(), '系统字典', '/dicts', 'GET', '系统字典菜单', 'menu', 2, 50, 'List'),
  (11, NOW(), NOW(), '系统参数', '/configs', 'GET', '系统参数菜单', 'menu', 2, 60, 'Tools')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `description` = VALUES(`description`),
  `type` = VALUES(`type`),
  `parent_id` = VALUES(`parent_id`),
  `sort` = VALUES(`sort`),
  `icon` = VALUES(`icon`);

-- 初始化菜单权限
INSERT INTO `permissions` (`id`, `created_at`, `updated_at`, `name`, `code`, `description`, `resource_id`)
VALUES
  (1, NOW(), NOW(), '仪表盘菜单权限', 'menu:dashboard:view', '访问仪表盘菜单', 1),
  (2, NOW(), NOW(), '系统管理菜单权限', 'menu:system:view', '访问系统管理菜单', 2),
  (3, NOW(), NOW(), '消息公告菜单权限', 'menu:notices:view', '访问消息公告菜单', 3),
  (4, NOW(), NOW(), '日志管理菜单权限', 'menu:logs:view', '访问日志管理菜单', 4),
  (5, NOW(), NOW(), 'IP统计菜单权限', 'menu:ip-statistics:view', '访问IP统计菜单', 5),
  (6, NOW(), NOW(), '用户管理菜单权限', 'menu:users:view', '访问用户管理菜单', 6),
  (7, NOW(), NOW(), '角色管理菜单权限', 'menu:roles:view', '访问角色管理菜单', 7),
  (8, NOW(), NOW(), '权限管理菜单权限', 'menu:permissions:view', '访问权限管理菜单', 8),
  (9, NOW(), NOW(), '资源管理菜单权限', 'menu:resources:view', '访问资源管理菜单', 9),
  (10, NOW(), NOW(), '系统字典菜单权限', 'menu:dicts:view', '访问系统字典菜单', 10),
  (11, NOW(), NOW(), '系统参数菜单权限', 'menu:configs:view', '访问系统参数菜单', 11),
  (12, NOW(), NOW(), '系统监控菜单权限', 'menu:system-monitor:view', '访问系统监控菜单', 12)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `description` = VALUES(`description`),
  `resource_id` = VALUES(`resource_id`);

-- 管理员角色拥有全部菜单权限
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 7),
  (1, 8),
  (1, 9),
  (1, 10),
  (1, 11),
  (1, 12)
ON DUPLICATE KEY UPDATE `role_id` = `role_id`;

-- ============================================
-- 脚本执行完成
-- ============================================


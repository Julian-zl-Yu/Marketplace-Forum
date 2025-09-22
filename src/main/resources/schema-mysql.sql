SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `post_id` bigint NOT NULL,
                             `author` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                             `user_id` bigint NULL DEFAULT NULL,
                             PRIMARY KEY (`id`) USING BTREE,
                             INDEX `idx_comments_post`(`post_id` ASC) USING BTREE,
                             INDEX `idx_comments_user_id`(`user_id` ASC) USING BTREE,
                             CONSTRAINT `fk_comments_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES (18, 7, 'dongye', '很好', '2025-09-21 19:08:30', 4);
INSERT INTO `comments` VALUES (20, 7, 'dongye', 'henhao ', '2025-09-21 19:10:04', 4);
INSERT INTO `comments` VALUES (22, 7, 'dongye', 's', '2025-09-21 19:19:46', 4);

-- ----------------------------
-- Table structure for posts
-- ----------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts`  (
                          `id` bigint NOT NULL AUTO_INCREMENT,
                          `category` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                          `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                          `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                          `author` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                          `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                          `price` decimal(10, 2) NULL DEFAULT NULL,
                          `company` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                          `wage` decimal(10, 2) NULL DEFAULT NULL,
                          `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                          `user_id` bigint NULL DEFAULT NULL,
                          PRIMARY KEY (`id`) USING BTREE,
                          INDEX `idx_posts_category_created`(`category` ASC, `created_at` ASC) USING BTREE,
                          INDEX `idx_posts_title`(`title` ASC) USING BTREE,
                          INDEX `idx_posts_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of posts
-- ----------------------------
INSERT INTO `posts` VALUES (4, 'SECOND_HAND', '出椅子一把', '新的，买来没坐过', 'Jules', 'Richmond', 10.00, '', 0.00, '2025-09-21 01:26:28', NULL);
INSERT INTO `posts` VALUES (5, 'SECOND_HAND', '出一个水杯', '不锈钢保温的', 'Julie', 'Vancouver', 8.00, NULL, NULL, '2025-09-21 01:44:17', NULL);
INSERT INTO `posts` VALUES (6, 'SECOND_HAND', '出旧家具', '八成新家具', 'Alice', 'Vancouver', 68.00, NULL, NULL, '2025-09-21 02:53:00', NULL);
INSERT INTO `posts` VALUES (7, 'SECOND_HAND', '出旧手机', '二手手机', 'Alice', 'Richmond', 300.00, NULL, NULL, '2025-09-21 02:53:35', NULL);

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
                          `id` bigint NOT NULL AUTO_INCREMENT,
                          `name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                          PRIMARY KEY (`id`) USING BTREE,
                          UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES (2, 'ROLE_ADMIN');
INSERT INTO `roles` VALUES (1, 'ROLE_USER');

-- ----------------------------
-- Table structure for user_roles
-- ----------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles`  (
                               `user_id` bigint NOT NULL,
                               `role_id` bigint NOT NULL,
                               PRIMARY KEY (`user_id`, `role_id`) USING BTREE,
                               INDEX `fk_ur_role`(`role_id` ASC) USING BTREE,
                               CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                               CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_roles
-- ----------------------------
INSERT INTO `user_roles` VALUES (1, 1);
INSERT INTO `user_roles` VALUES (2, 1);
INSERT INTO `user_roles` VALUES (3, 1);
INSERT INTO `user_roles` VALUES (4, 1);
INSERT INTO `user_roles` VALUES (5, 1);
INSERT INTO `user_roles` VALUES (6, 1);
INSERT INTO `user_roles` VALUES (1, 2);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
                          `id` bigint NOT NULL AUTO_INCREMENT,
                          `username` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                          `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                          `enabled` tinyint(1) NOT NULL DEFAULT 1,
                          `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (`id`) USING BTREE,
                          UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '$2a$12$tq4KCgK/XiwerDO8y8S22.bGFLMKQJVJSWYuTBZ6Oes5NR3efgy/a', 1, '2025-09-21 01:58:45');
INSERT INTO `users` VALUES (2, 'bob', '$2a$10$AbCdEf123...xyz', 1, '2025-09-21 02:00:40');
INSERT INTO `users` VALUES (3, 'alice', '$2a$10$qI8.AC2.T7AfUyyunOD5Ge3sJdURAtts3nOOrtpUKcRvy7rWHryyG', 1, '2025-09-21 02:21:15');
INSERT INTO `users` VALUES (4, 'dongye', '$2a$10$Sl1rxvN4uR.phbHBzvpwTuqI9.6ufDnl6.Bcq9YzM.mOooPRuc5/O', 1, '2025-09-21 03:45:15');
INSERT INTO `users` VALUES (5, 'jules', '$2a$10$lAFaxK0KMJZwjFH50hnxoeLA6XWgvGAUUVIODQVhgK4ZRBmeCB9PS', 1, '2025-09-21 17:08:06');
INSERT INTO `users` VALUES (6, 'julian', '$2a$10$csLleAgDblFqFJT.RTKv3udDWV9ACCLwHv2whsKRCN0Uovo0qGLWS', 1, '2025-09-22 21:33:49');

SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE chat DROP CONSTRAINT chat_lmi_1;
ALTER TABLE chat_user DROP CONSTRAINT chat_user_lrmi_1;
ALTER TABLE chat DROP CONSTRAINT chat_ibfk_1;
ALTER TABLE message DROP CONSTRAINT message_ibfk_1;

DROP TABLE chat_user;
DROP TABLE version;
DROP TABLE token;
DROP TABLE message;
DROP TABLE chat;
DROP TABLE user;

CREATE TABLE `chat` (
  `identifier` int unsigned NOT NULL AUTO_INCREMENT,
  `name` char(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `last_message_id` int unsigned,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user` (
  `identifier` int unsigned NOT NULL AUTO_INCREMENT,
  `name` char(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `version` (
  `identifier` int unsigned NOT NULL AUTO_INCREMENT,
  `version` int unsigned NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `chat_user` (
  `identifier` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `chat_id` int unsigned NOT NULL,
  PRIMARY KEY (`identifier`),
  KEY `user_id` (`user_id`),
  KEY `chat_id` (`chat_id`),
  CONSTRAINT `chat_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`identifier`),
  CONSTRAINT `chat_user_ibfk_2` FOREIGN KEY (`chat_id`) REFERENCES `chat` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `message` (
  `identifier` int unsigned NOT NULL AUTO_INCREMENT,
  `date` int unsigned NOT NULL,
  `chat_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` char(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`identifier`),
  KEY `chat_id` (`chat_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`chat_id`) REFERENCES `chat` (`identifier`),
  CONSTRAINT `message_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `token` (
  `token` char(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `user_id` int unsigned NOT NULL,
  PRIMARY KEY (`token`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `token_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE chat ADD CONSTRAINT chat_lmi_1 FOREIGN KEY (`last_message_id`) REFERENCES `message` (`identifier`);
ALTER TABLE chat ADD COLUMN is_personal BOOLEAN NOT NULL DEFAULT 0;

ALTER TABLE chat ADD COLUMN message_count INT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE chat_user ADD COLUMN last_read_message_id INT UNSIGNED DEFAULT NULL;
ALTER TABLE chat_user ADD CONSTRAINT chat_user_lrmi_1 FOREIGN KEY (`last_read_message_id`) REFERENCES `message` (`identifier`);
ALTER TABLE chat_user ADD COLUMN not_read_message_count INT UNSIGNED DEFAULT 0;

ALTER TABLE user ADD COLUMN `security_hash` char(65) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL;
ALTER TABLE token ADD COLUMN secret_key char(65) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL;


INSERT INTO user(name, security_hash) VALUES ('Den','fb5cc970a18a1f3a14e9b98c337300e99bbe0100507b9a574705cf77f0794eda');
SET @den_id = LAST_INSERT_ID ();
INSERT INTO user(name, security_hash) VALUES ('Alex','73fb21fed40d8da46950c784fd21c0734690f801c9a48c65e7f69b3433b27a27');
SET @alex_id = LAST_INSERT_ID ();
INSERT INTO user(name, security_hash) VALUES ('Nikita','3c24134859c93a3dcf4714ed8578128196f5dd19a51b8d2192a22d9021ddf65a');
SET @nikita_id = LAST_INSERT_ID ();

INSERT INTO chat(name, is_personal) VALUES ('Group', 0);
SET @group_id = LAST_INSERT_ID ();

INSERT INTO message(user_id, chat_id, body, date, type) VALUES (@alex_id, @group_id, 'Test chat', 978307200, 'SYSTEM_TEXT');
SET @message_identifier = LAST_INSERT_ID ();
UPDATE chat SET last_message_id = @message_identifier WHERE identifier = @group_id;

INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (@den_id , @group_id, @message_identifier);
INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (@alex_id , @group_id, @message_identifier);
INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (@nikita_id , @group_id, @message_identifier);

INSERT INTO chat(name, is_personal) VALUES ('Group2', 0);
SET @group_id = LAST_INSERT_ID ();

INSERT INTO message(user_id, chat_id, body, date, type) VALUES (@alex_id, @group_id, 'Test chat 2', 978307200, 'SYSTEM_TEXT');
SET @message_identifier = LAST_INSERT_ID ();
UPDATE chat SET last_message_id = @message_identifier WHERE identifier = @group_id;

INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (@den_id , @group_id, @message_identifier);
INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (@alex_id , @group_id, @message_identifier);
INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (@nikita_id , @group_id, @message_identifier);


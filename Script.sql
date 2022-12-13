DROP DATABASE IF EXISTS sirius;
CREATE DATABASE IF NOT EXISTS sirius;
USE sirius;

-- 1
DROP TABLE IF EXISTS users;
CREATE 	TABLE users(
	id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(150) NOT NULL,
	lastname VARCHAR(150) NOT NULL,
	working_position VARCHAR(150) NOT NULL,
	status ENUM('Сreator', 'Custom') NOT NULL,
	email VARCHAR(150) UNIQUE NOT NULL,
	phone CHAR(11) UNIQUE NOT NULL,
	password_hash CHAR(65) DEFAULT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	INDEX (lastname)
) COMMENT = 'Пользователи';

ALTER TABLE users ADD CONSTRAINT CHECK (REGEXP_LIKE(phone, '^[0-9]{11}$'));

-- 2
DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL,
	name VARCHAR(50) UNIQUE NOT NULL 
) COMMENT = 'Типы медиа файлов';

-- 3
DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_types_id INT UNSIGNED NOT NULL,
	file_name VARCHAR(255),
	file_size BIGINT UNSIGNED,
	created_at DATETIME DEFAULT NOW(),
	CONSTRAINT fk_media_user_id FOREIGN KEY (user_id) REFERENCES users(id),
	CONSTRAINT fk_medias_media_types_id FOREIGN KEY (media_types_id) REFERENCES media_types(id)
) COMMENT = 'Медиа файлы';

-- 4
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles(
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	gender ENUM('Female', 'Male','Not defined') NOT NULL,
	birthday DATE NOT NULL,
	photo_id BIGINT UNSIGNED,
	sity VARCHAR(130),
	country VARCHAR(130),
	CONSTRAINT fk_profiles_user_id FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_profiles_photo_id FOREIGN KEY(photo_id) REFERENCES media(id)
) COMMENT = 'Профили пользователей';

-- 5
DROP TABLE IF EXISTS teams;
CREATE TABLE teams(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255),
	сreator_id BIGINT UNSIGNED NOT NULL,
	member_id BIGINT UNSIGNED NOT NULL,
	KEY (name),
	CONSTRAINT fk_teams_сreator_id FOREIGN KEY (сreator_id) REFERENCES users(id),
	CONSTRAINT fk_teams_member_id FOREIGN KEY (member_id) REFERENCES users(id)
) COMMENT = 'Команды';

-- 6
DROP TABLE IF EXISTS locations;
CREATE TABLE locations(
	id SERIAL PRIMARY KEY,
	location VARCHAR(50) NOT NULL,
	KEY (location)
) COMMENT = 'Места';

-- 7
DROP TABLE IF EXISTS events;
CREATE TABLE events(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(150),
	location_id BIGINT UNSIGNED NOT NULL COMMENT 'Место проведения события',
	start_datetime DATETIME COMMENT 'Время начала события',
	end_datetime DATETIME COMMENT 'Время завершения события',
	duration TIME COMMENT 'Продолжительность события',
	status ENUM('Planned', 'Running', 'Comleted') COMMENT 'Статус события',
	сreator_id BIGINT UNSIGNED NOT NULL COMMENT 'Создатель события',
	team_id BIGINT UNSIGNED NOT NULL COMMENT 'Команда, учавствующая в событии',
	member_id BIGINT UNSIGNED NOT NULL COMMENT 'Участники события',
	invitee_id BIGINT UNSIGNED NOT NULL COMMENT 'Третьи лица',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	KEY (name),
	CONSTRAINT fk_events_сreator_id FOREIGN KEY (сreator_id) REFERENCES users(id),
	CONSTRAINT fk_events_member_id FOREIGN KEY (member_id) REFERENCES users(id),
	CONSTRAINT fk_events_invitee_id FOREIGN KEY (invitee_id) REFERENCES users(id),
	CONSTRAINT fk_events_location_id FOREIGN KEY (location_id) REFERENCES locations(id),
	CONSTRAINT fk_events_team_id FOREIGN KEY (team_id) REFERENCES teams(id)
) COMMENT = 'События';

-- 8
DROP TABLE IF EXISTS messages;
CREATE TABLE messages(
	id SERIAL PRIMARY KEY, 
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	txt TEXT NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	is_delivered BOOLEAN DEFAULT FALSE,
	CONSTRAINT fk_messages_from_user_id FOREIGN KEY (from_user_id) REFERENCES users(id),
	CONSTRAINT fk_messagess_to_user_id FOREIGN KEY (to_user_id) REFERENCES users(id)
) COMMENT = 'Сообщения';

-- 9
DROP TABLE IF EXISTS notifications;
CREATE TABLE notifications(
	id SERIAL PRIMARY KEY, 
	user_id BIGINT UNSIGNED NOT NULL,
	event_id BIGINT UNSIGNED NOT NULL,
	methods ENUM('viaPusher','viaSMS','viaEmail','viaTelegram'),
	frequency INT COMMENT 'Частота уведомлений',
	intervals TIME COMMENT 'Интервал уведомлений',
	CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id),
	CONSTRAINT fk_notifications_event_id FOREIGN KEY (event_id) REFERENCES events(id)
) COMMENT = 'Уведомления';

-- 10
DROP TABLE IF EXISTS invitees_answers;
CREATE TABLE invitees_answers(
	id SERIAL PRIMARY KEY,
	event_id BIGINT UNSIGNED NOT NULL,
	invitee_id BIGINT UNSIGNED NOT NULL COMMENT 'Третьи лица',
	answers ENUM('Participate', 'May participate', 'Remind me later', 'Rejection') NOT NULL COMMENT 'Ответ на приглашение',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT fk_invitees_answers_event_id FOREIGN KEY (event_id) REFERENCES events(id),
	CONSTRAINT fk_invitees_answers_invitee_id FOREIGN KEY (invitee_id) REFERENCES events(invitee_id)
) COMMENT = 'Ответы приглашенных лиц';


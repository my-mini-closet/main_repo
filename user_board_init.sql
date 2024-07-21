create database mycloset;

use mycloset;

create table users(
	id bigint unsigned not null auto_increment,
    `user_email` varchar(200) not null unique,
	`password` varchar(200),
	`nick_name` varchar(200) not null,
	`created_at` timestamp default current_timestamp,
	`updated_at` timestamp default current_timestamp,
    `pesonal_color` varchar(200),
    `personal_color` varchar(200),
	constraint primary key(id)
);
-- personal_color 항목 추가 되었으니 mySQL에서 sql문 추가한 담에
-- ALTER TABLE users ADD COLUMN `personal_color` varchar(200);
-- 이 구문 사용해서 update 바람

create table `boards`(
	id bigint unsigned not null auto_increment,
	`title` varchar(100) not null,
	`text` varchar(500) not null,
	`like` bigint unsigned default 0,
	`unlike` bigint unsigned default 0,
	`user` bigint unsigned not null,
	`created_at` timestamp default current_timestamp,
	`updated_at` timestamp default current_timestamp,
	constraint primary key(id),
	constraint foreign key(`user`) references users(id)
);


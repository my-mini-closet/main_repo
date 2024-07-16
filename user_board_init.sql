create database mycloset;

use mycloset;

create table users(
	id bigint unsigned not null auto_increment,
    `user_email` varchar(200) not null unique,
	`password` varchar(200),
	`nick_name` varchar(200) not null,
	`created_at` timestamp default current_timestamp,
	`updated_at` timestamp default current_timestamp,
	constraint primary key(id)
);

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

